/// Calendar-day bounds for pregnancy "expecting" date pickers.
///
/// Care logs may still use past times; these helpers are only for due dates
/// and future appointments while still expecting.
library;

DateTime calendarToday([DateTime? now]) {
  final n = now ?? DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

/// Ensure [value] is not before local today (date-only).
DateTime clampOnOrAfterToday(DateTime value, [DateTime? now]) {
  final today = calendarToday(now);
  final day = DateTime(value.year, value.month, value.day);
  if (day.isBefore(today)) return today;
  return day;
}
