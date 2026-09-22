import '../../l10n/generated/app_localizations.dart';

/// When to fire the "how is baby" ping if nothing is logged yet today.
///
/// Evening, not overnight: 18:00 if it's still afternoon; otherwise about
/// 90 minutes from now, but never after 21:30.
DateTime? nextCareReminderAt(DateTime now) {
  final sixPm = DateTime(now.year, now.month, now.day, 18);
  final quiet = DateTime(now.year, now.month, now.day, 21, 30);
  if (now.isBefore(sixPm)) return sixPm;
  if (!now.isBefore(quiet)) return null;
  final later = now.add(const Duration(minutes: 90));
  return later.isAfter(quiet) ? quiet : later;
}

String careReminderBody(AppL10n l10n, String babyName) {
  final name = babyName.trim();
  final who = name.isEmpty || name.toLowerCase() == 'baby'
      ? l10n.careReminderFallbackWho
      : name;
  return l10n.careReminderBody(who);
}
