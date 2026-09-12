import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/enfold_api_client.dart';
import 'auth_repository.dart';
import 'auth_session.dart';

final apiClientProvider = Provider<EnfoldApiClient>((ref) {
  return EnfoldApiClient();
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: ref.watch(apiClientProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

final authSessionProvider =
    AsyncNotifierProvider<AuthSessionNotifier, AuthSession?>(AuthSessionNotifier.new);

class AuthSessionNotifier extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    return ref.read(authRepositoryProvider).loadSession();
  }

  Future<String?> requestMagicCode(String email) {
    return ref.read(authRepositoryProvider).requestMagicCode(email);
  }

  Future<void> verifyMagicCode({
    required String email,
    required String code,
  }) async {
    final session = await ref.read(authRepositoryProvider).verifyMagicCode(
          email: email,
          code: code,
        );
    state = AsyncData(session);
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }

  Future<void> deleteAccount() async {
    final current = state.valueOrNull;
    if (current == null) return;
    await ref.read(authRepositoryProvider).deleteAccount(current.token);
    state = const AsyncData(null);
  }

  Future<void> updateDisplayName(String displayName) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final session = await ref.read(authRepositoryProvider).updateDisplayName(
          token: current.token,
          displayName: displayName,
        );
    state = AsyncData(session);
  }
}