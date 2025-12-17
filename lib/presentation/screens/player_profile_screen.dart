import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:darts_app/domain/player.dart';
import 'package:darts_app/domain/game_match.dart';
import 'package:darts_app/domain/scoring/models.dart';
import 'package:darts_app/domain/stats.dart';
import 'package:darts_app/presentation/providers/di_providers.dart';
import 'package:darts_app/presentation/theme/app_themes.dart';
import 'package:darts_app/presentation/widgets/glass_card.dart';
import 'package:darts_app/presentation/widgets/premium_button.dart';
import 'package:darts_app/presentation/widgets/player_form_dialog.dart';
import 'match_detail_screen.dart';
import 'analytics/player_analytics_screen.dart';

class PlayerProfileScreen extends ConsumerStatefulWidget {
  final Player player;
  const PlayerProfileScreen({super.key, required this.player});

  @override
  ConsumerState<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

final playerProfileProvider = FutureProvider.family<PlayerProfileData, String>((ref, playerId) async {
   final matchRepo = ref.watch(matchRepositoryProvider);
   
   final stats = await matchRepo.getPlayerStats(playerId);
   final recentMatches = await matchRepo.getMatchesForPlayer(playerId, limit: 10);
   
   return PlayerProfileData(stats: stats, recentMatches: recentMatches);
});

class PlayerProfileData {
  final PlayerStats stats;
  final List<GameMatch> recentMatches;
  PlayerProfileData({required this.stats, required this.recentMatches});
}

class _PlayerProfileScreenState extends ConsumerState<PlayerProfileScreen> {
  // We keep local copy of player if optimized edit happened
  late Player _player;

  @override
  void initState() {
    super.initState();
    _player = widget.player;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final dataAsync = ref.watch(playerProfileProvider(_player.id));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('PROFILE', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Deep Analytics',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerAnalyticsScreen(playerId: _player.id, playerName: _player.name))),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: theme.dangerColor),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: SafeArea(
           child: dataAsync.when(
             data: (data) => _buildContent(context, theme, data),
             loading: () => const Center(child: CircularProgressIndicator()),
             error: (e, s) => Center(child: Text('Error: $e')),
           )
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppThemeData theme, PlayerProfileData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
           // Header
           Column(
             children: [
               CircleAvatar(
                 radius: 40,
                 backgroundColor: _player.color,
                 child: Text(_player.name[0], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
               ),
               const SizedBox(height: 16),
               Text(_player.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
               const SizedBox(height: 8),
               Text('${data.stats.matchesPlayed} Matches Played', style: const TextStyle(color: Colors.grey)),
             ],
           ),
           const SizedBox(height: 24),
           
           // Stats Grid
           Row(
             children: [
               Expanded(child: _StatCard(label: 'Win Rate', value: '${(data.stats.winRate * 100).toStringAsFixed(1)}%')),
               const SizedBox(width: 16),
               Expanded(child: _StatCard(label: 'Matches Won', value: '${data.stats.matchesWon}')),
             ],
           ),
           const SizedBox(height: 16),
           
           // Game Type Splits
           GlassCard(
             padding: const EdgeInsets.all(16),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Text('PERFORMANCE BY GAME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                 const SizedBox(height: 16),
                 _GameTypeRow(
                    label: 'X01', 
                    played: data.stats.x01MatchesPlayed, 
                    won: data.stats.x01MatchesWon,
                    rate: data.stats.x01WinRate
                 ),
                 const Divider(color: Colors.white10),
                 _GameTypeRow(
                    label: 'Cricket', 
                    played: data.stats.cricketMatchesPlayed, 
                    won: data.stats.cricketMatchesWon,
                    rate: data.stats.cricketWinRate
                 ),
               ],
             ),
           ),
           
           const SizedBox(height: 24),
           
           // Recent Matches
           const Align(alignment: Alignment.centerLeft, child: Text('RECENT MATCHES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey))),
           const SizedBox(height: 8),
           
           if (data.recentMatches.isEmpty) 
             const Padding(padding: EdgeInsets.all(16), child: Text('No matches played yet.', style: TextStyle(color: Colors.white54))),

           ...data.recentMatches.map((m) {
              final isWin = m.winnerId == _player.id;
              final outcomeColor = isWin ? theme.successColor : Colors.white54;
              
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MatchDetailScreen(matchId: m.id))),
                child: GlassCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(m.config.type == GameType.x01 ? 'X01' : 'Cricket', style: const TextStyle(fontWeight: FontWeight.bold)),
                           Text(DateFormat.MMMd().format(m.createdAt), style: const TextStyle(fontSize: 12, color: Colors.white54)),
                        ],
                      ),
                      Text(isWin ? 'WON' : 'LOST', style: TextStyle(color: outcomeColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
           })
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => PlayerFormDialog(playerToEdit: _player),
    );
    // Refresh self
    final repo = ref.read(playerRepositoryProvider);
    final updated = await repo.getPlayer(_player.id);
    if (updated != null && mounted) {
      setState(() {
        _player = updated;
      });
      ref.invalidate(playerProfileProvider(_player.id));
    }
  }

  void _confirmDelete(BuildContext context) {
     final theme = ref.read(appThemeProvider);
     showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
         backgroundColor: theme.surfaceColor,
         title: const Text('Delete Player?'),
         content: Text('Are you sure you want to delete ${_player.name}?'),
         actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
           TextButton(
             onPressed: () {
                ref.read(playerRepositoryProvider).deletePlayer(_player.id);
                Navigator.pop(ctx); // Dialog
                Navigator.pop(context); // Screen
             },
             child: Text('Delete', style: TextStyle(color: theme.dangerColor)),
           ),
         ],
       ),
     );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _GameTypeRow extends StatelessWidget {
  final String label;
  final int played;
  final int won;
  final double rate;

  const _GameTypeRow({
    required this.label, required this.played, required this.won, required this.rate
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        Text('$played Played'),
        Text('$won Won'),
        Text('${(rate * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.greenAccent)),
      ],
    );
  }
}
