import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../auth/auth_session.dart';
import '../database/database_provider.dart';
import 'fcm_token_source.dart';
import 'push_service.dart';

final fcmTokenSourceProvider = Provider<FcmTokenSource>((ref) {
  return const NoOpFcmTokenSource();
});

final pushServiceProvider = Provider<PushService>((ref) {
  return PushService(api: ref.watch(apiClientProvider));
});

final pushActionsProvider = Provider<PushActions>((ref) => PushActions(ref));

/// Activates partner-push registration when a session appears.
/// No-op until [fcmTokenSourceProvider] returns a real token.
final pushBootstrapProvider = Provider<void>((ref) {
  ref.listen(authSessionProvider, (previous, next) {
    final session = next.valueOrNull;
    if (session == null) return;
    if (previous?.valueOrNull?.token == session.token) return;
    ref.read(pushActionsProvider).syncPartnerPushIfEnabled(session: session);
  });
});

class PushActions {
  PushActions(this._ref);

  final Ref _ref;

  Future<void> syncPartnerPushIfEnabled({required AuthSession session}) async {
    final enabled = await _ref
        .read(databaseProvider)
        .settingsDao
        .partnerActivityPushEnabled();
    if (!enabled) return;

    final token = await _ref.read(fcmTokenSourceProvider).getToken();
    await _ref.read(pushServiceProvider).registerIfPossible(
          session: session,
          fcmToken: token,
          platform: _platformLabel(),
        );
  }
}

String _platformLabel() {
  if (kIsWeb) return 'web';
  if (Platform.isIOS) return 'ios';
  if (Platform.isAndroid) return 'android';
  return 'unknown';
}