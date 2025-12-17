import '../scoring/models.dart'; // For GameType, Dart

class TurnData {
  final String matchId;
  final List<Dart> darts;
  final int score;
  final GameType gameType;
  final DateTime createdAt;
  final int? startingScore;
  
  TurnData({
    required this.matchId,
    required this.darts,
    required this.score,
    required this.gameType,
    required this.createdAt,
    this.startingScore,
  });
}

class SegmentStats {
  final Map<String, int> distribution; // Key format: "20-1" (Single 20), "20-3" (Triple), "25-1" (Bull), "50-1" (DBull), "0-0" (Miss)
  
  const SegmentStats({required this.distribution});
}

class PlayerMetrics {
  final double avg3Dart;
  final double avgFirst9;
  final int highestTurn;
  final int bestLegDarts;
  final int checkoutCount;
  final double checkoutAccuracy;
  final double consistency;
  final int totalDarts;
  final int totalScore;
  final List<TurnData> recentHistory;
  final SegmentStats? segmentStats; // Optional if not computed
  final double mpr;
  final int cricketGamesPlayed;

  const PlayerMetrics({
    this.avg3Dart = 0.0,
    this.avgFirst9 = 0.0,
    this.highestTurn = 0,
    this.bestLegDarts = 0,
    this.checkoutCount = 0,
    this.checkoutAccuracy = 0.0,
    this.consistency = 0.0,
    this.totalDarts = 0,
    this.totalScore = 0,
    this.recentHistory = const [],
    this.segmentStats,
    this.mpr = 0.0,
    this.cricketGamesPlayed = 0,
  });
}
