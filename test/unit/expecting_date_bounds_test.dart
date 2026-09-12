import 'package:enfold/features/pregnancy/expecting_date_bounds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('expecting_date_bounds', () {
    final now = DateTime(2026, 8, 10, 15, 30);

    test('calendarToday strips time', () {
      expect(calendarToday(now), DateTime(2026, 8, 10));
    });

    test('clampOnOrAfterToday keeps future days', () {
      expect(
        clampOnOrAfterToday(DateTime(2026, 9, 1), now),
        DateTime(2026, 9, 1),
      );
    });

    test('clampOnOrAfterToday lifts past days to today', () {
      expect(
        clampOnOrAfterToday(DateTime(2026, 6, 4), now),
        DateTime(2026, 8, 10),
      );
    });

    test('clampOnOrAfterToday keeps today', () {
      expect(
        clampOnOrAfterToday(DateTime(2026, 8, 10, 8), now),
        DateTime(2026, 8, 10),
      );
    });
  });
}
