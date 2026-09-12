import 'package:enfold/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> _pickBirthDateJune4(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('onboarding_pick_birth_date')));
  await tester.pumpAndSettle();

  final prevMonth = find.byIcon(Icons.chevron_left);
  if (prevMonth.evaluate().isNotEmpty) {
    await tester.tap(prevMonth);
    await tester.pumpAndSettle();
  }

  final day4 = find.descendant(
    of: find.byType(DatePickerDialog),
    matching: find.text('4'),
  );
  await tester.tap(day4.first);
  await tester.pumpAndSettle();

  await tester.tap(find.descendant(
    of: find.byType(DatePickerDialog),
    matching: find.text('OK'),
  ));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Enfold e2e', () {
    testWidgets('onboarding baby born shows Today log buttons', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byKey(const Key('onboarding_get_started')), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding_get_started')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('onboarding_journey_baby')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('onboarding_continue')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('onboarding_baby_name')),
        'Damian',
      );
      await tester.pump();
      await _pickBirthDateJune4(tester);
      expect(find.textContaining('Born 2026-06-04'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding_finish')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text("Today's log"), findsOneWidget);
      expect(find.text("You're doing fine."), findsOneWidget);
      expect(find.byKey(const Key('log_feed')), findsOneWidget);
      expect(find.byKey(const Key('log_diaper')), findsOneWidget);
      expect(find.byKey(const Key('log_sleep')), findsOneWidget);

      await tester.tap(find.byKey(const Key('log_feed')));
      await tester.pumpAndSettle();

      expect(find.text('Log feed'), findsOneWidget);
      expect(find.byKey(const Key('save_feed_log')), findsOneWidget);
    });

    testWidgets('launch, log feed, navigate tabs, switch dark mode', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (find.byKey(const Key('onboarding_get_started')).evaluate().isNotEmpty) {
        await tester.tap(find.byKey(const Key('onboarding_skip')));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      expect(find.text("Today's log"), findsOneWidget);
      expect(find.text("You're doing fine."), findsOneWidget);

      await tester.longPress(find.byKey(const Key('log_feed')));
      await tester.pumpAndSettle();

      expect(find.text('Log feed'), findsOneWidget);

      await tester.tap(find.text('Learn'));
      await tester.pumpAndSettle();
      expect(find.text('Is this normal?'), findsOneWidget);
      expect(find.byKey(const Key('learn_card_wet-diapers-day-1-7')), findsOneWidget);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('log_diaper')), findsOneWidget);

      await tester.tap(find.byKey(const Key('log_diaper')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Diaper logged'), findsOneWidget);
    });
  });
}