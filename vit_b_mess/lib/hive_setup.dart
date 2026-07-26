import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:vit_b_mess/hive_registrar.g.dart';
import 'package:vit_b_mess/models/meals.dart';
import 'package:vit_b_mess/models/settings.dart';

Future<void> hiveSetup() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapters();
  }

  await Hive.openBox<Settings>("mess_app_settings");
  await Hive.openBox<MessMealDays>("mess_app_data");
}
