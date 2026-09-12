import 'package:enfold/features/today/models/care_log_details.dart';
import 'package:enfold/features/today/models/care_log_entry.dart';
import 'package:enfold/features/today/models/log_type.dart';
import 'package:flutter_test/flutter_test.dart';

CareLogEntry _sleep({
  required DateTime loggedAt,
  DateTime? start,
  DateTime? end,
  bool inProgress = false,
}) {
  return CareLogEntry(
    id: 's1',
    type: LogType.sleep,
    loggedAt: loggedAt,
    pendingSync: false,
    details: CareLogDetails(
      sleepStart: start,
      sleepEnd: end,
      sleepInProgress: inProgress,
      durationMinutes: start != null && end != null
          ? end.difference(start).inMinutes
          : null,
    ),
  );
}

void main() {
  test('completed sleep tiles show start and end on the same day', () {
    final entry = _sleep(
      loggedAt: DateTime(2026, 9, 8, 7),
      start: DateTime(2026, 9, 8, 5, 12),
      end: DateTime(2026, 9, 8, 7),
    );
    expect(entry.listTimeLabel(), 'Sep 8 · 5:12 AM–7:00 AM');
  });

  test('overnight sleep tiles show both dates', () {
    final entry = _sleep(
      loggedAt: DateTime(2026, 9, 8, 7),
      start: DateTime(2026, 9, 7, 23, 12),
      end: DateTime(2026, 9, 8, 7),
    );
    expect(
      entry.listTimeLabel(),
      'Sep 7, 11:12 PM – Sep 8, 7:00 AM',
    );
  });

  test('in-progress sleep tiles show the start time', () {
    final entry = _sleep(
      loggedAt: DateTime(2026, 9, 8, 0, 7),
      start: DateTime(2026, 9, 8, 0, 7),
      inProgress: true,
    );
    expect(entry.listTimeLabel(), 'Sep 8 · 12:07 AM');
  });

  test('24-hour clock labels use HH:mm', () {
    final sameDay = _sleep(
      loggedAt: DateTime(2026, 9, 8, 7),
      start: DateTime(2026, 9, 8, 5, 12),
      end: DateTime(2026, 9, 8, 7),
    );
    expect(
      sameDay.listTimeLabel(use24Hour: true),
      'Sep 8 · 05:12–07:00',
    );

    final overnight = _sleep(
      loggedAt: DateTime(2026, 9, 8, 7),
      start: DateTime(2026, 9, 7, 23, 12),
      end: DateTime(2026, 9, 8, 7),
    );
    expect(
      overnight.listTimeLabel(use24Hour: true),
      'Sep 7, 23:12 – Sep 8, 07:00',
    );
  });
}
