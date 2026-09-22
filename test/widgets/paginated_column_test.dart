import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:enfold/widgets/paginated_column.dart';
import '../helpers/localized_app.dart';

Widget _host(List<int> items) {
  return ProviderScope(
    child: localizedApp(
      Scaffold(
        body: ListView(
          children: [
            const SizedBox(height: 300),
            PaginatedColumn<int>(
              items: items,
              pageSize: 10,
              loadMoreKey: const Key('load_more'),
              itemBuilder: (context, item) => SizedBox(
                height: 60,
                key: Key('item_$item'),
                child: Text('Item $item'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows one page and a Load more button', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host(List.generate(25, (i) => i)));
    await tester.pump();

    expect(find.byKey(const Key('item_9')), findsOneWidget);
    expect(find.byKey(const Key('item_10')), findsNothing);
    expect(find.text('Load more (15 remaining)'), findsOneWidget);
  });

  testWidgets('scrolling near the bottom loads the next page by itself',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host(List.generate(25, (i) => i)));
    await tester.pump();

    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pump();
    await tester.pump();

    // The second page appeared without tapping Load more.
    expect(find.byKey(const Key('item_10')), findsOneWidget);

    // Staying at the bottom keeps loading until everything is shown.
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('item_24')), findsOneWidget);
    expect(find.byKey(const Key('load_more')), findsNothing);
  });
}
