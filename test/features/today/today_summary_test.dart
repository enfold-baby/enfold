import 'package:enfold/features/today/models/care_log_details.dart';
import 'package:enfold/features/today/models/care_log_entry.dart';
import 'package:enfold/features/today/models/log_type.dart';
import 'package:enfold/features/today/models/today_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TodaySummary', () {
    test('aggregates feed, diaper, and sleep totals', () {
      final now = DateTime(2026, 7, 8, 14, 0);
      final summary = TodaySummary.fromEntries(
        [
          CareLogEntry(
            id: '1',
            type: LogType.feed,
            loggedAt: now,
            pendingSync: false,
          ),
          CareLogEntry(
            id: '2',
            type: LogType.feed,
            loggedAt: now,
            pendingSync: false,
          ),
          CareLogEntry(
            id: '3',
            type: LogType.diaper,
            loggedAt: now,
            pendingSync: false,
          ),
          CareLogEntry(
            id: '4',
            type: LogType.sleep,
            loggedAt: now,
            pendingSync: false,
            details: const CareLogDetails(durationMinutes: 80),
          ),
        ],
        now: now,
      );

      expect(summary.feedCount, 2);
      expect(summary.diaperCount, 1);
      expect(summary.sleepMinutes, 80);
      expect(summary.sleepLabel, '1h 20m');
    });

    test('includes in-progress sleep minutes until now', () {
      final now = DateTime(2026, 7, 8, 14, 0);
      final summary = TodaySummary.fromEntries(
        [
          CareLogEntry(
            id: '1',
            type: LogType.sleep,
            loggedAt: now.subtract(const Duration(minutes: 45)),
            pendingSync: true,
            details: CareLogDetails(
              sleepStart: now.subtract(const Duration(minutes: 45)),
              sleepInProgress: true,
            ),
          ),
        ],
        now: now,
      );

      expect(summary.sleepMinutes, 45);
      expect(summary.sleepLabel, '45m');
    });

    test('an overnight sleep only counts the part after midnight', () {
      // Slept 22:00 to 02:00; Today (the 18th) should show 2h, not 4h.
      final now = DateTime(2026, 9, 18, 9, 0);
      final summary = TodaySummary.fromEntries(
        [
          CareLogEntry(
            id: '1',
            type: LogType.sleep,
            loggedAt: DateTime(2026, 9, 18, 2, 0),
            pendingSync: false,
            details: CareLogDetails(
              sleepStart: DateTime(2026, 9, 17, 22, 0),
              sleepEnd: DateTime(2026, 9, 18, 2, 0),
              durationMinutes: 240,
            ),
          ),
        ],
        now: now,
      );
      expect(summary.sleepMinutes, 120);
      expect(summary.sleepLabel, '2h');
    });

    test('an in-progress sleep that began yesterday counts from midnight', () {
      final now = DateTime(2026, 9, 18, 1, 30);
      final summary = TodaySummary.fromEntries(
        [
          CareLogEntry(
            id: '1',
            type: LogType.sleep,
            loggedAt: DateTime(2026, 9, 17, 23, 0),
            pendingSync: false,
            details: CareLogDetails(
              sleepStart: DateTime(2026, 9, 17, 23, 0),
              sleepInProgress: true,
            ),
          ),
        ],
        now: now,
      );
      expect(summary.sleepMinutes, 90);
    });

    test('a duration-only sleep row is anchored to its logged end time', () {
      // 3h logged at 01:00 means 22:00 to 01:00: one hour belongs to today.
      final now = DateTime(2026, 9, 18, 8, 0);
      final summary = TodaySummary.fromEntries(
        [
          CareLogEntry(
            id: '1',
            type: LogType.sleep,
            loggedAt: DateTime(2026, 9, 18, 1, 0),
            pendingSync: false,
            details: const CareLogDetails(durationMinutes: 180),
          ),
        ],
        now: now,
      );
      expect(summary.sleepMinutes, 60);
    });

    test('a sleep entirely within today is unchanged', () {
      final now = DateTime(2026, 9, 18, 16, 0);
      final summary = TodaySummary.fromEntries(
        [
          CareLogEntry(
            id: '1',
            type: LogType.sleep,
            loggedAt: DateTime(2026, 9, 18, 14, 0),
            pendingSync: false,
            details: CareLogDetails(
              sleepStart: DateTime(2026, 9, 18, 12, 30),
              sleepEnd: DateTime(2026, 9, 18, 14, 0),
              durationMinutes: 90,
            ),
          ),
        ],
        now: now,
      );
      expect(summary.sleepMinutes, 90);
    });

    test('empty day returns zeros', () {
      final summary = TodaySummary.fromEntries([]);
      expect(summary.feedCount, 0);
      expect(summary.diaperCount, 0);
      expect(summary.sleepMinutes, 0);
      expect(summary.sleepLabel, '0m');
    });
  });
}