import 'package:enfold/features/today/models/care_log_details.dart';
import 'package:enfold/features/today/models/care_log_entry.dart';
import 'package:enfold/features/today/models/log_type.dart';
import 'package:enfold/features/today/providers/today_log_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dayStart = DateTime(2026, 9, 18);
  final now = DateTime(2026, 9, 18, 6, 0);

  CareLogEntry entry(String id, LogType type, DateTime at, {CareLogDetails? details}) =>
      CareLogEntry(id: id, type: type, loggedAt: at, pendingSync: false, details: details ?? CareLogDetails.empty);

  test("yesterday's finished logs are dropped, today's kept", () {
    final kept = entriesForToday(
      [
        entry('y-feed', LogType.feed, DateTime(2026, 9, 17, 20, 0)),
        entry('y-sleep', LogType.sleep, DateTime(2026, 9, 17, 21, 0),
            details: CareLogDetails(
              sleepStart: DateTime(2026, 9, 17, 19, 0),
              sleepEnd: DateTime(2026, 9, 17, 21, 0),
              durationMinutes: 120,
            )),
        entry('t-feed', LogType.feed, DateTime(2026, 9, 18, 3, 0)),
      ],
      dayStart: dayStart,
      now: now,
    );
    expect(kept.map((e) => e.id), ['t-feed']);
  });

  test('a sleep still running since last night stays on Today', () {
    final kept = entriesForToday(
      [
        entry('night', LogType.sleep, DateTime(2026, 9, 17, 22, 0),
            details: CareLogDetails(
              sleepStart: DateTime(2026, 9, 17, 22, 0),
              sleepInProgress: true,
            )),
      ],
      dayStart: dayStart,
      now: now,
    );
    expect(kept.map((e) => e.id), ['night']);
  });
}
