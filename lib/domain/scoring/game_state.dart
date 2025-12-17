import 'models.dart';
import 'player_state.dart';

class GameState {
  final Map<String, PlayerGameScore> playerScores;
  final List<String> playerOrder;
  final int currentPlayerIndex;
  final List<Turn> history;
  final GameConfig config;
  final String? winnerId;

  const GameState({
    required this.playerScores,
    required this.playerOrder,
    this.currentPlayerIndex = 0,
    required this.history,
    required this.config,
    this.winnerId,
  });

  String get currentPlayerId => playerOrder[currentPlayerIndex];

  GameState copyWith({
    Map<String, PlayerGameScore>? playerScores,
    int? currentPlayerIndex,
    List<Turn>? history,
    String? winnerId,
  }) {
    return GameState(
      playerScores: playerScores ?? this.playerScores,
      playerOrder: this.playerOrder,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      history: history ?? this.history,
      config: this.config,
      winnerId: winnerId ?? this.winnerId,
    );
  }
}
