import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:enfold/widgets/paginated_column.dart';
import '../helpers/localized_app.dart';

Widget _host(List<int> items, {Widget? trailer}) {
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
            ?trailer,
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

  testWidgets('Load more adds exactly one page', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host(List.generate(25, (i) => i)));
    await tester.pump();

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('load_more')));
    await tester.pump();

    expect(find.byKey(const Key('item_19'), skipOffstage: false),
        findsOneWidget);
    expect(find.byKey(const Key('item_20'), skipOffstage: false), findsNothing);
    expect(find.text('Load more (5 remaining)'), findsOneWidget);
  });

  // Regression: a single fling used to trip the scroll listener several times
  // and swallow three or four pages, so the button was never seen and whatever
  // sat after the list (Recently deleted on the Logs hub) kept moving away.
  testWidgets('scrolling never loads a page on its own', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _host(
        List.generate(60, (i) => i),
        trailer: const SizedBox(
          height: 200,
          child: Text('trailing section', key: Key('trailer')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 4; i++) {
      await tester.fling(find.byType(ListView), const Offset(0, -900), 2000);
      await tester.pumpAndSettle();
    }

    expect(find.byKey(const Key('item_10'), skipOffstage: false), findsNothing);
    expect(find.text('Load more (50 remaining)'), findsOneWidget);
    // Anything after the list stays reachable.
    expect(find.byKey(const Key('trailer')), findsOneWidget);
  });
}
