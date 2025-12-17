import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/active_match_notifier.dart';
import '../widgets/scoreboard.dart';
import '../widgets/scoring_keypad.dart';
import '../theme/app_themes.dart';
import '../widgets/in_game_stats_modal.dart';
import '../widgets/live_stats_bar.dart';
import '../providers/di_providers.dart';

class ScoringScreen extends ConsumerStatefulWidget {
  const ScoringScreen({super.key});

  @override
  ConsumerState<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends ConsumerState<ScoringScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  String? _overlayText;
  Color _overlayColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnimation = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
  }
  
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
  
  void _triggerOverlay(String text, Color color) {
    setState(() {
      _overlayText = text;
      _overlayColor = color;
    });
    _animController.forward(from: 0.0).then((_) {
       // Wait a bit then clear? Or let user tap?
       // Auto fade out
       Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _overlayText == text) { // Check if still same
             _animController.reverse().then((_) {
                if (mounted) {
                   setState(() => _overlayText = null);
                   (ref.read(activeMatchProvider.notifier) as ActiveMatchNotifier).clearEvent();
                }
             });
          }
       });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final state = ref.watch(activeMatchProvider);
    
    // Listen for events
    ref.listen(activeMatchProvider, (prev, next) {
      if (prev?.lastEvent != next.lastEvent && next.lastEvent != MatchEvent.none) {
         if (next.lastEvent == MatchEvent.bust) {
            _triggerOverlay('BUST', theme.dangerColor);
            // Haptic?
         } else if (next.lastEvent == MatchEvent.legWon) {
            _triggerOverlay('LEG WON', theme.successColor);
         } else if (next.lastEvent == MatchEvent.matchWon) {
            _triggerOverlay('MATCH WON', theme.warningColor);
         }
      }
    });

    if (state.match == null) {
      return const Scaffold(body: Center(child: Text('No active match')));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: state.match!.config.sets > 1 
            ? Text('Set ${state.currentSet}  •  Leg ${state.currentLeg}')
            : Text('Leg ${state.currentLeg}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () {
               (ref.read(activeMatchProvider.notifier) as ActiveMatchNotifier).undoLastDart();
            },
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
               // "Edit" in this context (V1) effectively means "Undo the last event to correct it"
               // We could show a dialog, but for speed of gameplay, direct action is often preferred.
               // Or let's show a quick confirmation if it's a turn rewind?
               // For now, map to undo.
               (ref.read(activeMatchProvider.notifier) as ActiveMatchNotifier).undoLastDart();
            },
            tooltip: 'Correction Mode',
          ),
          IconButton(
             icon: const Icon(Icons.bar_chart),
             onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (_) => InGameStatsModal(state: state.gameState!, activePlayerId: state.gameState!.currentPlayerId),
                );
             },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: Stack(
          children: [
            SafeArea(
              bottom: true, // Respect system nav bar
              top: false, // Don't respect top status bar (covered by AppBar)
              child: Column(
                children: [
                  SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top),
                  Expanded(
                    flex: 4,
                  child: Scoreboard(state: state),
                ),
                const LiveStatsBar(), 
                Expanded(
                  flex: 6,
                  child: ScoringKeypad(
                    onDartEntered: (dart) {
                       (ref.read(activeMatchProvider.notifier) as ActiveMatchNotifier).addDart(dart);
                    },
                    currentDarts: state.currentTurnDarts,
                  ),
                ),
                ],
              ),
            ),
            
            if (_overlayText != null)
               Positioned.fill(
                 child: Container(
                   color: Colors.black45,
                   child: Center(
                     child: ScaleTransition(
                       scale: _scaleAnimation,
                       child: Text(
                         _overlayText!,
                         style: TextStyle(
                           fontSize: 80, 
                           fontWeight: FontWeight.w900, 
                           color: _overlayColor,
                           letterSpacing: 4,
                           shadows: const [Shadow(color: Colors.black, blurRadius: 20)],
                         ),
                       ),
                     ),
                   ),
                 ),
               ),
          ],
        ),
      ),
    );
  }
}
