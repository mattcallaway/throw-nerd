import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/game_match.dart';
import '../../domain/scoring/darts_scoring.dart';
import '../../domain/interfaces/i_match_repository.dart';
import 'di_providers.dart';
import 'package:uuid/uuid.dart';
import '../../services/league/league_sync_service.dart';

enum MatchEvent { none, bust, legWon, matchWon }

// State Class
class ActiveMatchState {
  final GameMatch? match;
  final GameState? gameState;
  final List<Dart> currentTurnDarts;
  final int currentLeg;
  final int currentSet; // NEW
  final int globalLegIndex; // NEW
  final Map<String, int> legsWon;
  final Map<String, int> setsWon; // NEW
  final bool isMatchOver;
  final MatchEvent lastEvent;

  const ActiveMatchState({
    this.match,
    this.gameState,
    this.currentTurnDarts = const [],
    this.currentLeg = 1,
    this.currentSet = 1,
    this.globalLegIndex = 1,
    this.legsWon = const {},
    this.setsWon = const {},
    this.isMatchOver = false,
    this.lastEvent = MatchEvent.none,
  });

  ActiveMatchState copyWith({
    GameMatch? match,
    GameState? gameState,
    List<Dart>? currentTurnDarts,
    int? currentLeg,
    int? currentSet,
    int? globalLegIndex,
    Map<String, int>? legsWon,
    Map<String, int>? setsWon,
    bool? isMatchOver,
    MatchEvent? lastEvent,
  }) {
    return ActiveMatchState(
      match: match ?? this.match,
      gameState: gameState ?? this.gameState,
      currentTurnDarts: currentTurnDarts ?? this.currentTurnDarts,
      currentLeg: currentLeg ?? this.currentLeg,
      currentSet: currentSet ?? this.currentSet,
      globalLegIndex: globalLegIndex ?? this.globalLegIndex,
      legsWon: legsWon ?? this.legsWon,
      setsWon: setsWon ?? this.setsWon,
      isMatchOver: isMatchOver ?? this.isMatchOver,
      lastEvent: lastEvent ?? this.lastEvent,
    );
  }
}

// Notifier
class ActiveMatchNotifier extends StateNotifier<ActiveMatchState> {
  final IMatchRepository _matchRepo;
  final LeagueSyncService _syncService;
  GameEngine? _engine;
  
  ActiveMatchNotifier(this._matchRepo, this._syncService) : super(const ActiveMatchState());

  Future<void> startMatch(GameConfig config, List<String> playerIds, String? locationId, {String? leagueId}) async {
    final matchId = const Uuid().v4();
    final match = GameMatch(
      id: matchId,
      config: config,
      playerIds: playerIds,
      createdAt: DateTime.now(),
      locationId: locationId,
      leagueId: leagueId,
    );

    // Persist Match
    await _matchRepo.createMatch(match);

    // Initialize Engine
    if (config.type == GameType.x01) {
      _engine = X01Engine();
    } else if (config.type == GameType.cricket) {
      _engine = CricketEngine();
    } else {
      // Blank/Other
      _engine = X01Engine(); // Fallback or implement BlankEngine
    }
    
    final initialState = _engine!.createInitialState(config, playerIds);
    
    state = ActiveMatchState(
      match: match,
      gameState: initialState,
      currentTurnDarts: [],
      currentLeg: 1,
      currentSet: 1,
      globalLegIndex: 1,
      legsWon: {for (var p in playerIds) p: 0},
      setsWon: {for (var p in playerIds) p: 0},
    );
  }

  void addDart(Dart dart) {
    if (state.isMatchOver || state.gameState == null) return;
    
    final currentDarts = List<Dart>.from(state.currentTurnDarts)..add(dart);
    
    // Check constraints before committing
    // X01 Bust Check (Need to peek at score)
    bool shouldCommit = false;
    
    if (state.match!.config.type == GameType.x01) {
       final playerId = state.gameState!.currentPlayerId;
       final scoreObj = state.gameState!.playerScores[playerId] as X01PlayerScore;
       int remainder = scoreObj.remaining;
       // Subtract previous darts in this turn
       // Actually 'remaining' in GameState is at start of turn (since we haven't applied it yet).
       // Correct.
       
       int turnTotal = currentDarts.fold(0, (sum, d) => sum + d.total);
       int result = remainder - turnTotal;
       
    if (result < 0 || (result == 0 && !_isValidFinish(dart, state.match!.config)) || (result == 1 && _isDoubleMasterOut(state.match!.config))) {
         // Bust!
         shouldCommit = true;
         // We set event here, but commitTurn overwrites state.
         // We need commitTurn to accept an event or set it after.
    } else if (result == 0) {
         // Winner
         shouldCommit = true;
    }
    } // End X01 Logic
    
    if (currentDarts.length == 3) {
      shouldCommit = true;
    }

    state = state.copyWith(currentTurnDarts: currentDarts, lastEvent: MatchEvent.none); // Reset event on add?
    
    if (shouldCommit) {
       // Re-evaluate bust for the event
       // Or pass it.
       commitTurn();
    }
  }
  
