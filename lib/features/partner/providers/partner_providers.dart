import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/database/database_provider.dart';
import '../../../services/push/push_providers.dart';
import '../../../services/auth/auth_providers.dart';
import '../../settings/widgets/partner_section.dart';
import '../../today/providers/today_log_provider.dart';
import '../models/partner_nudge.dart';

final hasPartnerProvider = Provider<AsyncValue<bool>>((ref) {
  final familyAsync = ref.watch(familyInfoProvider);
  return familyAsync.whenData(
    (family) => family != null && family.members.length > 1,
  );
});

final partnerActivityPushProvider = FutureProvider<bool>((ref) async {
  final db = ref.read(databaseProvider);
  return db.settingsDao.partnerActivityPushEnabled();
});

final partnerGentleNudgeProvider = FutureProvider<bool>((ref) async {
  final db = ref.read(databaseProvider);
  return db.settingsDao.partnerGentleNudgeEnabled();
});

final partnerNudgeProvider = Provider<AsyncValue<PartnerNudge?>>((ref) {
  final enabled = ref.watch(partnerGentleNudgeProvider).valueOrNull ?? false;
  final hasPartner = ref.watch(hasPartnerProvider).valueOrNull ?? false;
  if (!enabled || !hasPartner) {
    return const AsyncData(null);
  }

  final logsAsync = ref.watch(todayLogProvider);
  return logsAsync.whenData(
    (logs) => detectGentleNudge(todayLogs: logs, now: DateTime.now()),
  );
});

final partnerNotificationActionsProvider =
    Provider<PartnerNotificationActions>((ref) {
  return PartnerNotificationActions(ref);
});

class PartnerNotificationActions {
  PartnerNotificationActions(this._ref);

  final Ref _ref;

  Future<void> setActivityPushEnabled(bool value) async {
    await _ref
        .read(databaseProvider)
        .settingsDao
        .setPartnerActivityPushEnabled(value);
    _ref.invalidate(partnerActivityPushProvider);
    final session = _ref.read(authSessionProvider).valueOrNull;
    if (session == null) return;
    if (value) {
      await _ref
          .read(pushActionsProvider)
          .syncPartnerPushIfEnabled(session: session);
    } else {
      await _ref
          .read(pushActionsProvider)
          .unregisterPartnerPush(session: session);
    }
  }

  Future<void> setGentleNudgeEnabled(bool value) async {
    await _ref
        .read(databaseProvider)
        .settingsDao
        .setPartnerGentleNudgeEnabled(value);
    _ref.invalidate(partnerGentleNudgeProvider);
    _ref.invalidate(partnerNudgeProvider);
  }
}