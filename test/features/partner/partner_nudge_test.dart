import 'package:enfold/features/partner/models/partner_nudge.dart';
import 'package:enfold/features/today/models/care_log_details.dart';
import 'package:enfold/features/today/models/care_log_entry.dart';
import 'package:enfold/features/today/models/log_type.dart';
import 'package:flutter_test/flutter_test.dart';

CareLogEntry _entry({
  required LogType type,
  required DateTime loggedAt,
}) {
  return CareLogEntry(
    id: '${type.name}-1',
    type: type,
    loggedAt: loggedAt,
    pendingSync: false,
    details: CareLogDetails.empty,
  );
}

void main() {
  final now = DateTime(2026, 7, 8, 14, 0);

  test('detectGentleNudge returns null when all core logs are recent', () {
    final logs = [
      _entry(type: LogType.feed, loggedAt: now.subtract(const Duration(hours: 1))),
      _entry(type: LogType.diaper, loggedAt: now.subtract(const Duration(hours: 2))),
      _entry(type: LogType.sleep, loggedAt: now.subtract(const Duration(hours: 3))),
    ];

    expect(detectGentleNudge(todayLogs: logs, now: now), isNull);
  });

  test('detectGentleNudge prioritizes feed gap', () {
    final logs = [
      _entry(type: LogType.feed, loggedAt: now.subtract(const Duration(hours: 5))),
      _entry(type: LogType.diaper, loggedAt: now.subtract(const Duration(hours: 1))),
      _entry(type: LogType.sleep, loggedAt: now.subtract(const Duration(hours: 1))),
    ];

    final nudge = detectGentleNudge(todayLogs: logs, now: now);
    expect(nudge?.type, LogType.feed);
    expect(nudge?.hoursSince, 5);
  });

  test('detectGentleNudge suggests diaper when feed is recent', () {
    final logs = [
      _entry(type: LogType.feed, loggedAt: now.subtract(const Duration(hours: 1))),
      _entry(type: LogType.diaper, loggedAt: now.subtract(const Duration(hours: 7))),
    ];

    final nudge = detectGentleNudge(todayLogs: logs, now: now);
    expect(nudge?.type, LogType.diaper);
  });

  test('detectGentleNudge handles missing logs for the day', () {
    final nudge = detectGentleNudge(todayLogs: const [], now: now);
    expect(nudge?.type, LogType.feed);
    expect(nudge?.nothingToday, isTrue);
    expect(nudge?.type, LogType.feed);
  });
}