  bool _isValidFinish(Dart lastDart, GameConfig config) {
    if (config.doubleOut && lastDart.isDouble) return true;
    if (config.masterOut && (lastDart.isDouble || lastDart.isTriple)) return true;
    if (!config.doubleOut && !config.masterOut) return true;
    return false;
  }
  
  bool _isDoubleMasterOut(GameConfig config) => config.doubleOut || config.masterOut;

  void undoLastDart() {
    if (state.currentTurnDarts.isNotEmpty) {
      // Simple Undo: just pop the last dart
      final newDarts = List<Dart>.from(state.currentTurnDarts)..removeLast();
      state = state.copyWith(currentTurnDarts: newDarts);
    } else if (state.gameState != null && state.gameState!.history.isNotEmpty) {
      // Complex Undo: Rewind to previous turn
      final history = List<Turn>.from(state.gameState!.history);
      final lastTurn = history.removeLast(); // Pop last turn
      
      // 1. Replay history to get base state
      // We must rotate players correctly if we are traversing legs? 
      // V1: We assume we are in the SAME leg. 
      // If we just finished a leg, can we undo?
      // If `winnerId` is set, we are in "Leg Finished" state. 
      // Auto-advance might have happened. This is tricky.
      // If we auto-advanced, `history` in the NEW leg is empty.
      
      if (state.gameState!.history.isEmpty && state.globalLegIndex > 1) {
         // We just started a new leg. Can we go back to previous leg?
         // This implies reloading the previous leg's history.
         // For V1, let's LIMIT undo to within the current leg.
         return; 
      }
      
      // Reconstitute State from scratch for this Leg
      // We need the original player order for this leg.
      // Derived from `state.globalLegIndex` and `state.match.playerIds`.
      final starterIndex = (state.globalLegIndex - 1) % state.match!.playerIds.length;
      final rotatedIds = List<String>.from(state.match!.playerIds);
      for(int i=0; i<starterIndex; i++) {
        rotatedIds.add(rotatedIds.removeAt(0));
      }
      
      GameState newState = _engine!.createInitialState(state.match!.config, rotatedIds);
      
      // Apply all turns except the last one
      for (final t in history) {
        newState = _engine!.applyTurn(newState, t);
      }
      
      // 2. Set the "Current Darts" to the popped turn's darts (minus one?)
      // User tapped "Undo". They want to go back to "Before I threw that last dart".
      // If the last turn was valid and complete (3 darts or finished), we now open it back up.
      // But wait! If they tap Undo, do they want to edit the WHOLE turn or just the last dart of that turn?
      // "Undo" usually implies "Undo last action".
      // Last action was "Commit Turn".
      // So Undo reverses "Commit Turn" -> We are back to "Holding 3 darts".
      // Then if they tap Undo AGAIN, it removes 1 dart.
      // Ideally, specific request: "undo should revert to the previous player and reopen their turn state"
      
      state = state.copyWith(
        gameState: newState, // State without the last turn
        currentTurnDarts: lastTurn.darts, // Restore the darts
      );
      
      // Note: We do NOT remove the last dart here. 
      // We explicitly put them back in "Editing" mode. 
      // The user can then tap Undo again to remove the bad dart.
      // This is safer and clearer.
    }
  }

