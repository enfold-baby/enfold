/// Abstraction over FCM token retrieval.
///
/// Swap [noOpFcmTokenSource] for a Firebase-backed implementation once the
/// Firebase project and platform config files exist. See
/// `feature/todos/FCM_PARTNER_PUSH.md`.
abstract class FcmTokenSource {
  const FcmTokenSource();

  Future<String?> getToken();
}

/// Safe default until Firebase Messaging is configured.
class NoOpFcmTokenSource extends FcmTokenSource {
  const NoOpFcmTokenSource();

  @override
  Future<String?> getToken() async => null;
}