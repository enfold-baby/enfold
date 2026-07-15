import '../../today/models/care_log_entry.dart';
import '../../today/models/log_type.dart';

class PartnerNudge {
  const PartnerNudge({
    required this.type,
    required this.hoursSince,
    required this.message,
  });

  final LogType type;
  final int hoursSince;
  final String message;
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
      message: feed == null
          ? 'No feed logged yet today — only if you want a gentle reminder.'
          : 'It has been a while since the last feed was logged.',
    );
  }

  final diaper = _latestOfType(todayLogs, LogType.diaper);
  if (diaper == null || now.difference(diaper.loggedAt).inHours >= diaperHours) {
    return PartnerNudge(
      type: LogType.diaper,
      hoursSince:
          diaper == null ? diaperHours : now.difference(diaper.loggedAt).inHours,
      message: diaper == null
          ? 'No diaper logged yet today — only if you want a gentle reminder.'
          : 'It has been a while since the last diaper was logged.',
    );
  }

  final sleep = _latestOfType(todayLogs, LogType.sleep);
  if (sleep == null || now.difference(sleep.loggedAt).inHours >= sleepHours) {
    return PartnerNudge(
      type: LogType.sleep,
      hoursSince:
          sleep == null ? sleepHours : now.difference(sleep.loggedAt).inHours,
      message: sleep == null
          ? 'No sleep logged yet today — only if you want a gentle reminder.'
          : 'It has been a while since sleep was logged.',
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