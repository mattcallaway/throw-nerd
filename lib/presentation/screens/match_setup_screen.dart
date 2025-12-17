import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../domain/scoring/models.dart';
import '../../domain/player.dart';
import '../../domain/location.dart';
import '../../domain/league/models.dart' as domain;
import '../../domain/league/league_file_models.dart';
import '../providers/di_providers.dart';
import '../providers/active_match_notifier.dart';
import '../../data/repositories/league_repository.dart';
import 'scoring_screen.dart';

class MatchSetupScreen extends ConsumerStatefulWidget {
  final String? initialLeagueId;
  const MatchSetupScreen({super.key, this.initialLeagueId});

  @override
  ConsumerState<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends ConsumerState<MatchSetupScreen> {
  // Game Config
  GameType _selectedType = GameType.x01;
  X01Mode _x01Mode = X01Mode.game501;
  bool _doubleIn = false;
  bool _doubleOut = true;
  bool _masterOut = false;
  bool _cutThroat = false;
  int _legs = 1;
  int _sets = 1;
  
  // Selection State
  Set<String> _selectedPlayerIds = {};
  String? _selectedLocationId;

  // League State
  bool _isLeagueGame = false;
  domain.League? _selectedLeague;
  // Season? _selectedSeason; // Future
  
  @override
  void initState() {
    super.initState();
    if (widget.initialLeagueId != null) {
      _isLeagueGame = true;
      // We'll set _selectedLeague once leagues load if needed, 
      // but simpler to let user pick or auto-select in build?
      // For now, allow manual selection or relying on auto-select logic in build if restrictive.
    }
  }

  bool get _canStart {
    // Basic Requirements
    if (_selectedPlayerIds.isEmpty) return false;
    
    // League Requirements
    if (_isLeagueGame) {
      if (_selectedLeague == null) return false;
      // Rules compliance is enforced by UI locks, so assume valid if enabled.
    }
    
    return true;
  }
  
  void _updateEffectiveRules() {
    if (!_isLeagueGame || _selectedLeague == null || _selectedLeague!.rules == null) return;
    
    final rules = _selectedLeague!.rules!;
    
    // 1. Enforce Game Type
    if (!rules.allowedGameTypes.contains(_gameTypeToString(_selectedType))) {
      // Find valid default
      if (rules.allowedGameTypes.contains('501')) {
         _selectedType = GameType.x01;
         _x01Mode = X01Mode.game501;
      } else if (rules.allowedGameTypes.contains('301')) {
         _selectedType = GameType.x01;
         _x01Mode = X01Mode.game301;
      } else if (rules.allowedGameTypes.contains('cricket')) {
         _selectedType = GameType.cricket;
      }
    }
    
    // 2. Enforce Options
    if (rules.doubleOut && _selectedType == GameType.x01) {
      _doubleOut = true;
    }
    
    // 3. Enforce Sets/Legs
    _sets = rules.setsPerMatch > 0 ? rules.setsPerMatch : 1;
    _legs = rules.legsPerSet > 0 ? rules.legsPerSet : 1;
  }
  
  String _gameTypeToString(GameType t) {
    if (t == GameType.cricket) return 'cricket';
    if (t == GameType.x01) {
       return _x01Mode == X01Mode.game301 ? '301' : '501'; 
       // Note: AllowedTypes are usually specific like '501', '301', 'cricket'.
       // Only generic 'x01' isn't standard in the rules model shown previously.
    }
    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    // Watchers
    final playersAsync = ref.watch(allPlayersProvider);
    final locationsAsync = ref.watch(allLocationsProvider);
    final leaguesAsync = ref.watch(allLeaguesProvider);

    // Auto-select initial league if loaded
    if (widget.initialLeagueId != null && _selectedLeague == null && leaguesAsync.hasValue) {
       final l = leaguesAsync.value!.firstWhereOrNull((l) => l.id == widget.initialLeagueId);
       if (l != null) {
         // Defer state update
         WidgetsBinding.instance.addPostFrameCallback((_) {
           if (mounted) {
             setState(() {
                _selectedLeague = l;
                _updateEffectiveRules();
             });
           }
         });
       }
    }

    final rules = _selectedLeague?.rules;
    final isLockedByLeague = _isLeagueGame && _selectedLeague != null && _selectedLeague!.mode == 'formal';

    return Scaffold(
      appBar: AppBar(title: const Text('Setup Match')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SECTION 1: GAME MODE ---
            _buildSectionHeader('Game Mode'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // League Toggle
                    CheckboxListTile(
                      title: const Text('League Game'),
                      value: _isLeagueGame,
                      onChanged: (v) {
                        setState(() {
                          _isLeagueGame = v!;
                          if (!_isLeagueGame) {
                            _selectedLeague = null;
                            // Restore defaults? Or keep as is.
                          } else {
                            // If only one league, auto-select?
                            if (leaguesAsync.value != null && leaguesAsync.value!.length == 1) {
                               _selectedLeague = leaguesAsync.value!.first;
                               _updateEffectiveRules();
                            }
                          }
                        });
                      },
                    ),
                    
                    // League Selector
                    if (_isLeagueGame) ...[
                      const Divider(),
                      leaguesAsync.when(
                        data: (leagues) {
                          if (leagues.isEmpty) return const Text('No leagues joined.');
                          return DropdownButtonFormField<domain.League>(
                             decoration: const InputDecoration(labelText: 'Select League'),
                             value: _selectedLeague,
                             items: leagues.map((l) => DropdownMenuItem(value: l, child: Text(l.name))).toList(),
                             onChanged: (l) {
                               setState(() {
                                 _selectedLeague = l;
                                 _updateEffectiveRules();
                               });
                             },
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (e, s) => Text('Error loading leagues: $e'),
                      ),
                      if (_selectedLeague != null && isLockedByLeague)
                         Padding(
                           padding: const EdgeInsets.only(top: 8.0),
                           child: Row(children: [
                             const Icon(Icons.lock, size: 16, color: Colors.orange),
                             const SizedBox(width: 4),
                             Text('Rules set by ${_selectedLeague!.name}', style: const TextStyle(fontSize: 12, color: Colors.orange)),
                           ]),
                         ),
                      const SizedBox(height: 16),
                    ],

                    // Game Type Segments
                    ValueListenableBuilder( // Reactive to verify locks
                      valueListenable: ValueNotifier(_selectedType), 
                      builder: (ctx, _, __) => SegmentedButton<GameType>(
                        segments: const [
                          ButtonSegment(value: GameType.x01, label: Text('X01')),
                          ButtonSegment(value: GameType.cricket, label: Text('Cricket')),
                        ],
                        selected: {_selectedType},
                        onSelectionChanged: (s) {
                          final newType = s.first;
                          // Check lock
                          if (isLockedByLeague && rules != null) {
                             if (!rules.allowedGameTypes.any((t) => t.contains(newType == GameType.cricket ? 'cricket' : '01'))) {
                                // Shake or Toast?
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Game type not allowed by league rules')));
                                return;
                             }
                          }
                          setState(() => _selectedType = newType);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Sub-options
                    if (_selectedType == GameType.x01) ...[
                      SegmentedButton<X01Mode>(
                        segments: const [
                          ButtonSegment(value: X01Mode.game301, label: Text('301')),
                          ButtonSegment(value: X01Mode.game501, label: Text('501')),
                        ],
                        selected: {_x01Mode},
                        onSelectionChanged: (s) {
                           if (isLockedByLeague && rules != null) {
                             // Assuming 301/501 distinct checks
                             final t = s.first == X01Mode.game301 ? '301' : '501';
                             if (!rules.allowedGameTypes.contains(t)) {
                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$t not allowed by league rules')));
                               return;
                             }
                           }
                           setState(() => _x01Mode = s.first);
                        },
                      ),
                      Opacity(
                        opacity: isLockedByLeague && rules?.doubleOut == true ? 0.5 : 1.0, 
                        child: CheckboxListTile(
                          title: const Text('Double Out'),
                          value: _doubleOut,
                          onChanged: (v) {
                             if (isLockedByLeague && rules?.doubleOut == true && !v!) {
                                // Locked on
                                return;
                             }
                             setState(() => _doubleOut = v!);
                          },
                          secondary: isLockedByLeague && rules?.doubleOut == true ? const Icon(Icons.lock, size: 16) : null,
                        ),
                      ),
                      CheckboxListTile(
                        title: const Text('Double In'),
                        value: _doubleIn,
                        onChanged: (v) => setState(() => _doubleIn = v!),
                      ),
                    ],
                    if (_selectedType == GameType.cricket) ...[
                      CheckboxListTile(
                        title: const Text('Cut-Throat'),
                        value: _cutThroat,
                        onChanged: (v) => setState(() => _cutThroat = v!),
                      ),
                    ],

                    const Divider(),
                    // Sets / Legs
                    Row(
                      children: [
                        Expanded(
                          child: IgnorePointer(
                            ignoring: isLockedByLeague && rules != null && rules.setsPerMatch > 0,
                            child: DropdownButtonFormField<int>(
                              decoration: const InputDecoration(labelText: 'Sets'),
                              value: _sets,
                              items: [1, 3, 5, 7].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                              onChanged: (v) => setState(() => _sets = v!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: IgnorePointer(
                             ignoring: isLockedByLeague && rules != null && rules.legsPerSet > 0,
                             child: DropdownButtonFormField<int>(
                              decoration: const InputDecoration(labelText: 'Legs / Set'),
                              value: _legs,
                              items: [1, 3, 5, 7].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                              onChanged: (v) => setState(() => _legs = v!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isLockedByLeague) const Text('Structure locked by league', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- SECTION 2: PLAYERS ---
            _buildSectionHeader('Players'),
            Card(
              child: Column(
                children: [
                   playersAsync.when(
                     data: (allPlayers) {
                        return Column(
                          children: [
                              // League Members Source
                              if (_isLeagueGame && _selectedLeague != null) 
                                 _LeaguePlayersSection(
                                   leagueId: _selectedLeague!.id,
                                   selectedIds: _selectedPlayerIds,
                                   onToggle: (id, s) => setState(() {
                                      if (s) _selectedPlayerIds.add(id);
                                      else _selectedPlayerIds.remove(id);
                                   }),
                                   allPlayers: allPlayers,
                                 ),
                                 
                              // All / Other Players
                              ExpansionTile(
                                title: const Text('All Players'),
                                init(expanded: true) => this, // Hack or just use default
                                initiallyExpanded: !_isLeagueGame,
                                children: allPlayers.map((p) => CheckboxListTile(
                                  title: Text(p.name),
                                  secondary: CircleAvatar(backgroundColor: p.color, child: Text(p.name.isNotEmpty ? p.name[0] : '?')),
                                  value: _selectedPlayerIds.contains(p.id),
                                  onChanged: (v) {
                                    setState(() {
                                      if (v!) _selectedPlayerIds.add(p.id);
                                      else _selectedPlayerIds.remove(p.id);
                                    });
                                  },
                                )).toList(),
                              ),
                          ],
                        );
                     },
                     loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                     error: (e,s) => Text('Error: $e'),
                   ),
                   ListTile(
                     leading: const Icon(Icons.add),
                     title: const Text('Add New Player'),
                     onTap: _showAddPlayerDialog,
                   ),
                   ListTile(
                     leading: const Icon(Icons.person_add_alt),
                     title: const Text('Add Guest'),
                     onTap: _addGuest,
                   ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- SECTION 3: LOCATION ---
            _buildSectionHeader('Location'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: locationsAsync.when(
                  data: (locations) {
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
                  error: (e,s) => Text('Error: $e'),
                ),
              ),
            ),
            
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _canStart ? _startMatch : null,
        backgroundColor: _canStart ? null : Colors.grey.shade800,
        foregroundColor: _canStart ? null : Colors.grey.shade500,
        label: Row(
          children: [
            const Icon(Icons.play_arrow),
            const SizedBox(width: 8),
            Text(_canStart ? 'Start Game' : 'Incomplete Ssetup'),
          ],
        ),
        // If disabled, we still want to show it but maybe show helper text?
        // FAB doesn't support subtitle easily.
      ),
      bottomSheet: !_canStart && _selectedPlayerIds.isEmpty ? Container(
        padding: const EdgeInsets.all(8),
        color: Colors.black87,
        child: const Text('Select a game type and at least one player to start.', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
        height: 40, width: double.infinity,
      ) : null,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _startMatch() async {
    if (!_canStart) return;

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
      
      final playerList = _selectedPlayerIds.toList(); // Should verify existence?
  
      await ref.read(activeMatchProvider.notifier).startMatch(config, playerList, _selectedLocationId, leagueId: _isLeagueGame ? _selectedLeague?.id : null);
      
      if (mounted) {
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ScoringScreen()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to start: $e')));
    }
  }

  Future<void> _addGuest() async {
     final repo = ref.read(playerRepositoryProvider);
     final newGuest = Player(
       id: DateTime.now().millisecondsSinceEpoch.toString(),
       name: 'Guest ${_selectedPlayerIds.length + 1}',
       color: const Color(0xFF888888),
       avatar: null,
       isGuest: true,
     );
     await repo.createPlayer(newGuest);
     setState(() => _selectedPlayerIds.add(newGuest.id));
  }
  
  Future<void> _showAddPlayerDialog() async {
    final nameCtrl = TextEditingController();
    await showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Add Player'),
      content: TextField(
        controller: nameCtrl,
        decoration: const InputDecoration(labelText: 'Player Name', hintText: 'Enter name'),
        textCapitalization: TextCapitalization.words,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          final name = nameCtrl.text.trim();
          if (name.isEmpty) return;
          
          final repo = ref.read(playerRepositoryProvider);
          // Check duplicate?
          // We don't have direct check but can assume OK or check allPlayersAsync if available.
          
          final newPlayer = Player(
            id: DateTime.now().millisecondsSinceEpoch.toString(), // Should use UUID
            name: name,
            color: Colors.blue, // Randomize?
            avatar: null,
            isGuest: false
          );
          
          await repo.createPlayer(newPlayer);
          if (mounted) {
            setState(() => _selectedPlayerIds.add(newPlayer.id));
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added $name')));
          }
        }, child: const Text('Add')),
      ],
    ));
  }
}

// --- Local Providers & Widgets ---

final allLeaguesProvider = StreamProvider<List<domain.League>>((ref) {
  return ref.watch(leagueRepositoryProvider).watchMyLeagues();
});

class _LeaguePlayersSection extends ConsumerWidget {
  final String leagueId;
  final Set<String> selectedIds;
  final Function(String, bool) onToggle;
  final List<Player> allPlayers;

  const _LeaguePlayersSection({required this.leagueId, required this.selectedIds, required this.onToggle, required this.allPlayers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We derive league members from past matches in this league.
    final matchesAsync = ref.watch(leagueMatchesProvider(leagueId));

    return matchesAsync.when(
      data: (matches) {
         final memberIds = <String>{};
         for (var m in matches) {
           memberIds.addAll(m.playerIds);
         }
         
         if (memberIds.isEmpty) return const SizedBox.shrink();

         final members = allPlayers.where((p) => memberIds.contains(p.id)).toList();
         
         return Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Padding(padding: const EdgeInsets.all(8), child: Text('League Members', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))),
             ...members.map((p) => CheckboxListTile(
                 title: Text(p.name),
                 secondary: CircleAvatar(backgroundColor: p.color, child: Text(p.name[0])),
                 value: selectedIds.contains(p.id),
                 onChanged: (v) => onToggle(p.id, v!),
             )),
             const Divider(),
           ],
         );
      },
      loading: () => const SizedBox(height: 50, child: Center(child: LinearProgressIndicator())),
      error: (e, s) => const SizedBox.shrink(), // Fail silently
    );
  }
}

final leagueMatchesProvider = StreamProvider.family<List<GameMatch>, String>((ref, leagueId) {
   return ref.watch(matchRepositoryProvider).watchMatches(leagueId: leagueId, limit: 100);
});

