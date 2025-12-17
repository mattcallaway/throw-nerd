import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/league_repository.dart';
import '../../../data/repositories/drift_match_repository.dart';
import '../../../presentation/providers/di_providers.dart';
import '../../../services/league/league_sync_service.dart';
import '../../../domain/game_match.dart';
import '../../../domain/scoring/models.dart';
import 'league_settings_screen.dart';
import '../../analytics/ui/widgets/stat_card.dart';
import '../../../services/league/standings_service.dart';

import '../../../services/league/standings_service.dart';
import '../../features/leagues/ui/league_help_screen.dart';

class LeagueDashboardScreen extends ConsumerStatefulWidget {
  final String leagueId;
  final String leagueName;

  const LeagueDashboardScreen({super.key, required this.leagueId, required this.leagueName});

  @override
  ConsumerState<LeagueDashboardScreen> createState() => _LeagueDashboardScreenState();
}

class _LeagueDashboardScreenState extends ConsumerState<LeagueDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _sync() async {
    setState(() => _isSyncing = true);
    try {
      await ref.read(leagueSyncServiceProvider).syncLeague(widget.leagueId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync completed')));
        ref.invalidate(leagueMatchesProvider(widget.leagueId)); // Refresh lists
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastSyncAsync = ref.watch(leagueLastSyncProvider(widget.leagueId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.leagueName),
        actions: [
          IconButton(
            icon: _isSyncing 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.sync),
            onPressed: _isSyncing ? null : _sync,
            tooltip: 'Sync Now',
          ),
          IconButton(
             icon: const Icon(Icons.help_outline),
             onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeagueHelpScreen())),
          ),
          IconButton(
             icon: const Icon(Icons.settings),
             onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LeagueSettingsScreen(leagueId: widget.leagueId))),
          ),
          IconButton(
             icon: const Icon(Icons.info_outline),
             onPressed: () => _showLeagueInfo(context, lastSyncAsync.valueOrNull),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Matches'),
            Tab(text: 'Leaderboard'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMatchesTab(),
          _buildLeaderboardTab(),
        ],
      ),
    );
  }

  Widget _buildMatchesTab() {
    final matchesAsync = ref.watch(leagueMatchesProvider(widget.leagueId));
    
    return matchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) return const Center(child: Text('No matches synced yet.'));
        
        return ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return ListTile(
               leading: Icon(match.config.type == GameType.x01 ? Icons.score : Icons.grid_view),
               title: Row(children: [
                   Expanded(child: Text('${match.config.summary}')),
                   if (match.complianceStatus == 'ignored') const Tooltip(message: 'Ignored Match', child: Icon(Icons.block, color: Colors.red, size: 16)),
               ]),
               subtitle: Text('${DateFormat.yMMMd().format(match.createdAt)} • ${match.locationId ?? "Unknown"}'), // locationId is Name in remote matches basically
               trailing: match.winnerId != null ? const Icon(Icons.emoji_events, color: Colors.amber) : null,
               onTap: () {
                  // TODO: View Match Details
               },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildLeaderboardTab() {
     final matchesAsync = ref.watch(leagueMatchesProvider(widget.leagueId));
     // We also need player names. Ideally invalidation of leagueMatches triggers rebuild and we fetch players.
     final playersAsync = ref.watch(allPlayersProvider);
     
     return matchesAsync.when(
        data: (matches) {
           return playersAsync.when(
             data: (players) {
                if (matches.isEmpty) return const Center(child: Text('No matches recorded.'));
                
                final standings = LeagueStandingsService.calculateStandings(matches, players);
                
                if (standings.isEmpty) return const Center(child: Text('No complete matches found.'));
                
                return Column(
                  children: [
                    // Header
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                           SizedBox(width: 40, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                           Expanded(child: Text('Player', style: TextStyle(fontWeight: FontWeight.bold))),
                           SizedBox(width: 40, child: Text('P', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                           SizedBox(width: 40, child: Text('W', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                           SizedBox(width: 40, child: Text('L', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                           SizedBox(width: 40, child: Text('Pts', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.separated(
                        itemCount: standings.length,
                        separatorBuilder: (_,__) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                           final row = standings[i];
                           final bool isUser = false; // Highlight logic if we knew current user
                           
                           return Container(
                             color: isUser ? Colors.blue.withOpacity(0.1) : null,
                             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                             child: Row(
                                children: [
                                   SizedBox(width: 40, child: Text('${i+1}')),
                                   Expanded(child: Text(row.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                                   SizedBox(width: 40, child: Text('${row.matchesPlayed}', textAlign: TextAlign.center)),
                                   SizedBox(width: 40, child: Text('${row.wins}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.green))),
                                   SizedBox(width: 40, child: Text('${row.losses}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red))),
                                   SizedBox(width: 40, child: Text('${row.points}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                                ],
                             ),
                           );
                        },
                      ),
                    ),
                  ],
                );
             },
             loading: () => const Center(child: CircularProgressIndicator()),
             error: (e, s) => Center(child: Text('Error loading players: $e')),
           );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
     );
  }

  void _showLeagueInfo(BuildContext context, DateTime? lastSync) {
     showDialog(context: context, builder: (_) => AlertDialog(
        title: const Text('League Info'),
        content: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Text('Name: ${widget.leagueName}'),
              const SizedBox(height: 8),
              Text('Last Sync: ${lastSync != null ? DateFormat.yMMMd().add_jm().format(lastSync) : "Never"}'),
              const SizedBox(height: 8),
              SelectableText('League ID: ${widget.leagueId}'),
           ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
     ));
  }
}

class _PlayerLeagueStats {
  String name;
  int matches = 0;
  int wins = 0;
  _PlayerLeagueStats({required this.name});
}

// Providers

final leagueMatchesProvider = StreamProvider.family<List<GameMatch>, String>((ref, leagueId) {
  final repo = ref.watch(matchRepositoryProvider);
  return repo.watchMatches(leagueId: leagueId); // Filter by league
});

final leagueLastSyncProvider = FutureProvider.family<DateTime?, String>((ref, leagueId) async {
   final repo = ref.watch(leagueRepositoryProvider);
   final league = await repo.getLocalLeague(leagueId);
   return league?.lastSyncAt;
});
