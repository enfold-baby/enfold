import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/database/app_database.dart';
import '../../../services/database/database_provider.dart';
import '../../../services/reminders/local_notifications.dart';
import '../../../services/reminders/medication_routine_scheduler.dart';
import '../../baby/providers/baby_profile_providers.dart';
import '../../logs/providers/logs_providers.dart' show mapCareEvents;
import '../../today/models/care_log_details.dart';
import '../../today/models/log_type.dart';
import '../../today/providers/today_log_provider.dart';
import '../utils/medication_routine_due.dart';
import 'medication_providers.dart';

final medicationRoutineSchedulerProvider =
    Provider<MedicationRoutineScheduler>((ref) {
  return LocalMedicationRoutineScheduler();
});

final medicationRoutinesProvider =
    StreamProvider<List<MedicationRoutine>>((ref) {
  final db = ref.read(databaseProvider);
  return Stream.fromFuture(db.careLogDao.ensureDefaultBaby()).asyncExpand(
    (babyId) => db.medicationRoutineDao.watchForBaby(babyId),
  );
});

final medicationRoutineActionsProvider = Provider<MedicationRoutineActions>(
  (ref) => MedicationRoutineActions(ref),
);

final medicationRoutineBootstrapProvider = Provider<void>((ref) {
  onNotificationResponse = (response) {
    unawaited(
      ref.read(medicationRoutineActionsProvider).handleNotification(response),
    );
  };
  unawaited(_consumeLaunchNotification(ref));

  ref.listen(medicationRoutinesProvider, (_, next) {
    next.whenData((_) {
      unawaited(ref.read(medicationRoutineActionsProvider).resync());
    });
  });
  ref.listen(todayMedicationLogsProvider, (_, next) {
    next.whenData((_) {
      unawaited(ref.read(medicationRoutineActionsProvider).resync());
    });
  });
  ref.listen(activeBabyProvider, (_, next) {
    next.whenData((_) {
      unawaited(ref.read(medicationRoutineActionsProvider).resync());
    });
  });
});

Future<void> _consumeLaunchNotification(Ref ref) async {
  final plugin = await ensureLocalNotifications();
  if (plugin == null) return;
  final launch = await plugin.getNotificationAppLaunchDetails();
  final response = launch?.notificationResponse;
  if (launch?.didNotificationLaunchApp != true || response == null) return;
  await ref.read(medicationRoutineActionsProvider).handleNotification(response);
}

class MedicationRoutineActions {
  MedicationRoutineActions(this._ref);

  final Ref _ref;

  Future<void> saveFromLog({
    required String name,
    required String dose,
    required String category,
    required int hour,
    required int minute,
    required bool remindDaily,
  }) async {
    final db = _ref.read(databaseProvider);
    final babyId = await db.careLogDao.ensureDefaultBaby();
    if (remindDaily) {
      final existing = await db.medicationRoutineDao.findByName(
        babyId: babyId,
        name: name,
      );
      final useExistingClock = existing != null && existing.enabled;
      await db.medicationRoutineDao.upsertDaily(
        babyId: babyId,
        name: name,
        dose: dose,
        category: category,
        hour: useExistingClock ? existing.hour : hour,
        minute: useExistingClock ? existing.minute : minute,
      );
    } else {
      await db.medicationRoutineDao.disableByName(babyId: babyId, name: name);
    }
    await resync();
  }

  Future<void> setEnabled(String id, bool enabled) async {
    await _ref.read(databaseProvider).medicationRoutineDao.setEnabled(id, enabled);
    await resync();
  }

  Future<void> setTime(
    String id, {
    required int hour,
    required int minute,
  }) async {
    await _ref
        .read(databaseProvider)
        .medicationRoutineDao
        .setTime(id, hour: hour, minute: minute);
    await resync();
  }

  Future<void> deleteRoutine(String id) async {
    await _ref.read(databaseProvider).medicationRoutineDao.deleteRoutine(id);
    await resync();
  }

  Future<void> giveNow(MedicationRoutine routine) async {
    if (await _loggedToday(routine.name)) return;
    await _ref.read(careLogActionsProvider).saveLog(
          type: LogType.medication,
          occurredAt: DateTime.now(),
          details: CareLogDetails(
            medicationCategory: routine.category,
            medicationName: routine.name,
            medicationDose: routine.dose.isEmpty ? null : routine.dose,
          ),
        );
    await _ref
        .read(databaseProvider)
        .medicationRoutineDao
        .setSnoozeUntil(routine.id, null);
    await resync();
  }

  Future<void> later(String routineId) async {
    await _ref.read(databaseProvider).medicationRoutineDao.setSnoozeUntil(
          routineId,
          laterSnoozeUntil(DateTime.now()),
        );
    await resync();
  }

  Future<void> handleNotification(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null || !payload.startsWith('med:')) return;
    final id = payload.substring(4);
    if (id.isEmpty) return;
    if (response.actionId == medicationLaterActionId) {
      await later(id);
      return;
    }
    if (response.actionId == medicationGivenActionId ||
        response.actionId == null ||
        response.actionId!.isEmpty) {
      final routine =
          await _ref.read(databaseProvider).medicationRoutineDao.getById(id);
      if (routine == null || !routine.enabled) return;
      if (response.actionId == medicationGivenActionId) {
        await giveNow(routine);
      }
    }
  }

  Future<void> resync() async {
    final db = _ref.read(databaseProvider);
    final baby = _ref.read(activeBabyProvider).valueOrNull;
    final babyId = baby?.id ?? await db.careLogDao.ensureDefaultBaby();
    final routines = await db.medicationRoutineDao.listForBaby(babyId);
    final todayLogs =
        _ref.read(todayMedicationLogsProvider).valueOrNull ?? const [];
    final now = DateTime.now();
    final jobs = <MedicationReminderJob>[
      for (final routine in routines)
        if (routine.enabled)
          MedicationReminderJob(
            routineId: routine.id,
            name: routine.name,
            when: nextMedicationReminderAt(
              hour: routine.hour,
              minute: routine.minute,
              now: now,
              alreadyLoggedToday: medicationLoggedToday(
                name: routine.name,
                todayLogs: todayLogs,
              ),
              snoozeUntil: routine.snoozeUntil,
            ),
          ),
    ];
    await _ref.read(medicationRoutineSchedulerProvider).sync(
          jobs: jobs,
          babyName: baby?.name ?? 'Baby',
        );
  }

  Future<bool> _loggedToday(String name) async {
    final db = _ref.read(databaseProvider);
    final babyId = await db.careLogDao.ensureDefaultBaby();
    final logs = mapCareEvents(await db.careLogDao.getTodayLogs(babyId));
    return medicationLoggedToday(name: name, todayLogs: logs);
  }
}
