import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import 'api_exception.dart';
import 'family_models.dart';

class AuthUser {
  const AuthUser({required this.id, required this.email, required this.displayName});

  final String id;
  final String email;
  final String displayName;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String? ?? '',
    );
  }
}

class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    this.familyId,
    this.birthDate,
  });

  final String id;
  final String name;
  final String? familyId;
  final DateTime? birthDate;

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    final rawBirthDate = json['birth_date'] as String?;
    return ChildProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      familyId: json['family_id'] as String?,
      birthDate: rawBirthDate == null ? null : DateTime.tryParse(rawBirthDate),
    );
  }
}

class EnfoldApiClient {
  EnfoldApiClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _http = httpClient ?? http.Client(),
        _baseUrl = (baseUrl ?? ApiConfig.baseUrl).replaceAll(RegExp(r'/+$'), '');

  final http.Client _http;
  final String _baseUrl;

  Future<Map<String, dynamic>> requestMagicCode(String email) async {
    return _post('/v1/auth/magic-code/request', {'email': email});
  }

  Future<String> verifyMagicCode({
    required String email,
    required String code,
  }) async {
    final body = await _post('/v1/auth/magic-code/verify', {
      'email': email,
      'code': code,
    });
    return body['access_token'] as String;
  }

  Future<AuthUser> getMe(String token) async {
    final body = await _get('/v1/auth/me', token: token);
    return AuthUser.fromJson(body['user'] as Map<String, dynamic>);
  }

  Future<AuthUser> updateMe({
    required String token,
    required String displayName,
  }) async {
    final body = await _patch(
      '/v1/auth/me',
      {'display_name': displayName},
      token: token,
    );
    return AuthUser.fromJson(body['user'] as Map<String, dynamic>);
  }

  Future<void> deleteAccount({required String token}) async {
    await _delete('/v1/auth/me', token: token);
  }

  Future<List<ChildProfile>> listChildren(String token) async {
    final response = await _http.get(
      Uri.parse('$_baseUrl/v1/children'),
      headers: _headers(token),
    );
    final body = _decode(response);
    return [
      for (final item in body as List<dynamic>)
        ChildProfile.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<ChildProfile> createChild({
    required String token,
    required String name,
    DateTime? birthDate,
  }) async {
    final payload = <String, dynamic>{'name': name};
    if (birthDate != null) {
      payload['birth_date'] = birthDate.toIso8601String().split('T').first;
    }
    final body = await _post('/v1/children', payload, token: token);
    return ChildProfile.fromJson(body);
  }

  Future<List<RemoteCareEvent>> listCareEvents({
    required String token,
    required String childId,
  }) async {
    final uri = Uri.parse('$_baseUrl/v1/care-events').replace(
      queryParameters: {'child_id': childId},
    );
    final response = await _http.get(uri, headers: _headers(token));
    final body = _decode(response);
    return [
      for (final item in body as List<dynamic>)
        RemoteCareEvent.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<FamilyInfo> getFamily(String token) async {
    final body = await _get('/v1/families/me', token: token);
    return FamilyInfo.fromJson(body);
  }

  Future<FamilyInvite> createFamilyInvite(String token) async {
    final body = await _post('/v1/families/invites', {}, token: token);
    return FamilyInvite.fromJson(body);
  }

  Future<FamilyInfo> joinFamily({
    required String token,
    required String code,
  }) async {
    final body = await _post(
      '/v1/families/join',
      {'code': code.trim().toUpperCase()},
      token: token,
    );
    return FamilyInfo.fromJson(body);
  }

  /// Leave a shared family. Returns the new solo family on the server.
  Future<FamilyInfo> leaveFamily(String token) async {
    final body = await _post('/v1/families/leave', {}, token: token);
    return FamilyInfo.fromJson(body);
  }

  Future<void> registerDevice({
    required String token,
    required String platform,
    required String fcmToken,
  }) async {
    await _post(
      '/v1/devices',
      {
        'platform': platform,
        'fcm_token': fcmToken,
      },
      token: token,
    );
  }

  Future<void> unregisterDevice({
    required String token,
    required String fcmToken,
  }) async {
    await _post(
      '/v1/devices/unregister',
      {'fcm_token': fcmToken},
      token: token,
    );
  }

  Future<void> createCareEvent({
    required String token,
    required String id,
    required String childId,
    required String type,
    required DateTime occurredAt,
    Map<String, dynamic> details = const {},
    String note = '',
    DateTime? clientUpdatedAt,
  }) async {
    await _post(
      '/v1/care-events',
      {
        'id': id,
        'child_id': childId,
        'type': type,
        'occurred_at': occurredAt.toUtc().toIso8601String(),
        'details': details,
        'note': note,
        if (clientUpdatedAt != null)
          'client_updated_at': clientUpdatedAt.toUtc().toIso8601String(),
      },
      token: token,
    );
  }

  Future<void> updateCareEvent({
    required String token,
    required String eventId,
    required String type,
    required DateTime occurredAt,
    Map<String, dynamic> details = const {},
    String note = '',
    DateTime? clientUpdatedAt,
  }) async {
    await _patch(
      '/v1/care-events/$eventId',
      {
        'type': type,
        'occurred_at': occurredAt.toUtc().toIso8601String(),
        'details': details,
        'note': note,
        if (clientUpdatedAt != null)
          'client_updated_at': clientUpdatedAt.toUtc().toIso8601String(),
      },
      token: token,
    );
  }

  Future<void> deleteCareEvent({
    required String token,
    required String eventId,
  }) async {
    await _delete('/v1/care-events/$eventId', token: token);
  }

  Future<Map<String, dynamic>> _get(String path, {String? token}) async {
    final response = await _http.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(token),
    );
    final body = _decode(response);
    return body as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> payload, {
    String? token,
  }) async {
    final response = await _http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(token),
      body: jsonEncode(payload),
    );
    final body = _decode(response);
    if (body is Map<String, dynamic>) return body;
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> _patch(
    String path,
    Map<String, dynamic> payload, {
    String? token,
  }) async {
    final response = await _http.patch(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(token),
      body: jsonEncode(payload),
    );
    final body = _decode(response);
    if (body is Map<String, dynamic>) return body;
    return <String, dynamic>{};
  }

  Future<void> _delete(String path, {String? token}) async {
    final response = await _http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(token),
    );
    _decode(response);
  }

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Object? _decode(http.Response response) {
    final raw = response.body;
    Object? body;
    if (raw.isNotEmpty) {
      try {
        body = jsonDecode(raw);
      } on FormatException {
        body = raw.trim();
      }
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body ?? <String, dynamic>{};
    }
    final message = switch (body) {
      Map<String, dynamic> map => _detailMessage(map) ?? 'Request failed',
      String text when text.isNotEmpty => text,
      _ => 'Request failed (${response.statusCode})',
    };
    throw ApiException(message, statusCode: response.statusCode);
  }

  String? _detailMessage(Map<String, dynamic> map) {
    final detail = map['detail'];
    if (detail is String && detail.trim().isNotEmpty) return detail.trim();
    if (detail != null) return detail.toString();
    return null;
  }
}