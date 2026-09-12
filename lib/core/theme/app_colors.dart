import 'package:flutter/material.dart';

/// Brand palette — see BRANDING.md
abstract final class AppColors {
  static const Color cream = Color(0xFFFAF7F2);
  static const Color creamDeep = Color(0xFFF3EDE4);
  static const Color bark = Color(0xFF3D3229);
  static const Color barkSoft = Color(0xFF6B5E54);
  static const Color sage = Color(0xFF5C7F71);
  static const Color sageDeep = Color(0xFF4A675C);
  static const Color bloom = Color(0xFFC96B7E);
  static const Color bloomDeep = Color(0xFFA85568);
  static const Color sleepBlue = Color(0xFF7A8FA8);
  static const Color medicationAmber = Color(0xFFC49A4A);
  static const Color pumpLavender = Color(0xFF8B7BA8);
  static const Color tummyCoral = Color(0xFFD4846A);
  static const Color sageMist = Color(0xFFE4EEE8);
  static const Color bloomMist = Color(0xFFF6E7EA);
  static const Color sleepMist = Color(0xFFE8EDF3);
  static const Color amberMist = Color(0xFFF5EEDC);

  // Dark surfaces — warm sage-tinted, not flat gray
  static const Color night = Color(0xFF141A17);
  static const Color nightElevated = Color(0xFF1E2723);
  static const Color nightCard = Color(0xFF28322E);
  static const Color nightLine = Color(0xFF3F4F48);
  // Sage-cream secondary on night surfaces (WCAG AA 4.5:1 vs night + nightCard).
  // Light barkSoft is ~2.1–2.8:1 on these — never use it as dark-mode ink.
  static const Color nightMuted = Color(0xFFDCE6E1);
  static const Color nightAccent = Color(0xFF9ECBB5);
  static const Color nightNavUnselected = Color(0xFFB7C9C0);
  static const Color nightDisabledFill = Color(0xFF35403B);
  static const Color nightDisabledLabel = Color(0xFFB8C6BE);

  /// Secondary labels — readable on both light and dark backgrounds.
  static Color mutedText(Brightness brightness) =>
      brightness == Brightness.dark ? nightMuted : barkSoft;

  /// Sage used as ink (section labels, small icons). Light sage fails on night cards.
  static Color accent(Brightness brightness) =>
      brightness == Brightness.dark ? nightAccent : sage;

  /// Lift a light-mode brand color so 13px labels still meet WCAG AA at night.
  static Color readableInk(Color color, Brightness brightness) {
    if (brightness != Brightness.dark) return color;
    if (color == sage || color == sageDeep) return nightAccent;
    return Color.lerp(color, cream, 0.42)!;
  }

  /// Inactive bottom-nav icons and labels in dark mode.
  static Color navUnselected(Brightness brightness) =>
      brightness == Brightness.dark ? nightNavUnselected : barkSoft;

  /// Default raised card surface.
  static Color cardSurface(Brightness brightness) =>
      brightness == Brightness.dark ? nightElevated : Colors.white;

  /// Softer inset surface used for grouped content.
  static Color softSurface(Brightness brightness) =>
      brightness == Brightness.dark ? nightCard : creamDeep;
}
