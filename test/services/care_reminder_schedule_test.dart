import 'package:enfold/services/reminders/care_reminder_schedule.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enfold/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

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
    final en = lookupAppL10n(const Locale('en'));
    expect(
      careReminderBody(en, 'Damian'),
      'How is Damian today? No logs so far. Add one when you can.',
    );
    expect(
      careReminderBody(en, 'Baby'),
      'How is baby today? No logs so far. Add one when you can.',
    );

    final ro = lookupAppL10n(const Locale('ro'));
    expect(
      careReminderBody(ro, 'Damian'),
      'Cum se simte Damian azi? Încă nicio notare. Adaugă una când poți.',
    );
  });
}
