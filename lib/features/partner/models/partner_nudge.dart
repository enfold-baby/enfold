import '../../../l10n/generated/app_localizations.dart';
import '../../today/models/care_log_entry.dart';
import '../../today/models/log_type.dart';

class PartnerNudge {
  const PartnerNudge({
    required this.type,
    required this.hoursSince,
    required this.nothingToday,
  });

  final LogType type;
  final int hoursSince;

  /// Nothing of this type logged at all today, as opposed to a stale last log.
  final bool nothingToday;

  String message(AppL10n l10n) => switch (type) {
        LogType.feed => nothingToday ? l10n.nudgeFeedNone : l10n.nudgeFeedStale,
        LogType.diaper =>
          nothingToday ? l10n.nudgeDiaperNone : l10n.nudgeDiaperStale,
        _ => nothingToday ? l10n.nudgeSleepNone : l10n.nudgeSleepStale,
      };
}

PartnerNudge? detectGentleNudge({
  required List<CareLogEntry> todayLogs,
  required DateTime now,
  int feedHours = 4,
  int diaperHours = 6,
  int sleepHours = 8,
}) {
  final feed = _latestOfType(todayLogs, LogType.feed);
  if (feed == null || now.difference(feed.loggedAt).inHours >= feedHours) {
    return PartnerNudge(
      type: LogType.feed,
      hoursSince: feed == null ? feedHours : now.difference(feed.loggedAt).inHours,
      nothingToday: feed == null,
    );
  }

  final diaper = _latestOfType(todayLogs, LogType.diaper);
  if (diaper == null || now.difference(diaper.loggedAt).inHours >= diaperHours) {
    return PartnerNudge(
      type: LogType.diaper,
      hoursSince:
          diaper == null ? diaperHours : now.difference(diaper.loggedAt).inHours,
      nothingToday: diaper == null,
    );
  }

  final sleep = _latestOfType(todayLogs, LogType.sleep);
  if (sleep == null || now.difference(sleep.loggedAt).inHours >= sleepHours) {
    return PartnerNudge(
      type: LogType.sleep,
      hoursSince:
          sleep == null ? sleepHours : now.difference(sleep.loggedAt).inHours,
      nothingToday: sleep == null,
    );
  }

  return null;
}

CareLogEntry? _latestOfType(List<CareLogEntry> logs, LogType type) {
  for (final entry in logs) {
    if (entry.type == type) return entry;
  }
  return null;
}