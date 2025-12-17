import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/league/league_metadata_service.dart';
import '../../../presentation/providers/di_providers.dart';
import '../../../domain/league/league_file_models.dart';
import 'league_dashboard_screen.dart'; // Reuse provider

class LeagueMembersScreen extends ConsumerStatefulWidget {
  final String leagueId;
  const LeagueMembersScreen({super.key, required this.leagueId});

  @override
  ConsumerState<LeagueMembersScreen> createState() => _LeagueMembersScreenState();
}

class _LeagueMembersScreenState extends ConsumerState<LeagueMembersScreen> {
  List<String> _bannedIds = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBans();
  }

  Future<void> _loadBans() async {
    try {
      final service = ref.read(leagueMetadataServiceProvider);
      final meta = await service.fetchLeagueMetadata(widget.leagueId);
      if (meta != null && mounted) {
        setState(() {
          _bannedIds = List.from(meta.bannedMemberIds);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleBan(String playerId) async {
    setState(() => _loading = true);
    try {
      final service = ref.read(leagueMetadataServiceProvider);
      final meta = await service.fetchLeagueMetadata(widget.leagueId);
      
      if (meta != null) {
        final newBans = List<String>.from(meta.bannedMemberIds);
        if (newBans.contains(playerId)) {
          newBans.remove(playerId);
        } else {
          newBans.add(playerId);
        }

        final newMeta = LeagueFile(
          schemaVersion: meta.schemaVersion,
            leagueId: meta.leagueId,
            name: meta.name,
            createdAt: meta.createdAt,
            createdBy: meta.createdBy,
            provider: meta.provider,
            remoteRootPath: meta.remoteRootPath,
            ownerId: meta.ownerId,
            mode: meta.mode,
            bannedMemberIds: newBans, // Updated
            rules: meta.rules,
            activeSeasonId: meta.activeSeasonId,
            updatedAt: DateTime.now(),
            updatedBy: meta.ownerId,
        );

        await service.updateLeagueMetadata(widget.leagueId, newMeta);
        
        // Reload
        await _loadBans();
        
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text( newBans.contains(playerId) ? 'Member Banned' : 'Member Unbanned')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Get all players from local matches
    final matchesAsync = ref.watch(leagueMatchesProvider(widget.leagueId));

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Members')),
      body: matchesAsync.when(
        data: (matches) {
           final players = <String>{};
           for (var m in matches) {
             players.addAll(m.playerIds);
           }
           final playerList = players.toList();
           
           if (playerList.isEmpty) return const Center(child: Text('No members found in synced matches.'));

           return ListView.builder(
             itemCount: playerList.length,
             itemBuilder: (ctx, i) {
                final pid = playerList[i];
                final isBanned = _bannedIds.contains(pid);
                
                return ListTile(
                   title: Text('Player $pid'), // Resolve name if possible
                   subtitle: Text(isBanned ? 'Banned (Uploads Ignored)' : 'Active'),
                   trailing: Switch(
                      value: !isBanned,
                      onChanged: (val) => _toggleBan(pid),
                      activeColor: Colors.green,
                      inactiveTrackColor: Colors.red,
                   ),
                );
             },
           );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
