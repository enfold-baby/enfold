import '../../../core/datetime/calendar_day.dart';
import 'care_log_entry.dart';
import 'log_type.dart';

class TodaySummary {
  const TodaySummary({
    required this.feedCount,
    required this.diaperCount,
    required this.sleepMinutes,
  });

  final int feedCount;
  final int diaperCount;
  final int sleepMinutes;

  static const empty = TodaySummary(
    feedCount: 0,
    diaperCount: 0,
    sleepMinutes: 0,
  );

  factory TodaySummary.fromEntries(
    List<CareLogEntry> entries, {
    DateTime? now,
  }) {
    var feeds = 0;
    var diapers = 0;
    var sleepMinutes = 0;
    final clock = now ?? DateTime.now();

    for (final entry in entries) {
      switch (entry.type) {
        case LogType.feed:
          feeds++;
        case LogType.diaper:
          diapers++;
        case LogType.sleep:
          sleepMinutes += _sleepMinutesFor(entry, clock);
        case LogType.medication:
        case LogType.pumping:
        case LogType.tummyTime:
          break;
      }
    }

    return TodaySummary(
      feedCount: feeds,
      diaperCount: diapers,
      sleepMinutes: sleepMinutes,
    );
  }

  /// Minutes of [entry]'s sleep that fall inside [now]'s calendar day.
  ///
  /// A sleep row is stamped with its end time, so a night that ran 22:00 to
  /// 02:00 shows up in today's list with 4h of duration. Only the part after
  /// midnight belongs to today, so the interval is clipped to the day.
  static int _sleepMinutesFor(CareLogEntry entry, DateTime now) {
    final interval = sleepInterval(entry, now);
    if (interval == null) return 0;
    final dayStart = calendarDayStart(now);
    final dayEnd = calendarDayEnd(dayStart);
    final start = interval.start.isAfter(dayStart) ? interval.start : dayStart;
    final end = interval.end.isBefore(dayEnd) ? interval.end : dayEnd;
    final minutes = end.difference(start).inMinutes;
    return minutes < 0 ? 0 : minutes;
  }

  /// The [start, end) span of a sleep entry, or null when it has no duration.
  /// An in-progress sleep runs until [now]. Rows saved with only a duration
  /// are anchored to their logged time, which is the sleep's end.
  static ({DateTime start, DateTime end})? sleepInterval(
    CareLogEntry entry,
    DateTime now,
  ) {
    final details = entry.details;
    if (details.sleepInProgress == true) {
      final start = details.sleepStart ?? entry.loggedAt;
      return (start: start, end: now.isAfter(start) ? now : start);
    }
    final end = details.sleepEnd ?? entry.loggedAt;
    final start = details.sleepStart ??
        (details.durationMinutes != null
            ? end.subtract(Duration(minutes: details.durationMinutes!))
            : null);
    if (start == null) return null;
    return (start: start, end: end);
  }

  String get sleepLabel {
    if (sleepMinutes <= 0) return '0m';
    if (sleepMinutes < 60) return '${sleepMinutes}m';
    final hours = sleepMinutes ~/ 60;
    final remainder = sleepMinutes % 60;
    if (remainder == 0) return '${hours}h';
    return '${hours}h ${remainder}m';
  }

}