  Future<void> commitTurn() async {
    // ... (Bust Check Logic Same as before)
    // Redundant bust check for safety
    MatchEvent event = MatchEvent.none;
    if (state.match!.config.type == GameType.x01) {
       final playerId = state.gameState!.currentPlayerId;
       // We must use the snapshot state, not current (which doesn't include current darts)
       final scoreObj = state.gameState!.playerScores[playerId] as X01PlayerScore;
       int total = state.currentTurnDarts.fold(0, (s, d) => s + d.total);
       int remainder = scoreObj.remaining - total;
       if (remainder < 0 || (remainder <= 1 && _isDoubleMasterOut(state.match!.config) && remainder != 0) || (remainder == 0 && !_isValidFinish(state.currentTurnDarts.last, state.match!.config))) {
          event = MatchEvent.bust;
       }
    }

    final turn = Turn(
      playerId: state.gameState!.currentPlayerId,
      darts: state.currentTurnDarts,
    );
    
    int? startingScore;
    if (state.match!.config.type == GameType.x01) {
       final playerId = state.gameState!.currentPlayerId;
       // Assuming playerScores holds X01PlayerScore if type is x01
       if (state.gameState!.playerScores[playerId] is X01PlayerScore) {
          startingScore = (state.gameState!.playerScores[playerId] as X01PlayerScore).remaining;
       }
    }

    // Save to DB
    await _matchRepo.saveTurn(
      state.match!.id,
      turn,
      state.currentLeg,
      state.currentSet,
      state.gameState!.history.length + 1,
      startingScore: startingScore,
    );

    final newState = _engine!.applyTurn(state.gameState!, turn);
    
    state = state.copyWith(
      gameState: newState,
      currentTurnDarts: [],
      lastEvent: event,
    );
    
    _checkLegWinner();
  }
  
  void _checkLegWinner() {
    if (state.gameState!.winnerId != null) {
      final winner = state.gameState!.winnerId!;
      final newLegsWon = Map<String, int>.from(state.legsWon);
      newLegsWon[winner] = (newLegsWon[winner] ?? 0) + 1;
      
      // Best Of Calculation
      final legsToWinSet = (state.match!.config.legs / 2).floor() + 1;
      
      if (newLegsWon[winner]! >= legsToWinSet) {
         // Set Won
         final newSetsWon = Map<String, int>.from(state.setsWon);
         newSetsWon[winner] = (newSetsWon[winner] ?? 0) + 1;
         
         final setsToWinMatch = (state.match!.config.sets / 2).floor() + 1;
         
         if (newSetsWon[winner]! >= setsToWinMatch) {
            // Match Won
            state = state.copyWith(legsWon: newLegsWon, setsWon: newSetsWon, isMatchOver: true, lastEvent: MatchEvent.matchWon);
            _matchRepo.updateMatchStatus(state.match!.id, finishedAt: DateTime.now(), winnerId: winner);
            
            if (state.match!.leagueId != null) {
               _syncService.uploadMatchForLeague(state.match!.id, state.match!.leagueId!);
            }
         } else {
            // Set Won -> New Set
            state = state.copyWith(legsWon: newLegsWon, setsWon: newSetsWon, lastEvent: MatchEvent.legWon);
            _advanceGame(newSet: true);
         }
      } else {
         // Leg Won only
         state = state.copyWith(legsWon: newLegsWon, lastEvent: MatchEvent.legWon);
         _advanceGame(newSet: false);
      }
    }
  }
  
  void clearEvent() {
    state = state.copyWith(lastEvent: MatchEvent.none);
  }

  void _advanceGame({required bool newSet}) {
     final config = state.match!.config;
     
     int nextLeg = state.currentLeg;
     int nextSet = state.currentSet;
     int nextGlobalLeg = state.globalLegIndex + 1;
     Map<String, int> nextLegsWon = state.legsWon;

     if (newSet) {
       nextSet++;
       nextLeg = 1;
       nextLegsWon = {for (var p in state.match!.playerIds) p: 0};
     } else {
       nextLeg++;
     }

     int starterIndex = (nextGlobalLeg - 1) % state.match!.playerIds.length;
     
     List<String> newOrder = List.from(state.match!.playerIds);
     for(int i=0; i<starterIndex; i++) {
       newOrder.add(newOrder.removeAt(0));
     }
     
     final newState = _engine!.createInitialState(config, newOrder);
     
     state = state.copyWith(
       gameState: newState,
       currentLeg: nextLeg,
       currentSet: nextSet,
       globalLegIndex: nextGlobalLeg,
       legsWon: nextLegsWon, 
       currentTurnDarts: [],
     );
  }
}

final activeMatchProvider = StateNotifierProvider<ActiveMatchNotifier, ActiveMatchState>((ref) {
  return ActiveMatchNotifier(
    ref.watch(matchRepositoryProvider),
    ref.watch(leagueSyncServiceProvider),
  );
});
