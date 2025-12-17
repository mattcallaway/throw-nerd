import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/scoring/models.dart';
import '../../domain/player.dart';
import '../../domain/location.dart';
import '../providers/di_providers.dart';
import '../providers/active_match_notifier.dart';
import 'scoring_screen.dart';

class MatchSetupScreen extends ConsumerStatefulWidget {
  final String? leagueId;
  const MatchSetupScreen({super.key, this.leagueId});

  @override
  ConsumerState<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends ConsumerState<MatchSetupScreen> {
  GameType _selectedType = GameType.x01;
  X01Mode _x01Mode = X01Mode.game501;
  bool _doubleIn = false;
  bool _doubleOut = true;
  bool _masterOut = false;
  bool _cutThroat = false;
  int _legs = 1;
  int _sets = 1; // NEW
  Set<String> _selectedPlayerIds = {};
  String? _selectedLocationId;

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(allPlayersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Setup Match')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        controlsBuilder: (context, details) {
           final isLast = _currentStep == 3;
           return Padding(
             padding: const EdgeInsets.only(top: 16.0),
             child: Row(
               children: [
                 FilledButton(
                   onPressed: details.onStepContinue,
                   child: Text(isLast ? 'Start Match' : 'Continue'),
                 ),
                 const SizedBox(width: 8),
                 if (_currentStep > 0)
                   TextButton(
                     onPressed: details.onStepCancel,
                     child: const Text('Back'),
                   ),
               ],
             ),
           );
        },
        steps: [
          Step(
            title: const Text('Game Mode'),
            content: Column(
              children: [
                SegmentedButton<GameType>(
                  segments: const [
                    ButtonSegment(value: GameType.x01, label: Text('X01')),
                    ButtonSegment(value: GameType.cricket, label: Text('Cricket')),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (s) => setState(() => _selectedType = s.first),
                ),
                const SizedBox(height: 16),
                if (_selectedType == GameType.x01) ...[
                  SegmentedButton<X01Mode>(
                    segments: const [
                      ButtonSegment(value: X01Mode.game301, label: Text('301')),
                      ButtonSegment(value: X01Mode.game501, label: Text('501')),
                    ],
                    selected: {_x01Mode},
                    onSelectionChanged: (s) => setState(() => _x01Mode = s.first),
                  ),
                  CheckboxListTile(
                    title: const Text('Double In'),
                    value: _doubleIn,
                    onChanged: (v) => setState(() => _doubleIn = v!),
                  ),
                  CheckboxListTile(
                    title: const Text('Double Out'),
                    value: _doubleOut,
                    onChanged: (v) => setState(() => _doubleOut = v!),
                  ),
                ],
                if (_selectedType == GameType.cricket) ...[
                  CheckboxListTile(
                    title: const Text('Cut-Throat'),
                    subtitle: const Text('Points go to opponents'),
                    value: _cutThroat,
                    onChanged: (v) => setState(() => _cutThroat = v!),
                  ),
                ],
              ],
            ),
          ),
          Step(
            title: const Text('Players'),
            content: playersAsync.when(
              data: (players) => Column(
                children: [
                   ...players.map((p) => CheckboxListTile(
                     title: Text(p.name),
                     secondary: CircleAvatar(backgroundColor: p.color, child: Text(p.name[0])),
                     value: _selectedPlayerIds.contains(p.id),
                     onChanged: (v) {
                       setState(() {
                         if (v!) _selectedPlayerIds.add(p.id);
                         else _selectedPlayerIds.remove(p.id);
                       });
                     },
                   )),
                   ListTile(
                     leading: const Icon(Icons.add),
                     title: const Text('Add Guest'),
                     onTap: _addGuest,
                   ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error: $e'),
            ),
          ),
          Step(
            title: const Text('Location'),
                content: Consumer(
                  builder: (context, ref, _) {
                    final locAsync = ref.watch(allLocationsProvider);
                    return locAsync.when(
                      data: (locations) {
                         if (locations.isEmpty) return const Text('No locations added');
                         return DropdownButton<String?>(
                           value: _selectedLocationId,
                           hint: const Text('Select Location (Optional)'),
                           isExpanded: true,
                           items: [
                             const DropdownMenuItem(value: null, child: Text('None')),
                             ...locations.map((l) => DropdownMenuItem(value: l.id, child: Text(l.name))),
                           ],
                           onChanged: (v) => setState(() => _selectedLocationId = v),
                         );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (e, s) => Text('Error: $e'),
                    );
                  }
                ),
              ),
          Step(
            title: const Text('Rules'),
            content: Column(
                children: [
                   ListTile(
                     title: const Text('Sets (Best of)'),
                     subtitle: Text('First to ${(_sets/2).floor() + 1} sets wins match'),
                     trailing: DropdownButton<int>(
                       value: _sets,
                       items: [1, 3, 5, 7].map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                       onChanged: (v) => setState(() => _sets = v!),
                     ),
                   ),
                   ListTile(
                     title: const Text('Legs per Set (Best of)'),
                     subtitle: Text('First to ${(_legs/2).floor() + 1} legs wins set'),
                     trailing: DropdownButton<int>(
                       value: _legs,
                       items: [1, 3, 5, 7].map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                       onChanged: (v) => setState(() => _legs = v!),
                     )
                   )
                ],
            ),
          ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _startMatch,
            child: const Icon(Icons.check),
          ),
        );
      }
    
      int _currentStep = 0;
      void _onStepContinue() {
        if (_currentStep < 3) {
           setState(() => _currentStep++);
        } else {
           _startMatch();
        }
      }
      void _onStepCancel() {
         if (_currentStep > 0) setState(() => _currentStep--);
      }
    
    Future<void> _startMatch() async {
        if (_selectedPlayerIds.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one player')));
          return;
        }
    
        try {
          final config = GameConfig(
            type: _selectedType,
            x01Mode: _selectedType == GameType.x01 ? _x01Mode : null,
            doubleIn: _doubleIn,
            doubleOut: _doubleOut,
            masterOut: _masterOut,
            cutThroatCricket: _cutThroat,
            legs: _legs,
            sets: _sets,
          );
          
          final playerList = _selectedPlayerIds.toList();
      
          await ref.read(activeMatchProvider.notifier).startMatch(config, playerList, _selectedLocationId, leagueId: widget.leagueId);
          
          if (mounted) {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ScoringScreen()));
          }
        } catch (e, st) {
          debugPrint('Start Match Error: $e\n$st');
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to start match: $e')));
          }
        }
      }
    
      Future<void> _addGuest() async {
         final repo = ref.read(playerRepositoryProvider);
         final newGuest = Player(
           id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
           name: 'Guest ${_selectedPlayerIds.length + 1}',
           color: const Color(0xFF888888),
           avatar: null,
         );
         
         await repo.createPlayer(newGuest);
         setState(() {
            _selectedPlayerIds.add(newGuest.id);
         });
      }
    }
    
    // Providers
    final allPlayersProvider = StreamProvider<List<Player>>((ref) {
      final repo = ref.watch(playerRepositoryProvider);
      return repo.watchAllPlayers();
    });
    
    final allLocationsProvider = StreamProvider<List<Location>>((ref) {
      final repo = ref.watch(locationRepositoryProvider);
      return repo.watchAllLocations();
    });
