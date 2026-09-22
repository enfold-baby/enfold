import 'dart:convert';

import '../../../core/units/volume_units.dart';
import 'log_type.dart';
import '../../../l10n/generated/app_localizations.dart';

class CareLogDetails {
  const CareLogDetails({
    this.feedMode,
    this.breastSide,
    this.breastDelivery,
    this.bottleMl,
    this.feedDurationMinutes,
    this.wet,
    this.dirty,
    this.stoolConsistency,
    this.durationMinutes,
    this.sleepStart,
    this.sleepEnd,
    this.sleepInProgress,
    this.medicationCategory,
    this.medicationName,
    this.medicationDose,
    this.activity,
  });

  final String? feedMode;
  final String? breastSide;

  /// When [feedMode] is breast: `direct` (at breast) or `pumped` (expressed, bottle-fed).
  final String? breastDelivery;
  final int? bottleMl;
  final int? feedDurationMinutes;
  final bool? wet;
  final bool? dirty;
  final String? stoolConsistency;
  final int? durationMinutes;
  final DateTime? sleepStart;
  final DateTime? sleepEnd;
  final bool? sleepInProgress;
  final String? medicationCategory;
  final String? medicationName;
  final String? medicationDose;

  /// Distinguishes structured `note` events, e.g. `tummy_time`.
  final String? activity;

  static const empty = CareLogDetails();
  static const tummyTimeActivity = 'tummy_time';

