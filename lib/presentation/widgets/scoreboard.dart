import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/scoring/darts_scoring.dart';
import '../../domain/scoring/checkout_calculator.dart'; // Hints
import '../../domain/scoring/stats.dart';
import '../providers/active_match_notifier.dart';
import '../providers/di_providers.dart';
import '../theme/app_themes.dart'; // Colors

class Scoreboard extends ConsumerWidget {
  final ActiveMatchState state;
  const Scoreboard({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
     final type = state.match!.config.type;
     if (type == GameType.x01) {
       return _X01Scoreboard(state: state);
     } else if (type == GameType.cricket) {
       return _CricketScoreboard(state: state);
     }
     return const Center(child: Text('Unknown Mode'));
  }
}

class _X01Scoreboard extends ConsumerWidget {
  final ActiveMatchState state;
  const _X01Scoreboard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch Theme
    final theme = ref.watch(appThemeProvider);
    
    if (state.gameState == null) return const SizedBox();
    
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: state.match!.playerIds.length,
      itemBuilder: (context, index) {
        final pid = state.match!.playerIds[index];
        final isActive = state.gameState!.currentPlayerId == pid;
        final playerScore = state.gameState!.playerScores[pid] as X01PlayerScore;
        
        // Checkout Hints
        List<String> checkoutHints = [];
        if (isActive && playerScore.remaining <= 170) {
           final dartsLeft = 3 - state.currentTurnDarts.length;
           if (dartsLeft > 0) {
             checkoutHints = CheckoutCalculator.getCheckoutSuggestion(
                playerScore.remaining, 
                darts: dartsLeft,
                doubleOut: state.match!.config.doubleOut,
             );
           }
        }
          
        final legsWon = state.legsWon[pid] ?? 0;
        final legsToWin = state.match!.config.legs;

        return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? theme.activePlayerBackground : Colors.transparent,
        border: Border.all(
          color: isActive ? theme.activePlayerBorder : Colors.white12, 
          width: isActive ? 3 : 1
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isActive && theme.mode == AppThemeMode.neon ? [
           BoxShadow(color: theme.activePlayerBorder.withOpacity(0.5), blurRadius: 12, spreadRadius: 1)
        ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.match!.config.sets > 1)
             Padding(
               padding: const EdgeInsets.only(bottom: 4),
               child: Text('Sets: ${state.setsWon[pid] ?? 0}', style: TextStyle(color: theme.scoreColor, fontWeight: FontWeight.bold, fontSize: 12)),
             ),
          _LegIndicators(total: legsToWin, current: legsWon, color: theme.playerColors[index % theme.playerColors.length]),
          _PlayerName(playerId: pid, isActive: isActive, color: theme.playerColors[index % theme.playerColors.length]),
          const SizedBox(height: 12),
              
              // Animated Score
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: playerScore.remaining, end: playerScore.remaining),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutExpo,
                builder: (ctx, value, child) {
                  return Text(
                    '$value', 
                    style: TextStyle(
                      fontSize: 56, 
                      fontWeight: FontWeight.bold,
                      color: theme.scoreColor,
                      shadows: theme.mode == AppThemeMode.neon ? [
                        BoxShadow(color: theme.scoreColor.withOpacity(0.8), blurRadius: 8)
                      ] : null,
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 8),
              
                  if (isActive && checkoutHints.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      checkoutHints.join('  '),
                      style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),

                if (state.isMatchOver && state.gameState!.winnerId == pid)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Icon(Icons.emoji_events, color: Colors.yellow, size: 40),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _CricketScoreboard extends ConsumerWidget {
  final ActiveMatchState state;
  const _CricketScoreboard({required this.state});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final targets = [20, 19, 18, 17, 16, 15, 25];
    final players = state.match!.playerIds;
    
    return Row(
      children: [
        // Numbers Column
        Column(
           children: [
             const SizedBox(height: 40), // Header spacer
             ...targets.map((t) => Expanded(
                 child: Center(child: Text(
                   t == 25 ? 'B' : '$t', 
                   style: TextStyle(fontWeight: FontWeight.bold, color: theme.scoreColor, fontSize: 18)
                 ))
             )),
             const SizedBox(height: 40), // Footer spacer
           ],
        ),
        // Player Columns
        ...players.asMap().entries.map((entry) {
           final index = entry.key;
           final pid = entry.value;
           final pScore = state.gameState!.playerScores[pid] as CricketPlayerScore;
           final isActive = state.gameState!.currentPlayerId == pid;
           final pColor = theme.playerColors[index % theme.playerColors.length];
           
           return Expanded(
             child: Container(
               decoration: BoxDecoration(
                 color: isActive ? theme.activePlayerBackground : null,
                 border: Border(
                   top: BorderSide(width: 4, color: isActive ? theme.activePlayerBorder : Colors.transparent),
                   left: BorderSide(width: 1, color: Colors.white12),
                 )
               ),
               child: Column(
                 children: [
                  SizedBox(
                    height: 60, 
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         _LegIndicators(total: state.match!.config.legs, current: state.legsWon[pid] ?? 0, color: pColor),
                         _PlayerName(playerId: pid, small: true, isActive: isActive, color: pColor),
                      ],
                    ),
                  ),
                   ...targets.map((t) {
                      final marks = pScore.marks[t] ?? 0;
                      // Highlight marks for active player if closed?
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                             color: Colors.white.withOpacity(0.05),
                             borderRadius: BorderRadius.circular(4)
                          ),
                          child: Center(child: _MarkIndicator(marks: marks, color: pColor)),
                        ),
                      );
                   }),
                   SizedBox(
                     height: 40, 
                     child: Center(child: Text('${pScore.score}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: pColor)))
                   ),
                 ],
               ),
             ),
           );
        }),
      ],
    );
  }
}

class _MarkIndicator extends StatelessWidget {
  final int marks;
  final Color color;
  const _MarkIndicator({required this.marks, required this.color});
  
