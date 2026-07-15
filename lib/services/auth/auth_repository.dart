import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_exception.dart';
import '../api/bloomdue_api_client.dart';
import 'auth_session.dart';

const _tokenKey = 'bloomdue_access_token';

class AuthRepository {
  AuthRepository({
    required BloomdueApiClient api,
    FlutterSecureStorage? storage,
  })  : _api = api,
        _storage = storage ?? const FlutterSecureStorage();

  final BloomdueApiClient _api;
  final FlutterSecureStorage _storage;

  Future<AuthSession?> loadSession() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) return null;
    try {
      final user = await _api.getMe(token);
      return AuthSession(token: token, user: user);
    } on ApiException {
      await _storage.delete(key: _tokenKey);
      return null;
    }
  }

  Future<String?> requestMagicCode(String email) async {
    final response = await _api.requestMagicCode(email.trim());
    return response['dev_code'] as String?;
  }

  Future<AuthSession> verifyMagicCode({
    required String email,
    required String code,
  }) async {
    final token = await _api.verifyMagicCode(email: email.trim(), code: code.trim());
    await _storage.write(key: _tokenKey, value: token);
    final user = await _api.getMe(token);
    return AuthSession(token: token, user: user);
  }

  Future<void> signOut() async {
    await _storage.delete(key: _tokenKey);
  }
}