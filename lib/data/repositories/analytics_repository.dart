import 'dart:convert';
import 'package:drift/drift.dart';
import '../local/database.dart';
import '../../domain/scoring/models.dart';
import '../../domain/analytics/analytics_models.dart';

class AnalyticsRepository {
  final AppDatabase _db;
  
  AnalyticsRepository(this._db);

  /// Calculates basic X01 stats using SQL Aggregation for speed.
  Future<Map<String, num>> getX01BasicStats(String playerId, {DateTime? since}) async {
    // Queries
    final query = _db.select(_db.turns).join([
       innerJoin(_db.matches, _db.matches.id.equalsExp(_db.turns.matchId))
    ])
    ..where(_db.turns.playerId.equals(playerId))
    ..where(_db.matches.gameType.equals(GameType.x01.name));

    if (since != null) {
      query.where(_db.turns.createdAt.isBiggerOrEqualValue(since));
    }

    query.addColumns([
       _db.turns.score.sum(),
       _db.turns.dartsThrown.sum(),
       _db.turns.score.max(),
    ]);
    
    final result = await query.getSingle();
    
    final totalScore = result.read(_db.turns.score.sum()) ?? 0;
    final totalDarts = result.read(_db.turns.dartsThrown.sum()) ?? 0;
    final maxTurn = result.read(_db.turns.score.max()) ?? 0;
    
    double avg3 = totalDarts > 0 ? (totalScore / totalDarts) * 3 : 0.0;
    
    return {
      'avg3': avg3,
      'highestTurn': maxTurn,
      'totalDarts': totalDarts,
      'totalScore': totalScore,
    };
  }
  
  /// Calculates First-9 Average (first 3 turns aka roundIndex <= 3)
  Future<double> getFirst9Avg(String playerId, {DateTime? since}) async {
    final query = _db.select(_db.turns).join([
       innerJoin(_db.matches, _db.matches.id.equalsExp(_db.turns.matchId))
    ])
    ..where(_db.turns.playerId.equals(playerId))
    ..where(_db.matches.gameType.equals(GameType.x01.name))
    ..where(_db.turns.roundIndex.isSmallerOrEqualValue(3));

    if (since != null) {
      query.where(_db.turns.createdAt.isBiggerOrEqualValue(since));
    }

    query.addColumns([
       _db.turns.score.sum(),
       _db.turns.dartsThrown.sum(),
    ]);
    
    final result = await query.getSingle();
    final score = result.read(_db.turns.score.sum()) ?? 0;
    final darts = result.read(_db.turns.dartsThrown.sum()) ?? 0;
    
    return darts > 0 ? (score / darts) * 3 : 0.0;
  }
  
  /// Fetches raw turns for granular analysis (Heatmaps, Checkout %, Consistency)
  /// Can be heavy, consider limiting.
  Future<List<TurnData>> getRawTurns(String playerId, {GameType? type, DateTime? since, int limit = 2000}) async {
    final query = _db.select(_db.turns).join([
       innerJoin(_db.matches, _db.matches.id.equalsExp(_db.turns.matchId))
    ])
    ..where(_db.turns.playerId.equals(playerId))
    ..orderBy([OrderingTerm.desc(_db.turns.createdAt)])
    ..limit(limit);
    
    if (type != null) {
       // Need to parse enum manually if it's stored as String or use converter?
       // Matches table uses TextColumn with map(GameTypeConverter).
       // In Join, `matches.gameType` is the column. equals accepts value of same type.
       query.where(_db.matches.gameType.equals(type.name)); 
    }
    
    if (since != null) {
      query.where(_db.turns.createdAt.isBiggerOrEqualValue(since));
    }
    
    final rows = await query.get();
    
    // We map manually because we joined
    return rows.map((row) {
       final t = row.readTable(_db.turns);
       final m = row.readTable(_db.matches);
       
       final int calculatedScore = t.score ?? t.darts.fold<int>(0, (sum, dart) => sum + dart.value * dart.multiplier);
       // DartsConverter is automatic on t.darts
       return TurnData(
         matchId: t.matchId,
         darts: t.darts,
         score: calculatedScore, 
         gameType: m.gameType,
         createdAt: t.createdAt,
         startingScore: t.startingScore,
       );
    }).toList();
  }