  @override
  Widget build(BuildContext context) {
    if (marks == 0) return const Text('');
    if (marks == 1) return Text('/', style: TextStyle(fontSize: 24, color: color.withOpacity(0.7)));
    if (marks == 2) return Text('X', style: TextStyle(fontSize: 24, color: color.withOpacity(0.9)));
    if (marks >= 3) return Container(
      width: 24, height: 24, 
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color)),
      child: Center(child: Text('X', style: TextStyle(fontSize: 12, color: color))),
    );
    return const Text('?');
  }
}

class _StatSmall extends StatelessWidget {
  final String label;
  final String value;
  const _StatSmall({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
      ],
    );
  }
}

class _PlayerName extends ConsumerWidget {
  final String playerId;
  final bool small;
  final bool isActive;
  final Color? color;

  const _PlayerName({required this.playerId, this.small = false, this.isActive = false, this.color});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(playerRepositoryProvider);
    return FutureBuilder(
      future: repo.getPlayer(playerId),
      builder: (ctx, snap) {
        if (snap.hasData) {
          return Text(
            snap.data!.name, 
            overflow: TextOverflow.ellipsis, 
            style: TextStyle(
              fontSize: small ? 12 : 20,
              fontWeight: small ? FontWeight.normal : FontWeight.bold,
              color: isActive ? (color ?? Colors.white) : Colors.white70,
              shadows: isActive ? [Shadow(color: (color ?? Colors.white), blurRadius: 12)] : null,
            )
          );
        }
        return const Text('Loading...', style: TextStyle(color: Colors.white38));
      }
    );
  }
}

class _LegIndicators extends StatelessWidget {
  final int total;
  final int current;
  final Color color;
  
  const _LegIndicators({
    required this.total,
    required this.current,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (total <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) {
          bool isFilled = i < current;
          return Container(
            width: 10, height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
               shape: BoxShape.circle,
               color: isFilled ? color : Colors.transparent,
               border: Border.all(color: color.withOpacity(0.5), width: 1),
            ),
          );
        }),
      ),
    );
  }
}
