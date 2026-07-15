import 'package:bloomdue_baby/features/settings/widgets/account_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_until.dart';
import '../helpers/test_database.dart';

void main() {
  testWidgets('account section shows sign-in flow', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: AccountSection())),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('auth_email')), findsOneWidget);
    expect(find.byKey(const Key('auth_send_code')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('auth_email')), 'parent@bloomdue.baby');
    await tester.tap(find.byKey(const Key('auth_send_code')));
    await pumpUntilFound(tester, find.byKey(const Key('auth_code')));

    expect(find.byKey(const Key('auth_verify')), findsOneWidget);
  });
}