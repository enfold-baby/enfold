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

  static String weightFieldLabel({required bool useImperial}) =>
      useImperial ? 'Weight (lb, optional)' : 'Weight (kg, optional)';

  static String lengthFieldLabel({required bool useImperial}) =>
      useImperial ? 'Length (in, optional)' : 'Length (cm, optional)';

  static String headFieldLabel({required bool useImperial}) =>
      useImperial ? 'Head (in, optional)' : 'Head (cm, optional)';
}