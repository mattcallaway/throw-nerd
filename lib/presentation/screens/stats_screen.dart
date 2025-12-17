import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darts_app/domain/stats.dart';
import 'package:darts_app/domain/player.dart';
import 'package:darts_app/presentation/providers/di_providers.dart';
import 'package:darts_app/presentation/theme/app_themes.dart';
import 'package:darts_app/presentation/widgets/glass_card.dart';
import 'head_to_head_screen.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final statsAsync = ref.watch(statsDashboardProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('STATISTICS', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: SafeArea(
          child: statsAsync.when(
            data: (data) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GlobalStatsCard(stats: data.global, mostActiveName: data.mostActivePlayerName),
                    
                    const SizedBox(height: 16),
                    GlassCard(
                      onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => const HeadToHeadScreen()));
                      },
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.compare_arrows, color: theme.accentColor),
                          const SizedBox(width: 8),
                          Text('HEAD TO HEAD COMPARISON', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: theme.accentColor)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('LEADERBOARD', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 16),
                    ...data.playerStats.map((p) => GlassCard(
                       margin: const EdgeInsets.only(bottom: 12),
                       padding: const EdgeInsets.all(16),
                       child: Row(
                         children: [
                           CircleAvatar(backgroundColor: p.player.color, child: Text(p.player.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                           const SizedBox(width: 16),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(p.player.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                 const SizedBox(height: 4),
                                 Text('${p.stats.matchesWon} Wins / ${p.stats.matchesPlayed} Matches', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                               ],
                             ),
                           ),
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.end,
                             children: [
                               Text('${(p.stats.winRate * 100).toStringAsFixed(0)}%', 
                                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.successColor)),
                               const Text('Win Rate', style: TextStyle(fontSize: 10, color: Colors.grey)),
                             ],
                           )
                         ],
                       ),
                    )),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
        ),
      ),
    );
  }
}

class _GlobalStatsCard extends StatelessWidget {
  final GlobalStats stats;
  final String? mostActiveName;
  
  const _GlobalStatsCard({required this.stats, this.mostActiveName});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Total Matches', value: stats.totalMatches.toString()),
          if (mostActiveName != null)
            _StatItem(label: 'Most Active', value: mostActiveName!, small: true),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool small;
  
  const _StatItem({required this.label, required this.value, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: small ? 18 : 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// Data Bundle
class StatsDashboardData {
  final GlobalStats global;
  final String? mostActivePlayerName;
  final List<PlayerStatsEntry> playerStats;
  
  StatsDashboardData({required this.global, this.mostActivePlayerName, required this.playerStats});
}

class PlayerStatsEntry {
  final Player player;
  final PlayerStats stats;
  PlayerStatsEntry(this.player, this.stats);
}

final statsDashboardProvider = FutureProvider<StatsDashboardData>((ref) async {
  final matchRepo = ref.watch(matchRepositoryProvider);
  final playerRepo = ref.watch(playerRepositoryProvider);
  
  // 1. Global
  final global = await matchRepo.getGlobalStats();
  String? mostActiveName;
  if (global.mostActivePlayerId != null) {
     final p = await playerRepo.getPlayer(global.mostActivePlayerId!);
     mostActiveName = p?.name;
  }
  
  // 2. All Players Stats
  final players = await playerRepo.getAllPlayers();
  final entries = <PlayerStatsEntry>[];
  
  for (final p in players) {
    final s = await matchRepo.getPlayerStats(p.id);
    if (s.matchesPlayed > 0) { // Only show active
       entries.add(PlayerStatsEntry(p, s));
    }
  }
  
  // Sort by Win Rate desc, then Wins
  entries.sort((a, b) {
     int cmp = b.stats.matchesWon.compareTo(a.stats.matchesWon); // Wins first
     if (cmp == 0) return b.stats.winRate.compareTo(a.stats.winRate);
     return cmp;
  });
  
  return StatsDashboardData(global: global, mostActivePlayerName: mostActiveName, playerStats: entries);
});
