import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/league_repository.dart';
import '../../../services/league/league_metadata_service.dart';
import '../../../presentation/providers/di_providers.dart';
import '../../../domain/league/league_file_models.dart';
import 'league_members_screen.dart';
import 'season_list_screen.dart';
import 'league_rules_screen.dart';

class LeagueSettingsScreen extends ConsumerStatefulWidget {
  final String leagueId;

  const LeagueSettingsScreen({super.key, required this.leagueId});

  @override
  ConsumerState<LeagueSettingsScreen> createState() => _LeagueSettingsScreenState();
}

class _LeagueSettingsScreenState extends ConsumerState<LeagueSettingsScreen> {
  bool _isLoading = false;

  void _renameLeague(String currentName) {
    showDialog(context: context, builder: (ctx) {
       final controller = TextEditingController(text: currentName);
       return AlertDialog(
         title: const Text('Rename League'),
         content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'New Name')),
         actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
           FilledButton(
             onPressed: () async {
                Navigator.pop(ctx);
                await _performRename(controller.text);
             },
             child: const Text('Save'),
           )
         ]
       );
    });
  }

  Future<void> _performRename(String newName) async {
    setState(() => _isLoading = true);
    try {
       final service = ref.read(leagueMetadataServiceProvider);
       final meta = await service.fetchLeagueMetadata(widget.leagueId);
       
       if (meta != null) {
          final newMeta = LeagueFile(
            schemaVersion: meta.schemaVersion,
            leagueId: meta.leagueId,
            name: newName,
            createdAt: meta.createdAt,
            createdBy: meta.createdBy,
            provider: meta.provider,
            remoteRootPath: meta.remoteRootPath,
            ownerId: meta.ownerId,
            mode: meta.mode,
            bannedMemberIds: meta.bannedMemberIds,
            rules: meta.rules,
            activeSeasonId: meta.activeSeasonId,
            updatedAt: DateTime.now(),
            updatedBy: meta.ownerId, // Assume owner is acting
          );
          
          await service.updateLeagueMetadata(widget.leagueId, newMeta);
          
          await ref.read(leagueRepositoryProvider).updateLeagueDetails(widget.leagueId, name: newName);
          
          if(mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('League Renamed')));
             setState(() {}); // Refresh UI
          }
       }
    } catch (e) {
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
       if(mounted) setState(() => _isLoading = false);
    }
  }



  Future<void> _toggleMode(String currentMode) async {
     final newMode = currentMode == 'informal' ? 'formal' : 'informal';
     final warning = newMode == 'formal'
       ? 'Switching to Formal Mode enables Seasons, Schedules, and Rules. Ensure you configure them.'
       : 'Switching to Informal Mode disables Seasons/Schedules enforcement. Stats will be aggregate.';
       
     showDialog(context: context, builder: (ctx) => AlertDialog(
        title: Text('Switch to $newMode?'),
        content: Text(warning),
        actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
           FilledButton(
              onPressed: () async {
                 Navigator.pop(ctx);
                 await _performModeChange(newMode);
              },
              child: const Text('Switch'),
           )
        ],
     ));
  }
  
  Future<void> _performModeChange(String newMode) async {
    setState(() => _isLoading = true);
    try {
       final service = ref.read(leagueMetadataServiceProvider);
       final meta = await service.fetchLeagueMetadata(widget.leagueId);
       
       if (meta != null) {
          final newMeta = LeagueFile(
            schemaVersion: meta.schemaVersion,
            leagueId: meta.leagueId,
            name: meta.name,
            createdAt: meta.createdAt,
            createdBy: meta.createdBy,
            provider: meta.provider,
            remoteRootPath: meta.remoteRootPath,
            ownerId: meta.ownerId,
            mode: newMode, // Updated
            bannedMemberIds: meta.bannedMemberIds,
            rules: meta.rules,
            activeSeasonId: meta.activeSeasonId,
            updatedAt: DateTime.now(),
            updatedBy: meta.ownerId,
          );
          
          await service.updateLeagueMetadata(widget.leagueId, newMeta);
          await ref.read(leagueRepositoryProvider).updateLeagueDetails(widget.leagueId, mode: newMode);
          
          if(mounted) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Switched to $newMode')));
             setState(() {});
          }
       }
    } catch(e) {
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
       if(mounted) setState(() => _isLoading = false);
    }
  }

  void _deleteLeague() {
     showDialog(context: context, builder: (ctx) => AlertDialog(
        title: const Text('Delete / Leave League?'),
        content: const Text('This will remove the league and all synced matches from this device. It will NOT delete the league from the Cloud Provider.'),
        actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
           FilledButton(
               style: FilledButton.styleFrom(backgroundColor: Colors.red),
               onPressed: () async {
                  Navigator.pop(ctx);
                  setState(() => _isLoading = true);
                  try {
                     await ref.read(leagueRepositoryProvider).deleteLocalLeague(widget.leagueId);
                     if (mounted) {
                        Navigator.pop(context); // Close Settings
                        Navigator.pop(context); // Close Dashboard to List
                     }
                  } catch (e) {
                     if (mounted) {
                       setState(() => _isLoading = false);
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                     }
                  }
               },
               child: const Text('Delete'),
           )
        ],
     ));
  }

  @override
  Widget build(BuildContext context) {
     final userId = 'user_1'; // Mock ID usage consistent with Repository
     
     return Scaffold(
       appBar: AppBar(title: const Text('League Settings')),
       body: _isLoading 
         ? const Center(child: CircularProgressIndicator()) 
         : FutureBuilder(
         future: ref.read(leagueRepositoryProvider).getLocalLeague(widget.leagueId),
         builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final league = snapshot.data!;
            final isOwner = league.ownerId == userId;
            
            return ListView(
              children: [
                ListTile(
                  title: const Text('League Name'),
                  subtitle: Text(league.name),
                  trailing: isOwner ? IconButton(icon: const Icon(Icons.edit), onPressed: () => _renameLeague(league.name)) : null,
                ),
                ListTile(
                   title: const Text('Mode'),
                   subtitle: Text(league.mode.toUpperCase()),
                   trailing: isOwner ? IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: () => _toggleMode(league.mode),
                   ) : null,
                ),
                if (isOwner) ...[
                  const Divider(),
                  ListTile(
                     title: const Text('Manage Members'),
                     subtitle: const Text('Ban/Unban players'),
                     trailing: const Icon(Icons.arrow_forward_ios),
                     onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => LeagueMembersScreen(leagueId: widget.leagueId)));
                     },
                  ),
                  if (league.mode == 'formal') ...[
                      ListTile(
                         title: const Text('Manage Seasons'),
                         trailing: const Icon(Icons.arrow_forward_ios),
                         onTap: () {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => SeasonListScreen(leagueId: widget.leagueId, isOwner: true)));
                         },
                      ),
                      ListTile(
                         title: const Text('League Rules'),
                         trailing: const Icon(Icons.arrow_forward_ios),
                         onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => LeagueRulesScreen(leagueId: widget.leagueId)));
                         },
                      ),
                  ],
                ],
                const Divider(),
                ListTile(
                    title: const Text('Delete / Leave League'),
                    subtitle: const Text('Remove from this device'),
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    onTap: _deleteLeague,
                )
              ],
            );
         },
       ),
     );
  }
}
