import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// System bar handling for Android 15 edge-to-edge.
///
/// From targetSdk 35 Android draws every app behind the status and navigation
/// bars and ignores `statusBarColor` / `navigationBarColor`, so the app opts in
/// explicitly (which also makes Android 10 to 14 look the same) and keeps both
/// bars transparent with icons that follow the current theme.
///
/// Contrast enforcement stays on: with 3-button navigation the system paints a
/// translucent scrim behind the buttons so they stay readable over content.
class SystemUi {
  const SystemUi._();

  /// Call once at startup, before `runApp`.
  static void enableEdgeToEdge() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// Transparent bars with icons legible against a [brightness] background.
  static SystemUiOverlayStyle overlayStyle(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final iconBrightness = isDark ? Brightness.light : Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: iconBrightness,
      // iOS reads the background brightness, not the icon brightness.
      statusBarBrightness: brightness,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: iconBrightness,
      systemNavigationBarContrastEnforced: true,
    );
  }
}
