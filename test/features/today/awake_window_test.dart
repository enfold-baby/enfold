import 'package:enfold/features/today/models/awake_window.dart';
import 'package:enfold/features/today/models/care_log_details.dart';
import 'package:enfold/features/today/models/care_log_entry.dart';
import 'package:enfold/features/today/models/log_type.dart';
import 'package:flutter_test/flutter_test.dart';

CareLogEntry _sleep(
  String id, {
  required DateTime loggedAt,
  CareLogDetails details = CareLogDetails.empty,
}) {
  return CareLogEntry(
    id: id,
    type: LogType.sleep,
    loggedAt: loggedAt,
    pendingSync: false,
    details: details,
  );
}

CareLogEntry _range(String id, DateTime start, DateTime end) {
  return _sleep(
    id,
    loggedAt: end,
    details: CareLogDetails(
      sleepStart: start,
      sleepEnd: end,
      sleepInProgress: false,
      durationMinutes: end.difference(start).inMinutes,
    ),
  );
}

void main() {
  group('AwakeWindow', () {
    final now = DateTime(2026, 9, 13, 15, 30);

    test('counts from the end of the last sleep', () {
      final window = AwakeWindow.fromSleeps(
        [_range('1', DateTime(2026, 9, 13, 12, 0), DateTime(2026, 9, 13, 14, 10))],
        now: now,
      );
      expect(window, isNotNull);
      expect(window!.wokeAt, DateTime(2026, 9, 13, 14, 10));
      expect(window.awake, const Duration(hours: 1, minutes: 20));
    });

    test('latest end wins even when logged out of order', () {
      final window = AwakeWindow.fromSleeps(
        [
          // Backfilled last night, but listed first.
          _range('night', DateTime(2026, 9, 12, 21, 0), DateTime(2026, 9, 13, 6, 0)),
          _range('nap', DateTime(2026, 9, 13, 13, 0), DateTime(2026, 9, 13, 14, 0)),
          _range('morning', DateTime(2026, 9, 13, 9, 0), DateTime(2026, 9, 13, 10, 0)),
        ],
        now: now,
      );
      expect(window!.wokeAt, DateTime(2026, 9, 13, 14, 0));
    });

    test('works across midnight', () {
      final window = AwakeWindow.fromSleeps(
        [_range('1', DateTime(2026, 9, 12, 22, 0), DateTime(2026, 9, 12, 23, 30))],
        now: DateTime(2026, 9, 13, 0, 15),
      );
      expect(window!.awake, const Duration(minutes: 45));
    });

    test('hidden while a sleep is in progress', () {
      final window = AwakeWindow.fromSleeps(
        [
          _range('1', DateTime(2026, 9, 13, 12, 0), DateTime(2026, 9, 13, 13, 0)),
          _sleep(
            '2',
            loggedAt: DateTime(2026, 9, 13, 15, 0),
            details: CareLogDetails(
              sleepStart: DateTime(2026, 9, 13, 15, 0),
              sleepInProgress: true,
            ),
          ),
        ],
        now: now,
      );
      expect(window, isNull);
    });

    test('hidden with no sleeps or a gap longer than 12 hours', () {
      expect(AwakeWindow.fromSleeps(const [], now: now), isNull);
      expect(
        AwakeWindow.fromSleeps(
          [_range('1', DateTime(2026, 9, 13, 1, 0), DateTime(2026, 9, 13, 3, 0))],
          now: now,
        ),
        isNull,
      );
    });

    test('ignores entries that are not sleep', () {
      final window = AwakeWindow.fromSleeps(
        [
          CareLogEntry(
            id: 'feed',
            type: LogType.feed,
            loggedAt: DateTime(2026, 9, 13, 15, 0),
            pendingSync: false,
          ),
        ],
        now: now,
      );
      expect(window, isNull);
    });

    test('quick log without details ends at the log time', () {
      final window = AwakeWindow.fromSleeps(
        [_sleep('1', loggedAt: DateTime(2026, 9, 13, 15, 0))],
        now: now,
      );
      expect(window!.awake, const Duration(minutes: 30));
    });

    test('start plus duration gives the end when no end is stored', () {
      final window = AwakeWindow.fromSleeps(
        [
          _sleep(
            '1',
            loggedAt: DateTime(2026, 9, 13, 11, 0),
            details: CareLogDetails(
              sleepStart: DateTime(2026, 9, 13, 13, 0),
              durationMinutes: 90,
            ),
          ),
        ],
        now: now,
      );
      expect(window!.wokeAt, DateTime(2026, 9, 13, 14, 30));
    });

    test('an end slightly in the future reads as just woke up', () {
      final window = AwakeWindow.fromSleeps(
        [_range('1', DateTime(2026, 9, 13, 14, 0), DateTime(2026, 9, 13, 15, 31))],
        now: now,
      );
      expect(window!.awake, Duration.zero);
    });
  });
}
