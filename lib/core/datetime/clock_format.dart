import 'package:intl/intl.dart';

/// 12-hour AM/PM vs 24-hour clock for log times, pickers, and the visit PDF.
abstract final class ClockFormat {
  static DateFormat time({
    bool use24Hour = false,
    String locale = 'en_US',
  }) =>
      DateFormat(use24Hour ? 'HH:mm' : 'h:mm a', locale);

  static String formatTime(
    DateTime value, {
    bool use24Hour = false,
    String locale = 'en_US',
  }) =>
      time(use24Hour: use24Hour, locale: locale).format(value);

  static String formatDateAndTime(
    DateTime value, {
    bool use24Hour = false,
    String locale = 'en_US',
  }) {
    final date = DateFormat('MMM d', locale).format(value);
    return '$date · ${formatTime(value, use24Hour: use24Hour, locale: locale)}';
  }

  static String formatWeekdayDateAndTime(
    DateTime value, {
    bool use24Hour = false,
    String locale = 'en_US',
  }) {
    final date = DateFormat('EEE, MMM d', locale).format(value);
    return '$date · ${formatTime(value, use24Hour: use24Hour, locale: locale)}';
  }

  static String formatLongDateAndTime(
    DateTime value, {
    bool use24Hour = false,
    String locale = 'en_US',
  }) {
    final date = DateFormat.yMMMd(locale).format(value);
    return '$date · ${formatTime(value, use24Hour: use24Hour, locale: locale)}';
  }
}
