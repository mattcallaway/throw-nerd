import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/game_match.dart';
import '../../domain/league/models.dart';
import '../providers/di_providers.dart';
import '../../services/league/league_sync_service.dart';
import '../../data/repositories/league_repository.dart';
import '../theme/app_themes.dart';
import '../widgets/glass_card.dart';
import 'match_history_screen.dart'; // Reuse History List Item or Logic
import 'match_setup_screen.dart';
import 'match_detail_screen.dart';

class LeagueDashboardScreen extends ConsumerStatefulWidget {
  final String leagueId;
  const LeagueDashboardScreen({super.key, required this.leagueId});

  @override
  ConsumerState<LeagueDashboardScreen> createState() => _LeagueDashboardScreenState();
}

class _LeagueDashboardScreenState extends ConsumerState<LeagueDashboardScreen> {
  bool _isSyncing = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final leagueAsync = ref.watch(localLeagueProvider(widget.leagueId));
    final matchesAsync = ref.watch(leagueMatchesProvider(widget.leagueId));
    
    return Scaffold(
      appBar: AppBar(
        title: leagueAsync.when(
          data: (l) => Text(l?.name ?? 'League'),
          loading: () => const Text('Loading...'),
          error: (_,__) => const Text('Error'),
        ),
        actions: [
           IconButton(
             icon: _isSyncing 
               ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
               : const Icon(Icons.sync),
             onPressed: _isSyncing ? null : _sync,
           ),
           IconButton(
             icon: const Icon(Icons.info_outline),
             onPressed: () {
                // Show invite code / details
                if (leagueAsync.value != null) {
                   _showLeagueInfo(context, leagueAsync.value!);
                }
             },
           )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MatchSetupScreen(leagueId: widget.leagueId))),
        icon: const Icon(Icons.play_arrow),
        label: const Text('New Match'),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
               // Stats / Leaderboard Header (Placeholder)
               Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: GlassCard(
                   child: Container(
                     width: double.infinity,
                     padding: const EdgeInsets.all(16),
                     child: Column(
                       children: const [
                          Text('Leaderboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 8),
                          Text('(Coming Soon)', style: TextStyle(color: Colors.white54)),
                       ],
                     ),
                   ),
                 ),
               ),
               
               const Padding(
                 padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                 child: Align(alignment: Alignment.centerLeft, child: Text('Recent Matches', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold))),
               ),
               
               Expanded(
                 child: matchesAsync.when(
                   data: (matches) {
                      if (matches.isEmpty) return const Center(child: Text('No matches yet', style: TextStyle(color: Colors.white54)));
                      
                      return ListView.builder(
                        itemCount: matches.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (ctx, i) {
                          final match = matches[i];
                          // Simple list item for now
                          return GestureDetector(
                            onTap: () {
                               Navigator.push(context, MaterialPageRoute(builder: (_) => MatchDetailScreen(matchId: match.id)));
                            },
                            child: GlassCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                dense: true,
                                title: Text(match.config.summary, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  'Won by ${match.winnerId ?? "Unknown"} • ${match.createdAt.toString().substring(0, 16)}', 
                                  style: const TextStyle(color: Colors.white70)
                                ),
                                trailing: const Icon(Icons.chevron_right, color: Colors.white30),
                              ),
                            ),
                          );
                        },
                      );
                   },
                   loading: () => const Center(child: CircularProgressIndicator()),
                   error: (e, s) => Center(child: Text('Error: $e')),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _sync() async {
    setState(() => _isSyncing = true);
    try {
      await ref.read(leagueSyncServiceProvider).syncLeague(widget.leagueId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync completed')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }
  
  void _showLeagueInfo(BuildContext context, League league) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(league.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           SelectableText('ID/Path: ${league.id}'), // Copyable for sharing
           const SizedBox(height: 8),
           if (league.id.contains('/')) const Text('Type: File System (Dropbox/Drive)'),
           const SizedBox(height: 8),
           Text('Sync Status: ${league.createdAt}'), // TODO: expose sync info
        ],
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
    ));
  }
}

// Providers
final localLeagueProvider = FutureProvider.family<League?, String>((ref, id) async {
  final repo = ref.watch(leagueRepositoryProvider);
  final dao = await repo.getLocalLeague(id);
  if (dao == null) return null;
  return League(id: dao.id, name: dao.name, createdBy: '', createdAt: dao.createdAt);
});

final leagueMatchesProvider = StreamProvider.family<List<GameMatch>, String>((ref, id) {
  final repo = ref.watch(matchRepositoryProvider);
  return repo.watchMatches(leagueId: id);
});
