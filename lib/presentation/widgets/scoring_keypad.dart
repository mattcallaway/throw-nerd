import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptics
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darts_app/presentation/providers/di_providers.dart'; // To read theme
import 'package:darts_app/domain/scoring/models.dart';
import 'package:darts_app/presentation/theme/app_themes.dart';

class ScoringKeypad extends ConsumerStatefulWidget {
  final Function(Dart) onDartEntered;
  final List<Dart> currentDarts;

  const ScoringKeypad({
    super.key,
    required this.onDartEntered,
    required this.currentDarts,
  });

  @override
  ConsumerState<ScoringKeypad> createState() => _ScoringKeypadState();
}

class _ScoringKeypadState extends ConsumerState<ScoringKeypad> {
  int _multiplier = 1;

  void _handleInput(int value) {
    HapticFeedback.lightImpact(); // Feedback
    
    int m = _multiplier;
    if (value == 25) {
       if (m == 3) m = 1;
    }
    
    widget.onDartEntered(Dart(value: value, multiplier: m));
    setState(() => _multiplier = 1);
  }

  void _toggleMultiplier(int m) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_multiplier == m) _multiplier = 1;
      else _multiplier = m;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    
    return Column(
      children: [
        // Feedback Row
        Container(
          height: 56, // Slightly taller
          color: Colors.black26, 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.currentDarts.map((d) => 
               Container(
                 margin: const EdgeInsets.symmetric(horizontal: 4),
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 decoration: BoxDecoration(
                   color: theme.keypadButtonBg,
                   borderRadius: BorderRadius.circular(20),
                   border: Border.all(color: Colors.white24),
                 ),
                 child: Text(d.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.keypadButtonFg)),
               )
            ).toList(),
          ),
        ),
        const Divider(height: 1),
        
        // Main Input Area
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Modifiers (Left Side)
              SizedBox(
                width: 100, // Fixed width for modifiers
                child: Column(
                  children: [
                     Expanded(child: _ModifierButton(
                       label: 'DOUBLE', 
                       isSelected: _multiplier == 2, 
                       color: theme.dangerColor, // Or a specific Accent? Using danger implies red/hot
                       onTap: () => _toggleMultiplier(2)
                     )),
                     Expanded(child: _ModifierButton(
                       label: 'TRIPLE', 
                       isSelected: _multiplier == 3, 
                       color: theme.successColor, // Green
                       onTap: () => _toggleMultiplier(3)
                     )),
                     Expanded(child: _ModifierButton(
                       label: 'MISS', 
                       isSelected: false, 
                       color: Colors.grey, // Standard miss
                       onTap: () => _handleInput(0)
                     )),
                     Expanded(child: _ModifierButton(
                       label: 'BULL', 
                       isSelected: false, 
                       color: theme.dangerColor,
                       onTap: () => _handleInput(25)
                     )),
                  ],
                ),
              ),
              
              // Numbers Grid (Right Side - Fills rest)
              Expanded(
                child: Column(
                  children: [
                    for (int row = 0; row < 4; row++)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (int col = 0; col < 5; col++)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: EdgeInsets.zero,
                                      backgroundColor: theme.keypadButtonBg,
                                      foregroundColor: theme.keypadButtonFg,
                                      elevation: 2,
                                      side: theme.mode == AppThemeMode.neon ? BorderSide(color: theme.keypadButtonFg.withOpacity(0.3)) : null,
                                    ),
                                    onPressed: () => _handleInput((row * 5) + col + 1),
                                    child: Text(
                                      '${(row * 5) + col + 1}', 
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModifierButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ModifierButton({required this.label, required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Material(
        color: isSelected ? color : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(label, style: TextStyle(
               fontWeight: FontWeight.bold,
               color: isSelected ? Colors.white : color
            )),
          ),
        ),
      ),
    );
  }
}
