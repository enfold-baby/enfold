import 'package:enfold/features/medication/providers/medication_routine_providers.dart';
import 'package:enfold/features/logs/providers/logs_providers.dart' show mapCareEvents;
import 'package:enfold/services/reminders/local_notifications.dart';
import 'package:enfold/services/database/database_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

void main() {
  test('tapping Given on the reminder logs the dose once', () async {
    final container = createTestContainer();
    addTearDown(container.dispose);
    final db = container.read(databaseProvider);
    final babyId = await db.careLogDao.ensureDefaultBaby();
    final routineId = await db.medicationRoutineDao.upsertDaily(
      babyId: babyId,
      name: 'Vitamin D drops',
      dose: '1 drop',
      hour: 10,
      minute: 22,
    );

    final actions = container.read(medicationRoutineActionsProvider);
    await actions.handleNotification(
      NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        actionId: medicationGivenActionId,
        payload: 'med:$routineId',
      ),
    );
    // A second tap (or the launch-details replay) must not double log.
    await actions.handleNotification(
      NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        actionId: medicationGivenActionId,
        payload: 'med:$routineId',
      ),
    );

    final logs = mapCareEvents(await db.careLogDao.getTodayLogs(babyId));
    final doses = logs.where((l) => l.details.medicationName == 'Vitamin D drops');
    expect(doses, hasLength(1));
    expect(doses.single.details.medicationDose, '1 drop');
  });

  test('tapping Later snoozes the routine without logging', () async {
    final container = createTestContainer();
    addTearDown(container.dispose);
    final db = container.read(databaseProvider);
    final babyId = await db.careLogDao.ensureDefaultBaby();
    final routineId = await db.medicationRoutineDao.upsertDaily(
      babyId: babyId,
      name: 'Vitamin D drops',
      hour: 10,
      minute: 22,
    );

    await container.read(medicationRoutineActionsProvider).handleNotification(
      NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        actionId: medicationLaterActionId,
        payload: 'med:$routineId',
      ),
    );

    final routine = await db.medicationRoutineDao.getById(routineId);
    expect(routine!.snoozeUntil, isNotNull);
    expect(await db.careLogDao.getTodayLogs(babyId), isEmpty);
  });
}
