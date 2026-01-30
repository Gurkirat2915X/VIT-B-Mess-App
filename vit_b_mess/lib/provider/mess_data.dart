import 'dart:convert';
import 'dart:developer';
import 'package:vit_b_mess/routines/mess_notification.dart'
    as mess_notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vit_b_mess/models/meals.dart';
import 'package:vit_b_mess/provider/settings.dart';
import 'package:vit_b_mess/mess_app_info.dart' as app_info;
import "package:http/http.dart" as http;
part 'mess_data.g.dart';

final initialMeal = Meal(nonVeg: [], veg: []);

final initialMeals = Meals(
  breakfast: initialMeal,
  lunch: initialMeal,
  snacks: initialMeal,
  dinner: initialMeal,
);

final initialMessMealDays = MessMealDays(
  mess: MessType.BoysMayuri,
  monday: initialMeals,
  tuesday: initialMeals,
  wednesday: initialMeals,
  thursday: initialMeals,
  friday: initialMeals,
  saturday: initialMeals,
  sunday: initialMeals,
);

@HiveType(typeId: 1)
enum Hostels {
  @HiveField(0)
  Boys,
  @HiveField(1)
  Girls,
}

@HiveType(typeId: 2)
enum MessType {
  @HiveField(0)
  CRCL(hostel: Hostels.Boys),
  @HiveField(1)
  BoysMayuri(hostel: Hostels.Boys),
  @HiveField(2)
  Safal(hostel: Hostels.Boys),
  @HiveField(3)
  JMB(hostel: Hostels.Boys),
  @HiveField(4)
  GirlsMayuri(hostel: Hostels.Girls),
  @HiveField(5)
  AB(hostel: Hostels.Girls);

  final Hostels hostel;
  const MessType({required this.hostel});
  static List<MessType> getMess(Hostels hostel) {
    return MessType.values.where((mess) => mess.hostel == hostel).toList();
  }
}

Future<List<bool>> updateMessData(WidgetRef ref) async {
  try {
    final currentSettings = ref.read(settingsNotifier);
    var updateMessages = <bool>[false, false];
    dynamic data = await fetchMessData();
    final receivedMessAppVersion = data["messAppVersion"];
    if (currentSettings.newUpdateVersion != receivedMessAppVersion ||
        app_info.appVersion != receivedMessAppVersion) {
      log("New update available: $receivedMessAppVersion");
      currentSettings.newUpdateVersion = receivedMessAppVersion;
      updateMessages[0] = true;
    } else {
      log("No new update available.");
    }
    final messDataVersion = data["messDataVersion"];
    if (messDataVersion == currentSettings.messDataVersion) {
      log("Mess data version is up to date. No need to update.");
      currentSettings.updatedTill = data["UpdatedTill"];
      await ref.read(settingsNotifier.notifier).saveSettings(currentSettings);
      return updateMessages;
    }
    log("Mess data version changed. Updating...");
    currentSettings.messDataVersion = messDataVersion;
    currentSettings.updatedTill = data["UpdatedTill"];
    updateMessages[1] = true;

    final messData = data["data"];
    final messBox = Hive.box<MessMealDays>("mess_app_data");
    final mess = currentSettings.selectedMess;
    ref
        .read(messDataNotifier.notifier)
        .setMessData(await messSetup(messBox, messData, mess));
    await ref.read(settingsNotifier.notifier).saveSettings(currentSettings);
    log("Mess data updated successfully for ${mess.name}");
    mess_notification.dailyNotificationInitializer();
    return updateMessages;
  } catch (e) {
    log("Error updating mess data: $e");
    return <bool>[false, false, true];
  }
}

