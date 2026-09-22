import '../../l10n/generated/app_localizations.dart';

class GrowthUnits {
  GrowthUnits._();

  static const cmPerInch = 2.54;
  static const kgPerLb = 0.45359237;

  static double? parseWeightKg(String text, {required bool useImperial}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final value = double.tryParse(trimmed);
    if (value == null) return null;
    return useImperial ? value * kgPerLb : value;
  }

  static double? parseLengthCm(String text, {required bool useImperial}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final value = double.tryParse(trimmed);
    if (value == null) return null;
    return useImperial ? value * cmPerInch : value;
  }

  static String formatWeightKg(double? kg, {required bool useImperial}) {
    if (kg == null) return '—';
    if (useImperial) {
      final totalOz = kg / kgPerLb * 16;
      final lbs = totalOz ~/ 16;
      final oz = (totalOz % 16).round();
      if (oz == 0) return '$lbs lb';
      return '$lbs lb $oz oz';
    }
    final rounded = (kg * 10).round() / 10;
    if (rounded == rounded.roundToDouble()) {
      return '${rounded.toInt()} kg';
    }
    return '$rounded kg';
  }

  static String formatLengthCm(double? cm, {required bool useImperial}) {
    if (cm == null) return '—';
    if (useImperial) {
      final inches = cm / cmPerInch;
      final rounded = (inches * 10).round() / 10;
      if (rounded == rounded.roundToDouble()) {
        return '${rounded.toInt()} in';
      }
      return '$rounded in';
    }
    final rounded = (cm * 10).round() / 10;
    if (rounded == rounded.roundToDouble()) {
      return '${rounded.toInt()} cm';
    }
    return '$rounded cm';
  }

  static String weightFieldLabel(AppL10n l10n, {required bool useImperial}) =>
      useImperial ? l10n.growthWeightFieldLb : l10n.growthWeightFieldKg;

  static String lengthFieldLabel(AppL10n l10n, {required bool useImperial}) =>
      useImperial ? l10n.growthLengthFieldIn : l10n.growthLengthFieldCm;

  static String headFieldLabel(AppL10n l10n, {required bool useImperial}) =>
      useImperial ? l10n.growthHeadFieldIn : l10n.growthHeadFieldCm;
}