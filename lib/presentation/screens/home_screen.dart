import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darts_app/presentation/providers/di_providers.dart';
import 'package:darts_app/presentation/theme/app_themes.dart';
import 'package:darts_app/presentation/widgets/glass_card.dart';
import 'match_setup_screen.dart';
import 'players_screen.dart';
import 'stats_screen.dart';
import 'locations_screen.dart';
import '../../features/analytics/ui/analytics_home_screen.dart';
import 'backup_screen.dart';
import 'match_history_screen.dart';
import '../../features/leagues/ui/leagues_list_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text('PRO DARTS SCORER', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _GlassMenuCard(
                  icon: Icons.play_arrow_rounded,
                  title: 'New Match',
                  color: theme.menuNewMatch,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchSetupScreen())),
                ),
                _GlassMenuCard(
                  icon: Icons.people_alt_rounded,
                  title: 'Players',
                  color: theme.menuPlayers,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayersScreen())),
                ),
                _GlassMenuCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'Stats',
                  color: theme.menuStats,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsHomeScreen())),
                ),
                _GlassMenuCard(
                  icon: Icons.history_rounded,
                  title: 'History',
                  color: theme.menuHistory,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchHistoryScreen())),
                ),
                _GlassMenuCard(
                  icon: Icons.place_rounded,
                  title: 'Locations',
                  color: theme.menuLocations,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationsScreen())),
                ),
                _GlassMenuCard(
                  icon: Icons.emoji_events_rounded,
                  title: 'Leagues',
                  color: Colors.amber, // TODO: Add to Theme
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaguesListScreen())),
                ),
                _GlassMenuCard(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  color: theme.menuSettings,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _GlassMenuCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            ),
            child: Icon(icon, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            title, 
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.5),
            textAlign: TextAlign.center
          ),
        ],
      ),
    );
  }
}
