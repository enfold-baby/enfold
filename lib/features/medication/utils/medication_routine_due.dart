import '../../../l10n/generated/app_localizations.dart';

import '../../today/models/care_log_entry.dart';
import '../../today/models/log_type.dart';
import 'medication_name.dart';

/// Next local ping for a once-a-day vitamin reminder.
///
/// If today's dose is already logged, wait until tomorrow's clock time.
/// If the clock time has passed and it is still evening, nudge in about
/// 15 minutes — never after 21:30.
DateTime nextMedicationReminderAt({
  required int hour,
  required int minute,
  required DateTime now,
  required bool alreadyLoggedToday,
  DateTime? snoozeUntil,
}) {
  final todayAt = DateTime(now.year, now.month, now.day, hour, minute);
  final tomorrowAt = todayAt.add(const Duration(days: 1));
  final quiet = DateTime(now.year, now.month, now.day, 21, 30);

  if (snoozeUntil != null && snoozeUntil.isAfter(now)) {
    return snoozeUntil;
  }

  if (alreadyLoggedToday) return tomorrowAt;
  if (!now.isAfter(todayAt)) return todayAt;
  if (!now.isBefore(quiet)) return tomorrowAt;

  final soon = now.add(const Duration(minutes: 15));
  return soon.isAfter(quiet) ? quiet : soon;
}

DateTime laterSnoozeUntil(DateTime now) {
  final quiet = DateTime(now.year, now.month, now.day, 21, 30);
  final later = now.add(const Duration(minutes: 30));
  if (!now.isBefore(quiet)) {
    return DateTime(now.year, now.month, now.day + 1, 9);
  }
  return later.isAfter(quiet) ? quiet : later;
}

bool medicationLoggedToday({
  required String name,
  required Iterable<CareLogEntry> todayLogs,
}) {
  return todayLogs.any(
    (entry) =>
        entry.type == LogType.medication &&
        sameMedicationName(entry.details.medicationName ?? '', name),
  );
}

DateTime? latestDoseAt({
  required String name,
  required Iterable<CareLogEntry> todayLogs,
}) {
  DateTime? latest;
  for (final entry in todayLogs) {
    if (entry.type != LogType.medication) continue;
    if (!sameMedicationName(entry.details.medicationName ?? '', name)) {
      continue;
    }
    if (latest == null || entry.loggedAt.isAfter(latest)) {
      latest = entry.loggedAt;
    }
  }
  return latest;
}

String medicationReminderBody(
  AppL10n l10n,
  String medName,
  String babyName,
) {
  final med = medName.trim().isEmpty
      ? l10n.medicationReminderFallbackMedication
      : medName.trim();
  final name = babyName.trim();
  final who = name.isEmpty || name.toLowerCase() == 'baby'
      ? l10n.careReminderFallbackWho
      : name;
  return l10n.medicationReminderBody(med, who);
}

String medicationRoutineTodayLine({
  required String name,
  String? timeLabel,
}) {
  if (timeLabel == null || timeLabel.isEmpty) {
    return '$name: not logged yet';
  }
  return '$name · $timeLabel';
}
