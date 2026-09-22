import 'package:enfold/features/logs/providers/logs_providers.dart';
import 'package:enfold/features/settings/providers/awake_time_providers.dart';
import 'package:enfold/features/settings/settings_screen.dart';
import 'package:enfold/features/today/models/care_log_details.dart';
import 'package:enfold/features/today/models/log_type.dart';
import 'package:enfold/features/today/providers/today_log_provider.dart';
import 'package:enfold/features/today/today_screen.dart';
import 'package:enfold/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';
import '../helpers/localized_app.dart';

Future<void> _logFinishedSleep(ProviderContainer container, Duration ago) {
  final end = DateTime.now().subtract(ago);
  final start = end.subtract(const Duration(hours: 1));
  return container.read(careLogActionsProvider).detailedLog(
        LogType.sleep,
        occurredAt: end,
        details: CareLogDetails(
          sleepStart: start,
          sleepEnd: end,
          sleepInProgress: false,
          durationMinutes: 60,
        ),
      );
}

Future<void> _pumpToday(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: localizedApp(const TodayScreen()),
    ),
  );
  await tester.pump();
  await container.read(recentSleepsProvider.future);
  await container.read(showAwakeTimeProvider.future);
  await tester.pump();
}

void main() {
  testWidgets('Today shows time awake after a finished sleep', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);
    await _logFinishedSleep(container, const Duration(minutes: 40));

    await _pumpToday(tester, container);

    expect(find.byKey(const Key('awake_time_banner')), findsOneWidget);
    expect(find.textContaining('Awake for 40m'), findsOneWidget);
  });

  testWidgets('Today hides time awake when switched off', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);
    await _logFinishedSleep(container, const Duration(minutes: 40));
    await container.read(databaseProvider).settingsDao.setShowAwakeTime(false);

    await _pumpToday(tester, container);

    expect(find.byKey(const Key('awake_time_banner')), findsNothing);
  });

  testWidgets('Today shows the sleeping banner instead while asleep', (
    tester,
  ) async {
    final container = createTestContainer();
    addTearDown(container.dispose);
    await _logFinishedSleep(container, const Duration(hours: 2));
    await container
        .read(careLogActionsProvider)
        .startSleepAt(DateTime.now().subtract(const Duration(minutes: 10)));

    await _pumpToday(tester, container);
    await container.read(openSleepProvider.future);
    await tester.pump();

    expect(find.byKey(const Key('active_sleep_banner')), findsOneWidget);
    expect(find.byKey(const Key('awake_time_banner')), findsNothing);
  });

  testWidgets('settings can switch time awake off', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(const SettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final toggle = find.byKey(const Key('awake_time_toggle'));
    await tester.ensureVisible(toggle);
    await tester.pump();
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue);

    await tester.tap(toggle);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      await container.read(databaseProvider).settingsDao.showAwakeTime(),
      isFalse,
    );
  });
}
