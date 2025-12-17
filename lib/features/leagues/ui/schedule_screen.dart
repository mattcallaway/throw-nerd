import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darts_app/domain/league/league_file_models.dart';
import 'package:darts_app/services/league/league_metadata_service.dart';
import '../../../presentation/providers/di_providers.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

// Very basic schedule editor
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

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(leagueMetadataServiceProvider);
      // Try fetch
      var schedule = await service.fetchSchedule(widget.leagueId, widget.seasonId);
      
      if (schedule == null && widget.isOwner) {
         // Create default empty schedule
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
     
     final updatedSchedule = ScheduleFile(
         schemaVersion: _schedule!.schemaVersion,
         seasonId: _schedule!.seasonId,
         leagueId: _schedule!.leagueId,
         updatedAt: DateTime.now(),
         updatedBy: _schedule!.updatedBy,
         format: _schedule!.format,
         gameDays: [..._schedule!.gameDays, newDay],
         playoffs: _schedule!.playoffs
     );
     
     if(mounted) setState(() => _schedule = updatedSchedule);
     await _saveSchedule(updatedSchedule);
  }

  Future<void> _saveSchedule(ScheduleFile schedule) async {
    setState(() => _isLoading = true);
    try {
       await ref.read(leagueMetadataServiceProvider).saveSchedule(widget.leagueId, schedule);
    } catch (e) {
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    } finally {
       if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _schedule == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    final s = _schedule;
    if (s == null) return Scaffold(appBar: AppBar(title: const Text('Schedule')), body: const Center(child: Text('No Schedule')));

    return Scaffold(
       appBar: AppBar(title: const Text('Schedule')),
       floatingActionButton: widget.isOwner ? FloatingActionButton(onPressed: _addGameDay, child: const Icon(Icons.add)) : null,
       body: ListView.builder(
         itemCount: s.gameDays.length,
         itemBuilder: (ctx, i) {
            final day = s.gameDays[i];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ExpansionTile(
                 title: Text('Week ${day.index} - ${DateFormat.MMMd().format(day.date)}'),
                 subtitle: Text('${day.scheduledMatches.length} Matches'),
                 children: [
                    if (day.scheduledMatches.isEmpty) const ListTile(title: Text('No matches scheduled')),
                    // List matches
                    // To edit matches, we need player selection which is complex (requires Sync players).
                    // For now, just a placeholder "Add Match" button if Owner.
                    if (widget.isOwner) 
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Match (Placeholder)'),
                        onPressed: () { 
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Match Editor is coming soon.')));
                        },
                      )
                 ],
              ),
            );
         },
       ),
    );
  }
}
