import 'dart:ui';

import 'package:enfold/core/theme/app_colors.dart';
import 'package:flutter_test/flutter_test.dart';

double _linear(double channel) {
  final c = channel / 255;
  return c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) * ((c + 0.055) / 1.055);
}

double _luminance(Color color) {
  final r = _linear(color.r * 255);
  final g = _linear(color.g * 255);
  final b = _linear(color.b * 255);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrast(Color a, Color b) {
  final l1 = _luminance(a);
  final l2 = _luminance(b);
  final hi = l1 > l2 ? l1 : l2;
  final lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('dark secondary text meets WCAG AA on night surfaces', () {
    final secondary = AppColors.mutedText(Brightness.dark);
    expect(_contrast(secondary, AppColors.night), greaterThanOrEqualTo(4.5));
    expect(_contrast(secondary, AppColors.nightElevated), greaterThanOrEqualTo(4.5));
    expect(_contrast(secondary, AppColors.nightCard), greaterThanOrEqualTo(4.5));
  });

  test('dark sage accent meets WCAG AA on night surfaces', () {
    final accent = AppColors.accent(Brightness.dark);
    expect(_contrast(accent, AppColors.night), greaterThanOrEqualTo(4.5));
    expect(_contrast(accent, AppColors.nightElevated), greaterThanOrEqualTo(4.5));
    expect(_contrast(accent, AppColors.nightCard), greaterThanOrEqualTo(4.5));
  });

  test('dark nav labels meet WCAG AA on the elevated bar', () {
    expect(
      _contrast(AppColors.navUnselected(Brightness.dark), AppColors.nightElevated),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('light secondary text meets WCAG AA on cream', () {
    expect(
      _contrast(AppColors.mutedText(Brightness.light), AppColors.cream),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('light-mode barkSoft is not used as dark secondary', () {
    expect(
      _contrast(AppColors.barkSoft, AppColors.nightCard),
      lessThan(4.5),
    );
    expect(AppColors.mutedText(Brightness.dark), isNot(AppColors.barkSoft));
  });
}
