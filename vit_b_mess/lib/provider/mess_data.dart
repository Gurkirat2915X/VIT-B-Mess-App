import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vit_b_mess/models/meals.dart';
import 'package:vit_b_mess/provider/settings.dart';
import 'package:vit_b_mess/mess_app_info.dart' as app_info;
import "package:http/http.dart" as http;
part 'mess_data.g.dart';

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

Future<bool> updateMessData(WidgetRef ref) async {
  final currentSettings = ref.read(settingsNotifier);
  dynamic data = await fetchMessData();
  final receivedMessAppVersion =
      json.decode(data.body)["data"]["messAppVersion"];
  if (currentSettings.newUpdateVersion != receivedMessAppVersion) {
    print("New update available: $receivedMessAppVersion");
    currentSettings.newUpdateVersion = receivedMessAppVersion;
  } else {
    print("No new update available.");
  }
  final messDataVersion = json.decode(data.body)["data"]["messDataVersion"];
  if (messDataVersion == currentSettings.messDataVersion) {
    print("Mess data version is up to date. No need to update.");
    await ref.read(settingsNotifier.notifier).saveSettings(currentSettings);
    return false;
  }
  print("Mess data version changed. Updating...");
  currentSettings.messDataVersion = messDataVersion;
  await ref.read(settingsNotifier.notifier).saveSettings(currentSettings);
  final messData = json.decode(data.body)["data"]["data"];
  final messBox = Hive.box<MessMealDays>("mess_app_data");
  final mess = currentSettings.selectedMess;
  ref
      .read(messDataNotifier.notifier)
      .setMessData(await messSetup(messBox, messData, mess));

  return true;
}

Future<MessMealDays> messSetup(
  Box messBox,
  dynamic messData,
  MessType mess,
) async {
  for (MessType currentMess in MessType.values) {
    final messTypeData = messData[currentMess.name];
    // print(messTypeData);
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
    print(meals);
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

  print("Mess data setup completed for ${mess.name}");
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
    print("Error fetching mess data: $e");
    throw Exception("Failed to fetch mess data");
  }
  return data;
}

Future<MessMealDays> setupMeals(WidgetRef ref) async {
  final data = await fetchMessData();
  final messData = json.decode(data.body)["data"]["data"];
  final messBox = Hive.box<MessMealDays>("mess_app_data");
  final currentSettings = ref.read(settingsNotifier);
  final mess = currentSettings.selectedMess; 
  final messDataVersion =
      json.decode(data.body)["data"]["messDataVersion"];
  currentSettings.messDataVersion = messDataVersion;
  final newUpdateVersion =
      json.decode(data.body)["data"]["messAppVersion"];
  currentSettings.newUpdateVersion = newUpdateVersion;
  await ref.read(settingsNotifier.notifier).saveSettings(currentSettings);
  print("Setting up meals for ${mess.name}...");
  return await messSetup(messBox, messData, mess);
}

class MessDataProvider extends StateNotifier<MessMealDays> {
  MessDataProvider()
    : super(
        MessMealDays(
          mess: MessType.CRCL,
          monday: Meals(
            breakfast: Meal(nonVeg: [], veg: []),
            lunch: Meal(nonVeg: [], veg: []),
            snacks: Meal(nonVeg: [], veg: []),
            dinner: Meal(nonVeg: [], veg: []),
          ),
          tuesday: Meals(
            breakfast: Meal(nonVeg: [], veg: []),
            lunch: Meal(nonVeg: [], veg: []),
            snacks: Meal(nonVeg: [], veg: []),
            dinner: Meal(nonVeg: [], veg: []),
          ),
          wednesday: Meals(
            breakfast: Meal(nonVeg: [], veg: []),
            lunch: Meal(nonVeg: [], veg: []),
            snacks: Meal(nonVeg: [], veg: []),
            dinner: Meal(nonVeg: [], veg: []),
          ),
          thursday: Meals(
            breakfast: Meal(nonVeg: [], veg: []),
            lunch: Meal(nonVeg: [], veg: []),
            snacks: Meal(nonVeg: [], veg: []),
            dinner: Meal(nonVeg: [], veg: []),
          ),
          friday: Meals(
            breakfast: Meal(nonVeg: [], veg: []),
            lunch: Meal(nonVeg: [], veg: []),
            snacks: Meal(nonVeg: [], veg: []),
            dinner: Meal(nonVeg: [], veg: []),
          ),
          saturday: Meals(
            breakfast: Meal(nonVeg: [], veg: []),
            lunch: Meal(nonVeg: [], veg: []),
            snacks: Meal(nonVeg: [], veg: []),
            dinner: Meal(nonVeg: [], veg: []),
          ),
          sunday: Meals(
            breakfast: Meal(nonVeg: [], veg: []),
            lunch: Meal(nonVeg: [], veg: []),
            snacks: Meal(nonVeg: [], veg: []),
            dinner: Meal(nonVeg: [], veg: []),
          ),
        ),
      );

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
    print("Mess data loaded for ${mess.name}");
  }

  Future<bool> updateData(WidgetRef ref) async {
    print("Updating mess data...");
    return await updateMessData(ref);
  }

  void setMessData(MessMealDays newData) {
    state = newData;
  }
}

final messDataNotifier = StateNotifierProvider<MessDataProvider, MessMealDays>((
  ref,
) {
  return MessDataProvider();
});
