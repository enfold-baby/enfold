import 'package:enfold/features/pregnancy/pregnancy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';
import '../helpers/localized_app.dart';

void main() {
  testWidgets('pregnancy screen shows due date and kick counter', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(const PregnancyScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Track the journey'), findsOneWidget);
    expect(find.byKey(const Key('due_date_card')), findsOneWidget);
    expect(find.byKey(const Key('kick_counter_card')), findsOneWidget);
    expect(find.byKey(const Key('kick_count')), findsOneWidget);
    expect(find.text('Appointments'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('empty_appointments')),
      100,
    );
    expect(find.byKey(const Key('empty_appointments')), findsOneWidget);
  });

  testWidgets('kick counter increments on tap', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(const PregnancyScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const Key('log_kick')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('1'), findsOneWidget);
    expect(find.text('Kick 1 logged today'), findsOneWidget);
  });
}