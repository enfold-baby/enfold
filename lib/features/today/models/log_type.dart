import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum LogType {
  feed('Feed', 'Feed logged', 'feeding', Icons.restaurant_outlined),
  diaper('Diaper', 'Diaper logged', 'diaper', Icons.baby_changing_station_outlined),
  sleep('Sleep', 'Sleep logged', 'sleep', Icons.bedtime_outlined),
  medication(
    'Meds',
    'Medication logged',
    'medication',
    Icons.medication_outlined,
  ),
  pumping(
    'Pump',
    'Pumping logged',
    'pumping',
    Icons.water_drop_outlined,
  ),
  tummyTime(
    'Tummy',
    'Tummy time logged',
    'note',
    Icons.child_care_outlined,
  );

  const LogType(this.label, this.confirmation, this.apiType, this.icon);

  final String label;
  final String confirmation;
  final IconData icon;

  /// Matches VPS `care_events.type`.
  final String apiType;

  static LogType? fromApiType(String apiType) {
    for (final type in LogType.values) {
      if (type.apiType == apiType) return type;
    }
    return null;
  }

  Color get color => switch (this) {
        LogType.feed => AppColors.sage,
        LogType.diaper => AppColors.bloom,
        LogType.sleep => AppColors.sleepBlue,
        LogType.medication => AppColors.medicationAmber,
        LogType.pumping => AppColors.pumpLavender,
        LogType.tummyTime => AppColors.tummyCoral,
      };

  String get formSegment => switch (this) {
        LogType.feed => 'feed',
        LogType.diaper => 'diaper',
        LogType.sleep => 'sleep',
        LogType.medication => 'medication',
        LogType.pumping => 'pumping',
        LogType.tummyTime => 'tummy',
      };
}