import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/baby/providers/baby_profile_providers.dart';
import '../../features/today/providers/today_log_provider.dart';
import '../database/database_provider.dart';
import 'care_reminder_scheduler.dart';
import 'local_care_reminder_scheduler.dart';

final careReminderSchedulerProvider = Provider<CareReminderScheduler>((ref) {
  return LocalCareReminderScheduler();
});

final careRemindersEnabledProvider = StreamProvider<bool>((ref) async* {
  final db = ref.read(databaseProvider);
  await db.settingsDao.ensureSettings();
  yield* db.settingsDao.watchCareRemindersEnabled();
});

final careReminderActionsProvider = Provider<CareReminderActions>((ref) {
  return CareReminderActions(ref);
});

/// Keeps the evening ping in sync with logs and the settings toggle.
final careReminderBootstrapProvider = Provider<void>((ref) {
  ref.listen(todayLogProvider, (_, next) {
    next.whenData((_) {
      unawaited(ref.read(careReminderActionsProvider).resync());
    });
  });
  ref.listen(careRemindersEnabledProvider, (_, next) {
    next.whenData((_) {
      unawaited(ref.read(careReminderActionsProvider).resync());
    });
  });
  ref.listen(activeBabyProvider, (_, next) {
    next.whenData((_) {
      unawaited(ref.read(careReminderActionsProvider).resync());
    });
  });
});

class CareReminderActions {
  CareReminderActions(this._ref);

  final Ref _ref;

  Future<void> setEnabled(bool value) async {
    await _ref
        .read(databaseProvider)
        .settingsDao
        .setCareRemindersEnabled(value);
    await resync();
  }

  Future<void> resync() async {
    final db = _ref.read(databaseProvider);
    final enabled = await db.settingsDao.careRemindersEnabled();
    final baby = _ref.read(activeBabyProvider).valueOrNull;
    final logs = _ref.read(todayLogProvider).valueOrNull ?? const [];
    await _ref.read(careReminderSchedulerProvider).sync(
          enabled: enabled,
          babyName: baby?.name ?? 'Baby',
          hasLogsToday: logs.isNotEmpty,
        );
  }
}
