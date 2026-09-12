import 'package:enfold/features/growth/growth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  testWidgets('checking a milestone asks for a date', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GrowthScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.scrollUntilVisible(
      find.byKey(const Key('milestone_social_smile')),
      120,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('milestone_social_smile')));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });
}
