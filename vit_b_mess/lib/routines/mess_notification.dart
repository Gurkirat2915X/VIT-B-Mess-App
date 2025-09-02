import 'dart:developer';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:vit_b_mess/models/meals.dart';
import 'package:vit_b_mess/models/settings.dart';
import 'package:vit_b_mess/provider/mess_data.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const int dailyMessAlarmId = 0;
const int breakfastAlarmId = 1;
const int lunchAlarmId = 2;
const int snackAlarmId = 3;
const int dinnerAlarmId = 4;
bool vegOnly = false;

class MealTime {
  final int id;
  final String name;
  final int hour;
  final int minute;

  const MealTime(this.id, this.name, this.hour, this.minute);
}

final List<MealTime> mealTimes = [
  MealTime(breakfastAlarmId, 'Breakfast', 7, 0),
  MealTime(lunchAlarmId, 'Lunch', 12, 0),
  MealTime(snackAlarmId, 'Snack', 16, 30),
  MealTime(dinnerAlarmId, 'Dinner', 19, 0),
];

Future<void> hiveInitializer() async {
  await Hive.initFlutter();
  
  // Check if adapters are already registered before registering them
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(SettingsAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(HostelsAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(MessTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(MealAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(MealsAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(MessMealDaysAdapter());
  }
  if (!Hive.isBoxOpen("mess_app_settings")) {
    await Hive.openBox<Settings>("mess_app_settings");
  }
  if (!Hive.isBoxOpen("mess_app_data")) {
    await Hive.openBox<MessMealDays>("mess_app_data");
  }
}

Future<FlutterLocalNotificationsPlugin> notificationInitializer(
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
) async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  return flutterLocalNotificationsPlugin;
}

Meals getMealsFromStorage() {
  final settingsBox = Hive.box<Settings>('mess_app_settings');
  final settings = settingsBox.get('settings');
  if (settings == null) {
    throw Exception('Settings not found in storage');
  }
  vegOnly = settings.onlyVeg;
  final messDataBox = Hive.box<MessMealDays>('mess_app_data');
  final messData = messDataBox.get(settings.selectedMess.name);
  if (messData == null) {
    throw Exception(
      'Mess data not found in storage for ${settings.selectedMess}',
    );
  }

  return getDayMeals(DateTime.now().weekday - 1, messData);
}

Meals getDayMeals(int day, MessMealDays state) {
  switch (day) {
    case 0:
      return state.monday;
    case 1:
      return state.tuesday;
    case 2:
      return state.wednesday;
    case 3:
      return state.thursday;
    case 4:
      return state.friday;
    case 5:
      return state.saturday;
    case 6:
      return state.sunday;
    default:
      throw Exception("Invalid day index: $day");
  }
}

Meal getCurrentMeal(int id, Meals meals) {
  switch (id) {
    case breakfastAlarmId:
      return meals.breakfast;
    case lunchAlarmId:
      return meals.lunch;
    case snackAlarmId:
      return meals.snacks;
    case dinnerAlarmId:
      return meals.dinner;
    default:
      throw Exception("Invalid meal time id: $id");
  }
}

@pragma('vm:entry-point')
Future<void> dailyNotificationInitializer() async {
  log("Initializing daily notifications...");
  try {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Calcutta'));
    await hiveInitializer();
    await AndroidAlarmManager.initialize();

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        await notificationInitializer(FlutterLocalNotificationsPlugin());

    final Meals currentMeals = getMealsFromStorage();

  // Schedule all meal notifications
  for (final mealTime in mealTimes) {
    await setMealNotification(
      flutterLocalNotificationsPlugin,
      mealTime,
      currentMeals,
    );
    log(
      "Scheduled notification for ${mealTime.name} at ${mealTime.hour}:${mealTime.minute}",
    );
  }
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: AndroidNotificationDetails(
      'meal_channel',
      'Meal Notifications',
      channelDescription: 'Notifications for meal times',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      styleInformation: BigTextStyleInformation(
        "Your daily meal notifications have been set up. You will receive notifications for breakfast, lunch, snacks, and dinner",
        htmlFormatBigText: true,
        contentTitle: "Daily Mess Notification",
        htmlFormatContentTitle: true,
        summaryText: 'Tap to view details',
        htmlFormatSummaryText: true,
      ),
    ),
  );
  await flutterLocalNotificationsPlugin.show(
    dailyMessAlarmId,
    'Daily Mess Notification',
    'Your daily meal notifications have been set up.',
    platformChannelSpecifics,
  );
  log("Daily notifications initialized successfully.");
  } catch (e) {
    log("Error initializing daily notifications: $e");
  }
}

Future<void> setMealNotification(
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  MealTime mealTime,
  Meals currentMeals,
) async {
  final String title = 'Today\'s ${mealTime.name} Menu';
  final currentMeal = getCurrentMeal(mealTime.id, currentMeals);
  final String body = """
  Menu for ${mealTime.name}:
  ${currentMeal.veg.isNotEmpty ? "Veg: ${currentMeal.veg.join(', ')}\n" : ""}
  ${currentMeal.nonVeg.isNotEmpty ? "Non-Veg: ${currentMeal.nonVeg.join(', ')}" : ""}
  """;
  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: AndroidNotificationDetails(
      'meal_channel',
      'Meal Notifications',
      channelDescription: 'Notifications for meal times',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: 'Tap to view details',
        htmlFormatSummaryText: true,
      ),
    ),
  );
  final now = DateTime.now();
  var scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    mealTime.hour,
    mealTime.minute,
  );
  if (scheduledDate.isBefore(now)) {
    log("Scheduled time for ${mealTime.name} has already passed - skipping notification");
    return; 
  }
  
  log(
    "Scheduling ${mealTime.name} for today at ${mealTime.hour}:${mealTime.minute}",
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    mealTime.id,
    title,
    body,
    scheduledDate,
    platformChannelSpecifics,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}
