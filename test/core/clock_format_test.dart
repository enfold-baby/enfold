import 'package:enfold/core/datetime/clock_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final morning = DateTime(2026, 9, 8, 5, 12);
  final noonish = DateTime(2026, 9, 8, 15, 4);
  final midnight = DateTime(2026, 9, 8, 0, 7);

  test('12-hour clock uses AM/PM without a leading hour zero', () {
    expect(ClockFormat.formatTime(morning), '5:12 AM');
    expect(ClockFormat.formatTime(noonish), '3:04 PM');
    expect(ClockFormat.formatTime(midnight), '12:07 AM');
  });

  test('24-hour clock uses HH:mm', () {
    expect(ClockFormat.formatTime(morning, use24Hour: true), '05:12');
    expect(ClockFormat.formatTime(noonish, use24Hour: true), '15:04');
    expect(ClockFormat.formatTime(midnight, use24Hour: true), '00:07');
  });

  test('date-and-time labels keep the middle dot', () {
    expect(
      ClockFormat.formatDateAndTime(morning),
      'Sep 8 · 5:12 AM',
    );
    expect(
      ClockFormat.formatDateAndTime(morning, use24Hour: true),
      'Sep 8 · 05:12',
    );
    expect(
      ClockFormat.formatWeekdayDateAndTime(morning, use24Hour: true),
      'Tue, Sep 8 · 05:12',
    );
  });
}
