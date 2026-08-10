// Demo data + pause markers for host-side adb screenshots (Damian).
// Prefer host script: scripts/capture_demo_screenshots.sh

import 'dart:convert';

import 'package:bloomdue_baby/main.dart' as app;
import 'package:bloomdue_baby/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> _pickBirthDateJune4(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('onboarding_pick_birth_date')));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  final prevMonth = find.byIcon(Icons.chevron_left);
  if (prevMonth.evaluate().isNotEmpty) {
    await tester.tap(prevMonth);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  final day4 = find.descendant(
    of: find.byType(DatePickerDialog),
    matching: find.text('4'),
  );
  await tester.tap(day4.first);
  await tester.pumpAndSettle();

  final ok = find.descendant(
    of: find.byType(DatePickerDialog),
    matching: find.text('OK'),
  );
  if (ok.evaluate().isNotEmpty) {
    await tester.tap(ok);
  } else {
    // Some locales use "Done" / material 3 confirm.
    final done = find.descendant(
      of: find.byType(DatePickerDialog),
      matching: find.text('Done'),
    );
    if (done.evaluate().isNotEmpty) {
      await tester.tap(done);
    }
  }
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

Future<void> _seedDemoDay(WidgetTester tester) async {
  final element = tester.element(find.byType(MaterialApp).first);
  final container = ProviderScope.containerOf(element);
  final db = container.read(databaseProvider);
  final babyId = await db.careLogDao.ensureDefaultBaby();

  await db.careLogDao.updateBabyProfile(
    babyId: babyId,
    name: 'Damian',
    birthDate: DateTime(2026, 6, 4),
    isPreemie: false,
  );

  final now = DateTime.now();
  final day = DateTime(now.year, now.month, now.day);

  DateTime at(int hour, [int minute = 0]) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  Future<void> feed({
    required DateTime when,
    required String mode,
    String? side,
    String? delivery,
    int? ml,
    int? minutes,
    String note = '',
  }) async {
    final details = <String, dynamic>{
      'feed_mode': mode,
      if (side != null) 'breast_side': side,
      if (delivery != null) 'breast_delivery': delivery,
      if (ml != null) 'bottle_ml': ml,
      if (minutes != null) 'feed_duration_minutes': minutes,
    };
    await db.careLogDao.insertLog(
      babyId: babyId,
      type: 'feeding',
      occurredAt: when,
      detailsJson: jsonEncode(details),
      note: note,
      loggedByDisplayName: 'Parent',
    );
  }

  Future<void> diaper({
    required DateTime when,
    required bool wet,
    required bool dirty,
    String? consistency,
  }) async {
    final details = <String, dynamic>{
      'wet': wet,
      'dirty': dirty,
      if (consistency != null) 'stool_consistency': consistency,
    };
    await db.careLogDao.insertLog(
      babyId: babyId,
      type: 'diaper',
      occurredAt: when,
      detailsJson: jsonEncode(details),
      loggedByDisplayName: 'Parent',
    );
  }

  Future<void> sleep({
    required DateTime start,
    required DateTime end,
  }) async {
    final mins = end.difference(start).inMinutes;
    final details = <String, dynamic>{
      'sleep_start': start.toIso8601String(),
      'sleep_end': end.toIso8601String(),
      'sleep_in_progress': false,
      'duration_minutes': mins,
    };
    await db.careLogDao.insertLog(
      babyId: babyId,
      type: 'sleep',
      occurredAt: start,
      detailsJson: jsonEncode(details),
      loggedByDisplayName: 'Parent',
    );
  }

  await feed(
    when: at(6, 15),
    mode: 'breast',
    side: 'left',
    delivery: 'direct',
    minutes: 18,
    note: 'Calm morning feed',
  );
  await diaper(when: at(6, 40), wet: true, dirty: false);
  await sleep(start: at(7, 0), end: at(8, 45));

  await feed(
    when: at(9, 0),
    mode: 'breast',
    side: 'right',
    delivery: 'pumped',
    ml: 90,
    note: 'Bottle · expressed milk',
  );
  await diaper(when: at(9, 25), wet: true, dirty: true, consistency: 'soft');

  await feed(
    when: at(11, 30),
    mode: 'breast',
    side: 'left',
    delivery: 'direct',
    minutes: 14,
  );
  await sleep(start: at(12, 0), end: at(13, 20));

  await feed(
    when: at(13, 40),
    mode: 'formula',
    ml: 80,
    note: 'Small formula top-up',
  );
  await diaper(when: at(14, 10), wet: true, dirty: false);

  await feed(
    when: at(16, 0),
    mode: 'breast',
    delivery: 'pumped',
    ml: 100,
    note: 'Bottle · breast milk',
  );
  await sleep(start: at(16, 30), end: at(17, 45));

  await feed(
    when: at(18, 30),
    mode: 'breast',
    side: 'right',
    delivery: 'direct',
    minutes: 20,
  );
  await diaper(when: at(19, 0), wet: true, dirty: true, consistency: 'soft');

  final recentHour = now.hour >= 1 ? now.hour - 1 : 20;
  await feed(
    when: at(recentHour, 10),
    mode: 'breast',
    side: 'left',
    delivery: 'direct',
    minutes: 12,
  );
}

Future<void> _holdForShot(String name) async {
  // Host script greps logcat / stdout for this marker then adb screencaps.
  // ignore: avoid_print
  print('###SHOT### $name');
  await Future<void>.delayed(const Duration(seconds: 6));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo screenshots with Damian seed data', (tester) async {
    app.main();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    if (find.byKey(const Key('onboarding_get_started')).evaluate().isNotEmpty) {
      await tester.tap(find.byKey(const Key('onboarding_get_started')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key('onboarding_journey_baby')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const Key('onboarding_continue')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(
        find.byKey(const Key('onboarding_baby_name')),
        'Damian',
      );
      await tester.pump(const Duration(milliseconds: 500));
      // Dismiss keyboard if open
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await _pickBirthDateJune4(tester);

      await tester.tap(find.byKey(const Key('onboarding_finish')));
      await tester.pumpAndSettle(const Duration(seconds: 4));
    } else if (find.byKey(const Key('onboarding_skip')).evaluate().isNotEmpty) {
      await tester.tap(find.byKey(const Key('onboarding_skip')));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    await _seedDemoDay(tester);
    // Rebuild UI from DB
    await tester.pumpAndSettle(const Duration(seconds: 2));
    // Tap Today to refresh if needed
    if (find.text('Today').evaluate().isNotEmpty) {
      await tester.tap(find.text('Today').last);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    await _holdForShot('bloomdue_01_today');

    if (find.text('Logs').evaluate().isNotEmpty) {
      await tester.tap(find.text('Logs').last);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
    await _holdForShot('bloomdue_02_logs');

    if (find.text('Learn').evaluate().isNotEmpty) {
      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
    await _holdForShot('bloomdue_03_learn');

    if (find.text('Settings').evaluate().isNotEmpty) {
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
    await _holdForShot('bloomdue_04_settings');

    if (find.text('Today').evaluate().isNotEmpty) {
      await tester.tap(find.text('Today').last);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
    await _holdForShot('bloomdue_05_today_again');

    // ignore: avoid_print
    print('###SHOT_DONE###');
  });
}
