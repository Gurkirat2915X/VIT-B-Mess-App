import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_b_mess/provider/mess_data.dart';
import 'package:vit_b_mess/provider/settings.dart';
import 'package:vit_b_mess/screen/first_boot.dart';
import 'package:vit_b_mess/screen/splash.dart';
import 'package:vit_b_mess/screen/tabs.dart';
import 'package:vit_b_mess/screen/update.dart';
import 'package:vit_b_mess/themes.dart';
import "package:vit_b_mess/hive_setup.dart";
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await hiveSetup();

  runApp(const ProviderScope(child: MyApp()));
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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: FutureBuilder(
        future: settings.loadSettings().then(
          (_) => {
            if (!ref.read(settingsNotifier).isFirstBoot)
              {messData.loadData(ref)},
          },
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading data'));
            }
            return Consumer(
              builder: (context, ref, _) {
                final settings = ref.watch(settingsNotifier);
                if (settings.isFirstBoot) {
                  return const FirstBootScreen();
                }
                if (settings.newUpdate == true) {
                  return const UpdateScreen();
                }
                return const Tabs();
              },
            );
          }
          return const SplashScreen();
        },
      ),
    );
  }
}
