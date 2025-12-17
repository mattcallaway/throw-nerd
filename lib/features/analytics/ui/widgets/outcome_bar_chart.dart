
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OutcomeBarChart extends StatelessWidget {
  final Map<String, int> distribution;

  const OutcomeBarChart({super.key, required this.distribution});

  @override
  Widget build(BuildContext context) {
    // Aggregates
    int singles = 0;
    int doubles = 0;
    int triples = 0;
    int miss = 0;
    int bull = 0; // 25 or 50

    distribution.forEach((key, count) {
      // Key format "value-multiplier"
      final parts = key.split('-');
      final val = int.tryParse(parts[0]) ?? 0;
      final mult = int.tryParse(parts[1]) ?? 1;

      if (val == 0) {
        miss += count;
      } else if (val == 25) {
        bull += count;
      } else {
        if (mult == 1) singles += count;
        if (mult == 2) doubles += count;
        if (mult == 3) triples += count;
      }
    });

    final maxVal = [singles, doubles, triples, miss, bull].reduce((a, b) => a > b ? a : b).toDouble();

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.2, // Headroom
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(

               getTooltipItem: (group, groupIndex, rod, rodIndex) {
                 String label = '';
                 switch(group.x) {
                   case 0: label = 'Single'; break;
                   case 1: label = 'Double'; break;
                   case 2: label = 'Triple'; break;
                   case 3: label = 'Bull'; break;
                   case 4: label = 'Miss'; break;
                 }
                 return BarTooltipItem(
                   '$label\n',
                   const TextStyle(
                     color: Colors.white,
                     fontWeight: FontWeight.bold,
                   ),
                   children: [
                     TextSpan(
                       text: (rod.toY).toInt().toString(),
                       style: const TextStyle(
                         color: Colors.yellow,
                       ),
                     ),
                   ],
                 );
               } 
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  );
                  Widget text;
                  switch (value.toInt()) {
                    case 0:
                      text = const Text('S', style: style);
                      break;
                    case 1:
                      text = const Text('D', style: style);
                      break;
                    case 2:
                      text = const Text('T', style: style);
                      break;
                    case 3:
                      text = const Text('B', style: style);
                      break;
                    case 4:
                      text = const Text('X', style: style); // Miss
                      break;
                    default:
                      text = const Text('', style: style);
                      break;
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: text,
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40, 
                getTitlesWidget: (value, meta) {
                   if (value % 1 != 0) return const SizedBox.shrink(); 
                   // Simple decimation if needed, but FL Chart handles it okay usually
                   return Text(value.toInt().toString(), style: const TextStyle(color: Colors.white54, fontSize: 10));
                },
              )
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            _makeGroupData(0, singles.toDouble(), Colors.blue),
            _makeGroupData(1, doubles.toDouble(), Colors.green),
            _makeGroupData(2, triples.toDouble(), Colors.orange),
            _makeGroupData(3, bull.toDouble(), Colors.red),
            _makeGroupData(4, miss.toDouble(), Colors.grey),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
        ),
      ],
    );
  }
}
