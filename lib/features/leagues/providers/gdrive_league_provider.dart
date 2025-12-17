import 'dart:convert';
import 'package:darts_app/domain/league/league_sync_provider.dart';
import 'package:darts_app/domain/league/league_file_models.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:darts_app/services/auth/auth_service_gdrive.dart';

class GoogleDriveLeagueProvider implements LeagueSyncProvider {
  final GoogleDriveAuthProvider _auth;
  
  GoogleDriveLeagueProvider(this._auth);
  
  drive.DriveApi get _api {
    final client = _auth.getClient() as drive.DriveApi?;
    if (client == null) throw Exception('Google Drive not connected');
    return client;
  }
  
  @override
  String get providerId => 'gdrive';

  @override
  Future<void> ensureAuth() async {
    if (!await _auth.isSignedIn()) {
      await _auth.signIn();
    }
  }

  @override
  Future<LeagueRemoteRef> createLeague({required String name, required String creatorId}) async {
    // 1. Create Folder "DartLeagues" if not exists
    // 2. Create subfolder with league Name/ID
    
    final rootId = await _getOrCreateFolder('DartLeagues');
    final leagueFolderId = await _createFolder(name, parentId: rootId);
    
    // Create league.json
    final metadata = LeagueFile(
      schemaVersion: 1,
      leagueId: leagueFolderId, // Use FolderID as LeagueID for simplicty in Drive
      name: name,
      createdAt: DateTime.now(),
      createdBy: creatorId,
      provider: 'gdrive',
      remoteRootPath: leagueFolderId,
    );
    
    await _uploadJsonFile(leagueFolderId, 'league.json', metadata.toJson());
    
    // Create 'matches' subfolder
    await _createFolder('matches', parentId: leagueFolderId);
    
    return LeagueRemoteRef(
      remoteRoot: leagueFolderId,
      providerId: 'gdrive',
      inviteCode: leagueFolderId, // Folder ID is the invite code (requires permission)
    );
  }

  @override
  Future<LeagueJoinResult> joinLeague({required String inviteCodeOrLink}) async {
    // inviteCode is FolderID.
    // Check if we can access it.
    try {
       final file = await _api.files.get(inviteCodeOrLink, $fields: 'id, name, trashed');
       // TODO: Check 'league.json' inside?
       
       return LeagueJoinResult(
         ref: LeagueRemoteRef(remoteRoot: inviteCodeOrLink, providerId: 'gdrive'),
         name: (file as drive.File).name ?? 'Unknown League',
       );
    } catch (e) {
       throw Exception('Cannot access league folder ($inviteCodeOrLink). Ensure you have permission.');
    }
  }

  @override
  Future<void> uploadMatch({required LeagueRemoteRef leagueRef, required MatchExport payload}) async {
     // Find matches folder
     final matchesFolderId = await _findSubfolder(leagueRef.remoteRoot, 'matches');
     if (matchesFolderId == null) throw Exception('Matches folder missing');
     
     final filename = '${payload.completedAt.millisecondsSinceEpoch}_${payload.matchId}.json';
     
     await _uploadJsonFile(matchesFolderId, filename, payload.toJson());
  }

  @override
  Future<List<RemoteMatchDescriptor>> listMatches({required LeagueRemoteRef leagueRef, DateTime? since}) async {
     final matchesFolderId = await _findSubfolder(leagueRef.remoteRoot, 'matches');
     if (matchesFolderId == null) return [];
     
     // Query
     String q = "'$matchesFolderId' in parents and trashed = false";
     // If since is used, we need tricky timestamp query or just filter client side.
     // Drive 'modifiedTime' query: "modifiedTime > '...'"
     
     if (since != null) {
        q += " and modifiedTime > '${since.toIso8601String()}'";
     }
     
     final list = await _api.files.list(q: q, $fields: 'files(id, name, modifiedTime)');
     
     return (list.files ?? []).map((f) {
        return RemoteMatchDescriptor(
          remoteId: f.id!,
          matchId: null, // Need to parse filename
          modifiedAt: f.modifiedTime ?? DateTime.now(),
        );
     }).toList();
  }

  @override
  Future<MatchExport> downloadMatchPayload({required LeagueRemoteRef leagueRef, required String remoteMatchId}) async {
     final jsonStr = await readTextFile(remoteMatchId);
     return MatchExport.fromJson(jsonDecode(jsonStr));
  }
  
