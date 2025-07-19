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
      print("Subscribed to 'mess' topic");
    } else {
      print("Notification permission not granted");
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => const NotificationPermissionScreen(),
          ),
        );
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

    if (settings.newUpdate!) {
      return const UpdateScreen();
    }

    final List<Widget> pages = [
      const Menu(),
      const Preference(),
      const About(),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (settings.newUpdateVersion != settings.version)
            TextButton.icon(
              onPressed: () async {
                Uri url = Uri.parse(app_info.releaseGithubLink);
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              },
              label: Text(
                "Update Available",
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(Icons.system_update_rounded, color: Colors.white),
            ),
        ],
        title: Row(
          children: [
            Hero(
              tag: ValueKey("Icon"),
              child: Icon(
                Icons.dining,
                color: Theme.of(context).colorScheme.primary,
                size: 40,
              ),
            ),
            SizedBox(width: 10),
            Text("VIT-B Mess"),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            pageIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        labelBehavior:
            NavigationDestinationLabelBehavior
                .onlyShowSelected, // Optional: cleaner UI
        selectedIndex: pageIndex,
        onDestinationSelected: _onSelectBottom,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.food_bank_outlined),
            selectedIcon: Icon(Icons.food_bank_rounded),
            label: "Menu",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_applications_outlined),
            selectedIcon: Icon(Icons.settings_applications),
            label: "Preference",
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: "About",
          ),
        ],
      ),
    );
  }
}
