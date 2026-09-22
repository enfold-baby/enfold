import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'care_reminder_schedule.dart';
import 'care_reminder_scheduler.dart';
import 'local_notifications.dart';
import '../../l10n/generated/app_localizations.dart';

const _notificationId = 7101;
const _channelId = 'care_reminders';

class LocalCareReminderScheduler implements CareReminderScheduler {
  LocalCareReminderScheduler();

  @override
  Future<void> sync({
    required AppL10n l10n,
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

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        l10n.notificationChannelCareName,
        channelDescription: l10n.notificationChannelCareDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await plugin.zonedSchedule(
      _notificationId,
      'Enfold',
      careReminderBody(l10n, babyName),
      tz.TZDateTime.from(when, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
