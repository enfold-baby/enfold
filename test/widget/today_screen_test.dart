import 'package:enfold/core/router/app_router.dart';
import 'package:enfold/features/logs/log_feed_screen.dart';
import 'package:enfold/features/today/models/log_type.dart';
import 'package:enfold/features/today/providers/today_log_provider.dart';
import 'package:enfold/features/today/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/test_database.dart';
import '../helpers/localized_app.dart';
import 'package:enfold/l10n/generated/app_localizations.dart';

void main() {
  group('TodayScreen', () {
    testWidgets('shows reassurance copy and empty state', (tester) async {
      final container = createTestContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: localizedApp(const TodayScreen()),
        ),
      );
      await tester.pump();
      await container.read(todayLogProvider.future);
      await tester.pump();

      expect(find.text("You're doing fine."), findsOneWidget);
      expect(find.text('Quick actions'), findsOneWidget);
      expect(find.byKey(const Key('log_feed')), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Today so far'), 120);
      expect(find.text('Today so far'), findsOneWidget);
      expect(find.byKey(const Key('today_summary_feed')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Nothing logged yet today. Tap a button when you\'re ready.'),
        120,
      );
      expect(find.text('Recent'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('today_growth_card')),
        120,
      );
      expect(find.text('Growth & milestones'), findsOneWidget);
      expect(find.byKey(const Key('today_growth_card')), findsOneWidget);
      expect(find.byKey(const Key('today_medication_card')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('today_activity_card')),
        120,
      );
      expect(find.byKey(const Key('today_activity_card')), findsOneWidget);
    });

    testWidgets('long press opens feed add form', (tester) async {
      final container = createTestContainer();
      addTearDown(container.dispose);
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: AppRoutes.today,
            builder: (context, state) => const TodayScreen(),
          ),
          GoRoute(
            path: AppRoutes.logFeedAdd,
            builder: (context, state) => const LogFeedScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: localizedRouterApp(router),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      await tester.ensureVisible(find.byKey(const Key('log_feed')));
      await tester.pumpAndSettle();
      await tester.longPress(find.byKey(const Key('log_feed')));
      await tester.pumpAndSettle();

      expect(find.text('Log feed'), findsOneWidget);
      expect(find.byKey(const Key('feed_mode_picker')), findsOneWidget);
    });
  });

  group('TodayScreen helpers', () {
    test('greetingForHour returns night copy after 10pm', () {
      final en = lookupAppL10n(const Locale('en'));
      expect(TodayScreen.greetingForHour(en, 23), 'Good night');
      expect(TodayScreen.greetingForHour(en, 8), 'Good morning');

      final ro = lookupAppL10n(const Locale('ro'));
      expect(TodayScreen.greetingForHour(ro, 23), 'Noapte bună');
    });
  });

  group('CareLogDao', () {
    test('logs persist in sqlite', () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final babyId = await db.careLogDao.ensureDefaultBaby();
      await db.careLogDao.insertQuickLog(
        babyId: babyId,
        type: LogType.feed.apiType,
        occurredAt: DateTime.now(),
      );

      final logs = await db.careLogDao.getTodayLogs(babyId);
      expect(logs, hasLength(1));
      expect(logs.first.type, LogType.feed.apiType);
      expect(logs.first.pendingSync, isTrue);
    });

    test('ensureDefaultBaby creates only one default profile', () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final first = await db.careLogDao.ensureDefaultBaby();
      final second = await db.careLogDao.ensureDefaultBaby();
      expect(first, second);
    });

    test('getLogsForLastDays returns events in range', () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final babyId = await db.careLogDao.ensureDefaultBaby();
      final now = DateTime.now();
      await db.careLogDao.insertQuickLog(
        babyId: babyId,
        type: LogType.feed.apiType,
        occurredAt: now.subtract(const Duration(days: 2)),
      );
      await db.careLogDao.insertQuickLog(
        babyId: babyId,
        type: LogType.sleep.apiType,
        occurredAt: now.subtract(const Duration(days: 10)),
      );

      final logs = await db.careLogDao.getLogsForLastDays(babyId, 7);
      expect(logs, hasLength(1));
      expect(logs.first.type, LogType.feed.apiType);
    });
  });
}
