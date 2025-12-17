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
  
  // --- Private Helpers ---
  
  Future<dynamic> _rpc(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('https://api.dropboxapi.com/2/$endpoint');
    final response = await http.post(url, headers: _headers, body: jsonEncode(body));
    
    if (response.statusCode >= 400) {
      // 409 means path exists (often okay for create_folder)
      if (endpoint.contains('create_folder') && response.statusCode == 409) {
         // Return existing (simplified) ?? 
         // Actually verify error summary.
         return {}; 
      }
      throw Exception('Dropbox RPC Error ($endpoint): ${response.body}');
    }
    return jsonDecode(response.body);
  }
  
  Future<void> _uploadFile(String path, String content) async {
    // upload session not needed for small JSON
    // content.upload: https://content.dropboxapi.com/2/files/upload
    final url = Uri.parse('https://content.dropboxapi.com/2/files/upload');
    final headers = {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/octet-stream',
      'Dropbox-API-Arg': jsonEncode({
        'path': path,
        'mode': 'overwrite',
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
}
