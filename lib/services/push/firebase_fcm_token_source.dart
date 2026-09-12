import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'fcm_token_source.dart';

/// Background handler must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {
    // Native config missing (no google-services.json / plist) — ignore.
  }
}

/// FCM token source backed by Firebase Messaging.
///
/// Returns null when the Firebase native config files are not present, so
/// debug/widget tests and sideload builds without those files stay safe.
class FirebaseFcmTokenSource extends FcmTokenSource {
  const FirebaseFcmTokenSource();

  static bool _backgroundHandlerBound = false;

  Future<bool> ensureInitialized() async {
    if (Firebase.apps.isNotEmpty) {
      _bindBackgroundHandler();
      return true;
    }
    try {
      await Firebase.initializeApp();
      _bindBackgroundHandler();
      return Firebase.apps.isNotEmpty;
    } catch (error) {
      debugPrint('Firebase not configured: $error');
      return false;
    }
  }

  void _bindBackgroundHandler() {
    if (_backgroundHandlerBound) return;
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _backgroundHandlerBound = true;
    } catch (error) {
      debugPrint('FCM background handler not bound: $error');
    }
  }

  Stream<String> tokenRefreshes() async* {
    if (!await ensureInitialized()) return;
    yield* FirebaseMessaging.instance.onTokenRefresh;
  }

  @override
  Future<String?> getToken() async {
    if (!await ensureInitialized()) return null;
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // APNs token can be briefly null on a cold start / simulator.
        await messaging.getAPNSToken();
      }
      final token = await messaging.getToken();
      final trimmed = token?.trim();
      if (trimmed == null || trimmed.isEmpty) return null;
      return trimmed;
    } catch (error) {
      debugPrint('FCM token unavailable: $error');
      return null;
    }
  }
}
