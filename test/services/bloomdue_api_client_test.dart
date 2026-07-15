import 'dart:convert';

import 'package:bloomdue_baby/services/api/api_exception.dart';
import 'package:bloomdue_baby/services/api/bloomdue_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('verifyMagicCode returns access token', () async {
    final client = BloomdueApiClient(
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
    final client = BloomdueApiClient(
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
}