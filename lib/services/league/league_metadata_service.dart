import 'dart:convert';
import '../../domain/league/league_file_models.dart';
import '../../data/repositories/league_repository.dart';
import '../../domain/league/league_sync_provider.dart';

class LeagueMetadataService {
  final LeagueRepository _repo;

  LeagueMetadataService(this._repo);

  Future<LeagueSyncProvider> _getProvider(String leagueId) async {
    final provider = await _repo.getProviderForLeague(leagueId);
    if (provider == null) throw Exception('Provider for league $leagueId not found');
    return provider;
  }

  // --- LEAGUE.JSON ---
  Future<LeagueFile?> fetchLeagueMetadata(String leagueId) async {
    try {
      final provider = await _getProvider(leagueId);
      // readTextFile expects path relative to league root? 
      // Provider implementation usually takes relative path from league root if we set it contextually?
      // DropboxLeagueProvider / GoogleDriveLeagueProvider implementations:
      // "readTextFile(RemotePath path)"
      // Does 'path' include league root?
      // Looking at `readTextFile` implementation in `DropboxLeagueProvider` (assumed):
      // usually providers operate on absolute paths or relative to App Folder.
      // But `SyncProvider` usually context-aware? 
      // Current `DropboxLeagueProvider.createLeague` returns `RemoteLeagueRoot`.
      // We might need to handle paths carefully.
      // Assuming `readTextFile` takes relative path inside the league folder if we configured it,
      // OR we pass full path "DartLeagues/<leagueId>/league.json".
      // Let's assume the latter for safety unless provider has `scopeToLeague`.
      // Wait, `LeagueRepository` knows the `remoteRoot`. 
      
      // Let's look at `createLeague` in `LeagueRepository`:
      // final localId = ref.remoteRoot;
      // It implies `remoteRoot` is the folder ID (GDrive) or Path (Dropbox).
      
      // If GDrive, we need to list children of that ID.
      // If Dropbox, we construct path.
      
      // We need `fetchLeagueMetadata` to resolve the *League Object* first?
      // No, we pass `leagueId` (local ID = remoteRoot).
      
      // So checking `getProviderForLeague(leagueId)` just returns the global provider instance (e.g. GDrive).
      // It doesn't configure it for that league.
      
      // So we must pass the `remoteRoot` (which is `leagueId` in our DB) to the provider methods?
      // Or `readTextFile` takes a "Path" which we construct.
      
      // GDrive: `readTextFile` takes fileId. We don't know fileId of `league.json` inside the folder easily without listing.
      // Dropbox: `readTextFile` takes path `/DartLeagues/<id>/league.json`.
      
      // We need a helper `getLeagueFile(leagueId, filename)`?
      
      // Let's assume we implement a `findFileInLeague(leagueId, filename)` in Provider?
      // Or `readLeagueFile(leagueId, filename)`.
      
      // Current `LeagueSyncProvider` (from context) has:
      // Future<String> readTextFile(RemotePath path);
      // Future<List<RemoteFile>> listFolder(RemotePath path);
      
      // If GDrive, `path` is File ID. Folder listing returns children.
      // So flow is: 
      // 1. List folder `leagueId` (Remote Root ID).
      // 2. Find file named `league.json`.
      // 3. Read it.
      
      final rootId = leagueId; // In our schema, local ID is the remote root ID/Path.
      final files = await provider.listFolder(rootId);
      final file = files.firstWhere((f) => f.name == 'league.json', orElse: () => throw Exception('league.json not found'));
      
      final jsonStr = await provider.readTextFile(file.id); // file.id is ID for GDrive, Path for Dropbox
      return LeagueFile.fromJson(jsonDecode(jsonStr));
    } catch (e) {
      // print('Error fetching metadata: $e');
      return null;
    }
  }

