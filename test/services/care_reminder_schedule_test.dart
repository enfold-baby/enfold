import 'package:enfold/services/reminders/care_reminder_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('afternoon with no logs schedules 6pm', () {
    expect(
      nextCareReminderAt(DateTime(2026, 9, 8, 10, 15)),
      DateTime(2026, 9, 8, 18),
    );
  });

  test('early evening schedules about 90 minutes later, before quiet hours', () {
    expect(
      nextCareReminderAt(DateTime(2026, 9, 8, 18, 20)),
      DateTime(2026, 9, 8, 19, 50),
    );
  });

  test('late evening does not schedule overnight', () {
    expect(nextCareReminderAt(DateTime(2026, 9, 8, 21, 45)), isNull);
  });

  test('reminder copy uses the baby name', () {
    expect(
      careReminderBody('Damian'),
      'How is Damian today? No logs so far. Add one when you can.',
    );
    expect(
      careReminderBody('Baby'),
      'How is baby today? No logs so far. Add one when you can.',
    );
  });
}
