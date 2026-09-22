import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/providers/locale_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/auth_providers.dart';
import '../database/database_provider.dart';
import 'sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  // Rebuilds when the language override loads or changes, so sync errors
  // speak the same language as the rest of the app.
  final override = ref.watch(localeOverrideProvider).valueOrNull;
  return SyncService(
    api: ref.watch(apiClientProvider),
    db: ref.watch(databaseProvider),
    l10n: lookupAppL10n(override ?? resolvedDeviceLocale()),
  );
});

final lastSyncResultProvider = StateProvider<SyncResult?>((ref) => null);

final syncActionsProvider = Provider<SyncActions>((ref) => SyncActions(ref));

class SyncActions {
  SyncActions(this._ref);

  final Ref _ref;

  Future<SyncResult> syncIfSignedIn({bool fullHistory = false}) async {
    final session = _ref.read(authSessionProvider).valueOrNull;
    if (session == null) return const SyncResult(pushed: 0);

    final result = await _ref.read(syncServiceProvider).syncAll(
          session: session,
          fullHistory: fullHistory,
        );
    _ref.read(lastSyncResultProvider.notifier).state = result;
    return result;
  }

  /// After joining a partner family: rebind to their baby, then full pull.
  Future<({SyncResult result, String? babyName})> syncAfterFamilyJoin() async {
    final session = _ref.read(authSessionProvider).valueOrNull;
    if (session == null) {
      return (result: const SyncResult(pushed: 0), babyName: null);
    }

    final babyName = await _ref
        .read(syncServiceProvider)
        .rebindToFamilyPrimaryChild(session: session);
    final result = await syncIfSignedIn(fullHistory: true);
    return (result: result, babyName: babyName);
  }
}