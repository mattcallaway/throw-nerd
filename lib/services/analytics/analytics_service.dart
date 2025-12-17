import 'dart:math';
import '../../data/repositories/analytics_repository.dart';
import '../../domain/analytics/analytics_models.dart';
import '../../domain/scoring/models.dart';

class AnalyticsService {
  final AnalyticsRepository _repo;

  AnalyticsService(this._repo) {
    _repo.backfillHistoricalData();
  }

  Future<PlayerMetrics> getPlayerMetrics(String playerId) async {
    // Parallel fetch
    final basicFuture = _repo.getX01BasicStats(playerId);
    final f9Future = _repo.getFirst9Avg(playerId);
    // Fetch last 1000 X01 turns
    final rawFuture = _repo.getRawTurns(playerId, limit: 1000, type: GameType.x01);
    // Fetch last 1000 Cricket turns for MPR
    final cricketFuture = _repo.getRawTurns(playerId, limit: 1000, type: GameType.cricket);

    final results = await Future.wait([basicFuture, f9Future, rawFuture, cricketFuture]);
    
    final basic = results[0] as Map<String, num>;
    final f9Avg = results[1] as double;
    final rawTurns = results[2] as List<TurnData>;
    final cricketTurns = results[3] as List<TurnData>;

    // 1. Consistency (X01)
    double consistency = 0.0;
    if (rawTurns.isNotEmpty) {
      double sum = 0;
      for (var t in rawTurns) sum += t.score;
      double mean = sum / rawTurns.length;
      
      double sumSquaredDiff = 0;
      for (var t in rawTurns) {
        sumSquaredDiff += pow(t.score - mean, 2);
      }
      consistency = sqrt(sumSquaredDiff / rawTurns.length);
    }
    
    // 2. Checkout Stats
    // Improved Logic: 
    // - Checkouts are HITS if (current - dart == 0) and valid finish.
    // - Attempts: We count doubles as attempts if remaining <= 50.
    // - We also count ANY throw as a hit if it reduces score to 0 (validating Single Out scenarios).
    int checkoutAttempts = 0;
    int checkoutHits = 0;
    
    for (var t in rawTurns) {
       // Only if startingScore is known
       if (t.startingScore != null) {
          int current = t.startingScore!;
          for (var d in t.darts) {
              // Check if 'current' was a checkout opportunity (Standard Double Out rules assumption for "Attempts" metric)
              bool isStandardDoubleAttempt = false;
              if (current <= 40 && current % 2 == 0 && current > 0) isStandardDoubleAttempt = true;
              else if (current == 50) isStandardDoubleAttempt = true;
              
              bool isCheckoutHit = false;
              int val = d.total;
              
              // Did we finish?
              // The Turn score in DB is authoritative for the turn total, but individual dart validation
              // requires engine logic. Simple check: if (current - val == 0).
              if (current - val == 0) {
                 // Check if it was a valid double (most common) OR if we accept Single Out hits implicitly
                 // Since we don't have GameConfig here easily, we assume if it reduced to 0 in valid play, it IS a checkout.
                 isCheckoutHit = true;
              }
              
              if (isStandardDoubleAttempt || isCheckoutHit) {
                 // If we HIT a checkout (even single), we count it as attempt & hit for the metric to be fair?
                 // Or do we strictly measure Double Out Accuracy?
                 // Convention: "Checkout %" usually implies Doubles.
                 // But if user plays Single Out, they want to see 100% or similar.
                 // Let's count ANY hit as a hit.
                 // Let's count Double opportunities as attempts.
                 // If a user hits a Single Out (e.g. S10 from 10), isStandardDoubleAttempt is FALSE.
                 // So we should add to attempts if isCheckoutHit is true.
                 if (isStandardDoubleAttempt || isCheckoutHit) {
                    checkoutAttempts++;
                 }
                 
                 if (isCheckoutHit) {
                    checkoutHits++;
                    break; 
                 }
              }

              // Update State
              if (current - val < 2 && current - val != 0) {
                 // Bust assumption for Double Out to stop simulation
                 // But for Single out, 0 is valid. < 0 is bust.
                 // If we didn't hit 0 above, and < 2... 
                 // It's ambiguous. But statistically minor impact for "Attempts" count if we stop or continue.
                 // We'll continue unless < 0.
                 if (current - val < 0) break;
              }
              current -= val;
              if (current == 0) break;
          }
       }
    }
    
    double checkoutAcc = checkoutAttempts > 0 ? (checkoutHits / checkoutAttempts) * 100 : 0.0;

    // 3. Segment Stats (Combine X01 and Cricket?)
    // Usually separate, but for "Heatmap" we might want all throws.
    // Let's combine.
    final allTurns = [...rawTurns, ...cricketTurns];
    final dist = <String, int>{};
    for (var t in allTurns) {
      for (var d in t.darts) {
         final key = '${d.value}-${d.multiplier}';
         dist[key] = (dist[key] ?? 0) + 1;
      }
    }
    
    // 4. Cricket Stats (MPR)
    // MPR = Total Marks / (Total Darts / 3) => Total Marks / Turns? 
    // Standard MPR is Marks Per Round (Turn).
    double mpr = 0.0;
    int cricketGames = 0; // Approximate if we don't count unique matchIds. 
    // We can count unique matchIds in cricketTurns.
    final cricketMatchIds = <String>{};
    
    if (cricketTurns.isNotEmpty) {
       int totalMarks = 0;
       int totalCricketTurns = cricketTurns.length;
       
       for (var t in cricketTurns) {
          cricketMatchIds.add(t.matchId);
          for (var d in t.darts) {
             // Valid Cricket Marks: 15-20, Bull.
             if (d.value >= 15 || d.value == 25) {
                totalMarks += d.multiplier;
             }
          }
       }
       mpr = totalCricketTurns > 0 ? totalMarks / totalCricketTurns : 0.0;
       cricketGames = cricketMatchIds.length;
    }

    return PlayerMetrics(
      avg3Dart: (basic['avg3'] as num).toDouble(),
      avgFirst9: f9Avg,
      highestTurn: (basic['highestTurn'] as num).toInt(),
      totalDarts: (basic['totalDarts'] as num).toInt(),
      totalScore: (basic['totalScore'] as num).toInt(),
      consistency: consistency,
      checkoutCount: checkoutHits,
      checkoutAccuracy: checkoutAcc,
      recentHistory: rawTurns, // Keep X01 history for list? Or mix? distinct X01 for now.
      segmentStats: SegmentStats(distribution: dist), // Combined
      mpr: mpr,
      cricketGamesPlayed: cricketGames,
    );
  }
}
