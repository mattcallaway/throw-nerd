import 'dart:convert';
import 'package:darts_app/domain/game_match.dart';
import 'package:darts_app/domain/scoring/darts_scoring.dart';
import '../../domain/league/league_file_models.dart';

class MatchExportService {
  
  static MatchExport export(GameMatch match, GameState finalState, String locationName) {
     return exportFromTurns(match, finalState.history, locationName);
  }

  static MatchExport exportFromTurns(GameMatch match, List<Turn> turns, String locationName) {
    return MatchExport(
      matchId: match.id,
      completedAt: match.finishedAt ?? DateTime.now(),
      locationName: locationName,
      gameType: match.config.type == GameType.x01 ? 'x01' : 'cricket',
      settingsJson: match.settingsJson ?? '{}', // Propagate raw settings
      winnerId: match.winnerId,
      players: match.playerIds.map((pid) {
         return MatchPlayerExport(
           id: pid,
           name: 'Player $pid', // TODO: Resolve name
           order: match.playerIds.indexOf(pid),
         );
      }).toList(),
      turns: turns.map((t) {
         return TurnExport(
           playerId: t.playerId,
           leg: 1, // TODO: derived?
           set: 1,
           round: 1, 
           darts: t.darts.map((d) => DartExport(value: d.value, multiplier: d.multiplier)).toList(),
         );
      }).toList(),
    );
  }
}
