import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

enum LogType {
  feed('feeding', Icons.restaurant_outlined),
  diaper('diaper', Icons.baby_changing_station_outlined),
  sleep('sleep', Icons.bedtime_outlined),
  medication('medication', Icons.medication_outlined),
  pumping('pumping', Icons.water_drop_outlined),
  tummyTime('note', Icons.child_care_outlined);

  const LogType(this.apiType, this.icon);

  final IconData icon;

  /// Short tab/tile name, e.g. "Feed".
  String label(AppL10n l10n) => switch (this) {
        LogType.feed => l10n.logTypeFeed,
        LogType.diaper => l10n.logTypeDiaper,
        LogType.sleep => l10n.logTypeSleep,
        LogType.medication => l10n.logTypeMedication,
        LogType.pumping => l10n.logTypePumping,
        LogType.tummyTime => l10n.logTypeTummyTime,
      };

  /// Snackbar text after saving, e.g. "Feed logged".
  String confirmation(AppL10n l10n) => switch (this) {
        LogType.feed => l10n.logTypeFeedLogged,
        LogType.diaper => l10n.logTypeDiaperLogged,
        LogType.sleep => l10n.logTypeSleepLogged,
        LogType.medication => l10n.logTypeMedicationLogged,
        LogType.pumping => l10n.logTypePumpingLogged,
        LogType.tummyTime => l10n.logTypeTummyTimeLogged,
      };

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