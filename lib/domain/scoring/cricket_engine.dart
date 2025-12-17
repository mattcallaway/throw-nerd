import 'engine.dart';
import 'game_state.dart';
import 'models.dart';
import 'player_state.dart';

class CricketEngine implements GameEngine {
  static const List<int> targets = [15, 16, 17, 18, 19, 20, 25];

  @override
  GameState createInitialState(GameConfig config, List<String> playerIds) {
    // Initialize marks to 0 for all targets
    final initialMarks = {for (var t in targets) t: 0};
    
    final scores = {
      for (var id in playerIds) 
        id: CricketPlayerScore(score: 0, marks: Map.from(initialMarks))
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

    final currentPlayerId = turn.playerId;
    // We need mutable copies to update
    final newPlayerScores = <String, CricketPlayerScore>{};
    currentState.playerScores.forEach((key, value) {
      final cp = value as CricketPlayerScore;
      newPlayerScores[key] = CricketPlayerScore(score: cp.score, marks: Map.from(cp.marks));
    });

    final currentStats = newPlayerScores[currentPlayerId]!;
    
    for (final dart in turn.darts) {
      if (!targets.contains(dart.value)) continue; // Miss or non-target (e.g. 1-14)

      int hits = dart.multiplier;
      int number = dart.value;
      
      // Update marks
       int currentMarks = currentStats.marks[number] ?? 0;
       
       // Calculate "scoring marks" (marks beyond 3)
       int scoringHits = 0;
       
       if (currentMarks + hits > 3) {
         if (currentMarks >= 3) {
           scoringHits = hits;
         } else {
           scoringHits = (currentMarks + hits) - 3;
           // Cap marks at 3? Or keep tracking?
           // Usually tracked as 3 for "closed", but logical state might need to know if we just closed it.
           // Standard: once closed, marks don't strictly matter, just points.
           // But let's cap at 3 in storage for simplicity, points handled immediately.
         }
       }
       
       // Update marks (cap at 3 for storage logic, though physically hitting more doesn't add 'marks' per se)
       currentStats.marks[number] = (currentMarks + hits).clamp(0, 3);
       
       if (scoringHits > 0) {
         // Check if closed by all relevant opponents to determine if points are scored
         bool closedByAll = true;
         for (var pid in currentState.playerOrder) {
             // In Standard: We score if WE have closed, and at least one opponent hasn't. 
             // Wait, no. If I close 20, and Opponent hasn't, I can score on 20.
             // If ALL opponents closed 20, I cannot score.
             
             // In Cut-throat: I give points to opponents who haven't closed.
             if (pid == currentPlayerId) continue;
             
             final oppMarks = newPlayerScores[pid]!.marks[number] ?? 0;
             if (oppMarks < 3) {
               closedByAll = false;
               break;
             }
         }
         
         if (!closedByAll) {
           if (currentState.config.cutThroatCricket) {
             // Add points to opponents who haven't closed
             for (var pid in currentState.playerOrder) {
               if (pid == currentPlayerId) continue;
               final opp = newPlayerScores[pid]!;
               if ((opp.marks[number] ?? 0) < 3) {
                 newPlayerScores[pid] = CricketPlayerScore(
                   score: opp.score + (scoringHits * number),
                   marks: opp.marks
                 );
               }
             }
           } else {
             // Standard: Add points to self
             newPlayerScores[currentPlayerId] = CricketPlayerScore(
               score: currentStats.score + (scoringHits * number),
               marks: currentStats.marks
             );
             // Update reference for next dart loop
             // currentStats is a reference to the object in the map? No, I replaced it in the map.
             // But valid reference 'currentStats' is becoming stale relative to score.
             // Marks are map, so mutability works if I mutate the map.
             // But score is final.
             
             // Ah, I need to update 'currentStats' variable if I replace the object in map.
             // Actually, cleaner: Track score accumulation in a local var, update object at end?
             // No, because cut-throat updates OTHERS.
             
             // Let's re-fetch or keep updated.
             currentStats.marks[number] = (currentMarks + hits).clamp(0, 3); // marks map is mutable, shared? 
             // I did Map.from, so it is a new map.
             // But I replaced the CricketPlayerScore in the map.
             
             // Re-assignment strategy:
             // To support Standard scoring (self score) inside the loop:
             // I need to update my local 'currentStats' score if I add points.
             // Since 'score' is final, I need to replace 'currentStats' object.
             
              newPlayerScores[currentPlayerId] = CricketPlayerScore(
               score: newPlayerScores[currentPlayerId]!.score + (scoringHits * number),
               marks: newPlayerScores[currentPlayerId]!.marks
             );
           }
         }
       } else {
          // Just adding marks, no scoring checks needed (already updated marks map)
       }
    }

    // Check Win Condition
    // 1. Player has all numbers closed.
    // 2. Player has best score (>= others in Standard, <= others in Cut-throat)
    
    // Check if current player has all closed
    bool allClosed = true;
    final finalCurrentStats = newPlayerScores[currentPlayerId]!;
    for (var t in targets) {
      if ((finalCurrentStats.marks[t] ?? 0) < 3) {
        allClosed = false;
        break;
      }
    }

    bool won = false;
    if (allClosed) {
      if (currentState.config.cutThroatCricket) {
        // Must have lowest score (or equal lowest)
        bool hasLowest = true;
        for (var pid in currentState.playerOrder) {
          if (pid == currentPlayerId) continue;
          if (newPlayerScores[pid]!.score < finalCurrentStats.score) {
            hasLowest = false;
            break;
          }
        }
        if (hasLowest) won = true;
      } else {
        // Standard: Must have highest score
        bool hasHighest = true;
        for (var pid in currentState.playerOrder) {
           if (pid == currentPlayerId) continue;
           if (newPlayerScores[pid]!.score > finalCurrentStats.score) {
             hasHighest = false;
             break;
           }
        }
        if (hasHighest) won = true;
      }
    }
    
    int nextPlayerIndex = currentState.currentPlayerIndex;
    if (!won) {
       nextPlayerIndex = (currentState.currentPlayerIndex + 1) % currentState.playerOrder.length;
    }

    List<Turn> newHistory = List.from(currentState.history)..add(turn);

    return currentState.copyWith(
      playerScores: newPlayerScores,
      currentPlayerIndex: nextPlayerIndex,
      history: newHistory,
      winnerId: won ? currentPlayerId : null,
    );
  }
}
