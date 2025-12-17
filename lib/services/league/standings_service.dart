import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/game_match.dart';

class StandingsRow {
  final String playerId;
  // TODO: Resolve name?
  final String name; 
  int matchesPlayed = 0;
  int wins = 0;
  int losses = 0;
  int points = 0;
  // Tie breakers
  int legDiff = 0;

  StandingsRow({required this.playerId, required this.name});
}

class LeagueStandingsService {
  /// Aggregates matches into a sorted list of standings
  static List<StandingsRow> calculateStandings(List<GameMatch> matches, List<dynamic> players) {
    // "dynamic" players because we might use a Player entity or simple map. 
    // Assuming passed list is the `_allPlayers` to resolve names.
    
    final Map<String, StandingsRow> map = {};

    for (final m in matches) {
      if (m.finishedAt == null || m.winnerId == null) continue;
      
      // Initialize rows
      for (final pid in m.playerIds) {
        if (!map.containsKey(pid)) {
          final pName = players.firstWhere((p) => p.id == pid, orElse: () => null)?.name ?? 'Unknown';
          map[pid] = StandingsRow(playerId: pid, name: pName);
        }
      }

      // Aggregate
      // TODO: Logic depends on if we have team or individual, but for now 1v1
      if (m.playerIds.length == 2) {
          // Identify winner/loser
          final winner = m.winnerId!;
          final loser = m.playerIds.firstWhere((id) => id != winner);
          
          final wRow = map[winner]!;
          final lRow = map[loser]!;
          
          wRow.matchesPlayed++;
          wRow.wins++;
          wRow.points += 2; // Example: 2pts for win. If draw supported, 1pt.
          
          lRow.matchesPlayed++;
          lRow.losses++;
          
          // Leg Diff calculation requires leg scores which are in m.timeline or aggregated stats.
          // Currently `GameMatch` doesn't strictly expose leg scores in a simple property 
          // unless we parse `stats` or `timeline`.
          // Simplification: Win +1, Loss -1 leg diff ?? No, that's wrong.
          // Need actual set/leg score.
          // m.sets won might be in stats?
          // Let's defer leg diff until stats are richer.
      }
    }
    
    final list = map.values.toList();
    // Sort: Points DESC, Wins DESC, Matches ASC
    list.sort((a,b) {
       int cmp = b.points.compareTo(a.points);
       if (cmp != 0) return cmp;
       cmp = b.wins.compareTo(a.wins);
       if (cmp != 0) return cmp;
       return a.matchesPlayed.compareTo(b.matchesPlayed);
    });
    
    return list;
  }
}

// Provider
final leagueStandingsProvider = Provider.family<List<StandingsRow>, String>((ref, leagueId) {
   // This is a computed provider but 'matches' is async stream.
   // So UI should watch matches and compute, or we use a StreamProvider.
   throw UnimplementedError('Use UI aggregation or dedicated StreamProvider');
});
