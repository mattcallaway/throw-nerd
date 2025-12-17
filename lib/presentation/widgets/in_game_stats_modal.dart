import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darts_app/domain/scoring/game_state.dart';
import 'package:darts_app/domain/scoring/models.dart';
import 'package:darts_app/domain/scoring/stats.dart';
import 'package:darts_app/presentation/providers/di_providers.dart';
import 'package:darts_app/presentation/theme/app_themes.dart';
import 'package:darts_app/presentation/widgets/glass_card.dart';

class InGameStatsModal extends ConsumerWidget {
  final GameState state;
  final String? activePlayerId;

  const InGameStatsModal({super.key, required this.state, required this.activePlayerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final playerIds = state.playerOrder;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4, 
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          Text('MATCH STATISTICS', style: theme.materialTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: playerIds.length,
              separatorBuilder: (_,__) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final pid = playerIds[index];
                return _PlayerStatsCard(pid: pid, state: state, activePlayerId: activePlayerId);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerStatsCard extends ConsumerWidget {
  final String pid;
  final GameState state;
  final String? activePlayerId;

  const _PlayerStatsCard({required this.pid, required this.state, required this.activePlayerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final repo = ref.watch(playerRepositoryProvider);
    
    return FutureBuilder(
      future: repo.getPlayer(pid),
      builder: (context, snapshot) {
         if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
         
         final p = snapshot.data!;
         final stats = StatsCalculator.calculate(state, pid);
         final isTurn = pid == activePlayerId;
         
         final lastTurns = state.history.where((t) => t.playerId == pid).toList().reversed.take(3).toList();
         
         return GlassCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(backgroundColor: p.color, radius: 12, child: Text(p.name[0], style: const TextStyle(fontSize: 10, color: Colors.white))),
                    const SizedBox(width: 8),
                    Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, color: isTurn ? theme.accentColor : Colors.white)),
                    const Spacer(),
                    _StatChip(label: 'Darts', value: '${stats.totalDarts}', color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    if(state.config.type == GameType.x01)
                       _StatChip(label: 'Avg', value: stats.average.toStringAsFixed(1), color: theme.menuStats),
                    if(state.config.type == GameType.cricket)
                       _StatChip(label: 'MPR', value: stats.mpr.toStringAsFixed(2), color: theme.menuStats),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                     _StatDetail(label: 'High Turn', value: '${stats.highestTurn}'),
                     _StatDetail(label: 'Doubles', value: '${stats.doublesHit}'),
                     _StatDetail(label: 'Triples', value: '${stats.triplesHit}'),
                     if(state.config.type == GameType.x01)
                       _StatDetail(label: '1st 9', value: stats.first9Average.toStringAsFixed(1)),
                  ],
                ),
                if (lastTurns.isNotEmpty) ...[
                   const SizedBox(height: 12),
                   const Divider(color: Colors.white10),
                   const SizedBox(height: 8),
                   Row(
                     children: [
                        const Text('Recent: ', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ...lastTurns.map((t) {
                           final score = t.darts.fold(0, (sum, d) => sum + d.total);
                           return Container(
                             margin: const EdgeInsets.only(right: 4),
                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                             decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                             child: Text('$score', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                           );
                        }),
                     ],
                   )
                ]
              ],
            ),
         );
      }
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: color)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

class _StatDetail extends StatelessWidget {
  final String label;
  final String value;
  const _StatDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
