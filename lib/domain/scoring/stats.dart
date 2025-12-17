
import 'models.dart';
import 'game_state.dart';

class InMatchStats {
  final double average; // PPD (Points Per Dart) or PPR (Points Per Round)? Protocol usually uses PPD or PPR (3 darts).
  final double first9Average;
  final int doublesHit;
  final int triplesHit;
  final double checkoutPercentage; // X01
  final double mpr; // Cricket
  final int highestTurn;
  
  final int totalDarts;
  final int cricketHits;
  
  InMatchStats({
    required this.average,
    required this.first9Average,
    required this.doublesHit,
    required this.triplesHit,
    required this.checkoutPercentage,
    required this.mpr,
    required this.highestTurn,
    required this.totalDarts,
    required this.cricketHits,
  });
}

class StatsCalculator {
  static InMatchStats calculate(GameState state, String playerId) {
    final playerTurns = state.history.where((t) => t.playerId == playerId).toList();
    
    if (playerTurns.isEmpty) {
      return InMatchStats(
        average: 0, 
        first9Average: 0, 
        doublesHit: 0, 
        triplesHit: 0, 
        checkoutPercentage: 0, 
        mpr: 0,
        highestTurn: 0,
        totalDarts: 0,
        cricketHits: 0,
      );
    }

    // X01 Stats
    int totalPoints = 0;
    int totalDarts = 0;
    int doubles = 0;
    int triples = 0;
    int maxTurn = 0;
    
    // First 9
    int first9Points = 0;
    int first9Darts = 0;

    // Cricket Stats
    int totalMarks = 0;
    int totalCricketDarts = 0;
    
    for (int i = 0; i < playerTurns.length; i++) {
       final turn = playerTurns[i];
       int turnScore = 0; // For X01
       int turnMarks = 0; // For Cricket
       
       for (final dart in turn.darts) {
         if (state.config.type == GameType.x01) {
            // Need to filter valid scoring darts? 
            // The turn object just records what was hit.
            // Busted turns: in official stats, usually 0 score for the turn?
            // "PPD includes all darts thrown" vs "PPD excludes busted"?
            // Simplest: Count all darts thrown, and their value. 
            // BUT for 301, if I bust, I scored 0 points effectively.
            // Let's check logic: if we bust, we revert score. So effective score is 0.
            // But usually average is based on "points scored".
            // Implementation: We'd need to know if the turn was a bust. 
            // GameState doesn't store "wasBust" per turn history.
            // We might need to re-simulate or store metadata on Turn.
            // Taking 'Turn' score directly: Turn.totalScore is raw darts.
         }
         
         if (dart.isDouble) doubles++;
         if (dart.isTriple) triples++;
         turnScore += dart.total;
         
         if (state.config.type == GameType.cricket) {
             if ([15,16,17,18,19,20,25].contains(dart.value)) {
               turnMarks += dart.multiplier;
             }
         }
       }
       
       // Handle X01 Bust for Average? 
       // Complex without re-simulation. 
       // For V1, let's just use raw thrown score average, or maybe we can improve `Turn` to store `effectiveScore`.
       // Let's stick to raw for now or update Turn model.
       
       totalPoints += turnScore;
       totalDarts += turn.darts.length;
       if (turnScore > maxTurn) maxTurn = turnScore;

       // First 9
       if (totalDarts - turn.darts.length < 9) {
          int dartsToCount = 9 - (totalDarts - turn.darts.length);
          if (dartsToCount > turn.darts.length) dartsToCount = turn.darts.length;
          // approximate if we don't iterate darts again
          // Let's just assume full turn count if in first 3 turns
          if (i < 3) {
             first9Points += turnScore;
             first9Darts += turn.darts.length;
          }
       }
       
       totalMarks += turnMarks;
       totalCricketDarts += turn.darts.length; 
    }
    
    double avg = totalDarts > 0 ? (totalPoints / totalDarts) * 3 : 0; 
    double first9 = first9Darts > 0 ? (first9Points / first9Darts) * 3 : 0;
    double mpr = totalDarts > 0 ? (totalMarks / totalDarts) * 3 : 0;
    
    // Explicit Cricket Hits (any dart hitting a cricket number, regardless of mark value)
    int cHits = 0;
    if (state.config.type == GameType.cricket) {
       for(final t in playerTurns) {
          for(final d in t.darts) {
             if ([15,16,17,18,19,20,25].contains(d.value)) {
               cHits++;
             }
          }
       }
    }

    return InMatchStats(
      average: avg,
      first9Average: first9,
      doublesHit: doubles,
      triplesHit: triples,
      checkoutPercentage: 0, 
      mpr: mpr,
      highestTurn: maxTurn,
      totalDarts: totalDarts,
      cricketHits: cHits,
    );
  }
}
