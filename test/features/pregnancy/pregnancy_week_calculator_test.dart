import 'package:enfold/features/pregnancy/pregnancy_week_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('pregnancyWeekFromDueDate', () {
    test('returns week 20 at midpoint', () {
      final due = DateTime(2026, 7, 1);
      final today = due.subtract(const Duration(days: 140));
      expect(pregnancyWeekFromDueDate(due, today), 20);
    });

    test('returns null before conception window', () {
      final due = DateTime(2026, 7, 1);
      final today = due.subtract(const Duration(days: 300));
      expect(pregnancyWeekFromDueDate(due, today), isNull);
    });

    test('clamps to 42 weeks past term', () {
      final due = DateTime(2026, 1, 1);
      final today = DateTime(2026, 1, 1);
      expect(pregnancyWeekFromDueDate(due, today), 40);
    });
  });

  group('daysUntilDue', () {
    test('counts days remaining', () {
      final due = DateTime(2026, 8, 1);
      final today = DateTime(2026, 7, 1);
      expect(daysUntilDue(due, today), 31);
    });
  });
}