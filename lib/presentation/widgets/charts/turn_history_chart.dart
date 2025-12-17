import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TurnHistoryChart extends StatelessWidget {
  final List<int> scores; // Ordered Oldest -> Newest

  const TurnHistoryChart({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) return const Center(child: Text('No Data', style: TextStyle(color: Colors.white30)));

    final spots = scores.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.cyanAccent, // Neon theme
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.cyanAccent.withOpacity(0.1),
            ),
          ),
        ],
        titlesData: const FlTitlesData(show: false), 
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 180,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
