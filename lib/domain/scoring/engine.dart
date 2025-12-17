import 'game_state.dart';
import 'models.dart';

abstract class GameEngine {
  GameState createInitialState(GameConfig config, List<String> playerIds);
  
  /// Applies a single turn to the state and returns the new state.
  /// This should handle:
  /// - Updating scores
  /// - Checking win conditions
  /// - advancing to next player (if game not over)
  GameState applyTurn(GameState currentState, Turn turn);
}
