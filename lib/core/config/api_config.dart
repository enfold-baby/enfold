import 'package:flutter/foundation.dart';

/// API base URL.
///
/// - **Release / profile-on-device for store builds:** production.
/// - **Debug on Android emulator:** `10.0.2.2` is the host machine loopback.
/// - **Debug elsewhere (iOS sim, desktop, web):** localhost.
///
/// Override any time with `--dart-define=API_BASE_URL=https://…`.
abstract final class ApiConfig {
  static const String _prod = 'https://api.bloomdue.baby';
  static const String _define = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_define.isNotEmpty) {
      return _define.replaceAll(RegExp(r'/+$'), '');
    }
    if (kReleaseMode) {
      return _prod;
    }
    // Android emulator → host machine (docker backend :8282).
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8282';
    }
    return 'http://127.0.0.1:8282';
  }

  static bool get isLocalDev => !kReleaseMode && !baseUrl.contains('bloomdue.baby');
}
