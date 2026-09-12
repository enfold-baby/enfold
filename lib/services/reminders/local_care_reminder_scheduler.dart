import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'care_reminder_schedule.dart';
import 'care_reminder_scheduler.dart';
import 'local_notifications.dart';

const _notificationId = 7101;
const _channelId = 'care_reminders';

class LocalCareReminderScheduler implements CareReminderScheduler {
  LocalCareReminderScheduler();

  @override
  Future<void> sync({
    required bool enabled,
    required String babyName,
    required bool hasLogsToday,
    DateTime? now,
  }) async {
    if (kIsWeb) return;
    final plugin = await ensureLocalNotifications();
    if (plugin == null) return;
    await plugin.cancel(_notificationId);
    if (!enabled || hasLogsToday) return;

    final when = nextCareReminderAt(now ?? DateTime.now());
    if (when == null) return;

    await requestLocalNotificationPermission(plugin);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Care reminders',
        channelDescription: 'Gentle ping if nothing is logged by evening.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await plugin.zonedSchedule(
      _notificationId,
      'Enfold',
      careReminderBody(babyName),
      tz.TZDateTime.from(when, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
