import '../../../l10n/generated/app_localizations.dart';

String? babyAgeLabel(AppL10n l10n, DateTime? birthDate, {DateTime? now}) {
  if (birthDate == null) return null;
  final today = now ?? DateTime.now();
  final days = today.difference(birthDate).inDays;
  if (days < 0) return null;
  if (days == 0) return l10n.babyAgeBornToday;
  if (days < 14) return l10n.babyAgeDays(days);
  final weeks = days ~/ 7;
  if (weeks < 12) return l10n.babyAgeWeeks(weeks);
  final months = days ~/ 30;
  if (months < 24) return l10n.babyAgeMonths(months);
  final years = months ~/ 12;
  final remainingMonths = months % 12;
  if (remainingMonths == 0) return l10n.babyAgeYears(years);
  return l10n.babyAgeYearsMonths(years, remainingMonths);
}
