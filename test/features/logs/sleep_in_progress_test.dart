import 'package:enfold/features/logs/providers/logs_providers.dart';
import 'package:enfold/features/logs/widgets/active_sleep_banner.dart';
import 'package:enfold/features/today/models/care_log_details.dart';
import 'package:enfold/features/today/providers/today_log_provider.dart';
import 'package:enfold/services/database/database_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';
import 'package:enfold/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

void main() {
  test('formatSleepElapsed covers minutes and hours', () {
    final l10n = lookupAppL10n(const Locale('en'));
    final start = DateTime(2026, 9, 6, 20, 0);
    expect(
      formatSleepElapsed(l10n, start, start.add(const Duration(seconds: 20))),
      'just now',
    );
    expect(
      formatSleepElapsed(l10n, start, start.add(const Duration(minutes: 20))),
      '20m',
    );
    expect(
      formatSleepElapsed(l10n, start, start.add(const Duration(hours: 2))),
      '2h',
    );
    expect(
      formatSleepElapsed(l10n, start, start.add(const Duration(hours: 1, minutes: 5))),
      '1h 5m',
    );
  });

  test('startSleepAt backdates an open sleep', () async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    final start = DateTime.now().subtract(const Duration(minutes: 20));
    await container.read(careLogActionsProvider).startSleepAt(start);

    final open = await container.read(openSleepProvider.future);
    expect(open, isNotNull);
    expect(open!.details.sleepInProgress, isTrue);
    final savedStart = open.details.sleepStart!;
    expect(savedStart.difference(start).inSeconds.abs(), lessThan(2));
    expect(open.details.sleepEnd, isNull);
  });

  test('wakeFromSleep closes the open sleep', () async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    final id = await container
        .read(careLogActionsProvider)
        .startSleepAt(DateTime.now().subtract(const Duration(minutes: 20)));
    await container.read(careLogActionsProvider).wakeFromSleep(id);

    final open = await container.read(openSleepProvider.future);
    expect(open, isNull);

    final db = container.read(databaseProvider);
    final row = await db.careLogDao.getLog(id);
    final details = CareLogDetails.fromJsonString(row!.detailsJson);
    expect(details.sleepInProgress, isFalse);
    expect(details.sleepEnd, isNotNull);
    expect(details.durationMinutes, greaterThanOrEqualTo(20));
  });
}
