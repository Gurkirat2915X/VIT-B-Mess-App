import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vit_b_mess/routines/mess_notification.dart';
import 'package:workmanager/workmanager.dart';

const dailyNotificationTask = "dailyNotificationTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == dailyNotificationTask) {
      log("Workmanager: Executing daily notification task.");
      await notificationInitializer();
      await dailyNotificationInitializer();
    }
    return Future.value(true);
  });
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> notificationSetup() async {
  log("Daily notification initializer called");
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await notificationInitializer();
  await scheduleDailyTask();
}

Future<void> scheduleDailyTask() async {
  final now = DateTime.now();
  final tomorrowMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0);
  final initialDelay = tomorrowMidnight.difference(now);

  await Workmanager().registerPeriodicTask(
    dailyNotificationTask,
    dailyNotificationTask,
    frequency: const Duration(days: 1),
    initialDelay: initialDelay,
    existingWorkPolicy: ExistingWorkPolicy.replace,
    backoffPolicy: BackoffPolicy.linear,
    constraints: Constraints(networkType: NetworkType.notRequired),
  );
  log(
    "Workmanager task scheduled to run at $tomorrowMidnight with the delay of $initialDelay, repeating daily.",
  );
}

Future<void> notificationInitializer() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> cancelNotification() async {
  log("Cancelling all notifications");
  await flutterLocalNotificationsPlugin.cancelAll();
  await Workmanager().cancelAll();
}
