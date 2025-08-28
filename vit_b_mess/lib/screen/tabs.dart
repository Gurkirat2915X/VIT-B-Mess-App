import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vit_b_mess/models/settings.dart';
import 'package:vit_b_mess/notification.dart';
import 'package:vit_b_mess/provider/settings.dart';
import 'package:vit_b_mess/screen/update.dart';
import 'package:vit_b_mess/widgets/about.dart';
import 'package:vit_b_mess/widgets/menu.dart';
import 'package:vit_b_mess/screen/notification_permission_screen.dart';
import 'package:vit_b_mess/widgets/preference.dart';
import 'package:vit_b_mess/mess_app_info.dart' as app_info;
import 'package:permission_handler/permission_handler.dart';
import "package:firebase_messaging/firebase_messaging.dart";

Future<bool> checkPermissionGranted() async {
  final notificationStatus = await Permission.notification.status;
  final alarmStatus = await Permission.scheduleExactAlarm.status;

  if (notificationStatus.isGranted && alarmStatus.isGranted) {
    return true;
  } else {
    return false;
  }
}

class Tabs extends ConsumerStatefulWidget {
  const Tabs({super.key});

  @override
  ConsumerState<Tabs> createState() => _TabsState();
}

class _TabsState extends ConsumerState<Tabs> {
  int pageIndex = 0;
  late PageController _pageController;

  void _onSelectBottom(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

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
    _pageController = PageController();
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsNotifier);
    final colorScheme = Theme.of(context).colorScheme;

    if (settings.newUpdate!) {
      return const UpdateScreen();
    }

    final List<Widget> pages = <Widget>[
      const Menu(),
      const Preference(),
      const About(),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 8,
        surfaceTintColor: colorScheme.primary.withValues(alpha: 0.08),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withValues(alpha: 0.1),
                colorScheme.secondary.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Hero(
                tag: const ValueKey("Icon"),
                child: Icon(
                  Icons.restaurant,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "VIT-B Mess",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "Your daily meal companion",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (settings.newUpdateVersion != settings.version)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: FilledButton.tonal(
                onPressed: () async {
                  Uri url = Uri.parse(app_info.releaseGithubLink);
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: const Size(0, 36),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.system_update_rounded, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      "Update",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.02),
              colorScheme.surface,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: PageView(
          controller: _pageController,
          physics: const ClampingScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              pageIndex = index;
            });
          },
          children: pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: pageIndex,
          onDestinationSelected: _onSelectBottom,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu),
              label: "Menu",
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_outlined),
              selectedIcon: Icon(Icons.tune),
              label: "Settings",
            ),
            NavigationDestination(
              icon: Icon(Icons.info_outline),
              selectedIcon: Icon(Icons.info),
              label: "About",
            ),
          ],
        ),
      ),
    );
  }
}
