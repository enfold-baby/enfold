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

  static int _sleepMinutesFor(CareLogEntry entry, DateTime now) {
    final details = entry.details;
    if (details.sleepInProgress == true) {
      final start = details.sleepStart ?? entry.loggedAt;
      final minutes = now.difference(start).inMinutes;
      return minutes < 0 ? 0 : minutes;
    }
    return details.resolvedSleepDurationMinutes ?? 0;
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