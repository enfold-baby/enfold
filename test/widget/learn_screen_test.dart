import 'package:enfold/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_until.dart';
import '../helpers/test_database.dart';

void main() {
  testWidgets('learn list, card detail, and triage flow', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const EnfoldApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Learn'));
    await pumpUntilFound(tester, find.text('Is this normal?'));

    expect(find.byKey(const Key('learn_card_fever-newborn')), findsOneWidget);
    expect(find.byKey(const Key('learn_card_wet-diapers-day-1-7')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('learn_search')), 'fever');
    await tester.pump();
    expect(find.byKey(const Key('learn_card_fever-newborn')), findsOneWidget);
    expect(find.byKey(const Key('learn_card_wet-diapers-day-1-7')), findsNothing);

    await tester.tap(find.byKey(const Key('learn_search_clear')));
    await tester.pump();
    expect(find.byKey(const Key('learn_card_wet-diapers-day-1-7')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('learn_card_fever-newborn')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('learn_card_fever-newborn')));
    await pumpUntilFound(tester, find.byKey(const Key('triage_start_fever-newborn')));

    await tester.tap(find.byKey(const Key('triage_start_fever-newborn')));
    await pumpUntilFound(tester, find.byKey(const Key('triage_yes')));

    // No fever path: age -> yes -> temp -> no -> green
    await tester.tap(find.byKey(const Key('triage_yes')));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const Key('triage_no')));
    await pumpUntilFound(tester, find.byKey(const Key('triage_outcome_green')));

    expect(find.byKey(const Key('triage_outcome_green')), findsOneWidget);
  });
}