Future<MessMealDays> messSetup(
  Box messBox,
  dynamic messData,
  MessType mess,
) async {
  for (MessType currentMess in MessType.values) {
    final messTypeData = messData[currentMess.name];
    List<Meals> meals = [];
    if (messTypeData == null) continue;
    for (int i = 0; i < 7; i++) {
      final day = messTypeData["$i"];
      if (day == null) continue;
      final breakfast = Meal(
        nonVeg: List<String>.from(day["breakfast"]["nonVeg"]),
        veg: List<String>.from(day["breakfast"]["veg"]),
      );
      final lunch = Meal(
        nonVeg: List<String>.from(day["lunch"]["nonVeg"]),
        veg: List<String>.from(day["lunch"]["veg"]),
      );
      final snacks = Meal(
        nonVeg: List<String>.from(day["snacks"]["nonVeg"]),
        veg: List<String>.from(day["snacks"]["veg"]),
      );
      final dinner = Meal(
        nonVeg: List<String>.from(day["dinner"]["nonVeg"]),
        veg: List<String>.from(day["dinner"]["veg"]),
      );

      meals.add(
        Meals(
          breakfast: breakfast,
          lunch: lunch,
          snacks: snacks,
          dinner: dinner,
        ),
      );
    }
    final messMeals = MessMealDays(
      mess: currentMess,
      monday: meals[0],
      tuesday: meals[1],
      wednesday: meals[2],
      thursday: meals[3],
      friday: meals[4],
      saturday: meals[5],
      sunday: meals[6],
    );
    await messBox.put(currentMess.name, messMeals);
  }
  final messDataLoaded = messBox.get(mess.name);
  if (messDataLoaded == null) {
    throw Exception("Failed to load mess data for ${mess.name}");
  }

  log("Mess data setup completed for ${mess.name}");
  return messDataLoaded;
}

Future<dynamic> fetchMessData() async {
  http.Response data;
  try {
    data = await http.get(Uri.parse(app_info.backendLink));
    if (data.statusCode != 200) {
      throw Exception("Failed to load mess data: ${data.statusCode}");
    }
  } catch (e) {
    log("Error fetching mess data: $e");
    throw Exception("Failed to fetch mess data");
  }
  return await json.decode(data.body);
}

Future<MessMealDays> setupMeals(WidgetRef ref) async {
  final data = await fetchMessData();
  final messData = data["data"];
  final messBox = Hive.box<MessMealDays>("mess_app_data");
  final currentSettings = ref.read(settingsNotifier);
  final mess = currentSettings.selectedMess;

  final messDataVersion = data["messDataVersion"];
  currentSettings.messDataVersion = messDataVersion;
  final newUpdateVersion = data["messAppVersion"];
  currentSettings.newUpdateVersion = newUpdateVersion;
  log("updated till: ${data["UpdatedTill"]}");
  currentSettings.updatedTill = data["UpdatedTill"];

  log("Setting up meals for ${mess.name}...");
  MessMealDays messMeals = await messSetup(messBox, messData, mess);
  await ref.read(settingsNotifier.notifier).saveSettings(currentSettings);
  log("Meals setup completed for ${mess.name}");
  return messMeals;
}

class MessDataProvider extends Notifier<MessMealDays> {
  @override
  MessMealDays build() {
    return initialMessMealDays;
  }

  Future<void> loadData(WidgetRef ref) async {
    final messBox = Hive.box<MessMealDays>("mess_app_data");
    final currentSettings = ref.read(settingsNotifier);
    final mess = currentSettings.selectedMess;
    final messData = messBox.get(mess.name);
    if (messData == null) {
      state = await setupMeals(ref);
    } else {
      state = messData;
    }
    log("Mess data loaded for ${mess.name}");
  }

  Future<List<bool>> updateData(WidgetRef ref) async {
    log("Updating mess data...");
    return await updateMessData(ref);
  }

  void setMessData(MessMealDays newData) {
    state = newData;
  }

  Meals getDayMeal(int day) {
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
}

final messDataNotifier = NotifierProvider<MessDataProvider, MessMealDays>(
  MessDataProvider.new,
);
