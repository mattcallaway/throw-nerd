
import 'package:darts_app/domain/scoring/darts_scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CricketEngine', () {
    late CricketEngine engine;
    late GameConfig standardConfig;
    late GameConfig cutThroatConfig;

    setUp(() {
      engine = CricketEngine();
      standardConfig = const GameConfig(
        type: GameType.cricket,
        cutThroatCricket: false,
      );
      cutThroatConfig = const GameConfig(
        type: GameType.cricket,
        cutThroatCricket: true,
      );
    });

    test('Initializes with 0 marks', () {
      final state = engine.createInitialState(standardConfig, ['p1', 'p2']);
      final p1 = state.playerScores['p1'] as CricketPlayerScore;
      expect(p1.score, 0);
      expect(p1.marks[20], 0);
    });

    test('Standard: Marks accumulate', () {
      var state = engine.createInitialState(standardConfig, ['p1']);
      final turn = Turn(playerId: 'p1', darts: [
         const Dart(value: 20, multiplier: 1),
         const Dart(value: 20, multiplier: 1),
      ]);
      state = engine.applyTurn(state, turn);
      final p1 = state.playerScores['p1'] as CricketPlayerScore;
      expect(p1.marks[20], 2);
    });

    test('Standard: Scoring points after closing', () {
      var state = engine.createInitialState(standardConfig, ['p1', 'p2']);
      // p1 Hits T20, S20. (3 for close, 1 for points)
      final turn = Turn(playerId: 'p1', darts: [
        const Dart(value: 20, multiplier: 3),
        const Dart(value: 20, multiplier: 1),
      ]);
      
      state = engine.applyTurn(state, turn);
      final p1 = state.playerScores['p1'] as CricketPlayerScore;
      final p2 = state.playerScores['p2'] as CricketPlayerScore;

      expect(p1.marks[20], 3);
      expect(p1.score, 20); // got 20 points
      expect(p2.score, 0);  // p2 got nothing
    });

    test('Standard: No points if opponent also closed', () {
      var state = engine.createInitialState(standardConfig, ['p1', 'p2']);
      // Pre-close p2 20s
      state = state.copyWith(playerScores: {
        'p1': CricketPlayerScore(score: 0, marks: {20: 0}),
        'p2': CricketPlayerScore(score: 0, marks: {20: 3}), // Closed
      });
      // Fix full map for p1/p2 marks to avoid null errors if engine iterates all
      // We rely on default handling in test, but cleaner to just use engine for setup?
      // Engine setup sets all keys.
      
      // Let's use engine flow to close p2 first.
      var s = engine.createInitialState(standardConfig, ['p1', 'p2']);
      
      // P2 closes 20
      s = engine.applyTurn(s, Turn(playerId: 'p2', darts: [const Dart(value: 20, multiplier: 3)]));
      
      // P1 closes 20 and hits extra
      // Next turn is p1 usually, but let's force p1 ID
      s = engine.applyTurn(s, Turn(playerId: 'p1', darts: [
        const Dart(value: 20, multiplier: 3),
        const Dart(value: 20, multiplier: 1),
      ]));
      
      final p1 = s.playerScores['p1'] as CricketPlayerScore;
      expect(p1.marks[20], 3);
      expect(p1.score, 0); // No points because p2 is closed
    });

    test('Cut-Throat: Points go to opponent', () {
      var state = engine.createInitialState(cutThroatConfig, ['p1', 'p2']);
      
      // p1 closes 20 and scores
      final turn = Turn(playerId: 'p1', darts: [
        const Dart(value: 20, multiplier: 3),
        const Dart(value: 20, multiplier: 1),
      ]);
      
      state = engine.applyTurn(state, turn);
      final p1 = state.playerScores['p1'] as CricketPlayerScore;
      final p2 = state.playerScores['p2'] as CricketPlayerScore;

      expect(p1.score, 0); // Self score stays 0
      expect(p2.score, 20); // Opponent gets points (bad for them)
    });
  });
}
