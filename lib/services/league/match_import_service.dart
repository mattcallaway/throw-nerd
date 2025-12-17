import 'dart:convert';
import 'package:darts_app/domain/game_match.dart';
import 'package:darts_app/domain/scoring/models.dart';
import '../../domain/league/league_file_models.dart';
import '../../domain/interfaces/i_match_repository.dart';

class MatchImportService {
  final IMatchRepository _repo;
  
  MatchImportService(this._repo);
  
  Future<void> importMatch(MatchExport export, String leagueId, String providerId, String remoteId) async {
     // 1. Check existence? Service caller should check.
     
     // 2. Map Payload to Domain Objects
     final config = GameConfig.fromJson(jsonDecode(export.settingsJson));
     
     final match = GameMatch(
       id: export.matchId,
       config: config,
       playerIds: export.players.map((p) => p.id).toList(),
       createdAt: export.completedAt, // Or parse from ID?
       finishedAt: export.completedAt,
       locationId: null, // Resolving location name to ID is hard locally. Store as null or 'Unknown'.
       // We need to store league info!
       // GameMatch domain object needs leagueId extension or we update DB directly?
       // Domain object vs DB entity. 
     );
     
     // 3. Save Match
     // But `GameMatch` domain doesn't have leagueId. 
     // We need to update `DriftMatchRepository` to handle leagueId passed or extend `GameMatch`.
     // For now, save match then update columns in DB via repo custom method?
     // Or repo.createMatch handles standard fields, and we assume it's local.
     // Better: Add import method to repo.
     
     // Workaround: `createMatch` saves basic info. We need to set source/leagueId.
     await _repo.createMatch(match);
     
     // 4. Save Turns
     for (var i = 0; i < export.turns.length; i++) {
        final t = export.turns[i];
        final turn = Turn(
          playerId: t.playerId,
          darts: t.darts.map((d) => Dart(value: d.value, multiplier: d.multiplier)).toList(),
        );
        // Save turn
        await _repo.saveTurn(match.id, turn, t.leg, t.set, t.round);
     }
     
     // 5. Update Status & Winner
     // Determine winner from turns or export? Export doesn't explicitly field winnerId.
     // We can re-run engine? 
     // Or add winnerId to Export Model (Should do that).
     // Assuming last turn player is winner if finished? Risky.
     // TODO: Add winnerId to MatchExport schema. 
     
     // Update Sync Fields (Source, LeagueId, RemoteId)
     // repository must expose a way to set these.
  }
}
