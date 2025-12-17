import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:darts_app/domain/game_match.dart';
import 'package:darts_app/domain/scoring/models.dart';
import 'package:darts_app/presentation/providers/di_providers.dart';
import 'package:darts_app/presentation/theme/app_themes.dart';
import 'package:darts_app/presentation/widgets/glass_card.dart';
import 'match_detail_screen.dart';

// Filter State Provider
final matchHistoryFilterProvider = StateProvider<MatchHistoryFilter>((ref) => MatchHistoryFilter());

class MatchHistoryFilter {
  final GameType? gameType;
  final String? locationId;
  
  MatchHistoryFilter({this.gameType, this.locationId});
  
  MatchHistoryFilter copyWith({GameType? gameType, String? locationId}) {
    return MatchHistoryFilter(
      gameType: gameType ?? this.gameType,
      locationId: locationId ?? this.locationId,
    );
  }
}

// Filtered History Provider
final filteredMatchHistoryProvider = StreamProvider<List<GameMatch>>((ref) {
  final repo = ref.watch(matchRepositoryProvider);
  final filter = ref.watch(matchHistoryFilterProvider);
  return repo.watchMatches(type: filter.gameType, locationId: filter.locationId);
});

class MatchHistoryScreen extends ConsumerWidget {
  const MatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final historyAsync = ref.watch(filteredMatchHistoryProvider);
    final filter = ref.watch(matchHistoryFilterProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('HISTORY', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: filter.gameType != null || filter.locationId != null ? theme.accentColor : Colors.white),
            onPressed: () => _showFilterDialog(context, ref),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: SafeArea( // Keep title visible in body? No, appBar is transparent. Use SafeArea.
          child: Column(
            children: [
               _buildActiveFilters(ref, filter),
               Expanded(
                 child: historyAsync.when(
                    data: (matches) {
                      if (matches.isEmpty) {
                        return const Center(child: Text('No matches found', style: TextStyle(color: Colors.white54)));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: matches.length,
                        itemBuilder: (context, index) {
                          final match = matches[index];
                          return _MatchHistoryCard(match: match);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Error: $e')),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActiveFilters(WidgetRef ref, MatchHistoryFilter filter) {
    if (filter.gameType == null && filter.locationId == null) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
           if (filter.gameType != null)
             Padding(
               padding: const EdgeInsets.only(right: 8),
               child: InputChip(
                 label: Text(filter.gameType == GameType.x01 ? 'X01' : 'Cricket'),
                 onDeleted: () => ref.read(matchHistoryFilterProvider.notifier).state = 
                   ref.read(matchHistoryFilterProvider.notifier).state = MatchHistoryFilter(gameType: null, locationId: filter.locationId), // clear type
               ),
             ),
           if (filter.locationId != null)
              // We need location name, but for now just show "Location" or fetch name?
              // Let's just show "Location" label
             Padding(
               padding: const EdgeInsets.only(right: 8),
               child: InputChip(
                 label: const Text('Location'),
                 onDeleted: () => ref.read(matchHistoryFilterProvider.notifier).state = MatchHistoryFilter(gameType: filter.gameType, locationId: null),
               ),
             ),
           TextButton(
             onPressed: () => ref.read(matchHistoryFilterProvider.notifier).state = MatchHistoryFilter(),
             child: const Text('Clear All'),
           )
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
     final theme = ref.read(appThemeProvider);
     showModalBottomSheet(
       context: context,
       backgroundColor: theme.surfaceColor,
       builder: (ctx) => const _FilterSheet(),
     );
  }
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final filter = ref.watch(matchHistoryFilterProvider);
    final locationsAsync = ref.watch(allLocationsProvider); // Assuming we have this? Yes, created in Phase 3.
    
    // If allLocationsProvider isn't global, we fetch repo.
    final locRepo = ref.watch(locationRepositoryProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text('FILTER MATCHES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: theme.accentColor)),
           const SizedBox(height: 24),
           const Text('Game Type', style: TextStyle(color: Colors.grey)),
           const SizedBox(height: 12),
           Row(
             children: [
               _FilterChip(
                 label: 'All', 
                 selected: filter.gameType == null,
                 onTap: () => ref.read(matchHistoryFilterProvider.notifier).state = filter.copyWith(gameType: null), // Reset? 
                 // Null hack: copyWith(gameType: null) won't work if nullable logic not perfect. 
                 // Let's use direct constructor for purity.
                 // Actually logic below:
               ),
               const SizedBox(width: 8),
               _FilterChip(
                 label: 'X01', 
                 selected: filter.gameType == GameType.x01,
                 onTap: () => _updateType(ref, GameType.x01),
               ),
               const SizedBox(width: 8),
               _FilterChip(
                 label: 'Cricket', 
                 selected: filter.gameType == GameType.cricket,
                 onTap: () => _updateType(ref, GameType.cricket),
               ),
             ],
           ),
           const SizedBox(height: 24),
           const Text('Location', style: TextStyle(color: Colors.grey)),
           const SizedBox(height: 12),
           FutureBuilder(
             future: locRepo.getAllLocations(),
             builder: (context, snapshot) {
               if (!snapshot.hasData) return const LinearProgressIndicator();
               final locs = snapshot.data!;
               return Wrap(
                 spacing: 8,
                 children: [
                   _FilterChip(
                      label: 'Any',
                      selected: filter.locationId == null,
                      onTap: () => ref.read(matchHistoryFilterProvider.notifier).state = MatchHistoryFilter(gameType: filter.gameType, locationId: null),
                   ),
                   ...locs.map((l) => _FilterChip(
                      label: l.name,
                      selected: l.id == filter.locationId,
                      onTap: () => ref.read(matchHistoryFilterProvider.notifier).state = filter.copyWith(locationId: l.id),
                   ))
                 ],
               );
             }
           ),
           const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  void _updateType(WidgetRef ref, GameType type) {
    ref.read(matchHistoryFilterProvider.notifier).state = ref.read(matchHistoryFilterProvider.notifier).state.copyWith(gameType: type);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.blueAccent,
      backgroundColor: Colors.white10,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.white70),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _MatchHistoryCard extends ConsumerWidget {
  final GameMatch match;

  const _MatchHistoryCard({required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final dateFormat = DateFormat('MMM d, y • h:mm a');
    
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => MatchDetailScreen(matchId: match.id)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                match.config.type == GameType.x01 ? 'X01 (${match.config.x01Mode?.name.replaceAll('game', '') ?? ''})' : 'CRICKET',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
              ),
              if (match.isCanceled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: theme.dangerColor.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                  child: Text('CANCELED', style: TextStyle(color: theme.dangerColor, fontSize: 10)),
                )
              else if (match.finishedAt != null)
                 Icon(Icons.check_circle, size: 16, color: theme.successColor)
              else
                 const Icon(Icons.timelapse, size: 16, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dateFormat.format(match.createdAt),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
           const SizedBox(height: 8),
           if (match.winnerId != null)
             FutureBuilder(
                future: ref.read(playerRepositoryProvider).getPlayer(match.winnerId!),
                builder: (context, snapshot) {
                   if (snapshot.hasData) {
                     return Text('${snapshot.data!.name} won', style: TextStyle(color: theme.successColor, fontWeight: FontWeight.bold));
                   }
                   return const SizedBox.shrink();
                }
             )
           else
             Text('${match.playerIds.length} Players', style: const TextStyle(color: Colors.white70)),
             
           if (match.locationId != null)
             FutureBuilder(
               future: ref.read(locationRepositoryProvider).getLocation(match.locationId!),
               builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.place, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(snapshot.data!.name, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
               }
             ),
        ],
      ),
    );
  }
}
