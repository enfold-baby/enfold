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

    test('empty day returns zeros', () {
      final summary = TodaySummary.fromEntries([]);
      expect(summary.feedCount, 0);
      expect(summary.diaperCount, 0);
      expect(summary.sleepMinutes, 0);
      expect(summary.sleepLabel, '0m');
    });
  });
}