  factory CareLogDetails.fromJsonString(String json) {
    if (json.isEmpty || json == '{}') return CareLogDetails.empty;
    final map = jsonDecode(json) as Map<String, dynamic>;
    return CareLogDetails(
      feedMode: map['feed_mode'] as String?,
      breastSide: map['breast_side'] as String?,
      breastDelivery: map['breast_delivery'] as String?,
      bottleMl: map['bottle_ml'] as int?,
      feedDurationMinutes: map['feed_duration_minutes'] as int?,
      wet: map['wet'] as bool?,
      dirty: map['dirty'] as bool?,
      stoolConsistency: map['stool_consistency'] as String?,
      durationMinutes: map['duration_minutes'] as int?,
      sleepStart: _parseDateTime(map['sleep_start']),
      sleepEnd: _parseDateTime(map['sleep_end']),
      sleepInProgress: map['sleep_in_progress'] as bool?,
      medicationCategory: map['medication_category'] as String?,
      medicationName: map['medication_name'] as String?,
      medicationDose: map['medication_dose'] as String?,
      activity: map['activity'] as String?,
    );
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String toJsonString() {
    final map = <String, dynamic>{};
    if (feedMode != null) map['feed_mode'] = feedMode;
    if (breastSide != null) map['breast_side'] = breastSide;
    if (breastDelivery != null) map['breast_delivery'] = breastDelivery;
    if (bottleMl != null) map['bottle_ml'] = bottleMl;
    if (feedDurationMinutes != null) {
      map['feed_duration_minutes'] = feedDurationMinutes;
    }
    if (wet != null) map['wet'] = wet;
    if (dirty != null) map['dirty'] = dirty;
    if (stoolConsistency != null) map['stool_consistency'] = stoolConsistency;
    if (durationMinutes != null) map['duration_minutes'] = durationMinutes;
    if (sleepStart != null) map['sleep_start'] = sleepStart!.toIso8601String();
    if (sleepEnd != null) map['sleep_end'] = sleepEnd!.toIso8601String();
    if (sleepInProgress != null) map['sleep_in_progress'] = sleepInProgress;
    if (medicationCategory != null) {
      map['medication_category'] = medicationCategory;
    }
    if (medicationName != null) map['medication_name'] = medicationName;
    if (medicationDose != null) map['medication_dose'] = medicationDose;
    if (activity != null) map['activity'] = activity;
    return jsonEncode(map);
  }

  bool get hasData =>
      feedMode != null ||
      breastSide != null ||
      breastDelivery != null ||
      bottleMl != null ||
      feedDurationMinutes != null ||
      wet != null ||
      dirty != null ||
      stoolConsistency != null ||
      durationMinutes != null ||
      sleepStart != null ||
      sleepEnd != null ||
      sleepInProgress == true ||
      medicationCategory != null ||
      medicationName != null ||
      medicationDose != null ||
      activity != null;

  int? get resolvedSleepDurationMinutes {
    if (durationMinutes != null) return durationMinutes;
    if (sleepStart == null || sleepEnd == null) return null;
    return sleepEnd!.difference(sleepStart!).inMinutes;
  }

  String summarize(
    AppL10n l10n,
    LogType type, {
    bool useImperial = false,
  }) {
    switch (type) {
      case LogType.feed:
        final parts = <String>[];
        if (feedMode == 'breast') {
          parts.add(l10n.summaryBreast);
          if (breastDelivery == 'pumped') {
            parts.add(l10n.summaryPumpedBottle);
          } else if (breastDelivery == 'direct') {
            parts.add(l10n.summaryAtBreast);
          }
          if (breastSide != null) parts.add(_sideLabel(l10n, breastSide!));
          if (breastDelivery == 'pumped' && bottleMl != null) {
            parts.add(
              VolumeUnits.formatBottleMl(bottleMl!, useImperial: useImperial),
            );
          }
        } else if (feedMode == 'formula') {
          parts.add(l10n.summaryFormula);
          if (bottleMl != null) {
            parts.add(
              VolumeUnits.formatBottleMl(bottleMl!, useImperial: useImperial),
            );
          }
        } else if (feedMode == 'bottle') {
          parts.add(l10n.summaryBottle);
          if (bottleMl != null) {
            parts.add(
              VolumeUnits.formatBottleMl(bottleMl!, useImperial: useImperial),
            );
          }
        }
        if (feedDurationMinutes != null) {
          parts.add(l10n.summaryMinutes(feedDurationMinutes!));
        }
        return parts.join(' · ');
      case LogType.diaper:
        final parts = <String>[];
        if (wet == true) parts.add(l10n.summaryWet);
        if (dirty == true) parts.add(l10n.summaryPoop);
        if (stoolConsistency != null) {
          parts.add(_stoolLabel(l10n, stoolConsistency!));
        }
        return parts.join(' · ');
      case LogType.sleep:
        if (sleepInProgress == true) return l10n.summarySleepingNow;
        final minutes = resolvedSleepDurationMinutes;
        if (minutes != null) return _formatDuration(l10n, minutes);
        return '';
      case LogType.medication:
        final parts = <String>[];
        if (medicationCategory != null) {
          parts.add(_medicationCategoryLabel(l10n, medicationCategory!));
        }
        if (medicationName != null && medicationName!.isNotEmpty) {
          parts.add(medicationName!);
        }
        if (medicationDose != null && medicationDose!.isNotEmpty) {
          parts.add(medicationDose!);
        }
        return parts.join(' · ');
      case LogType.pumping:
        final parts = <String>[];
        if (breastSide != null) parts.add(_sideLabel(l10n, breastSide!));
        if (bottleMl != null) {
          parts.add(
            VolumeUnits.formatBottleMl(bottleMl!, useImperial: useImperial),
          );
        }
        if (durationMinutes != null) {
          parts.add(l10n.summaryMinutes(durationMinutes!));
        }
        return parts.join(' · ');
      case LogType.tummyTime:
        final minutes = durationMinutes;
        if (minutes != null) return _formatDuration(l10n, minutes);
        return l10n.summaryLogged;
    }
  }

  static String _sideLabel(AppL10n l10n, String side) => switch (side) {
        'left' => l10n.summarySideLeft,
        'right' => l10n.summarySideRight,
        'both' => l10n.summarySideBoth,
        _ => side,
      };

  static String _stoolLabel(AppL10n l10n, String consistency) =>
      switch (consistency) {
        'normal' => l10n.summaryStoolNormal,
        'soft' => l10n.summaryStoolSoft,
        'hard' => l10n.summaryStoolHard,
        'loose' => l10n.summaryStoolLoose,
        _ => consistency,
      };

  static String _medicationCategoryLabel(AppL10n l10n, String category) =>
      switch (category) {
        'vitamin' => l10n.summaryCategoryVitamin,
        'supplement' => l10n.summaryCategorySupplement,
        'medication' => l10n.summaryCategoryMedication,
        _ => category,
      };

  static String _formatDuration(AppL10n l10n, int minutes) {
    if (minutes < 60) return l10n.summaryMinutes(minutes);
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (remainder == 0) return l10n.summaryHours(hours);
    return l10n.summaryHoursMinutes(hours, remainder);
  }
}