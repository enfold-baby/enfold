import 'package:enfold/features/logs/logs_hub_screen.dart';
import 'package:enfold/features/growth/growth_screen.dart';
import 'package:enfold/features/logs/log_diaper_screen.dart';
import 'package:enfold/features/logs/log_sleep_screen.dart';
import 'package:enfold/features/logs/log_feed_screen.dart';
import 'package:enfold/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/localized_app.dart';
import '../helpers/test_database.dart';

void main() {
  testWidgets('a Romanian device gets the Romanian UI', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(
          const LogsHubScreen(),
          locale: const Locale('ro'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Istoricul tău'), findsOneWidget);
    expect(find.text('Filtru'), findsOneWidget);
    expect(find.text('Your log history'), findsNothing);
  });

  testWidgets('an English device keeps the English UI', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(const LogsHubScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Your log history'), findsOneWidget);
    expect(find.text('Istoricul tău'), findsNothing);
  });

  testWidgets('Settings offers the language override', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    tester.view.physicalSize = const Size(400, 4200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(const SettingsScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final selector =
        find.byKey(const Key('language_selector'), skipOffstage: false);
    expect(selector, findsOneWidget);
    await tester.ensureVisible(selector);
    await tester.pump();
    expect(find.text('Romanian'), findsOneWidget);
  });
  // Romanian runs longer than English, so a narrow phone is where a label
  // would overflow first. 320px is the smallest width Android still ships.
  // The segmented buttons in Settings and the log form buttons are the risky
  // parts: they put several translated labels on one row.
  testWidgets('Romanian fits a 320px phone', (tester) async {
    final screens = <Widget>[
      const LogsHubScreen(),
      const SettingsScreen(),
      const LogFeedScreen(),
      const LogSleepScreen(),
      const LogDiaperScreen(),
      const GrowthScreen(),
    ];
    for (final screen in screens) {
      final container = createTestContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(320, 5200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: localizedApp(screen, locale: const Locale('ro')),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        tester.takeException(),
        isNull,
        reason: '${screen.runtimeType} overflowed in Romanian at 360px',
      );
    }
  });
}