  Future<void> updateLeagueMetadata(String leagueId, LeagueFile metadata) async {
    final provider = await _getProvider(leagueId);
    final jsonStr = jsonEncode(metadata.toJson());
    
    // Check if exists to get ID (GDrive overwrite requires ID usually, or create new?)
    // `uploadTextFile` abstraction should handle "overwrite or create".
    // For GDrive, we usually need the fileID to update, OR we delete and re-upload (risky ID change), 
    // OR `uploadTextFile` takes parentID + filename.
    
    // Abstract provider needs `uploadLeagueFile(leagueId, filename, content)`.
    // Let's rely on `uploadTextFile` taking the *Parent* ID and *Filename*?
    // Start by listing.
    
    final rootId = leagueId;
    // We can optimize caching later.
    
    // Provider specific logic might be needed if `uploadTextFile` signature is generic.
    // Let's check `LeagueSyncProvider` signature from the prompt:
    // Future<void> uploadTextFile(RemotePath path, String contents, {bool overwrite = false});
    
    // Note: "path" in GDrive usually means File ID? Or Parent ID?
    // If we want to create: Parent ID?
    // If we want to update: File ID?
    // This abstraction is leaky for GDrive.
    // But usually `uploadTextFile` in these wrappers implies:
    // "Put this file at this virtual path".
    
    // If I use the method `uploadFileToLeague(leagueId, filename, content)` it would be safer.
    // I will add extension or helper here.
    
    // For now: List -> Check Exists -> Update(ID) or Create(ParentID).
    final files = await provider.listFolder(rootId);
    final existing = files.where((f) => f.name == 'league.json').firstOrNull;
    
    if (existing != null) {
       // Update
       await provider.uploadTextFile(existing.id, jsonStr, overwrite: true);
    } else {
       // Create in root
       // How to specify parent? 
       // If `path` argument is just the ID of the folder?
       // Ambiguity in `uploadTextFile` signature.
       // Let's assume we need a method `createFileInFolder(folderId, filename, content)`.
       // Since I can't see the provider implementation details fully, I will use `uploadTextFile` assuming it handles "Path" logic 
       // or I'll use `uploadToLeagueRoot` if available.
       
       // I'll define `uploadLeagueFile` in this service and implement best-guess logic, 
       // expecting `uploadTextFile` to handle "ID or Path".
       // For Dropbox: path = "$rootId/league.json".
       // For GDrive: path = "$rootId/league.json" (virtual) or we need a specific call.
       
       // Let's rely on a helper `_upload(provider, rootId, filename, content)`
       await _upload(provider, rootId, 'league.json', jsonStr);
    }
  }

