
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/providers/di_providers.dart';
import '../../../../presentation/theme/app_themes.dart';
import '../../../../presentation/widgets/glass_card.dart';
import '../../../../domain/player.dart';
import '../../../../domain/stats.dart';
import '../../../../presentation/screens/head_to_head_screen.dart';
import '../../../../presentation/screens/stats_screen.dart'; // For statsDashboardProvider
import 'player_analytics_screen.dart';

class AnalyticsHomeScreen extends ConsumerStatefulWidget {
  const AnalyticsHomeScreen({super.key});

  @override
  ConsumerState<AnalyticsHomeScreen> createState() => _AnalyticsHomeScreenState();
}

class _AnalyticsHomeScreenState extends ConsumerState<AnalyticsHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text('ANALYTICS CENTER', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.accentColor,
          tabs: const [
             Tab(text: 'LEADERBOARD'),
             Tab(text: 'RIVALS'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
               const _LeaderboardTab(),
               const HeadToHeadScreen(), // Reusing existing screen as a widget
            ],
          ),
        ),
      ),
    );
  }
}

// Reuse logic from old StatsScreen
class _LeaderboardTab extends ConsumerWidget {
  const _LeaderboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsDashboardProvider);
    final theme = ref.watch(appThemeProvider);

    return statsAsync.when(
      data: (data) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GlobalStatsCard(stats: data.global, mostActiveName: data.mostActivePlayerName),
              const SizedBox(height: 24),
              const Text('PLAYER RANKINGS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 16),
              ...data.playerStats.map((p) => GlassCard(
                  onTap: () {
                     // Drill Down
                     Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerAnalyticsScreen(
                        playerId: p.player.id,
                        playerName: p.player.name,
                     )));
                  },
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                          backgroundColor: p.player.color,
                          child: Text(p.player.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                      ),
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
              if (data.playerStats.isEmpty) 
                 const Center(child: Text("No matches played yet.", style: TextStyle(color: Colors.white54))),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
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

// Temporary Duplication of Data Bundle classes if they were private in stats_screen.
// But stats_screen keys them as top level? 
// Let's check stats_screen.dart... 
// yes, StatsDashboardData is top-level. I can import it if I import stats_screen.dart
// But stats_screen is a screen file.
// Better to move the Provider to a shared location, but for now I will just import from stats_screen.dart
// Wait, ideally avoid importing Screens into other Screens (except for navigation).
// But the provider is defined there.
// I'll import 'package:darts_app/presentation/screens/stats_screen.dart' to access the provider.

