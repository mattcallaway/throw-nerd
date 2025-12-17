import 'package:flutter_test/flutter_test.dart';
import 'package:darts_app/domain/scoring/checkout_calculator.dart';

void main() {
  group('CheckoutCalculator Tests', () {
    test('Impossible Checkouts (Bogey Numbers)', () {
      expect(CheckoutCalculator.getCheckoutSuggestion(169), isEmpty);
      expect(CheckoutCalculator.getCheckoutSuggestion(168), isEmpty);
      expect(CheckoutCalculator.getCheckoutSuggestion(166), isEmpty);
      expect(CheckoutCalculator.getCheckoutSuggestion(165), isEmpty);
      expect(CheckoutCalculator.getCheckoutSuggestion(163), isEmpty);
      expect(CheckoutCalculator.getCheckoutSuggestion(162), isEmpty);
      expect(CheckoutCalculator.getCheckoutSuggestion(159), isEmpty);
    });

    test('High Checkouts (Double Out)', () {
      // 170 -> T20 T20 BULL
      final c170 = CheckoutCalculator.getCheckoutSuggestion(170, darts: 3, doubleOut: true);
      expect(c170, ['T20', 'T20', 'BULL']);
      
      // 167 -> T20 T19 BULL
      final c167 = CheckoutCalculator.getCheckoutSuggestion(167, darts: 3, doubleOut: true);
      expect(c167.length, 3);
      expect(c167.last, 'BULL');
    });

    test('Double Out vs Single Out', () {
      // 32 remaining, 1 dart left.
      // Double Out: Must hit D16.
      expect(CheckoutCalculator.getCheckoutSuggestion(32, darts: 1, doubleOut: true), ['D16']);
      
      // 32 remaining, 1 dart left, Single Out.
      // Can hit 32? (No 32 segment). 
      // Need D16 anyway or multiple darts?
      // If 1 dart left, Double Out requires D16. 
      // Single out just needs 32 points. 
      // Is '32' a valid single throw? No. So must be D16.
    });

    test('Remaining 2, 1 dart', () {
      expect(CheckoutCalculator.getCheckoutSuggestion(2, darts: 1, doubleOut: true), ['D1']);
    });
    
    test('Remaining 50, 1 dart', () {
       expect(CheckoutCalculator.getCheckoutSuggestion(50, darts: 1, doubleOut: true), ['BULL']);
    });

    test('Complex low checkout (52, 2 darts)', () {
       // 52 -> 20, D16? or 12, D20?
       // Algorithm prefers T20? No, 52 < 60.
       // It tries D26 (Invalid).
       // It tries T17 (51) -> leaves 1 (Invalid for Double Out).
       // It tries diffs: 52 - 40 = 12. So 12, D20.
       // Or 52 - 32 = 20. So 20, D16.
       final res = CheckoutCalculator.getCheckoutSuggestion(52, darts: 2, doubleOut: true);
       expect(res, isNotEmpty);
       expect(res.last, startsWith('D')); // Ends on double
    });
    
    test('Darts Remaining impact', () {
       // 40 remaining. 
       // 3 darts: D20? or 20 D10? D20 is fastest.
       final d3 = CheckoutCalculator.getCheckoutSuggestion(40, darts: 3, doubleOut: true);
       expect(d3, ['D20']);
       
       // 1 dart: D20.
       final d1 = CheckoutCalculator.getCheckoutSuggestion(40, darts: 1, doubleOut: true);
       expect(d1, ['D20']);
       
       // 50 remaining 2 darts.
       // 10, D20? Or Bull? Bull is risky but 1 dart.
       // Algorithm adds Bull first if valid.
       // So ['BULL'] is 1 dart solution.
       // Wait, if 1 dart solution exists, does it return that?
       // Recursive solver iterates moves. 
       // Moves list: [D20 (invalid rem=10), BULL (valid rem=0), ... T20 (bust)...]
       // If BULL is valid, it returns ['BULL'].
       final d2 = CheckoutCalculator.getCheckoutSuggestion(50, darts: 2, doubleOut: true);
       expect(d2, ['BULL']);
    });
  });
}
