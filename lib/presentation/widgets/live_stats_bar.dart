import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/scoring/stats.dart';
import '../../domain/scoring/models.dart';
import '../providers/active_match_notifier.dart';
import '../providers/di_providers.dart';
import '../theme/app_themes.dart';

class LiveStatsBar extends ConsumerWidget {
  const LiveStatsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeMatchProvider);
    final theme = ref.watch(appThemeProvider);
    
    if (state.match == null || state.gameState == null) return const SizedBox.shrink();
    
    final pid = state.gameState!.currentPlayerId;
    final stats = StatsCalculator.calculate(state.gameState!, pid);
    final lastTurns = state.gameState!.history.where((t) => t.playerId == pid).toList().reversed.take(3).toList();
    final gameType = state.match!.config.type;

    return Container(
      width: double.infinity,
      color: Colors.black45,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
            // Left Stats
            if (gameType == GameType.x01) ...[
               _StatItem(label: 'Avg (PPR)', value: stats.average.toStringAsFixed(1), color: theme.accentColor),
               _StatItem(label: '1st 9', value: stats.first9Average.toStringAsFixed(1)),
               _StatItem(label: 'Best', value: '${stats.highestTurn}'),
            ] else ...[
               _StatItem(label: 'MPR', value: stats.mpr.toStringAsFixed(1), color: theme.accentColor),
               _StatItem(label: 'Hit Rate', value: stats.totalDarts > 0 ? '${((stats.cricketHits / stats.totalDarts)*100).toStringAsFixed(0)}%' : '0%'),
            ],
            
            Container(width: 1, height: 24, color: Colors.white24),
            
            // Right Stats (Recent)
            Row(
              children: [
                const Text('LAST 3:  ', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                if (lastTurns.isEmpty)
                   const Text('-', style: TextStyle(color: Colors.white54, fontSize: 12)),
                   
                ...lastTurns.map((t) {
                   int score = 0;
                   if (gameType == GameType.x01) {
                      score = t.darts.fold(0, (sum, d) => sum + d.total);
                   } else {
                      // For Cricket, maybe show marks? Or just points if we tracked them.
                      // Let's show marks count
                      score = 0;
                      for(final d in t.darts) {
                         if([15,16,17,18,19,20,25].contains(d.value)) score += d.multiplier;
                      }
                   }
                   
                   return Container(
                     margin: const EdgeInsets.only(right: 6),
                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                     decoration: BoxDecoration(
                       color: Colors.white10,
                       borderRadius: BorderRadius.circular(4),
                       border: Border.all(color: Colors.white12)
                     ),
                     child: Text(
                        gameType == GameType.cricket ? 'M:$score' : '$score', 
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                     ),
                   );
                }).toList(),
              ],
            )
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatItem({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color ?? Colors.white)),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }
}
