import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darts_app/domain/interfaces/i_match_repository.dart';
import '../../data/repositories/league_repository.dart';
import '../../data/repositories/drift_match_repository.dart';
import 'match_export_service.dart';
import 'match_import_service.dart';
import '../../presentation/providers/active_match_notifier.dart';
import '../../domain/league/league_sync_provider.dart';
import '../../presentation/providers/di_providers.dart';
import 'league_metadata_service.dart';

class LeagueSyncService {
  final IMatchRepository _matchRepo;
  final LeagueRepository _leagueRepo;
  final LeagueMetadataService _metadataService;
  final MatchImportService _importer;
  
  LeagueSyncService(this._matchRepo, this._leagueRepo, this._metadataService) 
     : _importer = MatchImportService(_matchRepo);
  
  Future<void> syncLeague(String leagueId) async {
    // 1. Get Provider and Local Info
    final provider = await _leagueRepo.getProviderForLeague(leagueId);
    final localLeague = await _leagueRepo.getLocalLeague(leagueId);
    if (provider == null || localLeague == null) return;
    
    final ref = LeagueRemoteRef(
       remoteRoot: localLeague.remoteRoot!, 
       providerId: localLeague.providerType,
       inviteCode: localLeague.inviteCode
    );
    
    // 2. Ensure Auth
    await provider.ensureAuth();
    
    // 3. Sync Metadata First
    await _syncMetadata(leagueId);
    
    // Refresh local league data after metadata sync (to get updated banned members etc if stored locally?)
    // Currently banned members are only in league.json (loaded via metadata service).
    final meta = await _metadataService.fetchLeagueMetadata(leagueId);
    final bannedIds = meta?.bannedMemberIds ?? [];

    // 4. List new remote matches
    final remoteMatches = await provider.listMatches(
      leagueRef: ref,
      since: localLeague.lastSyncAt,
    );
    
    // 5. Process matches
    for (final rm in remoteMatches) {
       // Check duplication
       if (await _matchRepo.existsByRemoteId(rm.remoteId)) continue;
       
       // Download
       try {
         final payload = await provider.downloadMatchPayload(leagueRef: ref, remoteMatchId: rm.remoteId);
         
         // Check Bans
         bool isBanned = false;
         for (var p in payload.players) {
             if (bannedIds.contains(p.id)) {
                 isBanned = true;
                 break;
             }
         }
         // Actually MatchExport logic might need update to expose player IDs easily.
         // Let's assume we import first, then mark ignored locally if needed?
         // Or check payload.
         
         // Import
         await _importer.importMatch(payload, leagueId, provider.providerId, rm.remoteId);
         
         // Verification: if banned, set complianceStatus 'ignored'
         // We need to check IDs. payload.teams...
         
         await _matchRepo.setMatchLeagueSyncStatus(
           payload.matchId, 
           leagueId, 
           'league_${provider.providerId}', 
           rm.remoteId,
           complianceStatus: isBanned ? 'ignored' : 'valid'
         );
         
       } catch (e) {
         // Log error, continue?
         print('Failed to sync match ${rm.remoteId}: $e');
         continue;
       }
    }
    
    // 6. Update timestamp
    await _leagueRepo.updateLastSync(leagueId);
  }

  Future<void> _syncMetadata(String leagueId) async {
     try {
       // 1. League File
       final meta = await _metadataService.fetchLeagueMetadata(leagueId);
       if (meta != null) {
          await _leagueRepo.updateLeagueDetails(leagueId, 
             name: meta.name, 
             ownerId: meta.ownerId, 
             mode: meta.mode, 
             activeSeasonId: meta.activeSeasonId,
             rulesJson: meta.rules != null ? jsonEncode(meta.rules!.toJson()) : null,
          );
       }
       
       // 2. Seasons
       final seasons = await _metadataService.fetchSeasons(leagueId);
       if (seasons.isNotEmpty) {
          await _leagueRepo.upsertSeasons(leagueId, seasons);
       }
       
       // 3. Locations
       final locFile = await _metadataService.fetchLocations(leagueId);
       if (locFile != null) {
          await _leagueRepo.upsertLocations(leagueId, locFile.locations);
       }
       
       // 4. Schedule (if needed)
       if (meta?.activeSeasonId != null && meta?.mode == 'formal') {
          final schedule = await _metadataService.fetchSchedule(leagueId, meta!.activeSeasonId!);
          if (schedule != null) {
             await _leagueRepo.upsertSchedule(leagueId, schedule);
          }
       }
     } catch (e) {
       print('Metadata sync failed: $e');
     }
  }

  Future<void> uploadMatchForLeague(String matchId, String leagueId) async {
    final match = await _matchRepo.getMatch(matchId);
    if (match == null) return;
    
    final turns = await _matchRepo.getTurnsForMatch(matchId);
    
    final provider = await _leagueRepo.getProviderForLeague(leagueId);
    if (provider == null) return;
    
    final localLeague = await _leagueRepo.getLocalLeague(leagueId);
    if (localLeague == null) return;

    // Check Rules/Compliance (Phase 3 mostly, but stub here)
    final meta = await _metadataService.fetchLeagueMetadata(leagueId);
    if (meta?.mode == 'formal') {
       // Validate against rules?
       // If require schedule, check if match linked?
       // TODO: Validation logic.
    }

    final payload = MatchExportService.exportFromTurns(match, turns, 'Unknown Location');
    await provider.uploadMatch(
      leagueRef: LeagueRemoteRef(remoteRoot: localLeague.remoteRoot!, providerId: localLeague.providerType),
      payload: payload,
    );
    
    await _matchRepo.setMatchLeagueSyncStatus(matchId, leagueId, 'league_${provider.providerId}', 'uploaded_${DateTime.now().millisecondsSinceEpoch}');
  }
}

final leagueSyncServiceProvider = Provider<LeagueSyncService>((ref) {
  return LeagueSyncService(
    ref.watch(matchRepositoryProvider),
    ref.watch(leagueRepositoryProvider),
    ref.watch(leagueMetadataServiceProvider),
  );
});
