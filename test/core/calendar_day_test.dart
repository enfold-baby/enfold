import 'package:enfold/core/datetime/calendar_day.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calendarDayStart and calendarDayEnd bracket the local day', () {
    final start = calendarDayStart(DateTime(2026, 9, 12, 23, 59, 30));
    expect(start, DateTime(2026, 9, 12));
    expect(calendarDayEnd(start), DateTime(2026, 9, 13));
  });

  tickerTests();
}

class _Probe extends ConsumerStatefulWidget {
  const _Probe({required this.onReady});
  final void Function(WidgetRef ref) onReady;
  @override
  ConsumerState<_Probe> createState() => _ProbeState();
}

class _ProbeState extends ConsumerState<_Probe> {
  @override
  void initState() {
    super.initState();
    widget.onReady(ref);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void tickerTests() {
  testWidgets('ticker moves the current day forward after midnight',
      (tester) async {
    var now = DateTime(2026, 9, 12, 23, 59, 59);
    late WidgetRef ref;
    await tester.pumpWidget(
      ProviderScope(child: _Probe(onReady: (r) => ref = r)),
    );
    final ticker = CalendarDayTicker(ref, clock: () => now);
    addTearDown(ticker.dispose);

    ticker.start();
    expect(ref.read(currentCalendarDayProvider), DateTime(2026, 9, 12));

    now = DateTime(2026, 9, 13, 0, 0, 1);
    await tester.pump(const Duration(seconds: 3));
    expect(ref.read(currentCalendarDayProvider), DateTime(2026, 9, 13));

    // Coming back to the foreground on a later day refreshes too.
    now = DateTime(2026, 9, 15, 8);
    ticker.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(ref.read(currentCalendarDayProvider), DateTime(2026, 9, 15));
    ticker.dispose(); // cancels the armed midnight timer
  });
}
