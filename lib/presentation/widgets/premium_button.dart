import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darts_app/presentation/providers/di_providers.dart';

class PremiumButton extends ConsumerWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isAccented; // If true, uses accent color/style

  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isAccented = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.borderRadiusSmall),
        boxShadow: isAccented ? [
          BoxShadow(
            color: theme.accentColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isAccented ? theme.accentColor.withOpacity(0.2) : theme.surfaceColor,
          foregroundColor: isAccented ? theme.accentColor : Colors.white70,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.borderRadiusSmall),
            side: isAccented ? BorderSide(color: theme.accentColor) : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
