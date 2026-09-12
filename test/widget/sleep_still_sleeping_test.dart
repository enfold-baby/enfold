import 'package:enfold/features/logs/log_sleep_screen.dart';
import 'package:enfold/features/logs/providers/logs_providers.dart';
import 'package:enfold/features/today/providers/today_log_provider.dart';
import 'package:enfold/features/today/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  testWidgets('sleep form can hide wake time when still sleeping', (
    tester,
  ) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LogSleepScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Woke up'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(find.text('Woke up'), findsNothing);
    expect(find.text('Save, still sleeping'), findsOneWidget);
    expect(find.text('Fell asleep'), findsOneWidget);
  });

  testWidgets('Today shows an active sleep banner', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);
    await container
        .read(careLogActionsProvider)
        .startSleepAt(DateTime.now().subtract(const Duration(minutes: 20)));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TodayScreen()),
      ),
    );
    await tester.pump();
    await container.read(openSleepProvider.future);
    await tester.pump();

    expect(find.byKey(const Key('active_sleep_banner')), findsOneWidget);
    expect(find.text('Sleeping now'), findsOneWidget);
    expect(find.byKey(const Key('wake_up_button')), findsOneWidget);
  });
}
