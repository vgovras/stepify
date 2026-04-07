import 'package:flutter_test/flutter_test.dart';

import 'package:stepify/core/core.dart';

void main() {
  group('formatTimer', () {
    test('formats zero', () {
      expect(formatTimer(0), '00:00');
    });

    test('formats seconds only', () {
      expect(formatTimer(45), '00:45');
    });

    test('formats minutes and seconds', () {
      expect(formatTimer(125), '02:05');
    });

    test('formats large values', () {
      expect(formatTimer(5400), '90:00');
    });

    test('clamps negative to 00:00', () {
      expect(formatTimer(-5), '00:00');
    });
  });
}
