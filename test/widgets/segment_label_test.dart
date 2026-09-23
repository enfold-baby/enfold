import 'package:enfold/widgets/segment_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/localized_app.dart';

Widget _host(Widget Function(String) label, double textScale) {
  return localizedApp(
    Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: label('Greutate')),
                ButtonSegment(value: 1, label: label('Lungime')),
                ButtonSegment(value: 2, label: label('Cap')),
              ],
              selected: const {0},
              onSelectionChanged: (_) {},
            ),
          ),
        ),
      ),
    ),
    locale: const Locale('ro'),
  );
}

void main() {
  // Regression: "Greutate" wrapped inside the growth chart's segmented button
  // and broke as "Greutat" / "e". Segments split the row evenly, so a long
  // translated word has to shrink rather than wrap.
  testWidgets('a long segment label stays on one line', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final scale in [1.0, 1.15, 1.3]) {
      await tester.pumpWidget(_host((t) => SegmentLabel(t), scale));
      await tester.pumpAndSettle();

      final long = tester.getSize(find.text('Greutate').first).height;
      final short = tester.getSize(find.text('Cap').first).height;
      expect(
        long,
        lessThan(short * 1.5),
        reason: '"Greutate" wrapped at text scale $scale',
      );
    }
  });
}
