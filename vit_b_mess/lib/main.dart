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
import 'package:dynamic_color/dynamic_color.dart';

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
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'VIT-B Mess',
          theme: AppThemes.createLightTheme(lightDynamic),
          darkTheme: AppThemes.createDarkTheme(darkDynamic),
          themeMode: ThemeMode.system, 
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
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
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Oops! Something went wrong',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please restart the app to try again',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
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
      },
    );
  }
}
