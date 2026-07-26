import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vit_b_mess/models/settings.dart';
import 'package:vit_b_mess/notification.dart';
import 'package:vit_b_mess/provider/settings.dart';
import 'package:vit_b_mess/screen/update.dart';
import 'package:vit_b_mess/widgets/about.dart';
import 'package:vit_b_mess/widgets/animated_page_background.dart';
import 'package:vit_b_mess/widgets/app_menu_button.dart';
import 'package:vit_b_mess/widgets/menu.dart';
import 'package:vit_b_mess/screen/notification_permission_screen.dart';
import 'package:vit_b_mess/widgets/preference.dart';
import 'package:vit_b_mess/mess_app_info.dart' as app_info;
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vit_b_mess/provider/mess_data.dart';

Future<bool> checkPermissionGranted() async {
  final notificationStatus = await Permission.notification.status;
  final alarmStatus = await Permission.scheduleExactAlarm.status;

  if (notificationStatus.isGranted && alarmStatus.isGranted) {
    return true;
  } else {
    return false;
  }
}

Future<String> checkLastUpdatedMessData(WidgetRef ref) async {
  final settings = ref.read(settingsNotifier.notifier).getSettings();
  final lastUpdatedOn = settings.dataLastUpdatedOn;
  if (lastUpdatedOn == null ||
      DateTime.now().difference(lastUpdatedOn).inDays >= 7) {
    log("Mess data last updated more than 7 days ago, updating mess data");
    String updateMessage = "";
    final updateInfo = await updateMessData(ref);
    settings.dataLastUpdatedOn = DateTime.now();
    await ref.read(settingsNotifier.notifier).saveSettings(settings);
    if (updateInfo[0] & updateInfo[1]) {
      updateMessage += "App Update Available and Mess Data Updated.";
    } else if (updateInfo[0]) {
      updateMessage += "App Update Available.";
    } else if (updateInfo[1]) {
      updateMessage += "Mess Data Updated.";
    } else {
      updateMessage = "No New Updates Available.";
    }
    return updateMessage;
  } else {
    log("Mess data is up to date, no need to update");
    return "";
  }
}

class Tabs extends ConsumerStatefulWidget {
  const Tabs({super.key});

  @override
  ConsumerState<Tabs> createState() => _TabsState();
}

class _TabsState extends ConsumerState<Tabs> {
  void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    if (await checkPermissionGranted()) {
      await fcm.requestPermission();
      fcm.subscribeToTopic('mess');
      log("Subscribed to 'mess' topic");
    } else {
      log("Notification permission not granted");
    }
  }

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsNotifier.notifier);
    settings.loadSettings().then((_) async {
      Settings currentSettings = settings.getSettings();
      if (currentSettings.notificationPermission == null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (ctx) => const NotificationPermissionScreen(),
            ),
          );
        }
      } else {
        final isGranted = await checkPermissionGranted();
        if (isGranted != currentSettings.notificationPermission) {
          currentSettings.notificationPermission = null;
          await settings.saveSettings(currentSettings);
        } else {
          if (currentSettings.notificationPermission == true) {
            notificationSetup();
          } else {
            cancelNotification();
          }
        }
      }
    });
    setupPushNotifications();
    checkLastUpdatedMessData(ref).then((message) {
      if (message.isNotEmpty && mounted) {
        final colorScheme = Theme.of(context).colorScheme;
        final bool isUpdate =
            message.contains("Update Available") || message.contains("Updated");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isUpdate ? Icons.check_circle : Icons.info,
                  color:
                      isUpdate
                          ? colorScheme.onPrimary
                          : colorScheme.onSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsNotifier);
    final colorScheme = Theme.of(context).colorScheme;

    if (settings.newUpdate!) {
      return const UpdateScreen();
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
        title: Row(
          children: [
                Hero(
                  tag: const ValueKey('Icon'),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.restaurant,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
            const SizedBox(width: 16),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "VIT-B Mess",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Your daily meal companion",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          AppMenuButton(
            showUpdate: settings.newUpdateVersion != settings.version,
            onUpdate: () async {
              final url = Uri.parse(app_info.releaseGithubLink);
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            },
            preferencesBuilder:
                (ctx) => const _SecondaryScreen(
                  title: 'Preferences',
                  titleIcon: Icons.tune_rounded,
                  body: Preference(),
                ),
            aboutBuilder:
                (ctx) => const _SecondaryScreen(
                  title: 'About',
                  titleIcon: Icons.info_outline_rounded,
                  body: About(),
                ),
          ),
        ],
      ),
      body: const AnimatedPageBackground(
        drift: true,
        child: Menu(),
      ),
    );
  }
}

class _SecondaryScreen extends StatelessWidget {
  const _SecondaryScreen({
    required this.title,
    required this.body,
    this.titleIcon,
  });

  final String title;
  final IconData? titleIcon;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: colorScheme.primary,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            if (titleIcon != null) ...[
              // Match dropdown menu row icon chip.
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  titleIcon,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Text(
                title,
                style: titleStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      body: body,
    );
  }
}
