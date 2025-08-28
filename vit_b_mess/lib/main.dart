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

  Future<void> _initialize(WidgetRef ref) async {
    try {
      final settings = ref.read(settingsNotifier.notifier);
      await settings.loadSettings();

      if (!ref.read(settingsNotifier).isFirstBoot) {
        final messData = ref.read(messDataNotifier.notifier);
        await messData.loadData(ref);
      }
    } catch (e) {
      debugPrint('Error during initialization: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'VIT-B Mess',
      theme: messLightTheme,
      darkTheme: messDarkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Ensure consistent text scaling and handle MediaQuery constraints
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: FutureBuilder(
        future: _initialize(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Oops! Something went wrong',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please restart the app to try again',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Restart App'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
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
        },
      ),
    );
  }
}
