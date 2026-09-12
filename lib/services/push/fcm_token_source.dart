/// Abstraction over FCM token retrieval.
abstract class FcmTokenSource {
  const FcmTokenSource();

  Future<String?> getToken();
}

/// Used in tests, and as a fallback if Firebase native config is missing.
class NoOpFcmTokenSource extends FcmTokenSource {
  const NoOpFcmTokenSource();

  @override
  Future<String?> getToken() async => null;
}