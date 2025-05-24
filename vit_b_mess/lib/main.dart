import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vit_b_mess/models/meals.dart';
import 'package:vit_b_mess/models/settings.dart';
import 'package:vit_b_mess/provider/mess_data.dart';
import 'package:vit_b_mess/provider/settings.dart';
import 'package:vit_b_mess/screen/first_boot.dart';
import 'package:vit_b_mess/screen/splash.dart';
import 'package:vit_b_mess/screen/tabs.dart';
import 'package:vit_b_mess/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(HostelsAdapter());
  Hive.registerAdapter(MessTypeAdapter());
  Hive.registerAdapter(MealAdapter());
  Hive.registerAdapter(MealsAdapter());
  Hive.registerAdapter(MessMealDaysAdapter());

  await Hive.openBox<Settings>("mess_app_settings");
  await Hive.openBox<MessMealDays>("mess_app_data");
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifier.notifier);
    final messData = ref.watch(messDataNotifier.notifier);
    return MaterialApp(
      title: 'VIT-B Mess',
      theme: messLightTheme,
      darkTheme: messDarkTheme,
      home: FutureBuilder(
        future: settings.loadSettings().then((_) => {
          if(!ref.read(settingsNotifier).isFirstBoot){
            messData.loadData(ref)
          }
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading data'));
            } else if (settings.getSetting().isFirstBoot) {
              return const FirstBootScreen();
            } else {
              return const Tabs();
            }
          }
          return const SplashScreen();
        },
      ),
    );
  }
}
