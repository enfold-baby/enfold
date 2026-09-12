import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

const medicationReminderCategoryId = 'med_routine';
const medicationGivenActionId = 'given';
const medicationLaterActionId = 'later';

FlutterLocalNotificationsPlugin? _plugin;
bool _ready = false;
void Function(NotificationResponse response)? onNotificationResponse;

Future<FlutterLocalNotificationsPlugin?> ensureLocalNotifications() async {
  if (kIsWeb) return null;
  _plugin ??= FlutterLocalNotificationsPlugin();
  if (_ready) return _plugin;
  tzdata.initializeTimeZones();
  try {
    final name = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(name));
  } catch (_) {
    tz.setLocalLocation(tz.UTC);
  }

  const android = AndroidInitializationSettings('@drawable/ic_stat_enfold');
  final darwin = DarwinInitializationSettings(
    notificationCategories: [
      DarwinNotificationCategory(
        medicationReminderCategoryId,
        actions: [
          DarwinNotificationAction.plain(medicationGivenActionId, 'Given'),
          DarwinNotificationAction.plain(medicationLaterActionId, 'Later'),
        ],
      ),
    ],
  );
  await _plugin!.initialize(
    InitializationSettings(android: android, iOS: darwin),
    onDidReceiveNotificationResponse: (response) {
      onNotificationResponse?.call(response);
    },
  );
  _ready = true;
  return _plugin;
}

Future<void> requestLocalNotificationPermission(
  FlutterLocalNotificationsPlugin plugin,
) async {
  if (kIsWeb) return;
  if (Platform.isAndroid) {
    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }
  if (Platform.isIOS) {
    final ios = plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }
}
