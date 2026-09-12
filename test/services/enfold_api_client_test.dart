import 'dart:convert';

import 'package:enfold/services/api/api_exception.dart';
import 'package:enfold/services/api/enfold_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('verifyMagicCode returns access token', () async {
    final client = EnfoldApiClient(
      httpClient: MockClient((request) async {
        expect(request.url.path, '/v1/auth/magic-code/verify');
        return http.Response(
          jsonEncode({'access_token': 'jwt-123', 'token_type': 'bearer'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final token = await client.verifyMagicCode(email: 'a@b.com', code: '123456');
    expect(token, 'jwt-123');
  });

  test('throws ApiException on invalid code', () async {
    final client = EnfoldApiClient(
      httpClient: MockClient((request) async {
        return http.Response(
          jsonEncode({'detail': 'Invalid or expired code'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    expect(
      () => client.verifyMagicCode(email: 'a@b.com', code: '000000'),
      throwsA(isA<ApiException>()),
    );
  });

  test('plain-text 500 becomes ApiException, not FormatException', () async {
    final client = EnfoldApiClient(
      httpClient: MockClient((request) async {
        return http.Response(
          'Internal Server Error',
          500,
          headers: {'content-type': 'text/plain'},
        );
      }),
    );

    expect(
      () => client.listCareEvents(
        token: 'jwt',
        childId: '00000000-0000-0000-0000-000000000001',
      ),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 500)
            .having((e) => e.message, 'message', 'Internal Server Error'),
      ),
    );
  });

  test('registerDevice and unregisterDevice hit the devices routes', () async {
    final paths = <String>[];
    final client = EnfoldApiClient(
      httpClient: MockClient((request) async {
        paths.add('${request.method} ${request.url.path}');
        return http.Response(
          jsonEncode({'status': 'ok'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    await client.registerDevice(
      token: 'jwt',
      platform: 'android',
      fcmToken: 'token-1',
    );
    await client.unregisterDevice(token: 'jwt', fcmToken: 'token-1');

    expect(paths, [
      'POST /v1/devices',
      'POST /v1/devices/unregister',
    ]);
  });

  test('deleteAccount hits DELETE /v1/auth/me', () async {
    final paths = <String>[];
    final client = EnfoldApiClient(
      httpClient: MockClient((request) async {
        paths.add('${request.method} ${request.url.path}');
        return http.Response('', 204);
      }),
    );

    await client.deleteAccount(token: 'jwt');
    expect(paths, ['DELETE /v1/auth/me']);
  });
}