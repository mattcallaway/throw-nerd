import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:darts_app/domain/league/league_sync_provider.dart';
import 'package:darts_app/domain/league/league_file_models.dart';
// import 'package:darts_app/services/auth/auth_service_dropbox.dart'; // Future

class DropboxLeagueProvider implements LeagueSyncProvider {
  // final DropboxAuthProvider _auth; // TODO: Inject Auth
  final String _accessToken; // Placeholder for MVP
  
  DropboxLeagueProvider(this._accessToken);

  @override
  String get providerId => 'dropbox';

  @override
  Future<void> ensureAuth() async {
    // Check if token valid or refresh
  }
  
  // Headers Helper
  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_accessToken',
    'Content-Type': 'application/json',
  };

  @override
  Future<LeagueRemoteRef> createLeague({required String name, required String creatorId}) async {
    // 1. Create '/DartLeagues' (ignore if exists)
    // 2. Create '/DartLeagues/<Name>' (collision?)
    
    // Dropbox folder create: https://api.dropboxapi.com/2/files/create_folder_v2
    final leaguePath = '/DartLeagues/$name'; // Ideally UUID to avoid collision
    
    await _rpc('files/create_folder_v2', {'path': leaguePath, 'autorename': true});
    
    final metadata = LeagueFile(
      schemaVersion: 1,
      leagueId: leaguePath, // Path as ID? Or use returned ID?
      name: name,
      createdAt: DateTime.now(),
      createdBy: creatorId,
      provider: 'dropbox',
      remoteRootPath: leaguePath,
    );
    
    await _uploadFile('$leaguePath/league.json', jsonEncode(metadata.toJson()));
    await _rpc('files/create_folder_v2', {'path': '$leaguePath/matches'});
    
    return LeagueRemoteRef(
      remoteRoot: leaguePath,
      providerId: 'dropbox',
      inviteCode: leaguePath, // Path as invite
    );
  }

  @override
  Future<LeagueJoinResult> joinLeague({required String inviteCodeOrLink}) async {
     // Check if path exists and has league.json
     final path = inviteCodeOrLink;
     try {
       final jsonStr = await _downloadFile('$path/league.json');
       final meta = LeagueFile.fromJson(jsonDecode(jsonStr));
       
       return LeagueJoinResult(
         ref: LeagueRemoteRef(remoteRoot: path, providerId: 'dropbox'),
         name: meta.name,
       );
     } catch (e) {
       throw Exception('Cannot join league at $path. Make sure folder exists and is shared/mounted.');
     }
  }

  @override
  Future<void> uploadMatch({required LeagueRemoteRef leagueRef, required MatchExport payload}) async {
    final filename = '${payload.completedAt.millisecondsSinceEpoch}_${payload.matchId}.json';
    final path = '${leagueRef.remoteRoot}/matches/$filename';
    
    await _uploadFile(path, jsonEncode(payload.toJson()));
  }

  @override
  Future<List<RemoteMatchDescriptor>> listMatches({required LeagueRemoteRef leagueRef, DateTime? since}) async {
    final path = '${leagueRef.remoteRoot}/matches';
    final result = await _rpc('files/list_folder', {'path': path});
    
    // Parse entries
    final entries = result['entries'] as List;
    return entries.map((e) {
       // 'client_modified'
       final mod = DateTime.parse(e['client_modified']); // UTC ISO
       // Logic to filter by 'since' here if API doesn't support query in list_folder
       if (since != null && mod.isBefore(since)) return null;
       
       return RemoteMatchDescriptor(
         remoteId: e['path_lower'], // Use full path as ID
         matchId: null,
         modifiedAt: mod,
       );
    }).whereType<RemoteMatchDescriptor>().toList();
  }

  @override
  Future<MatchExport> downloadMatchPayload({required LeagueRemoteRef leagueRef, required String remoteMatchId}) async {
     final jsonStr = await _downloadFile(remoteMatchId);
     return MatchExport.fromJson(jsonDecode(jsonStr));
  }
  
  @override
  Future<String> readTextFile(String pathOrId) async {
    return _downloadFile(pathOrId);
  }

  @override
  Future<void> uploadTextFile(String pathOrId, String content, {bool overwrite = false}) async {
     await _uploadFile(pathOrId, content, mode: overwrite ? 'overwrite' : 'add');
  }

  @override
  Future<List<RemoteFile>> listFolder(String pathOrId) async {
     final result = await _rpc('files/list_folder', {'path': pathOrId});
     final entries = result['entries'] as List;
     return entries.map((e) {
        return RemoteFile(
           id: e['path_lower'],
           name: e['name'],
           isFolder: e['.tag'] == 'folder',
           modifiedAt: e['client_modified'] != null ? DateTime.parse(e['client_modified']) : null,
        );
     }).toList();
  }
  
  // --- Private Helpers ---
  
  Future<dynamic> _rpc(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('https://api.dropboxapi.com/2/$endpoint');
    final response = await http.post(url, headers: _headers, body: jsonEncode(body));
    
    if (response.statusCode >= 400) {
      if (endpoint.contains('create_folder') && response.statusCode == 409) {
         return {}; // Ignore collision
      }
      throw Exception('Dropbox RPC Error ($endpoint): ${response.body}');
    }
    return jsonDecode(response.body);
  }
  
  Future<void> _uploadFile(String path, String content, {String mode = 'overwrite'}) async {
    final url = Uri.parse('https://content.dropboxapi.com/2/files/upload');
    final headers = {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/octet-stream',
      'Dropbox-API-Arg': jsonEncode({
        'path': path,
        'mode': mode,
        'autorename': false,
        'mute': false,
      }),
    };
    
    final response = await http.post(url, headers: headers, body: utf8.encode(content));
    if (response.statusCode >= 400) {
      throw Exception('Dropbox Upload Error: ${response.body}');
    }
  }
  
  Future<String> _downloadFile(String path) async {
    final url = Uri.parse('https://content.dropboxapi.com/2/files/download');
    final headers = {
      'Authorization': 'Bearer $_accessToken',
      'Dropbox-API-Arg': jsonEncode({'path': path}),
    };
    
    final response = await http.post(url, headers: headers);
    if (response.statusCode >= 400) throw Exception('Dropbox Download Error: ${response.body}');
    
    return utf8.decode(response.bodyBytes);
  }
  Future<LeagueRemoteRef> resolveLeagueRootFromInvite(Map<String, String> remoteRoot) async {
    // For Dropbox, we expect 'dropboxSharedFolderId' or 'dropboxSharedLink'
    String? pathOrId;
    if (remoteRoot.containsKey('dropboxSharedFolderId')) {
       pathOrId = remoteRoot['dropboxSharedFolderId'];
    } else if (remoteRoot.containsKey('dropboxSharedLink')) {
       // TODO: Resolve link to ID using API 'sharing/get_shared_link_metadata'
       pathOrId = remoteRoot['dropboxSharedLink']; 
    }
    
    if (pathOrId == null) throw Exception('Invalid Invite for Dropbox');
    
    // Verify existence?
    // listFolder(pathOrId);
    
    return LeagueRemoteRef(remoteRoot: pathOrId, providerId: 'dropbox');
  }
}
