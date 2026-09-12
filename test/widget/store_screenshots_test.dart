import 'package:enfold/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  testWidgets('store phone screenshots', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const EnfoldApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/play_phone_today.png'),
    );

    await tester.tap(find.text('Logs'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/play_phone_logs.png'),
    );

    await tester.tap(find.text('Learn'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/play_phone_learn.png'),
    );

    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/play_phone_settings.png'),
    );
  }, skip: true);
}
