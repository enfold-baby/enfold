import '../api/enfold_api_client.dart';
import '../auth/auth_session.dart';

/// Registers (and unregisters) FCM tokens with the VPS when available.
class PushService {
  const PushService({required EnfoldApiClient api}) : _api = api;

  final EnfoldApiClient _api;

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

  Future<void> unregisterIfPossible({
    required AuthSession session,
    String? fcmToken,
  }) async {
    final token = fcmToken?.trim();
    if (token == null || token.isEmpty) return;

    await _api.unregisterDevice(
      token: session.token,
      fcmToken: token,
    );
  }
}