import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darts_app/domain/player.dart';
import 'package:darts_app/presentation/providers/di_providers.dart';
import 'package:darts_app/presentation/theme/app_themes.dart';
import 'package:darts_app/presentation/widgets/glass_card.dart';
import 'package:darts_app/presentation/widgets/player_form_dialog.dart';
import 'player_profile_screen.dart';

class PlayersScreen extends ConsumerWidget {
  const PlayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final repo = ref.watch(playerRepositoryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('PLAYERS', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: SafeArea( // Keep title visible in body? No, appBar is transparent. Use SafeArea.
          child: StreamBuilder<List<Player>>(
            stream: repo.watchAllPlayers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                 return Center(child: Text('Error: ${snapshot.error}'));
              }
    
              final players = snapshot.data ?? [];
    
              if (players.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                       const SizedBox(height: 16),
                       const Text('No players yet.', style: TextStyle(color: Colors.grey)),
                       const SizedBox(height: 8),
                       ElevatedButton(
                         onPressed: () => _showAddPlayerDialog(context),
                         child: const Text('Create Player'),
                       ),
                    ],
                  ),
                );
              }
    
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerProfileScreen(player: player))),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: player.color ?? Colors.grey,
                            child: Text(player.name.substring(0, 1).toUpperCase(), 
                               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 4),
                                const Text('Tap to view profile', style: TextStyle(color: Colors.white38, fontSize: 12)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: theme.accentColor),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.successColor,
        foregroundColor: Colors.black,
        onPressed: () => _showAddPlayerDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddPlayerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const PlayerFormDialog(),
    );
  }
}
