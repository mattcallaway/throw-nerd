import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/league/league_metadata_service.dart';
import '../../../presentation/providers/di_providers.dart';
import '../../../domain/league/league_file_models.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'schedule_screen.dart';

class SeasonListScreen extends ConsumerStatefulWidget {
  final String leagueId;
  final bool isOwner;

  const SeasonListScreen({super.key, required this.leagueId, required this.isOwner});

  @override
  ConsumerState<SeasonListScreen> createState() => _SeasonListScreenState();
}

class _SeasonListScreenState extends ConsumerState<SeasonListScreen> {
  bool _isLoading = false;
  List<SeasonFile> _seasons = []; 

  @override
  void initState() {
    super.initState();
    _loadSeasons();
  }

  Future<void> _loadSeasons() async {
    try {
       // Ideally fetch from DB repository, but service fetches from file (latest source of truth for admin)
       final seasons = await ref.read(leagueMetadataServiceProvider).fetchSeasons(widget.leagueId);
       if(mounted) setState(() => _seasons = seasons..sort((a,b) => b.startDate.compareTo(a.startDate)));
    } catch (e) {
       // Log
    }
  }

  Future<void> _createSeason() async {
    final nameController = TextEditingController();
    
    await showDialog(context: context, builder: (ctx) => AlertDialog(
       title: const Text('Start New Season'),
       content: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Season Name (e.g. "Spring 2024")')),
         ],
       ),
       actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
             child: const Text('Create'),
             onPressed: () async {
                Navigator.pop(ctx);
                if (nameController.text.isNotEmpty) {
                   await _performCreateSeason(nameController.text);
                }
             },
          )
       ],
    ));
  }

  Future<void> _performCreateSeason(String name) async {
    setState(() => _isLoading = true);
    try {
       final service = ref.read(leagueMetadataServiceProvider);
       final seasonId = const Uuid().v4();
       
       final newSeason = SeasonFile(
          schemaVersion: 1,
          seasonId: seasonId,
          leagueId: widget.leagueId,
          name: name,
          startDate: DateTime.now(),
          createdAt: DateTime.now(),
          createdBy: 'owner', // Mock
       );
       
       await service.saveSeason(widget.leagueId, newSeason);
       
       // Set Active
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
            mode: 'formal', // Force formal? Or keep existing?
            // Usually seasons imply formal.
            activeSeasonId: seasonId,
             bannedMemberIds: meta.bannedMemberIds,
            rules: meta.rules,
            updatedAt: DateTime.now(),
            updatedBy: meta.ownerId,
          );
          await service.updateLeagueMetadata(widget.leagueId, newMeta);
       }
       
       await _loadSeasons();
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Season Created and Activated')));
       
    } catch (e) {
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
       if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seasons')),
      floatingActionButton: widget.isOwner 
        ? FloatingActionButton(onPressed: _createSeason, child: const Icon(Icons.add))
        : null,
      body: _isLoading 
         ? const Center(child: CircularProgressIndicator()) 
         : ListView.builder(
            itemCount: _seasons.length,
            itemBuilder: (ctx, i) {
               final s = _seasons[i];
               // Determine if active? Need league meta.
               // For now just list them.
               return ListTile(
                  title: Text(s.name),
                  subtitle: Text('Started ${DateFormat.yMMMd().format(s.startDate)}'),
                  // trailing: isActive ? Chip(label: Text('Active')) : null
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => ScheduleScreen(
                         leagueId: widget.leagueId, 
                         seasonId: s.seasonId, 
                         isOwner: widget.isOwner
                     )));
                  },
               );
            },
         ),
    );
  }
}
