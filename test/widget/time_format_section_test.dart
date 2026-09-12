import 'package:enfold/features/settings/settings_screen.dart';
import 'package:enfold/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  testWidgets('settings can switch to 24-hour time', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(const Key('clock_format_selector')), findsOneWidget);
    expect(find.text('12-hour (AM/PM)'), findsOneWidget);
    expect(find.text('24-hour'), findsOneWidget);

    await tester.tap(find.text('24-hour'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      await container.read(databaseProvider).settingsDao.use24HourTime(),
      isTrue,
    );
  });
}
