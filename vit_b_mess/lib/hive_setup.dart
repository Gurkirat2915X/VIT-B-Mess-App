import 'package:hive_flutter/hive_flutter.dart';
import 'package:vit_b_mess/models/meals.dart';
import 'package:vit_b_mess/models/settings.dart';
import 'package:vit_b_mess/provider/mess_data.dart';

Future<void> hiveSetup() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(HostelsAdapter());
  Hive.registerAdapter(MessTypeAdapter());
  Hive.registerAdapter(MealAdapter());
  Hive.registerAdapter(MealsAdapter());
  Hive.registerAdapter(MessMealDaysAdapter());

  await Hive.openBox<Settings>("mess_app_settings");
  await Hive.openBox<MessMealDays>("mess_app_data");
}
