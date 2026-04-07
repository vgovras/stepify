import 'package:flutter_test/flutter_test.dart';

import 'package:stepify/core/core.dart';

void main() {
  group('scaleAmount', () {
    test('scales up from 4 to 8 servings', () {
      final result = scaleAmount(
        baseAmount: 500,
        baseServings: 4,
        currentServings: 8,
      );
      expect(result, 1000);
    });

    test('scales down from 4 to 2 servings', () {
      final result = scaleAmount(
        baseAmount: 500,
        baseServings: 4,
        currentServings: 2,
      );
      expect(result, 250);
    });

    test('returns null for null amount (за смаком)', () {
      final result = scaleAmount(
        baseAmount: null,
        baseServings: 4,
        currentServings: 8,
      );
      expect(result, isNull);
    });

    test('handles fractional amounts', () {
      final result = scaleAmount(
        baseAmount: 0.5,
        baseServings: 4,
        currentServings: 8,
      );
      expect(result, 1.0);
    });

    test('rounds to 1 decimal', () {
      final result = scaleAmount(
        baseAmount: 1,
        baseServings: 3,
        currentServings: 2,
      );
      expect(result, 0.7);
    });
  });
}
