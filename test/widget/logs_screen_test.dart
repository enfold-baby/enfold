import 'package:bloomdue_baby/features/logs/log_feed_screen.dart';
import 'package:bloomdue_baby/features/logs/logs_hub_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  testWidgets('logs hub shows type cards', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LogsHubScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Your log history'), findsOneWidget);
    expect(find.byKey(const Key('logs_hub_feed')), findsOneWidget);
    expect(find.byKey(const Key('logs_hub_diaper')), findsOneWidget);
    expect(find.byKey(const Key('logs_hub_sleep')), findsOneWidget);
    expect(find.byKey(const Key('logs_hub_medication')), findsOneWidget);
    expect(find.byKey(const Key('logs_hub_pumping')), findsOneWidget);
    expect(find.byKey(const Key('logs_hub_tummy')), findsOneWidget);
  });

  testWidgets('feed form saves formula log with amount', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LogFeedScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Formula'));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('feed_amount')), '120');
    await tester.pump();
    await tester.tap(find.byKey(const Key('save_feed_log')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Feed logged'), findsOneWidget);
  });
}