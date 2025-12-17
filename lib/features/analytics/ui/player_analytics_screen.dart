
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../presentation/providers/di_providers.dart';
import '../../../domain/analytics/analytics_models.dart';
import 'widgets/stat_card.dart';
import 'widgets/outcome_bar_chart.dart';

class PlayerAnalyticsScreen extends ConsumerStatefulWidget {
  final String playerId;
  final String playerName;

  const PlayerAnalyticsScreen({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  ConsumerState<PlayerAnalyticsScreen> createState() => _PlayerAnalyticsScreenState();
}

class _PlayerAnalyticsScreenState extends ConsumerState<PlayerAnalyticsScreen> {
  bool _nerdMode = false;

  @override
  Widget build(BuildContext context) {
    final analyticsService = ref.watch(analyticsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.playerName} Stats'),
        actions: [
          Row(
            children: [
              const Text('Nerd Mode'),
              Switch(
                value: _nerdMode,
                onChanged: (val) {
                  setState(() {
                    _nerdMode = val;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<PlayerMetrics>(
        future: analyticsService.getPlayerMetrics(widget.playerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final metrics = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // Added Value! Bottom Padding for FAB/Buttons
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewSection(context, metrics),
                const SizedBox(height: 24),
                if (_nerdMode) ...[
                   _buildNerdSection(context, metrics),
                ] else ...[
                   _buildRecentHistorySimple(context, metrics),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context, PlayerMetrics metrics) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        StatCard(
          label: '3-Dart Avg',
          value: metrics.avg3Dart.toStringAsFixed(1),
          icon: Icons.show_chart,
        ),
        StatCard(
          label: 'Checkout %',
          value: '${metrics.checkoutAccuracy.toStringAsFixed(1)}%',
          subValue: '${metrics.checkoutCount} hits',
          icon: Icons.check_circle_outline,
          color: Colors.greenAccent,
        ),
        StatCard(
          label: 'First 9 Avg',
          value: metrics.avgFirst9.toStringAsFixed(1),
          icon: Icons.looks_one,
        ),
        StatCard(
          label: 'Best Turn',
          value: metrics.highestTurn.toString(),
          icon: Icons.emoji_events_outlined,
          color: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildNerdSection(BuildContext context, PlayerMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Deep Dive', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        StatCard(
           label: 'Consistency (StdDev)',
           value: metrics.consistency.toStringAsFixed(2),
           subValue: 'Lower is better',
           icon: Icons.center_focus_strong,
           onTap: () => _showMetricInfo(context, 'Consistency', 'Standard Deviation of your turn scores (X01). Lower means you are more consistent in your scoring power.'),
        ),
        const SizedBox(height: 12),
        if (metrics.cricketGamesPlayed > 0) ...[
           StatCard(
             label: 'Cricket MPR',
             value: metrics.mpr.toStringAsFixed(2),
             subValue: '${metrics.cricketGamesPlayed} games',
             icon: Icons.track_changes,
             color: Colors.purpleAccent,
             onTap: () => _showMetricInfo(context, 'MPR (Marks Per Round)', 'Average number of marks (closed numbers) scored per turn in Cricket. 3.0+ is competitive.'),
           ),
           const SizedBox(height: 12),
        ],
        Row(
           children: [
              Text('Checkout Breakdown', style: Theme.of(context).textTheme.titleMedium),
              IconButton(onPressed: () => _showMetricInfo(context, 'Checkouts', 'Counts standard Double Out finishes as 100%. Also counts Single Out finishes (game specific) as a hit. Attempts are estimated based on "Double" opportunities remaining.'), icon: const Icon(Icons.info_outline, size: 20)),
           ],
        ),
        const SizedBox(height: 8),
        _buildCheckoutTable(context, metrics),
        const SizedBox(height: 24),
        Text('Segment Distribution', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        // Histogram
        if (metrics.segmentStats != null)
           OutcomeBarChart(distribution: metrics.segmentStats!.distribution)
        else
           const Text('No data'),
      ],
    );
  }

  void _showMetricInfo(BuildContext context, String title, String body) {
     showDialog(context: context, builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
        ],
     ));
  }
  
  Widget _buildCheckoutTable(BuildContext context, PlayerMetrics metrics) {
    // 1. Filter and Aggregation
    final checkoutCounts = <String, int>{};
    
    for (final turn in metrics.recentHistory) {
      if (turn.startingScore != null && turn.score == turn.startingScore) {
         if (turn.darts.isNotEmpty && turn.darts.last.isDouble) {
            final key = turn.darts.last.toString(); // e.g. D20
            checkoutCounts[key] = (checkoutCounts[key] ?? 0) + 1;
         }
      }
    }
    
    if (checkoutCounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        color: Colors.white10,
        child: const Text('No checkouts recorded yet.', textAlign: TextAlign.center),
      );
    }
    
    // Sort
    final sorted = checkoutCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    return Table(
      border: TableBorder.all(color: Colors.white24),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Colors.white10),
          children: [
            Padding(padding: EdgeInsets.all(8), child: Text('Double', style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(8), child: Text('Count', style: TextStyle(fontWeight: FontWeight.bold))),
          ]
        ),
        ...sorted.map((e) => TableRow(
           children: [
             Padding(padding: const EdgeInsets.all(8), child: Text(e.key)),
             Padding(padding: const EdgeInsets.all(8), child: Text(e.value.toString())),
           ]
        ))
      ],
    );
  }

  Widget _buildRecentHistorySimple(BuildContext context, PlayerMetrics metrics) {
    return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          Text('Recent Turns', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ListView.builder(
             shrinkWrap: true,
             physics: const NeverScrollableScrollPhysics(),
             itemCount: metrics.recentHistory.take(10).length,
             itemBuilder: (ctx, i) {
                final turn = metrics.recentHistory[i];
                return ListTile(
                   title: Text('${turn.score} points'),
                   subtitle: Text(DateFormat.yMMMd().add_jm().format(turn.createdAt)),
                   trailing: Text(turn.darts.map((d) => d.toString()).join(', ')),
                );
             },
          )
       ],
    );
  }
}
