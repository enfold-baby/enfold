/// Bottle volumes are stored as milliliters; display converts for imperial users.
class VolumeUnits {
  VolumeUnits._();

  static const mlPerFlOz = 29.5735;

  static int mlFromFlOz(num flOz) => (flOz * mlPerFlOz).round();

  static double flOzFromMl(int ml) => ml / mlPerFlOz;

  static String formatBottleMl(int ml, {required bool useImperial}) {
    if (useImperial) {
      final oz = flOzFromMl(ml);
      final rounded = (oz * 10).round() / 10;
      if (rounded == rounded.roundToDouble()) {
        return '${rounded.toInt()} fl oz';
      }
      return '$rounded fl oz';
    }
    return '${ml}ml';
  }
}