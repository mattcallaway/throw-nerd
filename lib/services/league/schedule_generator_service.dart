import 'package:uuid/uuid.dart';

import '../../domain/league/league_file_models.dart';

class ScheduleGeneratorService {
  
  /// Generates a Round Robin schedule for the given players.
  /// [playerIds] - List of player IDs to include.
  /// [seasonId] - The season ID to attach to the schedule.
  /// [leagueId] - The league ID.
  /// [startDate] - The date of the first game day.
  /// [weeks] - Number of weeks/cycles (e.g. 1 for single round robin, 2 for double).
  /// [matchesPerDay] - If null, plays all matchups for a round on one day. 
  ///                   If set, limits matches per day and spills over.
  static ScheduleFile generateRoundRobin({
    required List<String> playerIds,
    required String seasonId,
    required String leagueId,
    required DateTime startDate,
    int cycles = 1,
    required String updatedBy,
    ScheduleFormat? format,
  }) {
    if (playerIds.length < 2) return throw Exception('Need at least 2 players');

    final games = _generateRoundRobinPairings(playerIds);
    final allGames = <_Pairing>[];

    // Repeat for cycles
    for (int i = 0; i < cycles; i++) {
       // Flip home/away for even cycles?
       if (i % 2 == 1) {
         allGames.addAll(games.map((p) => _Pairing(p.away, p.home)));
       } else {
         allGames.addAll(games);
       }
    }
    
    // Group into Game Days (One round per week)
    // Detailed RR algo separates rounds, but simple pairing generation gives all combinations.
    // We need a proper round-based generator to avoid players playing twice in a week if possible.
    
    // Berger tables algorithm or Circle method is better for Rounds.
    final rounds = _generateBergerRounds(playerIds);
    final allRounds = <List<_Pairing>>[];
    
    for (int i = 0; i < cycles; i++) {
      bool flip = i % 2 == 1;
      for (final round in rounds) {
         if (flip) {
           allRounds.add(round.map((p) => _Pairing(p.away, p.home)).toList());
         } else {
           allRounds.add(round);
         }
      }
    }
    
    final gameDays = <GameDay>[];
    
    for (int i = 0; i < allRounds.length; i++) {
       final round = allRounds[i];
       final date = startDate.add(Duration(days: i * 7));
       
       gameDays.add(GameDay(
         gameDayId: const Uuid().v4(),
         index: i + 1,
         date: date,
         scheduledMatches: round.asMap().entries.map((e) {
            final p = e.value;
            // Check bye
            if (p.home == 'BYE' || p.away == 'BYE') return null;
            
            return ScheduledMatch(
               scheduleMatchId: const Uuid().v4(),
               homePlayerId: p.home,
               awayPlayerId: p.away,
               stage: 'regular',
               order: e.key + 1,
            );
         }).whereType<ScheduledMatch>().toList(),
         notes: 'Week ${i + 1}',
       ));
    }
    
    return ScheduleFile(
      schemaVersion: 1,
      seasonId: seasonId,
      leagueId: leagueId,
      updatedAt: DateTime.now(),
      updatedBy: updatedBy,
      format: format ?? ScheduleFormat(
         type: 'round_robin', 
         gamesPerMatchup: 1, 
         setsPerMatch: 1, 
         legsPerSet: 1, 
         doubleOut: false, 
         allowedGameTypes: ['501']
      ),
      gameDays: gameDays,
    );
  }

  static List<_Pairing> _generateRoundRobinPairings(List<String> players) {
    final pairings = <_Pairing>[];
    for (int i = 0; i < players.length; i++) {
      for (int j = i + 1; j < players.length; j++) {
        pairings.add(_Pairing(players[i], players[j]));
      }
    }
    return pairings;
  }
  
  // Circle Method for Rounds
  static List<List<_Pairing>> _generateBergerRounds(List<String> players) {
     var pool = List<String>.from(players);
     if (pool.length % 2 != 0) {
       pool.add('BYE'); // Dummy player
     }
     
     final rounds = <List<_Pairing>>[];
     final n = pool.length;
     final mid = n ~/ 2;
     
     for (int i = 0; i < n - 1; i++) {
        final round = <_Pairing>[];
        for (int j = 0; j < mid; j++) {
           final p1 = pool[j];
           final p2 = pool[n - 1 - j];
           
           // Alternate Home/Away based on round index to balance?
           // Standard circle method always has moving array.
           // To balance colors (Home/Away), simplest is:
           // If j==0 (pivot), alternate. Others alternate naturally?
           // Let's stick to simple implementation first.
           
           if (i % 2 == 0) {
              round.add(_Pairing(p1, p2));
           } else {
              round.add(_Pairing(p2, p1));
           }
        }
        rounds.add(round);
        
        // Rotate pool custom: keep index 0 fixed, rotate 1..last
        final last = pool.removeLast();
        pool.insert(1, last);
     }
     
     return rounds;
  }
}

class _Pairing {
  final String home;
  final String away;
  _Pairing(this.home, this.away);
}
