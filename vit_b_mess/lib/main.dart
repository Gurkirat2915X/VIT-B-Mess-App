import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  await Hive.openBox<Settings>("mess_app_settings");
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider.notifier);
    return MaterialApp(
      title: 'VIT-B Mess',
      theme: messLightTheme,
      darkTheme: messDarkTheme,
      home: FutureBuilder(
        future: settings.loadSettings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading settings'));
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
