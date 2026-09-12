import 'package:enfold/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  testWidgets('settings shows privacy and terms links', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const EnfoldApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('settings_privacy')), findsOneWidget);
    expect(find.byKey(const Key('settings_terms')), findsOneWidget);
    expect(
      find.textContaining('does not replace professional medical advice'),
      findsOneWidget,
    );
  });
}
