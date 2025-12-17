import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtext;
  final IconData? icon;
  final Color? color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtext,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Basic styling, can be improved to match Glossy/Neon theme
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             children: [
               if (icon != null) ...[
                 Icon(icon, color: color ?? Colors.white70, size: 20),
                 const SizedBox(width: 8),
               ],
               Expanded(child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1))),
             ],
           ),
           const Spacer(),
           Text(value, style: TextStyle(color: color ?? Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
           if (subtext != null)
             Text(subtext!, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}
