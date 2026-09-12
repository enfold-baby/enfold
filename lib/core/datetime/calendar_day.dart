import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Midnight at the start of [now]'s local calendar day.
DateTime calendarDayStart(DateTime now) => DateTime(now.year, now.month, now.day);

/// The current local calendar day (a midnight). Providers that compute
/// "today" or "last 7 days" ranges watch this so they recompute after
/// midnight or when the app comes back to the foreground on a new day,
/// instead of keeping the range from when the screen was first opened.
final currentCalendarDayProvider = StateProvider<DateTime>(
  (ref) => calendarDayStart(DateTime.now()),
);

/// End (exclusive) of the calendar day that starts at [dayStart].
DateTime calendarDayEnd(DateTime dayStart) =>
    dayStart.add(const Duration(days: 1));

/// Keeps [currentCalendarDayProvider] fresh: re-checks the date on every
/// app resume and on a timer armed for the next local midnight.
class CalendarDayTicker with WidgetsBindingObserver {
  CalendarDayTicker(this._ref, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final WidgetRef _ref;
  final DateTime Function() _clock;
  Timer? _timer;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    refresh();
  }

  void dispose() {
    if (!_started) return;
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  /// Updates the provider if the day changed and re-arms the midnight timer.
  void refresh() {
    final now = _clock();
    final today = calendarDayStart(now);
    final notifier = _ref.read(currentCalendarDayProvider.notifier);
    if (notifier.state != today) notifier.state = today;
    _timer?.cancel();
    // A second past midnight avoids firing a hair too early.
    final untilMidnight =
        calendarDayEnd(today).difference(now) + const Duration(seconds: 1);
    _timer = Timer(untilMidnight, refresh);
  }
}
