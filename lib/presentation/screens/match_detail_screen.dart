import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:darts_app/domain/game_match.dart';
import 'package:darts_app/domain/player.dart';
import 'package:darts_app/domain/location.dart';
import 'package:darts_app/domain/scoring/models.dart';
import 'package:darts_app/domain/scoring/game_state.dart';
import 'package:darts_app/domain/scoring/stats.dart';
import 'package:darts_app/presentation/providers/di_providers.dart';
import 'package:darts_app/presentation/theme/app_themes.dart';
import 'package:darts_app/presentation/widgets/glass_card.dart';
import 'package:darts_app/presentation/widgets/premium_button.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  final String matchId;
  const MatchDetailScreen({super.key, required this.matchId});

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class MatchDetailsData {
  final GameMatch match;
  final List<Player> players;
  final Location? location;
  final List<Turn> turns;
  
  MatchDetailsData({
    required this.match, 
    required this.players, 
    this.location, 
    required this.turns
  });
}

final matchDetailsProvider = FutureProvider.family<MatchDetailsData?, String>((ref, id) async {
   final matchRepo = ref.watch(matchRepositoryProvider);
   final playerRepo = ref.watch(playerRepositoryProvider);
   final locRepo = ref.watch(locationRepositoryProvider);
   
   final match = await matchRepo.getMatch(id);
   if (match == null) return null;
   
   final players = <Player>[];
   for (final pid in match.playerIds) {
     final p = await playerRepo.getPlayer(pid);
     if (p != null) players.add(p);
   }
   
   Location? location;
   if (match.locationId != null) {
     location = await locRepo.getLocation(match.locationId!);
   }
   
   final turns = await matchRepo.getTurnsForMatch(id);
   
   return MatchDetailsData(match: match, players: players, location: location, turns: turns);
});

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final matchAsync = ref.watch(matchDetailsProvider(widget.matchId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('MATCH DETAILS', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: theme.dangerColor),
            onPressed: () => matchAsync.hasValue && matchAsync.value != null 
              ? _confirmDelete(context, matchAsync.value!.match.id) : null,
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: matchAsync.when(
          data: (data) {
            if (data == null) return const Center(child: Text('Match not found'));
            
            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: NestedScrollView(
                      headerSliverBuilder: (context, _) => [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: _MatchHeader(data: data),
                          ),
                        ),
                        SliverPersistentHeader(
                          delegate: _SliverInternalTabBar(theme, _tabController),
                          pinned: true,
                        ),
                      ],
                      body: TabBarView(
                        controller: _tabController,
                        children: [
                          _StatsView(data: data),
                          _TurnLogView(data: data),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String matchId) {
     final theme = ref.read(appThemeProvider);
     showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
         backgroundColor: theme.surfaceColor,
         title: const Text('Delete Match?'),
         content: const Text('This action cannot be undone and will verify cascading deletes.'),
         actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
           TextButton(
             onPressed: () async {
                final repo = ref.read(matchRepositoryProvider);
                await repo.deleteMatch(matchId);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                }
             },
             child: Text('Delete', style: TextStyle(color: theme.dangerColor)),
           ),
         ],
       ),
     );
  }
}

class _SliverInternalTabBar extends SliverPersistentHeaderDelegate {
  final AppThemeData theme;
  final TabController controller;

  _SliverInternalTabBar(this.theme, this.controller);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: theme.surfaceColor.withOpacity(0.95), // Slight opacity
      child: TabBar(
        controller: controller,
        indicatorColor: theme.accentColor,
        labelColor: theme.accentColor,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: 'STATS'),
          Tab(text: 'LOG'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;
  @override
  double get minExtent => 48;
  @override
  bool shouldRebuild(covariant _SliverInternalTabBar oldDelegate) => false;
}

class _MatchHeader extends StatelessWidget {
  final MatchDetailsData data;
  const _MatchHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     data.match.config.type == GameType.x01 
                       ? 'X01 (${data.match.config.x01Mode?.toString().split('.').last.replaceAll('game', '') ?? ''})' 
                       : 'CRICKET',
                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                   ),
                   if (data.location != null)
                     Row(
                       children: [
                         const Icon(Icons.place, size: 14, color: Colors.grey),
                         const SizedBox(width: 4),
                         Text(data.location!.name, style: const TextStyle(color: Colors.grey)),
                       ],
                     ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Text(DateFormat.MMMEd().format(data.match.createdAt), style: const TextStyle(color: Colors.grey)),
                   Text(DateFormat.jm().format(data.match.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Winner Banner
          if (data.match.winnerId != null)
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(
                 color: Colors.green.withOpacity(0.2),
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: Colors.green.withOpacity(0.5)),
               ),
               child: Center(
                 child: Text(
                   'WINNER: ${data.players.firstWhere((p) => p.id == data.match.winnerId).name}',
                   style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, letterSpacing: 1),
                 ),
               ),
             ),
        ],
      ),
    );
  }
}

class _StatsView extends StatelessWidget {
  final MatchDetailsData data;
  const _StatsView({required this.data});

  @override
  Widget build(BuildContext context) {
    // Reconstruct state for stats
    final state = GameState(
       config: data.match.config,
       playerScores: const {}, // Minimal state for StatsCalculator
       playerOrder: data.players.map((p) => p.id).toList(),
       history: data.turns,
       currentPlayerIndex: 0,
       winnerId: data.match.winnerId,
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.players.length,
      itemBuilder: (context, index) {
        final p = data.players[index];
        final stats = StatsCalculator.calculate(state, p.id);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(backgroundColor: p.color, radius: 14, child: Text(p.name[0])),
                    const SizedBox(width: 12),
                    Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(color: Colors.white24, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: 'Avg', value: stats.average.toStringAsFixed(1)),
                    _StatItem(label: 'High', value: '${stats.highestTurn}'),
                    _StatItem(label: 'Darts', value: data.turns.where((t) => t.playerId == p.id).expand((t) => t.darts).length.toString()),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                   children: [
                      if (data.match.config.type == GameType.cricket) 
                         _StatItem(label: 'MPR', value: stats.mpr.toStringAsFixed(2)),
                      if (data.match.config.type == GameType.x01)
                         _StatItem(label: '1st 9', value: stats.first9Average.toStringAsFixed(1)),

                      _StatItem(label: 'Doubles', value: '${stats.doublesHit}'),
                      _StatItem(label: 'Triples', value: '${stats.triplesHit}'),
                   ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _TurnLogView extends StatelessWidget {
  final MatchDetailsData data;
  const _TurnLogView({required this.data});

  @override
  Widget build(BuildContext context) {
    // Reverse turns for log
    final turns = data.turns.reversed.toList();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: turns.length,
      itemBuilder: (context, index) {
        final t = turns[index];
        final p = data.players.firstWhere((pl) => pl.id == t.playerId, orElse: () => Player(id: '', name: 'Unknown', color: Colors.grey));
        // Calculate total for turn
        final total = t.darts.fold(0, (sum, d) => sum + d.total);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text('#${turns.length - index}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(width: 12),
              CircleAvatar(backgroundColor: p.color, radius: 8),
              const SizedBox(width: 8),
              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('$total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: t.darts.map((d) => Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(d.toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  )).toList(),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
