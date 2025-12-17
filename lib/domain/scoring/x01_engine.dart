import 'engine.dart';
import 'game_state.dart';
import 'models.dart';
import 'player_state.dart';

class X01Engine implements GameEngine {
  @override
  GameState createInitialState(GameConfig config, List<String> playerIds) {
    int startScore = 501;
    if (config.x01Mode == X01Mode.game301) startScore = 301;
    // Add other modes if needed

    final scores = {
      for (var id in playerIds) id: X01PlayerScore(startScore)
    };

    return GameState(
      playerScores: scores,
      playerOrder: playerIds,
      history: [],
      config: config,
    );
  }

  @override
  GameState applyTurn(GameState currentState, Turn turn) {
    if (currentState.winnerId != null) return currentState;

    final currentScoreObj = currentState.playerScores[turn.playerId] as X01PlayerScore;
    int currentScore = currentScoreObj.remaining;

    // Check Start Condition (Double In)
    // If Double In is on, player needs to hit a double to start scoring.
    // If they haven't started yet, only darts AFTER the first double count.
    
    // Actually, state needs to track if player has "stepped in".
    // For simplicity V1, let's assume standard handling or maybe minimal state enhancement.
    // Standard Double In: No points count until a double is hit. The double counts.
    // We can infer "has started" if score < startScore. EXCEPT if they started and went back to startScore (unlikely/impossible without undo).
    // Or we simply check each turn: if score == startScore, we look for double.
    
    bool hasStarted = true; // Default true if no double-in
    if (currentState.config.doubleIn) {
       // Logic to determine if already started.
       // Simplest: Check if score is different from Initial.
       int startValue = 301;
       if (currentState.config.x01Mode == X01Mode.game501) startValue = 501;
       if (currentScore == startValue) {
         hasStarted = false;
       }
    }

    int pointsScored = 0;
    bool busted = false;
    bool won = false;
    
    // Process darts one by one to handle "Double In" within a turn or "Bust" mid-turn
    int tempScore = currentScore;
    
    for (final dart in turn.darts) {
       if (!hasStarted) {
         if (dart.isDouble) {
           hasStarted = true;
           // The double counts
           tempScore -= dart.total;
         } else {
           // Dart ignored
           continue; 
         }
       } else {
         tempScore -= dart.total;
       }

       // Check Bust / Win
       if (tempScore < 0) {
         busted = true;
         break;
       } else if (tempScore == 0) {
         // Check Out condition
         bool isDoubleOut = currentState.config.doubleOut;
         bool isMasterOut = currentState.config.masterOut;
         
         bool validOut = false;
         if (isDoubleOut && dart.isDouble) validOut = true;
         else if (isMasterOut && (dart.isDouble || dart.isTriple)) validOut = true;
         else if (!isDoubleOut && !isMasterOut) validOut = true; // Straight out

         if (validOut) {
           won = true;
           break; // Game Over
         } else {
           busted = true; // Reached 0 but invalid double
           break;
         }
       } else if (tempScore == 1) {
         // If Double Out or Master Out is on, you cannot reach 1.
         // Because minimum double is 2.
         if (currentState.config.doubleOut || currentState.config.masterOut) {
           busted = true;
           break;
         }
       }
    }

    // Finalize Turn Result
    int newScoreValue;
    if (busted) {
      newScoreValue = currentScore; // Revert to start of turn
    } else {
      newScoreValue = tempScore;
    }

    // Update Player Score
    final newScores = Map<String, PlayerGameScore>.from(currentState.playerScores);
    newScores[turn.playerId] = X01PlayerScore(newScoreValue);

    // Determine Next Player
    // If won, no next player.
    // If match settings say "Alternate start", that's handled at Match/Leg level, here we just cycle list.
    int nextPlayerIndex = currentState.currentPlayerIndex;
    if (!won) {
       nextPlayerIndex = (currentState.currentPlayerIndex + 1) % currentState.playerOrder.length;
    }

    List<Turn> newHistory = List.from(currentState.history)..add(turn);

    return currentState.copyWith(
      playerScores: newScores,
      currentPlayerIndex: nextPlayerIndex,
      history: newHistory,
      winnerId: won ? turn.playerId : null,
    );
  }

  @override
  GameState undoLastTurn(GameState state) {
     // This is handled by the higher level manager usually, by popping history and re-applying.
     // But if we had to do it here, we would need the previous state.
     // Since we don't store previous state reference, we can't easily undo without re-simulation.
     throw UnimplementedError("Undo should be handled by state reconstruction.");
  }
}
