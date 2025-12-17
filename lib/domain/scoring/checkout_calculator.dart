import '../game_match.dart'; // For GameConfig

class CheckoutCalculator {
  
  static List<String> getCheckoutSuggestion(int remaining, {int darts = 3, bool doubleOut = true}) {
    // If not doubleOut, simple subtraction logic is easier, but standard darts usually implies double out or just hitting the number.
    // If doubleOut is false (straight out), we just need to hit the number.
    
    // Constraints
    if (remaining > 170) return [];
    
    // Memoization could be added but depth 3 is small.
    final result = _solve(remaining, darts, doubleOut);
    return result ?? [];
  }

  static List<String>? _solve(int rem, int darts, bool doubleOut) {
    if (rem == 0) {
      // If doubleOut required, we rely on the previous step ensuring the last dart was a double.
      // But here we just check if we reached 0 exactly.
      return [];
    }
    if (rem < 0) return null; // Bust
    if (darts == 0) return null; // No darts left, failed

    // Iterate possible throws. 
    // Optimization: Prioritize higher scoring darts or "Set up" darts.
    // Order: Bull, T20..T1, D25, D20..D1, 20..1.
    
    // Actually, for UI readability, we prefer:
    // 1. T20 (Score)
    // 2. Odd Triples if helps to leave even? (For double out)
    // 3. Bull
    
    // We can define "Valid Throws"
    final moves = _generatePossibleThrows(rem, doubleOut && darts == 1);
    
    for (final move in moves) {
      final val = move.total;
      final outcome = _solve(rem - val, darts - 1, doubleOut);
      
      if (outcome != null) {
        // Solution found!
        return [move.name, ...outcome];
      }
    }
    
    return null;
  }
  
  static List<_chkDart> _generatePossibleThrows(int rem, bool mustDouble) {
    final list = <_chkDart>[];
    
    // If we MUST double (last dart), only generate Doubles (and Bull if valid double)
    if (mustDouble) {
      if (rem == 50) return [_chkDart('BULL', 50, true)];
      if (rem <= 40 && rem % 2 == 0) return [_chkDart('D${rem ~/ 2}', rem, true)];
      return []; // Impossible to finish on double
    }

    // Otherwise, generate impactful throws.
    // Heuristic: Try to leave a "good" number.
    // Full search is too expensive (62^3). 
    // Limited search:
    // - Bull (50)
    // - 25
    // - D20..D1
    // - T20..T1
    // - 20..1
    
    // Smart filtering:
    // If rem > 60, don't bother with singles/doubles (except D20/Bull for finish/setup).
    // Actually simplicity:
    // Try High Triples first (T20, T19, T18, T17).
    // Try Bull.
    // Try High Singles/Doubles if rem is small.
    
    // Optimization: Just check if we can win NOW.
    if (rem <= 40 && rem % 2 == 0) list.add(_chkDart('D${rem ~/ 2}', rem, true));
    if (rem == 50) list.add(_chkDart('BULL', 50, true));
    
    // If we can't win now, try to score.
    // Try largest Triple that doesn't bust.
    if (rem > 60) list.add(_chkDart('T20', 60, false));
    if (rem > 57) list.add(_chkDart('T19', 57, false));
    if (rem > 54) list.add(_chkDart('T18', 54, false));
    if (rem > 51) list.add(_chkDart('T17', 51, false));
    
    // If rem is small (<60), try to leave a good double (e.g. 32, 40, 16).
    // Try Single/Triple to reach 32 (D16).
    if (rem > 32) {
       // Need (rem - 32).
       int diff = rem - 32;
       _addIfValid(diff, list);
    }
    if (rem > 40) {
       int diff = rem - 40;
       _addIfValid(diff, list);
    }
    if (rem > 24) { int diff = rem - 24; _addIfValid(diff, list); } // D12
    if (rem > 16) { int diff = rem - 16; _addIfValid(diff, list); } // D8
    
    // Also simplified "just hit what fits" if < 60
    _addIfValid(rem - 32, list);
    
    // Specific hardcoded patches for common setups:
    if (rem == 50) list.add(_chkDart('BULL', 50, true)); // Win
    if (rem == 25) list.add(_chkDart('25', 25, false));
    
    // Ensure T20 is always an option if valid and not bust
    if (rem > 61) list.add(_chkDart('T20', 60, false));

    // Sort descending by value to prefer higher scoring (shorter paths)
    // But stable sort?
    // list.sort((a,b) => b.total.compareTo(a.total));
    
    // Actually, because we recurse, we want the FIRST valid path to be the "Suggested" one.
    // So order matters:
    // 1. Win High (Bull) ? No, wins were added first.
    // 2. Setups.
    
    return list; 
  }
  
  static void _addIfValid(int val, List<_chkDart> list) {
     if (val <= 0) return;
     if (val > 60) return; 
     
     // Is it triple? (1-20)
     if (val % 3 == 0) {
        int base = val ~/ 3;
        if (base >= 1 && base <= 20) {
           list.add(_chkDart('T$base', val, false));
        }
     }
     // Is it double? (1-20, 25)
     if (val % 2 == 0) {
        int base = val ~/ 2;
        if ((base >= 1 && base <= 20) || base == 25) {
           list.add(_chkDart(base == 25 ? 'BULL' : 'D$base', val, true));
        }
     }
     // Single (1-20, 25, 50)
     // Actually 50 is Bull (Double 25), 25 is Outer Bull.
     if ((val >= 1 && val <= 20) || val == 25 || val == 50) {
       String name = '$val';
       if (val == 25) name = '25';
       if (val == 50) name = 'BULL'; // Usually treated as double
       list.add(_chkDart(name, val, name == 'BULL')); // Bull is double
     }
  }
}

class _chkDart {
  final String name;
  final int total;
  final bool isDouble;
  _chkDart(this.name, this.total, this.isDouble);
}
