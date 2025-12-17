import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/active_match_notifier.dart';

class MatchSummaryScreen extends ConsumerWidget {
  const MatchSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can read the final state from provider? 
    // Or we pass the match ID and fetch it?
    // If we rely on activeMatchProvider, it might still hold the state.
    final state = ref.watch(activeMatchProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Match Summary')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text('Winner', style: TextStyle(fontSize: 24)),
            // Lookup winner name
            if (state.match?.winnerId != null)
               Text(state.match!.winnerId!, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Return to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
