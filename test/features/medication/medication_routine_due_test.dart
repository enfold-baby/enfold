import 'package:enfold/features/medication/utils/medication_name.dart';
import 'package:enfold/features/medication/utils/medication_routine_due.dart';
import 'package:enfold/features/today/models/care_log_details.dart';
import 'package:enfold/features/today/models/care_log_entry.dart';
import 'package:enfold/features/today/models/log_type.dart';
import 'package:flutter_test/flutter_test.dart';

CareLogEntry _med(String name, DateTime at) {
  return CareLogEntry(
    id: 'm-$name',
    type: LogType.medication,
    loggedAt: at,
    pendingSync: false,
    details: CareLogDetails(medicationName: name),
  );
}

void main() {
  test('name matching ignores case and extra spaces', () {
    expect(sameMedicationName('Vitamin D drops', '  vitamin d drops'), isTrue);
    expect(sameMedicationName('Vigantol', 'Vitamin D drops'), isFalse);
    expect(sameMedicationName('', ''), isFalse);
  });

  test('schedules today when the clock time is still ahead', () {
    expect(
      nextMedicationReminderAt(
        hour: 9,
        minute: 0,
        now: DateTime(2026, 9, 10, 8, 15),
        alreadyLoggedToday: false,
      ),
      DateTime(2026, 9, 10, 9),
    );
  });

  test('waits until tomorrow when today is already logged', () {
    expect(
      nextMedicationReminderAt(
        hour: 9,
        minute: 0,
        now: DateTime(2026, 9, 10, 8, 15),
        alreadyLoggedToday: true,
      ),
      DateTime(2026, 9, 11, 9),
    );
  });

  test('missed morning gets a quiet 15-minute nudge before 21:30', () {
    expect(
      nextMedicationReminderAt(
        hour: 9,
        minute: 0,
        now: DateTime(2026, 9, 10, 10, 0),
        alreadyLoggedToday: false,
      ),
      DateTime(2026, 9, 10, 10, 15),
    );
  });

  test('does not ping overnight after quiet hours', () {
    expect(
      nextMedicationReminderAt(
        hour: 9,
        minute: 0,
        now: DateTime(2026, 9, 10, 21, 45),
        alreadyLoggedToday: false,
      ),
      DateTime(2026, 9, 11, 9),
    );
  });

  test('snooze wins while it is in the future', () {
    final snooze = DateTime(2026, 9, 10, 11, 30);
    expect(
      nextMedicationReminderAt(
        hour: 9,
        minute: 0,
        now: DateTime(2026, 9, 10, 10, 0),
        alreadyLoggedToday: false,
        snoozeUntil: snooze,
      ),
      snooze,
    );
  });

  test('today line is calm, not a streak', () {
    expect(
      medicationRoutineTodayLine(name: 'Vitamin D drops'),
      'Vitamin D drops: not logged yet',
    );
    expect(
      medicationRoutineTodayLine(name: 'Vitamin D drops', timeLabel: '9:14 AM'),
      'Vitamin D drops · 9:14 AM',
    );
  });

  test('logged today matches the routine name', () {
    final logs = [_med('Vitamin D drops', DateTime(2026, 9, 10, 9, 14))];
    expect(
      medicationLoggedToday(name: 'vitamin d drops', todayLogs: logs),
      isTrue,
    );
    expect(medicationLoggedToday(name: 'Iron drops', todayLogs: logs), isFalse);
    expect(
      latestDoseAt(name: 'Vitamin D drops', todayLogs: logs),
      DateTime(2026, 9, 10, 9, 14),
    );
  });

  test('reminder copy uses the baby name', () {
    expect(
      medicationReminderBody('Vitamin D drops', 'Damian'),
      'Vitamin D drops for Damian?',
    );
    expect(
      medicationReminderBody('Vigantol', 'Baby'),
      'Vigantol for baby?',
    );
  });
}
