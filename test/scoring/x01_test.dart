
import 'package:darts_app/domain/scoring/darts_scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('X01Engine', () {
    late X01Engine engine;
    late GameConfig config301;
    late GameConfig config501DoubleOut;

    setUp(() {
      engine = X01Engine();
      config301 = const GameConfig(
        type: GameType.x01,
        x01Mode: X01Mode.game301,
        doubleOut: false,
      );
      config501DoubleOut = const GameConfig(
        type: GameType.x01,
        x01Mode: X01Mode.game501,
        doubleOut: true,
      );
    });

    test('Initializes 301 game correctly', () {
      final state = engine.createInitialState(config301, ['p1', 'p2']);
      expect(state.playerScores.length, 2);
      expect((state.playerScores['p1'] as X01PlayerScore).remaining, 301);
      expect(state.currentPlayerId, 'p1');
    });

    test('Standard scoring reduces score', () {
      var state = engine.createInitialState(config301, ['p1']);
      final turn = Turn(playerId: 'p1', darts: [
        const Dart(value: 20, multiplier: 3), // 60
        const Dart(value: 20, multiplier: 1), // 20
        const Dart(value: 1, multiplier: 1),  // 1
      ]); // Total 81

      state = engine.applyTurn(state, turn);
      expect((state.playerScores['p1'] as X01PlayerScore).remaining, 301 - 81);
    });

    test('Turn switches player', () {
      var state = engine.createInitialState(config301, ['p1', 'p2']);
      final turn = Turn(playerId: 'p1', darts: [const Dart(value: 20, multiplier: 1)]);
      state = engine.applyTurn(state, turn);
      expect(state.currentPlayerId, 'p2');
    });

    test('Bust logic (score < 0)', () {
      // Setup player at 10
      // We can't manually set score easily without exposed API or mocking, 
      // but we can start 301 and hit 300 to get to 1. No, 300 is hard.
      // Let's just create a state manually? The state constructor is public.
      
      var state = engine.createInitialState(config301, ['p1']);
      state = state.copyWith(
        playerScores: {'p1': X01PlayerScore(10)},
      );

      // Hit 12 (T4)
      final turn = Turn(playerId: 'p1', darts: [const Dart(value: 4, multiplier: 3)]);
      state = engine.applyTurn(state, turn);

      // Should remain 10
      expect((state.playerScores['p1'] as X01PlayerScore).remaining, 10);
    });

    test('Win condition (Straight Out)', () {
      var state = engine.createInitialState(config301, ['p1']);
      state = state.copyWith(playerScores: {'p1': X01PlayerScore(10)});

      final turn = Turn(playerId: 'p1', darts: [const Dart(value: 10, multiplier: 1)]);
      state = engine.applyTurn(state, turn);

      expect((state.playerScores['p1'] as X01PlayerScore).remaining, 0);
      expect(state.winnerId, 'p1');
    });

    test('Double Out requirement', () {
      var state = engine.createInitialState(config501DoubleOut, ['p1']);
      state = state.copyWith(playerScores: {'p1': X01PlayerScore(40)}); // Need D20

      // Hit 20, 20 (Simulate straight hit totaling 40 but last not double)
      final turnFail = Turn(playerId: 'p1', darts: [
        const Dart(value: 20, multiplier: 1),
        const Dart(value: 20, multiplier: 1),
      ]);
      
      var nextState = engine.applyTurn(state, turnFail);
      expect((nextState.playerScores['p1'] as X01PlayerScore).remaining, 40, reason: "Should bust if last dart not double");

      // Hit D20
      final turnWin = Turn(playerId: 'p1', darts: [
        const Dart(value: 20, multiplier: 2),
      ]);
      
      nextState = engine.applyTurn(state, turnWin);
      expect((nextState.playerScores['p1'] as X01PlayerScore).remaining, 0);
      expect(nextState.winnerId, 'p1');
    });
  });
}
