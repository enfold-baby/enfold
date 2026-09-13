import 'care_log_entry.dart';
import 'log_type.dart';

/// How long the baby has been awake since the most recent finished sleep.
class AwakeWindow {
  const AwakeWindow({required this.wokeAt, required this.now});

  final DateTime wokeAt;
  final DateTime now;

  /// Past this, a sleep was most likely not logged, so the line stays hidden
  /// instead of showing an alarming number.
  static const maxAwake = Duration(hours: 12);

  Duration get awake => now.difference(wokeAt);

  /// When a finished sleep ended. Null for a sleep still in progress.
  static DateTime? sleepEndFor(CareLogEntry entry) {
    final details = entry.details;
    if (details.sleepInProgress == true) return null;
    if (details.sleepEnd != null) return details.sleepEnd;
    final start = details.sleepStart;
    final minutes = details.durationMinutes;
    if (start != null && minutes != null) {
      return start.add(Duration(minutes: minutes));
    }
    // Quick logs and wake-ups store the end as the log time.
    return entry.loggedAt;
  }

  /// Uses the latest sleep end, not the latest entry, so a sleep logged after
  /// the fact never hides a more recent nap. Null while asleep, with no sleep
  /// on record, or when the gap is longer than [maxAwake].
  static AwakeWindow? fromSleeps(
    Iterable<CareLogEntry> entries, {
    required DateTime now,
  }) {
    DateTime? latest;
    for (final entry in entries) {
      if (entry.type != LogType.sleep) continue;
      if (entry.details.sleepInProgress == true) return null;
      var end = sleepEndFor(entry);
      if (end == null) continue;
      // A partner's clock a little ahead should read as "just woke up".
      if (end.isAfter(now)) end = now;
      if (latest == null || end.isAfter(latest)) latest = end;
    }
    if (latest == null || now.difference(latest) > maxAwake) return null;
    return AwakeWindow(wokeAt: latest, now: now);
  }
}
