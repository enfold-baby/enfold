import 'package:bloomdue_baby/core/units/growth_units.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GrowthUnits', () {
    test('converts lb to kg and formats imperial weight', () {
      final kg = GrowthUnits.parseWeightKg('7', useImperial: true);
      expect(kg, closeTo(3.175, 0.01));
      expect(
        GrowthUnits.formatWeightKg(kg, useImperial: true),
        '7 lb',
      );
    });

    test('formats metric length', () {
      expect(
        GrowthUnits.formatLengthCm(56, useImperial: false),
        '56 cm',
      );
    });
  });
}