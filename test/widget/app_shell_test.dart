import 'package:bloomdue_baby/app.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  testWidgets('app shell navigates between tabs', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    tester.view.physicalSize = const Size(400, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const BloomDueApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text("You're doing fine."), findsOneWidget);

    await tester.tap(find.text('Logs'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Your log history'), findsOneWidget);
    expect(find.byKey(const Key('logs_hub_feed')), findsOneWidget);

    await tester.tap(find.text('Learn'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Is this normal?'), findsOneWidget);
    expect(find.byKey(const Key('learn_card_spit-up-vs-vomiting')), findsOneWidget);

    await tester.tap(find.text('Pregnancy'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Track the journey'), findsOneWidget);
    expect(find.byKey(const Key('kick_counter_card')), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('export_7day_pdf')), findsOneWidget);
    expect(find.byKey(const Key('theme_mode_selector')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('about_version')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('v0.1.0 (1)'), findsOneWidget);
    expect(find.byKey(const Key('about_version')), findsOneWidget);
    expect(find.byKey(const Key('about_beta_badge')), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Today'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('log_feed')), findsOneWidget);
  });
}
