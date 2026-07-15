import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../database/database_provider.dart';
import 'sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    api: ref.watch(apiClientProvider),
    db: ref.watch(databaseProvider),
  );
});

final lastSyncResultProvider = StateProvider<SyncResult?>((ref) => null);

final syncActionsProvider = Provider<SyncActions>((ref) => SyncActions(ref));

class SyncActions {
  SyncActions(this._ref);

  final Ref _ref;

  Future<SyncResult> syncIfSignedIn() async {
    final session = _ref.read(authSessionProvider).valueOrNull;
    if (session == null) return const SyncResult(pushed: 0);

    final result = await _ref.read(syncServiceProvider).syncAll(session: session);
    _ref.read(lastSyncResultProvider.notifier).state = result;
    return result;
  }
}