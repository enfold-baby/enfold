/// Gestational week from due date (40-week model, 280 days total).
int? pregnancyWeekFromDueDate(DateTime dueDate, DateTime referenceDate) {
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final today =
      DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
  final daysUntilDue = due.difference(today).inDays;
  final daysGestational = 280 - daysUntilDue;
  if (daysGestational < 0) return null;
  final weeks = daysGestational ~/ 7;
  return weeks.clamp(1, 42);
}

int? daysUntilDue(DateTime dueDate, DateTime referenceDate) {
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final today =
      DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
  return due.difference(today).inDays;
}