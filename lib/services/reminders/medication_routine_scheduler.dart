import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../features/medication/utils/medication_routine_due.dart';
import 'local_notifications.dart';

const medicationReminderChannelId = 'medication_routines';
const _notificationIdBase = 7200;

int medicationNotificationId(String routineId) {
  return _notificationIdBase + (routineId.hashCode & 0x7fffffff) % 800;
}

class MedicationReminderJob {
  const MedicationReminderJob({
    required this.routineId,
    required this.name,
    required this.when,
  });

  final String routineId;
  final String name;
  final DateTime when;
}

abstract class MedicationRoutineScheduler {
  Future<void> sync({
    required List<MedicationReminderJob> jobs,
    required String babyName,
  });
}

class NoOpMedicationRoutineScheduler implements MedicationRoutineScheduler {
  const NoOpMedicationRoutineScheduler();

  @override
  Future<void> sync({
    required List<MedicationReminderJob> jobs,
    required String babyName,
  }) async {}
}

class LocalMedicationRoutineScheduler implements MedicationRoutineScheduler {
  LocalMedicationRoutineScheduler();

  final _lastIds = <int>{};

  @override
  Future<void> sync({
    required List<MedicationReminderJob> jobs,
    required String babyName,
  }) async {
    if (kIsWeb) return;
    final plugin = await ensureLocalNotifications();
    if (plugin == null) return;

    final nextIds = {
      for (final job in jobs) medicationNotificationId(job.routineId),
    };
    for (final id in _lastIds.difference(nextIds)) {
      await plugin.cancel(id);
    }
    for (final id in nextIds) {
      await plugin.cancel(id);
    }
    _lastIds
      ..clear()
      ..addAll(nextIds);
    if (jobs.isEmpty) return;

    await requestLocalNotificationPermission(plugin);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        medicationReminderChannelId,
        'Vitamin reminders',
        channelDescription: 'Gentle ping for a daily vitamin or medication.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        // showsUserInterface must be true: without it Android routes the tap
        // to a background isolate callback we do not register, so nothing
        // happened when parents tapped Given or Later.
        actions: [
          AndroidNotificationAction(
            medicationGivenActionId,
            'Given',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            medicationLaterActionId,
            'Later',
            showsUserInterface: true,
          ),
        ],
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: medicationReminderCategoryId,
      ),
    );

    for (final job in jobs) {
      final id = medicationNotificationId(job.routineId);
      await plugin.zonedSchedule(
        id,
        'Enfold',
        medicationReminderBody(job.name, babyName),
        tz.TZDateTime.from(job.when, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'med:${job.routineId}',
      );
    }
  }
}
