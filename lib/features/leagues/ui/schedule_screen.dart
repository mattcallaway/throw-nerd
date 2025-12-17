import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darts_app/domain/league/league_file_models.dart';
import 'package:darts_app/services/league/league_metadata_service.dart';
import '../../../presentation/providers/di_providers.dart';
import '../../../../services/league/schedule_generator_service.dart';
import '../ui/league_dashboard_screen.dart'; // for leagueMatchesProvider reuse or similar? We need all players.
import '../../../../domain/player.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  final String leagueId;
  final String seasonId;
  final bool isOwner;

  const ScheduleScreen({super.key, required this.leagueId, required this.seasonId, required this.isOwner});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  bool _isLoading = false;
  ScheduleFile? _schedule;
  List<Player> _allPlayers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(leagueMetadataServiceProvider);
      // Fetch Schedule
      var schedule = await service.fetchSchedule(widget.leagueId, widget.seasonId);
      
      // Fetch Players (Sync from past matches for now, or use Member List if stored)
      // Since we don't have a direct "LeagueMember" repository yet, we derive from local matches
      // But for scheduling we usually want ALL potential players.
      // We will assume `allPlayersProvider` contains everyone including league members if they have been synced.
      // Or better: `_allPlayers` should come from `leagueMatchesProvider` unique set + any manual adds.
      // Actually `LeagueSettingsScreen` implies `league_members_screen` derives from matches.
      
      // Let's use `allPlayersProvider` (which is local DB)
      // If synced, players exist in DB.
      final players = await ref.read(allPlayersProvider.future);
      _allPlayers = players; // Filter by league if needed? For now allow all local.
      
      if (schedule == null && widget.isOwner) {
         schedule = ScheduleFile(
            schemaVersion: 1,
            seasonId: widget.seasonId,
            leagueId: widget.leagueId,
            updatedAt: DateTime.now(),
            updatedBy: 'owner',
            format: ScheduleFormat(type: 'round_robin', gamesPerMatchup: 1, setsPerMatch: 1, legsPerSet: 1, doubleOut: false, allowedGameTypes: ['501']),
            gameDays: [],
         );
      }
      
      if(mounted) setState(() => _schedule = schedule);
    } catch(e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  // --- ACTIONS ---

  Future<void> _generateSchedule() async {
    // 1. Select Players
    final selectedPlayers = <String>{};
    
    await showDialog(context: context, builder: (ctx) => StatefulBuilder(
       builder: (context, setDialogState) {
          return AlertDialog(
             title: const Text('Generate Round Robin'),
             content: SizedBox(
               width: double.maxFinite,
               height: 300,
               child: Column(
                 children: [
                    const Text('Select Players for this Season:'),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: _allPlayers.map((p) => CheckboxListTile(
                          title: Text(p.name),
                          value: selectedPlayers.contains(p.id),
                          onChanged: (v) {
                             setDialogState(() {
                               if (v!) selectedPlayers.add(p.id);
                               else selectedPlayers.remove(p.id);
                             });
                          },
                        )).toList(),
                      ),
                    ),
                 ],
               ),
             ),
             actions: [
               TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
               FilledButton(
                 onPressed: selectedPlayers.length < 2 ? null : () {
                    Navigator.pop(ctx);
                    _performGeneration(selectedPlayers.toList());
                 }, 
                 child: const Text('Generate')
               ),
             ],
          );
       }
    ));
  }
  
  Future<void> _performGeneration(List<String> playerIds) async {
     setState(() => _isLoading = true);
     try {
       final newSchedule = ScheduleGeneratorService.generateRoundRobin(
         playerIds: playerIds,
         seasonId: widget.seasonId,
         leagueId: widget.leagueId,
         startDate: DateTime.now(), // Could ask user
         updatedBy: 'owner',
       );
       
       setState(() => _schedule = newSchedule);
       await _saveSchedule(newSchedule);
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Generated ${newSchedule.gameDays.length} weeks of matches')));
       
     } catch (e) {
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Generation Failed: $e')));
     } finally {
       if(mounted) setState(() => _isLoading = false);
     }
  }

  Future<void> _addGameDay() async {
     if (_schedule == null) return;
     
     final newDayIndex = (_schedule!.gameDays.length) + 1;
     final newDay = GameDay(
        gameDayId: const Uuid().v4(),
        index: newDayIndex,
        date: DateTime.now().add(Duration(days: newDayIndex * 7)),
        scheduledMatches: [],
        notes: 'Week $newDayIndex'
     );
     
     final updated = _schedule!.copyWith(gameDays: [..._schedule!.gameDays, newDay]);
     
     await _saveSchedule(updated);
  }

  Future<void> _addMatch(GameDay day) async {
     // Dialog to select P1, P2
     String? p1;
     String? p2;
     
     await showDialog(context: context, builder: (ctx) => StatefulBuilder(
       builder: (context, setDialogState) {
          return AlertDialog(
             title: const Text('Add Match'),
             content: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Home Player'),
                    value: p1,
                    items: _allPlayers.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                    onChanged: (v) => setDialogState(() => p1 = v),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Away Player'),
                    value: p2,
                    items: _allPlayers.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                    onChanged: (v) => setDialogState(() => p2 = v),
                  ),
               ],
             ),
             actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                FilledButton(
                  onPressed: (p1 == null || p2 == null || p1 == p2) ? null : () {
                     Navigator.pop(ctx);
                     _performAddMatch(day, p1!, p2!);
                  },
                  child: const Text('Add'),
                )
             ],
          );
       }
     ));
  }
  
  Future<void> _performAddMatch(GameDay day, String p1, String p2) async {
     final match = ScheduledMatch(
       scheduleMatchId: const Uuid().v4(),
       homePlayerId: p1,
       awayPlayerId: p2,
       stage: 'regular',
       order: day.scheduledMatches.length + 1,
     );
     
     // Update nested list
     final newGameDays = _schedule!.gameDays.map((d) {
        if (d.gameDayId == day.gameDayId) {
           return GameDay(
             gameDayId: d.gameDayId,
             index: d.index,
             date: d.date,
             notes: d.notes,
             scheduledMatches: [...d.scheduledMatches, match],
           );
        }
        return d;
     }).toList();
     
     final updated = _schedule!.copyWith(gameDays: newGameDays);
     await _saveSchedule(updated);
  }
  
  Future<void> _deleteMatch(GameDay day, String matchId) async {
     final newGameDays = _schedule!.gameDays.map((d) {
        if (d.gameDayId == day.gameDayId) {
           return GameDay(
             gameDayId: d.gameDayId,
             index: d.index,
             date: d.date,
             notes: d.notes,
             scheduledMatches: d.scheduledMatches.where((m) => m.scheduleMatchId != matchId).toList(),
           );
        }
        return d;
     }).toList();
     final updated = _schedule!.copyWith(gameDays: newGameDays);
     await _saveSchedule(updated);
  }

  Future<void> _saveSchedule(ScheduleFile schedule) async {
    setState(() => _schedule = schedule); // Optimistic
    try {
       await ref.read(leagueMetadataServiceProvider).saveSchedule(widget.leagueId, schedule);
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _schedule == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    final s = _schedule;
    if (s == null) return Scaffold(appBar: AppBar(title: const Text('Schedule')), body: const Center(child: Text('No Schedule')));

    return Scaffold(
       appBar: AppBar(
         title: const Text('Schedule'),
         actions: [
            if (widget.isOwner) IconButton(
               icon: const Icon(Icons.autorenew),
               tooltip: 'Generate Round Robin',
               onPressed: _generateSchedule,
            )
         ],
       ),
       floatingActionButton: widget.isOwner ? FloatingActionButton(onPressed: _addGameDay, child: const Icon(Icons.add)) : null,
       body: s.gameDays.isEmpty 
          ? Center(child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Text('No games scheduled.'),
                 if (widget.isOwner) TextButton(onPressed: _generateSchedule, child: const Text('Generate Schedule')),
               ],
            ))
          : ListView.builder(
         itemCount: s.gameDays.length,
         itemBuilder: (ctx, i) {
            final day = s.gameDays[i];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ExpansionTile(
                 title: Text('Week ${day.index} - ${DateFormat.MMMd().format(day.date)}'),
                 subtitle: Text('${day.scheduledMatches.length} Matches'),
                 children: [
                    if (day.scheduledMatches.isEmpty) 
                       const ListTile(title: Text('No matches scheduled')),
                    
                    ...day.scheduledMatches.map((m) {
                       final p1 = _allPlayers.firstWhere((p) => p.id == m.homePlayerId, orElse: () => Player(id: m.homePlayerId, name: 'Unknown', color: Colors.grey));
                       final p2 = _allPlayers.firstWhere((p) => p.id == m.awayPlayerId, orElse: () => Player(id: m.awayPlayerId, name: 'Unknown', color: Colors.grey));
                       
                       return ListTile(
                          title: Text('${p1.name} vs ${p2.name}'),
                          subtitle: Text(m.stage),
                          trailing: widget.isOwner ? IconButton(
                             icon: const Icon(Icons.delete, size: 16),
                             onPressed: () => _deleteMatch(day, m.scheduleMatchId),
                          ) : null,
                       );
                    }),
                    
                    if (widget.isOwner) 
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Match'),
                          onPressed: () => _addMatch(day),
                        ),
                      )
                 ],
              ),
            );
         },
       ),
    );
  }
}

// Helpers for copyWith which are missing in original generated file?
// The file models are JsonSerializable but copyWith is usually manual or Freezed.
// I'll add extension methods or just manual construction.
extension ScheduleFileCopy on ScheduleFile {
   ScheduleFile copyWith({List<GameDay>? gameDays}) {
      return ScheduleFile(
         schemaVersion: schemaVersion,
         seasonId: seasonId,
         leagueId: leagueId,
         updatedAt: DateTime.now(),
         updatedBy: updatedBy,
         format: format,
         gameDays: gameDays ?? this.gameDays,
         playoffs: playoffs
      );
   }
}

