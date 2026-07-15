import 'package:bloomdue_baby/features/onboarding/onboarding_screen.dart';
import 'package:bloomdue_baby/services/database/database_provider.dart';
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
}