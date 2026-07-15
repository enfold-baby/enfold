import 'package:bloomdue_baby/features/medication/log_medication_screen.dart';
import 'package:bloomdue_baby/features/medication/medication_logs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  testWidgets('medication list screen shows empty state', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MedicationLogsScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Meds & vitamins'), findsOneWidget);
    expect(find.text('All doses'), findsOneWidget);
    expect(find.byKey(const Key('add_medication_log')), findsOneWidget);
    expect(find.byKey(const Key('medication_logs_empty')), findsOneWidget);
  });

  testWidgets('medication form saves vitamin D dose', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LogMedicationScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Vitamin D drops'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('save_medication_log')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('save_medication_log')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Dose logged'), findsOneWidget);
  });
}