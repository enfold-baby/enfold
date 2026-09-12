/// Shared calendar bounds for care-log date pickers.
///
/// Three years back covers newborn through toddler without turning the
/// picker into an unbounded archive. Future is limited to tomorrow so
/// a late-night log can still land on the next calendar day.
abstract final class LogDateBounds {
  static const lookbackYears = 3;

  static DateTime firstDate([DateTime? now]) {
    final n = now ?? DateTime.now();
    return DateTime(n.year - lookbackYears, n.month, n.day);
  }

  static DateTime lastDate([DateTime? now]) {
    final n = now ?? DateTime.now();
    return DateTime(n.year, n.month, n.day).add(const Duration(days: 1));
  }

  static DateTime clampInitial(DateTime value, {DateTime? now}) {
    final first = firstDate(now);
    final last = lastDate(now);
    if (value.isBefore(first)) return first;
    if (value.isAfter(last)) return last;
    return value;
  }
}
