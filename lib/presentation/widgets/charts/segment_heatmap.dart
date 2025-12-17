import 'package:flutter/material.dart';
import '../../../domain/analytics/analytics_models.dart';

class SegmentHeatmap extends StatelessWidget {
  final SegmentStats stats;

  const SegmentHeatmap({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    int max = 0;
    if (stats.distribution.isNotEmpty) {
      max = stats.distribution.values.reduce((a, b) => a > b ? a : b);
    }
    if (max == 0) max = 1;

    return Column(
      children: [
        // Headers
        const Row(
          children: [
             SizedBox(width: 30, child: Text('#', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 10))),
             Expanded(child: Text('S', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 10))),
             Expanded(child: Text('D', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 10))),
             Expanded(child: Text('T', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 10))),
          ],
        ),
        const SizedBox(height: 4),
        // Numbers 20 down to 1
        ...List.generate(20, (index) {
          final number = 20 - index;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(width: 30, child: Text('$number', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                _buildCell(number, 1, max),
                const SizedBox(width: 2),
                _buildCell(number, 2, max),
                const SizedBox(width: 2),
                _buildCell(number, 3, max),
              ],
            ),
          );
        }),
        const Divider(color: Colors.white12),
        // Bulls
        Row(
           children: [
             const SizedBox(width: 30, child: Text('B', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
             _buildCell(25, 1, max, label: '25'), // Single Bull
             const SizedBox(width: 2),
             _buildCell(25, 2, max, label: '50'), // Double Bull
             const SizedBox(width: 2),
             const Spacer(), // No triple bull
           ],
        ),
        const SizedBox(height: 8),
        // Misses
        Text('Misses: ${stats.distribution['0-0'] ?? 0}', style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
      ],
    );
  }

  Widget _buildCell(int number, int multiplier, int max, {String? label}) {
    final key = '$number-$multiplier';
    final count = stats.distribution[key] ?? 0;
    final intensity = count / max;
    
    // Color Scale: Blue (low) -> Green -> Red (high)
    // Or simple opacity of red.
    final color = count == 0 
        ? Colors.white.withOpacity(0.05) 
        : HSVColor.fromAHSV(1.0, 0, 0.8, 0.4 + (0.6 * intensity)).toColor(); // Red scale

    return Expanded(
      child: Container(
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          count > 0 ? (label ?? '$count') : '',
          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
