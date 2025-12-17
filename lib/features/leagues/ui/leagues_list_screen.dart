import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/league_repository.dart';
import 'create_league_screen.dart';
import 'join_league_screen.dart';
import 'league_dashboard_screen.dart';

class LeaguesListScreen extends ConsumerWidget {
  const LeaguesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaguesAsync = ref.watch(leaguesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Leagues'),
      ),
      body: leaguesAsync.when(
        data: (leagues) {
          if (leagues.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.group_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No leagues yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToCreate(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create League'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _navigateToJoin(context),
                    icon: const Icon(Icons.link),
                    label: const Text('Join with Code'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: leagues.length,
            itemBuilder: (context, index) {
              final league = leagues[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueGrey.shade800,
                  child: Text(league.name[0].toUpperCase()),
                ),
                title: Text(league.name),
               // subtitle: Text('Synced: ${league.lastSyncAt ?? 'Never'}'), // Model needs expanding or fetch detail
                subtitle: const Text('Tap to view dashboard'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => LeagueDashboardScreen(leagueId: league.id, leagueName: league.name)));
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.create_new_folder),
            title: const Text('Create New League'),
            onTap: () {
              Navigator.pop(ctx);
              _navigateToCreate(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.input),
            title: const Text('Join Existing League'),
            onTap: () {
               Navigator.pop(ctx);
               _navigateToJoin(context);
            },
          ),
          const SizedBox(height: 24),
        ],
      )
    );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateLeagueScreen()));
  }

  void _navigateToJoin(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinLeagueScreen()));
  }
}

final leaguesListProvider = StreamProvider((ref) {
  final repo = ref.watch(leagueRepositoryProvider);
  return repo.watchMyLeagues();
});
