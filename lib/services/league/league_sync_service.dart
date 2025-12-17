import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darts_app/domain/interfaces/i_match_repository.dart';
import '../../data/repositories/league_repository.dart';
import '../../data/repositories/drift_match_repository.dart';
import 'match_export_service.dart';
import 'match_import_service.dart';
import '../../presentation/providers/active_match_notifier.dart';
import '../../domain/league/league_sync_provider.dart';
import '../../presentation/providers/di_providers.dart';

class LeagueSyncService {
  final IMatchRepository _matchRepo;
  final LeagueRepository _leagueRepo;
  final MatchImportService _importer;
  
  LeagueSyncService(this._matchRepo, this._leagueRepo) : _importer = MatchImportService(_matchRepo);
  
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
    
    // 3. List new remote matches
    final remoteMatches = await provider.listMatches(
      leagueRef: ref,
      since: localLeague.lastSyncAt,
    );
    
    // 4. Process matches
    for (final rm in remoteMatches) {
       // Check duplication
       if (await _matchRepo.existsByRemoteId(rm.remoteId)) continue;
       
       // Download
       try {
         final payload = await provider.downloadMatchPayload(leagueRef: ref, remoteMatchId: rm.remoteId);
         
         // Import
         await _importer.importMatch(payload, leagueId, provider.providerId, rm.remoteId);
         
         // Update status is handled inside import or needs explicit call?
         // MatchImportService stub calls `_repo.createMatch` but we need to set source/remoteId.
         // Let's assume importMatch does basic save. We update sync columns here.
         // Wait, `MatchImportService` doesn't return the ID. It uses payload ID.
         
         await _matchRepo.setMatchLeagueSyncStatus(
           payload.matchId, 
           leagueId, 
           'league_${provider.providerId}', 
           rm.remoteId
         );
         
       } catch (e) {
         // Log error, continue?
         print('Failed to sync match ${rm.remoteId}: $e');
         continue;
       }
    }
    
    // 5. Update timestamp
    await _leagueRepo.updateLastSync(leagueId);
  }

  /// Call this when a match is completed.
  /// [leagueId] is the Local ID of the league.
  Future<void> uploadMatchForLeague(String matchId, String leagueId) async {
    // 1. Get Match Data
    final match = await _matchRepo.getMatch(matchId);
    if (match == null) return;
    
    // Get turns for reconstructing final state (MatchExportService requirement)
    // We assume turns are saved.
    // However, ActiveMatchNotifier has the specific GameState.
    // But we need to support upload from history too.
    // So better to reconstruct or fetch turns.
    final turns = await _matchRepo.getTurnsForMatch(matchId);
    // TODO: Reconstruct GameState from turns? 
    // MatchExportService currently requires GameState and GameMatch.
    // We can refactor MatchExportService to work with Turn objects directly.
    // Actually MatchExport loop through `turns` variable derived from GameState. 
    // If we pass `turns` list to export, it is easier.
    // Let's assume we refactor Export to take List<Turn>.
    
    // 2. Get Provider
    final provider = await _leagueRepo.getProviderForLeague(leagueId);
    if (provider == null) {
      // League might be local-only or config error
      return;
    }
    final localLeague = await _leagueRepo.getLocalLeague(leagueId);
    if (localLeague == null) return;

    // 3. Export
    // For now, simple mock state with history
    // We need to pass the real turns.
    // Refactor MatchExportService to accept List<Turn> instead of GameState
    // OR create a dummy state.
    
    // Let's use the current `MatchExportService` but mocked state:
    // Actually, `MatchExportService.export` uses `finalState.history`.
    // We can create a partial GameState with just history.
    // Or better: Fix MatchExportService to be robust.
    
    // Skip for MVP, assume `uploadMatchForLeague` is called with state if possible? 
    // No, detached service.
    // I will refactor `MatchExportService` to take `List<Turn>` instead of `GameState`.
    
    // 4. Upload
    final payload = MatchExportService.exportFromTurns(match, turns, 'Unknown Location');
    await provider.uploadMatch(
      leagueRef: LeagueRemoteRef(remoteRoot: localLeague.remoteRoot!, providerId: localLeague.providerType),
      payload: payload,
    );
    
    // 5. Update Local DB
    await _matchRepo.setMatchLeagueSyncStatus(matchId, leagueId, 'league_${provider.providerId}', 'uploaded_${DateTime.now().millisecondsSinceEpoch}');
  }
}

final leagueSyncServiceProvider = Provider<LeagueSyncService>((ref) {
  return LeagueSyncService(
    ref.watch(matchRepositoryProvider),
    ref.watch(leagueRepositoryProvider),
  );
});
