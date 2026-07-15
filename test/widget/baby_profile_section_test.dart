import 'package:bloomdue_baby/features/settings/widgets/baby_profile_section.dart';
import 'package:bloomdue_baby/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  testWidgets('baby profile saves name', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: BabyProfileSection())),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byKey(const Key('baby_name')), 'Emma');
    await tester.pump();
    await tester.tap(find.byKey(const Key('baby_save_profile')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Profile saved on device.'), findsOneWidget);

    final db = container.read(databaseProvider);
    final babyId = await db.careLogDao.ensureDefaultBaby();
    final baby = await db.careLogDao.getBaby(babyId);
    expect(baby?.name, 'Emma');
  });
}