  Future<void> backfillHistoricalData() async {
    // 1. Backfill score and dartsThrown if missing
    await _backfillSimpleStats();
    
    // 2. Backfill startingScore for X01 matches
    await _backfillStartingScores();
  }

  Future<void> _backfillSimpleStats() async {
    final turnsToFix = await (_db.select(_db.turns)
      ..where((t) => t.score.isNull())
      ..limit(500)
    ).get();

    if (turnsToFix.isEmpty) return;

    await _db.batch((batch) {
      for (final t in turnsToFix) {
         final int score = t.darts.fold<int>(0, (sum, dart) => sum + dart.value * dart.multiplier);
         final count = t.darts.length;
         batch.update(_db.turns, TurnsCompanion(
            score: Value(score),
            dartsThrown: Value(count),
         ), where: (row) => row.id.equals(t.id));
      }
    });
  }

  Future<void> _backfillStartingScores() async {
    // Select matches that might need backfill. 
    // We check for any turn in X01 that has startingScore = null
    // To be efficient, we might just load all X01 matches? 
    // Or simpler: limit to recent 50 matches to avoid lockup, run periodically?
    // Let's try to find matches that need it.
    
    // Simplification: Get X01 matches.
    final x01Matches = await (_db.select(_db.matches)
       ..where((m) => m.gameType.equals(GameType.x01.name))
       ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
       ..limit(50) // Process in chunks if needed
    ).get();

    for (final match in x01Matches) {
        final turns = await (_db.select(_db.turns)
           ..where((t) => t.matchId.equals(match.id))
           ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]) // Must be strictly ordered
        ).get();

        if (turns.isEmpty) continue;
        // If all have startingScore, skip
        if (turns.every((t) => t.startingScore != null)) continue;
        
        GameConfig config;
        try {
           config = GameConfig.fromJson(jsonDecode(match.settingsJson));
        } catch (e) {
           print('Error parsing match settings for ${match.id}: $e');
           config = const GameConfig(type: GameType.x01, x01Mode: X01Mode.game501);
        }

        final int startVal = config.x01Mode == X01Mode.game301 ? 301 : 501;

        // playerId -> currentScore
        // Note: we need to handle legs.
        Map<String, int> playerScores = {};
        
        int currentLeg = -1;
        
        await _db.batch((batch) {
             for (final turn in turns) {
                if (turn.legIndex != currentLeg) {
                   currentLeg = turn.legIndex;
                   playerScores.clear();
                }
                
                final pId = turn.playerId;
                final currentScore = playerScores[pId] ?? startVal;
                
                // Update DB
                if (turn.startingScore == null) {
                   batch.update(_db.turns, TurnsCompanion(
                      startingScore: Value(currentScore),
                   ), where: (row) => row.id.equals(turn.id));
                }
                
                // Calculate next state
                // We use the recorded 'score' as the truth for what happened.
                final turnScore = turn.score ?? turn.darts.fold<int>(0, (sum, d) => sum + d.total);
                
                // But we must respect Bust logic to know the score for NEXT turn.
                // If 'turnScore' in DB is already "effective score" (0 if bust), then we just subtract.
                // If 'turnScore' is raw thrown points even if bust, we need to detect bust.
                // Assuming raw thrown points is safer for history, implies we must check bust.
                
                int remaining = currentScore - turnScore;
                bool busted = false;
                
                if (remaining < 0) busted = true;
                else if (config.doubleOut && remaining == 1) busted = true;
                else if (remaining == 0 && config.doubleOut) {
                   // Check last dart. 
                   if (turn.darts.isNotEmpty && !turn.darts.last.isDouble) {
                      busted = true;
                   }
                }
                
                if (!busted) {
                   playerScores[pId] = remaining;
                }
                // if busted, score remains 'currentScore' for next turn.
             }
        });
    }
  }
}