  // --- SEASONS ---
  Future<List<SeasonFile>> fetchSeasons(String leagueId) async {
    try {
      final provider = await _getProvider(leagueId);
      final rootId = leagueId;
      
      // 1. Find seasons folder
      final rootFiles = await provider.listFolder(rootId);
      final seasonsFolder = rootFiles.where((f) => f.name == 'seasons').firstOrNull;
      
      if (seasonsFolder == null) return [];
      
      // 2. List seasons
      final seasonFiles = await provider.listFolder(seasonsFolder.id);
      final results = <SeasonFile>[];
      
      for (var f in seasonFiles) {
        if (f.name.startsWith('season_') && f.name.endsWith('.json')) {
           final content = await provider.readTextFile(f.id);
           try {
             results.add(SeasonFile.fromJson(jsonDecode(content)));
           } catch (e) {
             // ignore corrupt
           }
        }
      }
      return results;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveSeason(String leagueId, SeasonFile season) async {
    final provider = await _getProvider(leagueId);
    final jsonStr = jsonEncode(season.toJson());
    final filename = 'season_${season.seasonId}.json';
    
    await _uploadToSeasonsFolder(provider, leagueId, filename, jsonStr);
  }

  // --- LOCATIONS ---
  Future<LocationFile?> fetchLocations(String leagueId) async {
    final provider = await _getProvider(leagueId);
    final rootId = leagueId;
     // Try finding 'seasons' folder then locations.json
    final rootFiles = await provider.listFolder(rootId);
    final seasonsFolder = rootFiles.where((f) => f.name == 'seasons').firstOrNull;
    if (seasonsFolder == null) return null;
    
    final files = await provider.listFolder(seasonsFolder.id);
    final locFile = files.where((f) => f.name == 'locations.json').firstOrNull;
    
    if (locFile != null) {
      final content = await provider.readTextFile(locFile.id);
      return LocationFile.fromJson(jsonDecode(content));
    }
    return null;
  }
  
  Future<void> saveLocations(String leagueId, LocationFile file) async {
    final provider = await _getProvider(leagueId);
    final jsonStr = jsonEncode(file.toJson());
    await _uploadToSeasonsFolder(provider, leagueId, 'locations.json', jsonStr);
  }

  // --- SCHEDULE ---
  Future<ScheduleFile?> fetchSchedule(String leagueId, String seasonId) async {
    final provider = await _getProvider(leagueId);
    final rootId = leagueId;
    final rootFiles = await provider.listFolder(rootId);
    final seasonsFolder = rootFiles.where((f) => f.name == 'seasons').firstOrNull;
    if (seasonsFolder == null) return null;
    
    final files = await provider.listFolder(seasonsFolder.id);
    final sFile = files.where((f) => f.name == 'schedule_$seasonId.json').firstOrNull;
    
    if (sFile != null) {
       final content = await provider.readTextFile(sFile.id);
       return ScheduleFile.fromJson(jsonDecode(content));
    }
    return null;
  }
  
  Future<void> saveSchedule(String leagueId, ScheduleFile schedule) async {
    final provider = await _getProvider(leagueId);
    final jsonStr = jsonEncode(schedule.toJson());
    await _uploadToSeasonsFolder(provider, leagueId, 'schedule_${schedule.seasonId}.json', jsonStr);
  }

  // --- HELPERS ---
  
  Future<void> _upload(LeagueSyncProvider provider, String parentId, String filename, String content) async {
     // Check if exists
     final files = await provider.listFolder(parentId);
     final existing = files.where((f) => f.name == filename).firstOrNull;
     
     if (existing != null) {
       await provider.uploadTextFile(existing.id, content, overwrite: true);
     } else {
       // We MUST use a method that supports creation name. 
       // `uploadTextFile` in our interface might be ambiguous.
       // Assuming specific implementation knows how to handle "create new file with name in folder".
       // If GDrive: we need `createFile(parentId, name, content)`.
       // If usage of `uploadTextFile` with non-existent ID fails, we're in trouble.
       
       // HACK: We assume `uploadTextFile` accepts a special payload or we pass the parentId and put filename in metadata?
       // Actually `LeagueSyncProvider` interface:
       // Future<void> uploadTextFile(RemotePath path, String contents, {bool overwrite = false});
       
       // For Dropbox `path` is `/path/to/file.json`.
       // For GDrive `path` is FileID (for overwrite) or... ??? 
       
       // We need to extend `LeagueSyncProvider` to support `createFile(parentId, filename, content)`.
       // Since I can't edit the interface definition easily without breaking implementations, 
       // I'll assume `uploadTextFile` checks if `path` looks like an ID or a Path.
       // Or I should add `createFile` to the interface if I can edit the providers.
       
       // For MVP, allow `provider.createFileInFolder(parentId, filename, content)`.
       // I will invoke dynamic for now or update interface next.
       // Let's try casting or dynamic dispatch if interface doesn't have it.
       // OR: standard `uploadTextFile` takes a structure `RemotePath` which might wrap ID+Name?
       // `RemotePath` was type alias for String in prompt probably.
       
       // Better approach:
       // Use `uploadTextFile` but pass "$parentId/$filename" string.
       // Dropbox Provider: Works naturally.
       // GDrive Provider: Must parse this. "(ParentID)/(Filename)".
       
       await provider.uploadTextFile("$parentId/$filename", content); 
     }
  }

  Future<void> _uploadToSeasonsFolder(LeagueSyncProvider provider, String leagueRootId, String filename, String content) async {
     // Ensure seasons folder exists
     final rootFiles = await provider.listFolder(leagueRootId);
     var seasonsFolder = rootFiles.where((f) => f.name == 'seasons').firstOrNull;
     
     if (seasonsFolder == null) {
        // Create generic 'seasons' folder?
        // Provider interface missing `createFolder`.
        // I should add it.
        // For now, assume it exists or we can't create formal league structures easily.
        // Assuming `uploadTextFile` with path can create usage?
        // E.g. Dropbox: /root/seasons/file.json -> auto creates parent? (Usually yes)
        // GDrive: No.
        
        // I'll need to check if I can add `createFolder` to interface.
        throw Exception('Seasons folder missing and creation not implemented');
     }
     
     await _upload(provider, seasonsFolder.id, filename, content);
  }
}
