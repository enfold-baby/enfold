import 'package:enfold/features/growth/growth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  testWidgets('growth screen shows measurements and milestones', (tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GrowthScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Growing beautifully'), findsOneWidget);
    expect(find.text('Measurements'), findsOneWidget);
    expect(find.text('Milestones'), findsOneWidget);
    expect(find.text('First social smile'), findsOneWidget);
    expect(find.byKey(const Key('add_growth_measurement')), findsOneWidget);
    expect(find.byKey(const Key('growth_trend_chart')), findsOneWidget);
    expect(find.text('Trend'), findsOneWidget);
  });
}