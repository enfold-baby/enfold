import 'package:bloomdue_baby/services/api/bloomdue_api_client.dart';
import 'package:bloomdue_baby/services/auth/auth_session.dart';
import 'package:bloomdue_baby/services/push/fcm_token_source.dart';
import 'package:bloomdue_baby/services/push/push_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class RecordingApi extends BloomdueApiClient {
  RecordingApi() : super(httpClient: http.Client());

  int registerCalls = 0;
  String? lastFcmToken;

  @override
  Future<void> registerDevice({
    required String token,
    required String platform,
    required String fcmToken,
  }) async {
    registerCalls++;
    lastFcmToken = fcmToken;
  }
}

void main() {
  test('PushService no-ops without FCM token', () async {
    final api = RecordingApi();
    final service = PushService(api: api);
    await service.registerIfPossible(
      session: const AuthSession(
        token: 'jwt',
        user: AuthUser(id: 'u1', email: 'a@b.com', displayName: ''),
      ),
      fcmToken: null,
    );
    expect(api.registerCalls, 0);
  });

  test('PushService registers when token is present', () async {
    final api = RecordingApi();
    final service = PushService(api: api);
    await service.registerIfPossible(
      session: const AuthSession(
        token: 'jwt',
        user: AuthUser(id: 'u1', email: 'a@b.com', displayName: ''),
      ),
      fcmToken: 'fcm-token-abc',
      platform: 'android',
    );
    expect(api.registerCalls, 1);
    expect(api.lastFcmToken, 'fcm-token-abc');
  });

  test('NoOpFcmTokenSource returns null', () async {
    expect(await const NoOpFcmTokenSource().getToken(), isNull);
  });
}