String? babyAgeLabel(DateTime? birthDate, {DateTime? now}) {
  if (birthDate == null) return null;
  final today = now ?? DateTime.now();
  final days = today.difference(birthDate).inDays;
  if (days < 0) return null;
  if (days == 0) return 'Born today';
  if (days < 14) return '$days days old';
  final weeks = days ~/ 7;
  if (weeks < 12) return '$weeks weeks old';
  final months = days ~/ 30;
  if (months < 24) return '$months months old';
  final years = months ~/ 12;
  final remainingMonths = months % 12;
  if (remainingMonths == 0) {
    return years == 1 ? '1 year old' : '$years years old';
  }
  return '$years y $remainingMonths mo';
}