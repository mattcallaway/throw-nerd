import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:darts_app/domain/player.dart';
import 'package:darts_app/domain/game_match.dart';
import 'package:darts_app/domain/scoring/models.dart';
import 'package:darts_app/presentation/providers/di_providers.dart';
import 'package:darts_app/presentation/theme/app_themes.dart';
import 'package:darts_app/presentation/widgets/glass_card.dart';
import 'match_detail_screen.dart';

class HeadToHeadScreen extends ConsumerStatefulWidget {
  const HeadToHeadScreen({super.key});

  @override
  ConsumerState<HeadToHeadScreen> createState() => _HeadToHeadScreenState();
}

class _HeadToHeadScreenState extends ConsumerState<HeadToHeadScreen> {
  Player? _p1;
  Player? _p2;
  
  List<GameMatch>? _matches;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final playersAsync = ref.watch(allPlayersProvider);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
         title: const Text('HEAD TO HEAD', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
         centerTitle: true,
         backgroundColor: Colors.transparent,
         elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: SafeArea(
          child: Column(
             children: [
                _buildSelectors(playersAsync),
                Expanded(
                  child: _buildContent(theme),
                )
             ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectors(AsyncValue<List<Player>> playersAsync) {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      child: playersAsync.when(
        data: (players) {
           if (players.length < 2) return const Text('Need at least 2 players');
           
           return Row(
             children: [
                Expanded(child: _PlayerDropdown(
                  value: _p1,
                  items: players,
                  exclude: _p2,
                  hint: 'Player 1',
                  onChanged: (p) {
                    setState(() {
                      _p1 = p;
                      _matches = null;
                    });
                    _fetchMatches();
                  },
                )),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('VS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                Expanded(child: _PlayerDropdown(
                  value: _p2,
                  items: players,
                  exclude: _p1,
                  hint: 'Player 2',
                  onChanged: (p) {
                    setState(() {
                      _p2 = p;
                      _matches = null;
                    });
                    _fetchMatches();
                  },
                )),
             ],
           );
        },
        loading: () => const CircularProgressIndicator(),
        error: (_,__) => const Text('Error loading players'),
      ),
    );
  }
  
  void _fetchMatches() async {
     if (_p1 == null || _p2 == null) return;
     
     setState(() => _loading = true);
     final repo = ref.read(matchRepositoryProvider);
     final matches = await repo.getHeadToHeadMatches(_p1!.id, _p2!.id, limit: 100);
     
     if (mounted) {
       setState(() {
         _matches = matches;
         _loading = false;
       });
     }
  }

  Widget _buildContent(AppThemeData theme) {
    if (_p1 == null || _p2 == null) {
      return const Center(child: Text('Select two players to compare', style: TextStyle(color: Colors.white54)));
    }
    
    if (_loading) return const Center(child: CircularProgressIndicator());
    
    if (_matches != null && _matches!.isEmpty) {
       return const Center(child: Text('No matches found between these players.', style: TextStyle(color: Colors.white54)));
    }
    
    if (_matches == null) return const SizedBox.shrink();

    // Calculate Aggregates
    int p1Wins = 0;
    int p2Wins = 0;
    
    for (final m in _matches!) {
      if (m.winnerId == _p1!.id) p1Wins++;
      if (m.winnerId == _p2!.id) p2Wins++;
    }

    return Column(
      children: [
         // Score Banner
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 16),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: [
               Column(children: [
                 Text('$p1Wins', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: p1Wins > p2Wins ? theme.successColor : Colors.white)),
                 const Text('WINS', style: TextStyle(fontSize: 10, color: Colors.grey))
               ]),
               Column(children: [
                 Text('$p2Wins', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: p2Wins > p1Wins ? theme.successColor : Colors.white)),
                 const Text('WINS', style: TextStyle(fontSize: 10, color: Colors.grey))
               ]),
             ],
           ),
         ),
         const SizedBox(height: 24),
         
         const Divider(color: Colors.white10),
         
         // Match List
         Expanded(
           child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _matches!.length,
              itemBuilder: (context, index) {
                final match = _matches![index];
                final isP1Win = match.winnerId == _p1!.id;
                
                return GestureDetector(
                   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MatchDetailScreen(matchId: match.id))),
                   child: Container(
                     margin: const EdgeInsets.only(bottom: 8),
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.05),
                       borderRadius: BorderRadius.circular(8),
                       border: Border(
                         left: BorderSide(
                           color: isP1Win ? theme.playerColors[0] : (match.winnerId == _p2!.id ? theme.playerColors[1] : Colors.grey),
                           width: 4
                         )
                       )
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(match.config.type == GameType.x01 ? 'X01' : 'Cricket', style: const TextStyle(fontWeight: FontWeight.bold)),
                             Text(DateFormat.MMMd().format(match.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                           ],
                         ),
                         Text(
                           isP1Win ? _p1!.name : (match.winnerId == _p2!.id ? _p2!.name : 'Draw'),
                           style: TextStyle(
                             color: isP1Win ? theme.successColor : (match.winnerId == _p2!.id ? theme.dangerColor : Colors.white),
                             fontWeight: FontWeight.bold
                           )
                         )
                       ],
                     ),
                   ),
                );
              },
           ),
         )
      ],
    );
  }
}

class _PlayerDropdown extends StatelessWidget {
  final Player? value;
  final List<Player> items;
  final Player? exclude;
  final String hint;
  final ValueChanged<Player?> onChanged;

  const _PlayerDropdown({
    required this.value, required this.items, this.exclude, required this.hint, required this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<Player>(
        value: value,
        hint: Text(hint, style: const TextStyle(color: Colors.white54)),
        isExpanded: true,
        dropdownColor: const Color(0xFF252535),
        items: items.where((p) => p.id != exclude?.id).map((p) => DropdownMenuItem(
           value: p,
           child: Row(
             children: [
               CircleAvatar(backgroundColor: p.color, radius: 8),
               const SizedBox(width: 8),
               Text(p.name, overflow: TextOverflow.ellipsis),
             ],
           ),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
