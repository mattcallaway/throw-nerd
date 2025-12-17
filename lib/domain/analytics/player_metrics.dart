class PlayerMetrics {
  final double avg3Dart;
  final double avgFirst9;
  final int highestTurn;
  final int bestLegDarts; // Least darts to win
  final int checkoutCount;
  final double checkoutAccuracy; // Inferred %
  final double consistency; // StdDev
  final int totalDarts;
  final int totalScore;

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
  });
}
