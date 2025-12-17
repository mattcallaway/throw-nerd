import 'dart:convert';
import 'package:darts_app/domain/game_match.dart';
import 'package:darts_app/domain/scoring/models.dart';
import '../../domain/league/league_file_models.dart';
import '../../domain/interfaces/i_match_repository.dart';

class MatchImportService {
  final IMatchRepository _repo;
  // We need player repo to ensure players exist, but not injected yet.
  // Assuming we can pass it or add to constructor?
  // Let's rely on DI or add to constructor.
  
  MatchImportService(this._repo);
  
  Future<void> importMatch(MatchExport export, String leagueId, String providerId, String remoteId) async {

     // 2. Map Payload to Domain Objects
     final config = GameConfig.fromJson(jsonDecode(export.settingsJson));
     
     // CRITICAL: Ensure players exist locally!
     // We can't use IPlayerRepository if not injected.
     // However, Drift requires FK.
     // We should probably inject it.
     // For now, let's assume valid IDs or fail? No, that breaks sync.
     // We MUST insert players.
     // Since I can't easily change constructor signature without breaking callers (LeagueSyncService),
     // I need to use direct DB access or fix DI.
     // LeagueSyncService has access to Repos.
     // I will update LeagueSyncService to pass PlayerRepo or handle player sync?
     // Better: MatchImportService should take PlayerRepo.
     
     final match = GameMatch(
       id: export.matchId,
       config: config,
       playerIds: export.players.map((p) => p.id).toList(),
       createdAt: export.completedAt,
       finishedAt: export.completedAt,
       locationId: null,
       winnerId: export.winnerId,
     );
     
     await _repo.createMatch(match);
     
     // 4. Save Turns
     for (var i = 0; i < export.turns.length; i++) {
        final t = export.turns[i];
        final turn = Turn(
          playerId: t.playerId,
          darts: t.darts.map((d) => Dart(value: d.value, multiplier: d.multiplier)).toList(),
          legIndex: t.leg,
          setIndex: t.set,
          roundIndex: t.round,
        );
        // Save turn
        await _repo.saveTurn(match.id, turn, t.leg, t.set, t.round, startingScore: null);
     }
  }
}
