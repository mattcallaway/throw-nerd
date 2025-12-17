import 'package:flutter_test/flutter_test.dart';
import 'package:darts_app/domain/scoring/game_state.dart';
import 'package:darts_app/domain/scoring/models.dart';
import 'package:darts_app/domain/scoring/stats.dart';

void main() {
  group('StatsCalculator', () {
    test('Calculates simple average correctly', () {
      final config = GameConfig(type: GameType.x01);
      final history = [
        Turn(playerId: 'p1', darts: [
           Dart(value: 20, multiplier: 3), // 60
           Dart(value: 20, multiplier: 1), // 20
           Dart(value: 1, multiplier: 1),  // 1
        ]) // Total 81
      ];
      
      final state = GameState(
        config: config, 
        playerScores: {}, 
        playerOrder: ['p1'], 
        currentPlayerIndex: 0, 
        history: history
      );
      
      final stats = StatsCalculator.calculate(state, 'p1');
      
      expect(stats.average, 81.0); // 1 turn, 81 avg
      expect(stats.highestTurn, 81);
      expect(stats.first9Average, 81.0);
      expect(stats.triplesHit, 1);
    });

    test('Calculates MPR correctly for Cricket', () {
      final config = GameConfig(type: GameType.cricket);
      final history = [
        Turn(playerId: 'p1', darts: [
           Dart(value: 20, multiplier: 3), // 3 marks
           Dart(value: 19, multiplier: 2), // 2 marks
           Dart(value: 1, multiplier: 1),  // 0 marks
        ]), // 5 marks, 3 darts
        Turn(playerId: 'p1', darts: [
           Dart(value: 18, multiplier: 1), // 1 mark
           Dart(value: 17, multiplier: 1), // 1 mark
           Dart(value: 16, multiplier: 1), // 1 mark
        ]) // 3 marks, 3 darts
      ];
      
      // Total 8 marks in 6 darts. MPR = (8/6)*3 = 4.0
      
      final state = GameState(
        config: config, 
        playerScores: {}, 
        playerOrder: ['p1'], 
        currentPlayerIndex: 0, 
        history: history
      );
      
      final stats = StatsCalculator.calculate(state, 'p1');
      
      expect(stats.mpr, 4.0);
    });
  });
}
