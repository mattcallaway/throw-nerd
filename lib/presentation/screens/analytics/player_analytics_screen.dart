import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/di_providers.dart';
import '../../../domain/analytics/analytics_models.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/charts/turn_history_chart.dart';
import '../../widgets/charts/segment_heatmap.dart';

class PlayerAnalyticsScreen extends ConsumerStatefulWidget {
  final String playerId;
  final String playerName;

  const PlayerAnalyticsScreen({super.key, required this.playerId, required this.playerName});

  @override
  ConsumerState<PlayerAnalyticsScreen> createState() => _PlayerAnalyticsScreenState();
}

class _PlayerAnalyticsScreenState extends ConsumerState<PlayerAnalyticsScreen> {
  late Future<PlayerMetrics> _metricsFuture;

  @override
  void initState() {
    super.initState();
    _metricsFuture = ref.read(analyticsServiceProvider).getPlayerMetrics(widget.playerId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.playerName} Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: SafeArea(
          child: FutureBuilder<PlayerMetrics>(
            future: _metricsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
              }
              
              final metrics = snapshot.data!;
              final history = metrics.recentHistory.map((t) => t.score).toList().reversed.toList(); // Oldest to newest
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CORE METRICS (X01)', style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.5,
                      children: [
                        StatCard(
                          label: '3-Dart Avg', 
                          value: metrics.avg3Dart.toStringAsFixed(1),
                          color: Colors.greenAccent,
                          icon: Icons.show_chart,
                        ),
                        StatCard(
                           label: 'First-9 Avg', 
                           value: metrics.avgFirst9.toStringAsFixed(1),
                           color: Colors.orangeAccent,
                           icon: Icons.start,
                           subtext: 'First 3 turns only',
                        ),
                        StatCard(
                           label: 'Highest Turn', 
                           value: '${metrics.highestTurn}',
                           color: Colors.purpleAccent,
                           icon: Icons.emoji_events,
                        ),
                        StatCard(
                           label: 'Consistency', 
                           value: '±${metrics.consistency.toStringAsFixed(1)}',
                           color: Colors.blueAccent,
                           icon: Icons.waves,
                           subtext: 'Std Dev of Score',
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    Text('TURN SCORES TREND', style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                         color: Colors.black26,
                         borderRadius: BorderRadius.circular(16),
                         border: Border.all(color: Colors.white12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: TurnHistoryChart(scores: history),
                    ),
                    
                    const SizedBox(height: 32),
                    Text('HEATMAP', style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    if (metrics.segmentStats != null)
                      SegmentHeatmap(stats: metrics.segmentStats!),
                    
                    const SizedBox(height: 32),
                    Text('TOTALS', style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'Darts Thrown', 
                            value: '${metrics.totalDarts}',
                            // color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            label: 'Total Score', 
                            value: '${metrics.totalScore}',
                            // color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}
