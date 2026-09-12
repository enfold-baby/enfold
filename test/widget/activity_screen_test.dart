import 'package:enfold/features/pumping/log_pumping_screen.dart';
import 'package:enfold/features/pumping/pumping_logs_screen.dart';
import 'package:enfold/features/tummy_time/log_tummy_time_screen.dart';
import 'package:enfold/features/tummy_time/tummy_time_logs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  testWidgets('pumping list screen shows empty state', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: PumpingLogsScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Pumping'), findsOneWidget);
    expect(find.byKey(const Key('pumping_logs_empty')), findsOneWidget);
  });

  testWidgets('tummy list screen shows empty state', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TummyTimeLogsScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Tummy time'), findsOneWidget);
    expect(find.byKey(const Key('tummy_logs_empty')), findsOneWidget);
  });

  testWidgets('pumping form saves session with amount', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LogPumpingScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byKey(const Key('pumping_amount')), '60');
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('save_pumping_log')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('save_pumping_log')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Pumping logged'), findsOneWidget);
  });

  testWidgets('pumping form requires an amount', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LogPumpingScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.byKey(const Key('save_pumping_log')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('save_pumping_log')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Add how much you pumped.'), findsOneWidget);
    expect(find.text('Pumping logged'), findsNothing);
  });

  testWidgets('tummy form saves five minute session', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LogTummyTimeScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('5 min'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('save_tummy_log')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('save_tummy_log')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Tummy time logged'), findsOneWidget);
  });
}