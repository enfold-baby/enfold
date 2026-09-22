import 'package:enfold/features/medication/log_medication_screen.dart';
import 'package:enfold/features/medication/medication_logs_screen.dart';
import 'package:enfold/features/today/today_screen.dart';
import 'package:enfold/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';
import '../helpers/localized_app.dart';

void main() {
  testWidgets('logging vitamin D with daily reminder creates a routine', (
    tester,
  ) async {
    final container = createTestContainer();
    addTearDown(container.dispose);
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(const LogMedicationScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Vitamin D drops'));
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const Key('medication_daily_reminder_toggle')),
    );
    await tester.tap(find.byKey(const Key('medication_daily_reminder_toggle')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('save_medication_log')));
    await tester.tap(find.byKey(const Key('save_medication_log')));
    await tester.pump(const Duration(milliseconds: 400));

    final db = container.read(databaseProvider);
    final babyId = await db.careLogDao.ensureDefaultBaby();
    final routines = await db.medicationRoutineDao.listForBaby(babyId);
    expect(routines, hasLength(1));
    expect(routines.first.name, 'Vitamin D drops');
    expect(routines.first.enabled, isTrue);
  });

  testWidgets('Today shows not logged yet until Given', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);
    final db = container.read(databaseProvider);
    final babyId = await db.careLogDao.ensureDefaultBaby();
    await db.medicationRoutineDao.upsertDaily(
      babyId: babyId,
      name: 'Vitamin D drops',
      dose: '1 drop',
      hour: 9,
      minute: 0,
    );

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(const TodayScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.scrollUntilVisible(
      find.byKey(const Key('today_medication_card')),
      120,
    );

    expect(find.text('Vitamin D drops: not logged yet'), findsOneWidget);
    await tester.tap(find.byTooltip('Log Vitamin D drops'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Vitamin D drops: not logged yet'), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('today_medication_card')),
        matching: find.textContaining('Vitamin D drops ·'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('meds list shows daily reminders section', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);
    final db = container.read(databaseProvider);
    final babyId = await db.careLogDao.ensureDefaultBaby();
    await db.medicationRoutineDao.upsertDaily(
      babyId: babyId,
      name: 'Vigantol',
      hour: 9,
      minute: 0,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(const MedicationLogsScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Daily reminders'), findsOneWidget);
    expect(find.text('Vigantol'), findsOneWidget);
  });
}
