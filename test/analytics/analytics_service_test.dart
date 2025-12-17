
import 'package:flutter_test/flutter_test.dart';
import 'package:darts_app/services/analytics/analytics_service.dart';
import 'package:darts_app/data/repositories/analytics_repository.dart';
import 'package:darts_app/domain/analytics/analytics_models.dart';
import 'package:darts_app/domain/scoring/models.dart';
import 'package:mockito/mockito.dart';

// Mock Repository
class MockAnalyticsRepository extends Fake implements AnalyticsRepository {
  final Map<String, num> basicStats;
  final double first9Avg;
  final List<TurnData> rawTurns;

  MockAnalyticsRepository({
    this.basicStats = const {'avg3': 50.0, 'highestTurn': 180, 'totalDarts': 30, 'totalScore': 500},
    this.first9Avg = 60.0,
    required this.rawTurns,
  });

  @override
  Future<Map<String, num>> getX01BasicStats(String playerId, {DateTime? since}) async {
    return basicStats;
  }

  @override
  Future<double> getFirst9Avg(String playerId, {DateTime? since}) async {
    return first9Avg;
  }

  @override
  Future<List<TurnData>> getRawTurns(String playerId, {GameType? type, DateTime? since, int limit = 2000}) async {
    // If type is cricket, return empty for this test unless we want to test cricket integration
    if (type == GameType.cricket) return [];
    return rawTurns;
  }
  
  @override
  Future<void> backfillHistoricalData() async {
    // No-op for mock
  }
}

void main() {
  group('AnalyticsService Checkout Stats', () {
    test('Calculates checkout accuracy correctly for D20 sequence', () async {
      // Scenario: Player at 40 (D20).
      // Throws S20 (rem 20), S10 (rem 10), D5 (Win).
      // Expected: 3 attempts (40, 20, 10 are all checkout numbers), 1 hit.
      
      final turn = TurnData(
        matchId: 'm1',
        darts: [
           const Dart(value: 20, multiplier: 1), // S20
           const Dart(value: 10, multiplier: 1), // S10
           const Dart(value: 5, multiplier: 2),  // D5
        ],
        score: 40, // 20+10+10
        gameType: GameType.x01,
        createdAt: DateTime.now(),
        startingScore: 40,
      );

      final repo = MockAnalyticsRepository(rawTurns: [turn]);
      final service = AnalyticsService(repo);

      final metrics = await service.getPlayerMetrics('p1');

      expect(metrics.checkoutAccuracy, closeTo(33.33, 0.01)); // 1/3
      expect(metrics.checkoutCount, 1);
    });

    test('Calculates 0% accuracy for missed checkouts', () async {
      // Scenario: Player at 32 (D16). Takes 3 darts, misses all.
      // S16 (rem 16), S8 (rem 8), S4 (rem 4).
      // All remainders (32, 16, 8) are checkout numbers. 3 Attempts. 0 Hits.
      
      final turn = TurnData(
        matchId: 'm1',
        darts: [
           const Dart(value: 16, multiplier: 1), // S16 -> 16 left
           const Dart(value: 8, multiplier: 1),  // S8 -> 8 left
           const Dart(value: 4, multiplier: 1),  // S4 -> 4 left
        ],
        score: 28,
        gameType: GameType.x01,
        createdAt: DateTime.now(),
        startingScore: 32,
      );

      final repo = MockAnalyticsRepository(rawTurns: [turn]);
      final service = AnalyticsService(repo);

      final metrics = await service.getPlayerMetrics('p1');

      expect(metrics.checkoutAccuracy, 0.0);
      expect(metrics.checkoutCount, 0); // Not a finish
    });

    test('Does not count non-checkout numbers as attempts', () async {
      // Scenario: Player at 501. Throws T20.
      // 501 is not checkout. T20 -> 441.
      // 0 Attempts.
      
      final turn = TurnData(
        matchId: 'm1',
        darts: [const Dart(value: 20, multiplier: 3)],
        score: 60,
        gameType: GameType.x01,
        createdAt: DateTime.now(),
        startingScore: 501,
      );

      final repo = MockAnalyticsRepository(rawTurns: [turn]);
      final service = AnalyticsService(repo);

      final metrics = await service.getPlayerMetrics('p1');

      // Wait, getPlayerMetrics iterates? If attempts = 0, accuracy is 0.
      // But we should verify checkoutCount is 0.
      expect(metrics.checkoutCount, 0);
      expect(metrics.checkoutAccuracy, 0.0);
    });

    test('Counts Bull (50) as attempt', () async {
      // Scenario: Player at 50. Throws Bull (D25) -> Win.
      // 1 Attempt. 1 Hit.
      
      final turn = TurnData(
        matchId: 'm1',
        darts: [const Dart(value: 25, multiplier: 2)],
        score: 50,
        gameType: GameType.x01,
        createdAt: DateTime.now(),
        startingScore: 50,
      );

      final repo = MockAnalyticsRepository(rawTurns: [turn]);
      final service = AnalyticsService(repo);

      final metrics = await service.getPlayerMetrics('p1');

      expect(metrics.checkoutCount, 1);
      expect(metrics.checkoutAccuracy, 100.0);
    });
  });
}
