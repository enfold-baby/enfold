import '../../services/api/enfold_api_client.dart';

String authorLabelForUser(AuthUser user) {
  final name = user.displayName.trim();
  if (name.isNotEmpty) return name;
  final local = user.email.split('@').first.trim();
  if (local.isNotEmpty) return _capitalize(local);
  return 'You';
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}