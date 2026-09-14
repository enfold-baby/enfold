import 'package:enfold/features/onboarding/onboarding_screen.dart';
import 'package:enfold/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/test_database.dart';

GoRouter _testRouter() {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: Text('Home')),
      ),
    ],
  );
}

void main() {
  testWidgets('onboarding pregnancy path saves due date', (tester) async {
    final db = createTestDatabase();
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: _testRouter()),
      ),
    );

    await tester.tap(find.byKey(const Key('onboarding_get_started')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('onboarding_journey_pregnant')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('onboarding_continue')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('onboarding_pick_due_date')));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: find.byType(DatePickerDialog),
      matching: find.text('OK'),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('onboarding_finish')));
    await tester.pumpAndSettle();

    expect(await db.settingsDao.isOnboardingCompleted(), isTrue);
    final profile = await db.pregnancyDao.ensureProfile();
    expect(profile.dueDate, isNotNull);
    expect(find.text('Home'), findsOneWidget);
  });

  // The baby path is covered by test/features/onboarding/onboarding_actions_test.dart
  // and test/services/ensure_default_baby_test.dart; a widget-level version never
  // settles in the test harness (focused TextField + router redirect).

  testWidgets('skip completes onboarding', (tester) async {
    final db = createTestDatabase();
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: _testRouter()),
      ),
    );

    await tester.tap(find.byKey(const Key('onboarding_skip')));
    await tester.pumpAndSettle();

    expect(await db.settingsDao.isOnboardingCompleted(), isTrue);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('welcome hero stays visible on a landscape tablet', (tester) async {
    final db = createTestDatabase();
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: _testRouter()),
      ),
    );
    await tester.pumpAndSettle();

    final hero = tester.renderObject<RenderBox>(
      find.byKey(const Key('onboarding_welcome_hero')),
    );
    expect(hero.size.height, greaterThan(280));
    expect(hero.size.width / hero.size.height, lessThan(2.4));
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Skip for now'), findsOneWidget);
  });

  for (final phone in const [
    (name: 'iPhone', size: Size(390, 844)),
    (name: 'small iPhone SE', size: Size(320, 568)),
  ]) {
    testWidgets('welcome step lays out on a portrait ${phone.name}', (
      tester,
    ) async {
      final db = createTestDatabase();
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      addTearDown(db.close);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.physicalSize = phone.size * 3;
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: _testRouter()),
        ),
      );
      await tester.pumpAndSettle();

      // A LayoutBuilder under IntrinsicHeight throws here on every frame.
      expect(tester.takeException(), isNull);
      final hero = tester.renderObject<RenderBox>(
        find.byKey(const Key('onboarding_welcome_hero')),
      );
      expect(hero.size.height, inInclusiveRange(180, 300));
      await tester.ensureVisible(find.byKey(const Key('onboarding_skip')));
      await tester.pumpAndSettle();
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);
    });
  }
}
