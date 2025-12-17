import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/league_repository.dart';
import '../../domain/league/models.dart';
import '../theme/app_themes.dart';
import '../widgets/glass_card.dart';
import 'league_dashboard_screen.dart';
import '../providers/di_providers.dart';
import '../../features/leagues/ui/league_help_screen.dart';
import '../../services/league/invite_codec.dart';

class LeaguesListScreen extends ConsumerWidget {
  const LeaguesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final leaguesAsync = ref.watch(myLeaguesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Leagues'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
           IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeagueHelpScreen())),
           )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateLeagueDialog(context, ref);
        }, // TODO: Create/Join League
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: SafeArea(
           child: Column(
             children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GlassCard(
                    onTap: () {
                       _showJoinLeagueDialog(context, ref);
                    },
                    child: const ListTile(
                      leading: Icon(Icons.group_add, color: Colors.white),
                      title: Text('Join existing league', style: TextStyle(color: Colors.white)),
                      trailing: Icon(Icons.chevron_right, color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: leaguesAsync.when(
                    data: (leagues) {
                      if (leagues.isEmpty) {
                        return const Center(child: Text('No leagues found. Create or Join one!', style: TextStyle(color: Colors.white70)));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: leagues.length,
                        itemBuilder: (ctx, i) {
                          final league = leagues[i];
                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            onTap: () {
                               // Go to Dashboard
                               Navigator.push(context, MaterialPageRoute(builder: (_) => LeagueDashboardScreen(leagueId: league.id)));
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 60, height: 60,
                                  color: Colors.white10,
                                  child: const Icon(Icons.emoji_events, color: Colors.amber),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(league.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                        // Text('Members: ${league.memberCount}', style: TextStyle(color: Colors.white70)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
  
  void _showCreateLeagueDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    String selectedProvider = 'gdrive'; // Default
    
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Create League'),
          content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               TextField(
                 controller: nameCtrl,
                 decoration: const InputDecoration(labelText: 'League Name'),
               ),
               const SizedBox(height: 16),
               const Text('Storage Provider:', style: TextStyle(fontWeight: FontWeight.bold)),
               DropdownButton<String>(
                 value: selectedProvider,
                 isExpanded: true,
                 items: const [
                   DropdownMenuItem(value: 'gdrive', child: Text('Google Drive')),
                   DropdownMenuItem(value: 'dropbox', child: Text('Dropbox')),
                   DropdownMenuItem(value: 'firebase', child: Text('Cloud (Legacy)')),
                 ],
                 onChanged: (v) {
                    if(v != null) setState(() => selectedProvider = v);
                 },
               ),
             ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(onPressed: () async {
               if (nameCtrl.text.isNotEmpty) {
                  Navigator.pop(ctx);
                  try {
                    await ref.read(leagueRepositoryProvider).createLeague(nameCtrl.text, selectedProvider);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
               }
            }, child: const Text('Create')),
          ],
        );
      }
    ));
  }
  
  void _showJoinLeagueDialog(BuildContext context, WidgetRef ref) {
    final codeCtrl = TextEditingController();
    // No manual provider selection needed initially if we parse code.
    // But we keep it as fallback or confirmation if code fails.
    
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Join League'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Paste the Invite Link or Join Code sent by the league owner.'),
              const SizedBox(height: 16),
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Invite Link / Code',
                  hintText: 'https://dartleagues.app/join#... or DL1-...'
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(onPressed: () async {
               final input = codeCtrl.text.trim();
               if (input.isEmpty) return;

               Navigator.pop(ctx);
               try {
                  // 1. Try to decode as smart invite
                  try {
                     final payload = InviteCodec.decode(input);
                     // 2. Use payload to join
                     await _joinViaPayload(context, ref, payload);
                  } catch (e) {
                     // Fallback: If it's a raw folder ID (legacy) or simple link
                     // Prompt user for provider? Or just try?
                     // For MVP, we'll assume it MUST be a new code.
                     throw Exception('Invalid Invite Code format. Please ask the owner for a new Invite Link.');
                  }
               } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Join failed: $e')));
               }
            }, child: const Text('Join')),
          ],
        );
      }
    ));
  }

  Future<void> _joinViaPayload(BuildContext context, WidgetRef ref, InvitePayload payload) async {
     // Check if user needs to switch account?
     // We just try to join using the provider specified in payload.
     
     // The Repo needs a localized "joinFromInvite" method ideally, but we can reuse 'joinLeague' 
     // if 'joinLeague' is updated to handle the 'remoteRoot' map or we handle it here.
     
     // Current 'joinLeague(code, provider)' expects code to be the Remote Root ID/Path.
     // We need to resolve that from the payload first.
     
     final repo = ref.read(leagueRepositoryProvider);
     
     // We need to expose a method to RESOLVE the invites first or add a new method to repo.
     // Let's call a new method on repo: joinLeagueFromPayload
     await repo.joinLeagueFromPayload(payload);
     
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Joined ${payload.leagueName}!')));
  }
}

final myLeaguesProvider = StreamProvider<List<League>>((ref) {
  return ref.watch(leagueRepositoryProvider).watchMyLeagues();
});
