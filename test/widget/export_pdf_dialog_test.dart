import 'package:enfold/features/today/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';
import '../helpers/localized_app.dart';

void main() {
  testWidgets('Today PDF button explains the export before sharing', (
    tester,
  ) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(const TodayScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const Key('export_pdf_app_bar')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('export_pdf_confirm_dialog')), findsOneWidget);
    expect(find.text('Share a 7-day visit PDF?'), findsOneWidget);
    expect(find.byKey(const Key('export_pdf_cancel')), findsOneWidget);

    await tester.tap(find.byKey(const Key('export_pdf_cancel')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('export_pdf_confirm_dialog')), findsNothing);
  });
}
