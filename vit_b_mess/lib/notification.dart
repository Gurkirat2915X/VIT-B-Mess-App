import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vit_b_mess/routines/mess_notification.dart';
import "dart:developer";

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const int alarmId = 0;

DateTime _getNextMidnight() {
  final now = DateTime.now();
  final tomorrow = now.add(const Duration(days: 1));
  return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 0, 0, 0);
}

Future<void> notificationSetup() async {
  log("Daily notification initializer called");

  try {
    await AndroidAlarmManager.initialize();

    await notificationInitializer();
    DateTime now = DateTime.now();
    if (now.hour >= 0 && now.hour < 3) {
      log("Preventing notification setup (midnight to 3 AM)");
      return;
    }

    await AndroidAlarmManager.cancel(alarmId);

    final startTime = _getNextMidnight();

    final success = await AndroidAlarmManager.periodic(
      const Duration(hours: 24),
      alarmId,
      dailyNotificationInitializer,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      startAt: startTime,
      allowWhileIdle: true,
    );
    if (success) {
      log("Notification alarm scheduled successfully for $startTime");
    } else {
      log("Failed to schedule notification alarm");
    }
  } catch (e) {
    log("Error scheduling notification: $e");
  }
}

Future<void> notificationInitializer() async {
  try {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    log("Notification system initialized");
  } catch (e) {
    log("Failed to initialize notifications: $e");
  }
}

Future<void> cancelNotification() async {
  log("Cancelling all notifications");
  await flutterLocalNotificationsPlugin.cancelAll();
  await AndroidAlarmManager.cancel(alarmId);
}