  @override
  Future<String> readTextFile(String pathOrId) async {
    String fileId = pathOrId;
    if (pathOrId.contains('/')) {
       final parts = pathOrId.split('/');
       final parentId = parts[0];
       final name = parts[1];
       final found = await _findFileOrFolder(parentId, name);
       if (found == null) throw Exception('File not found: $pathOrId');
       fileId = found;
    }
    
    final file = await _api.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    return utf8.decodeStream(file.stream);
  }

  @override
  Future<void> uploadTextFile(String pathOrId, String content, {bool overwrite = false}) async {
    String? parentId;
    String? name;
    String? fileId;
    
    if (pathOrId.contains('/')) {
       final parts = pathOrId.split('/');
       parentId = parts[0];
       name = parts.sublist(1).join('/'); // Allow nested? No, GDrive is ID based. Assume "Parent/Name".
       // Check if exists
       fileId = await _findFileOrFolder(parentId, name!);
    } else {
       // Assume existing File ID
       fileId = pathOrId;
    }
    
    final bytes = utf8.encode(content);
    final media = drive.Media(Stream.value(bytes), bytes.length);

    if (fileId != null) {
       if (overwrite) {
         await _api.files.update(drive.File(), fileId, uploadMedia: media);
       } else {
         // Error or ignore? 
         throw Exception('File exists and overwrite is false');
       }
    } else {
       if (parentId != null && name != null) {
          // Create
          var file = drive.File()..name = name..parents = [parentId];
          await _api.files.create(file, uploadMedia: media);
       } else {
          throw Exception('Cannot create file without ParentID/Name path');
       }
    }
  }

  @override
  Future<List<RemoteFile>> listFolder(String pathOrId) async {
     // pathOrId is Folder ID
     final q = "'$pathOrId' in parents and trashed = false";
     final list = await _api.files.list(q: q, $fields: 'files(id, name, mimeType, modifiedTime)');
     
     return (list.files ?? []).map((f) {
        return RemoteFile(
           id: f.id!,
           name: f.name ?? 'unknown',
           isFolder: f.mimeType == 'application/vnd.google-apps.folder',
           modifiedAt: f.modifiedTime,
        );
     }).toList();
  }

  // Helpers
  
  Future<String> _getOrCreateFolder(String name) async {
     final q = "mimeType = 'application/vnd.google-apps.folder' and name = '$name' and trashed = false";
     final list = await _api.files.list(q: q);
     if (list.files?.isNotEmpty == true) {
        return list.files!.first.id!;
     }
     return _createFolder(name);
  }
  
  Future<String> _createFolder(String name, {String? parentId}) async {
    var file = drive.File()..name = name..mimeType = 'application/vnd.google-apps.folder';
    if (parentId != null) {
       file.parents = [parentId];
    }
    final result = await _api.files.create(file);
    return result.id!;
  }
  
  Future<String?> _findSubfolder(String parentId, String name) async {
     final q = "'$parentId' in parents and mimeType = 'application/vnd.google-apps.folder' and name = '$name' and trashed = false";
     final list = await _api.files.list(q: q);
     return list.files?.firstOrNull?.id;
  }

  Future<String?> _findFileOrFolder(String parentId, String name) async {
     final q = "'$parentId' in parents and name = '$name' and trashed = false";
     final list = await _api.files.list(q: q);
     return list.files?.firstOrNull?.id;
  }
  
  Future<void> _uploadJsonFile(String parentId, String name, Map<String, dynamic> content) async {
     final jsonStr = jsonEncode(content);
     await uploadTextFile('$parentId/$name', jsonStr);
  }
  Future<LeagueRemoteRef> resolveLeagueRootFromInvite(Map<String, String> remoteRoot) async {
     // Expected: 'driveFolderId'
     final folderId = remoteRoot['driveFolderId'];
     if (folderId == null) throw Exception('Invalid Invite for Google Drive');
     
     // Verify access
     try {
       await _api.files.get(folderId, $fields: 'id, name, trashed');
     } catch(e) {
       throw Exception('Cannot access Drive folder. Ensure it is shared with you.');
     }
     
     return LeagueRemoteRef(remoteRoot: folderId, providerId: 'gdrive');
  }
}
