import 'package:bloomdue_baby/core/units/volume_units.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VolumeUnits', () {
    test('converts fl oz to ml and back', () {
      expect(VolumeUnits.mlFromFlOz(4), 118);
      expect(VolumeUnits.flOzFromMl(118), closeTo(4.0, 0.1));
    });

    test('formats metric and imperial labels', () {
      expect(
        VolumeUnits.formatBottleMl(120, useImperial: false),
        '120ml',
      );
      expect(
        VolumeUnits.formatBottleMl(120, useImperial: true),
        '4.1 fl oz',
      );
    });
  });
}