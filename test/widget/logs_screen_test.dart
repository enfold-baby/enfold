import 'package:enfold/features/logs/log_feed_screen.dart';
import 'package:enfold/features/logs/logs_hub_screen.dart';
import 'package:enfold/features/logs/sleep_logs_screen.dart';
import 'package:enfold/services/database/database_provider.dart';
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
    expect(find.byKey(const Key('logs_hub_growth')), findsOneWidget);
    expect(find.byKey(const Key('logs_hub_milestones')), findsOneWidget);
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

  testWidgets('sleep logs show ten rows then load more', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);
    final db = container.read(databaseProvider);
    final babyId = await db.careLogDao.ensureDefaultBaby();
    final now = DateTime.now();
    for (var i = 0; i < 12; i++) {
      await db.careLogDao.insertLog(
        babyId: babyId,
        type: 'sleep',
        occurredAt: now.subtract(Duration(hours: i)),
      );
    }

    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SleepLogsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Load more (2 remaining)'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is Key &&
            widget.key.toString().contains('log_entry_'),
      ),
      findsNWidgets(10),
    );

    await tester.ensureVisible(find.byKey(const Key('load_more_logs')));
    await tester.tap(find.byKey(const Key('load_more_logs')));
    await tester.pump();
    expect(find.byKey(const Key('load_more_logs')), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is Key &&
            widget.key.toString().contains('log_entry_'),
      ),
      findsNWidgets(12),
    );
  });
}