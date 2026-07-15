import '../api/bloomdue_api_client.dart';
import '../auth/auth_session.dart';

/// Registers FCM tokens with the VPS when available.
///
/// Wire [registerIfPossible] after Firebase Messaging is configured on the
/// device. Until then this is a safe no-op.
class PushService {
  const PushService({required BloomdueApiClient api}) : _api = api;

  final BloomdueApiClient _api;

  Future<void> registerIfPossible({
    required AuthSession session,
    String? fcmToken,
    String platform = 'android',
  }) async {
    final token = fcmToken?.trim();
    if (token == null || token.isEmpty) return;

    await _api.registerDevice(
      token: session.token,
      platform: platform,
      fcmToken: token,
    );
  }
}