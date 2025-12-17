import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darts_app/domain/league/league_file_models.dart';
import 'package:darts_app/services/league/league_metadata_service.dart';
import '../../../presentation/providers/di_providers.dart';

class LeagueRulesScreen extends ConsumerStatefulWidget {
  final String leagueId;

  const LeagueRulesScreen({super.key, required this.leagueId});

  @override
  ConsumerState<LeagueRulesScreen> createState() => _LeagueRulesScreenState();
}

class _LeagueRulesScreenState extends ConsumerState<LeagueRulesScreen> {
  bool _isLoading = false;
  LeagueRules? _rules;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    setState(() => _isLoading = true);
    try {
       final service = ref.read(leagueMetadataServiceProvider);
       final meta = await service.fetchLeagueMetadata(widget.leagueId);
       
       if (meta != null) {
          final userId = 'user_1'; // Mock user
          setState(() {
             _rules = meta.rules ?? LeagueRules();
             _isOwner = meta.ownerId == userId;
          });
       }
    } catch(e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveRules() async {
     setState(() => _isLoading = true);
     try {
       final service = ref.read(leagueMetadataServiceProvider);
       final meta = await service.fetchLeagueMetadata(widget.leagueId);
       
       if (meta != null && _rules != null) {
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
            bannedMemberIds: meta.bannedMemberIds,
            activeSeasonId: meta.activeSeasonId,
            rules: _rules, // Updated
            updatedAt: DateTime.now(),
            updatedBy: meta.ownerId,
          );
          
          await service.updateLeagueMetadata(widget.leagueId, newMeta);
          if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rules Updated')));
       }
     } catch(e) {
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
     } finally {
       if(mounted) setState(() => _isLoading = false);
     }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    final r = _rules ?? LeagueRules();

    return Scaffold(
      appBar: AppBar(title: const Text('League Rules')),
      body: ListView(
        children: [
            SwitchListTile(
               title: const Text('Require X01 Only'),
               subtitle: const Text('Only X01 games count toward leaderboard'),
               value: r.requireX01,
               onChanged: _isOwner ? (v) => setState(() => _rules = LeagueRules(
                  requireX01: v, 
                  allowedGameTypes: r.allowedGameTypes,
                  doubleOut: r.doubleOut,
                  setsPerMatch: r.setsPerMatch,
                  legsPerSet: r.legsPerSet,
                  gamesPerMatchup: r.gamesPerMatchup,
                  requireScheduleForUpload: r.requireScheduleForUpload
               )) : null,
            ),
            SwitchListTile(
              title: const Text('Require Double Out'),
              value: r.doubleOut,
              onChanged: _isOwner ? (v) => setState(() => _rules = LeagueRules(
                  requireX01: r.requireX01, 
                  allowedGameTypes: r.allowedGameTypes,
                  doubleOut: v,
                  setsPerMatch: r.setsPerMatch,
                  legsPerSet: r.legsPerSet,
                  gamesPerMatchup: r.gamesPerMatchup,
                  requireScheduleForUpload: r.requireScheduleForUpload
               )) : null,
            ),
             SwitchListTile(
              title: const Text('Strict Schedule'),
              subtitle: const Text('Matches must match Schedule ID'),
              value: r.requireScheduleForUpload,
              onChanged: _isOwner ? (v) => setState(() => _rules = LeagueRules(
                  requireX01: r.requireX01, 
                  allowedGameTypes: r.allowedGameTypes,
                  doubleOut: r.doubleOut,
                  setsPerMatch: r.setsPerMatch,
                  legsPerSet: r.legsPerSet,
                  gamesPerMatchup: r.gamesPerMatchup,
                  requireScheduleForUpload: v
               )) : null,
            ),
            if (_isOwner) Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton(onPressed: _saveRules, child: const Text('Save Changes')),
            )
        ],
      ),
    );
  }
}
