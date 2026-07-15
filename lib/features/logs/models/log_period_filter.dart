import 'package:flutter/material.dart';

enum LogPeriodPreset {
  last7Days(7, '7 days'),
  last30Days(30, '30 days'),
  custom(null, 'Period');

  const LogPeriodPreset(this.days, this.label);

  final int? days;
  final String label;
}

@immutable
class LogPeriodFilter {
  const LogPeriodFilter({
    this.preset = LogPeriodPreset.last7Days,
    this.customStart,
    this.customEnd,
  });

  final LogPeriodPreset preset;
  final DateTime? customStart;
  final DateTime? customEnd;

  bool get isCustom => preset == LogPeriodPreset.custom;

  LogPeriodFilter copyWith({
    LogPeriodPreset? preset,
    DateTime? customStart,
    DateTime? customEnd,
    bool clearCustom = false,
  }) {
    return LogPeriodFilter(
      preset: preset ?? this.preset,
      customStart: clearCustom ? null : (customStart ?? this.customStart),
      customEnd: clearCustom ? null : (customEnd ?? this.customEnd),
    );
  }

  ({DateTime start, DateTime end}) resolveRange(DateTime Function() todayEnd) {
    if (preset == LogPeriodPreset.custom &&
        customStart != null &&
        customEnd != null) {
      final start = DateTime(
        customStart!.year,
        customStart!.month,
        customStart!.day,
      );
      final end = DateTime(
        customEnd!.year,
        customEnd!.month,
        customEnd!.day,
      ).add(const Duration(days: 1));
      return (start: start, end: end);
    }

    final days = preset.days ?? 7;
    final end = todayEnd();
    final start = end.subtract(Duration(days: days));
    return (start: start, end: end);
  }

  String periodLabel() {
    if (preset == LogPeriodPreset.custom &&
        customStart != null &&
        customEnd != null) {
      return '${_shortDate(customStart!)} – ${_shortDate(customEnd!)}';
    }
    return preset.label;
  }

  static String _shortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}