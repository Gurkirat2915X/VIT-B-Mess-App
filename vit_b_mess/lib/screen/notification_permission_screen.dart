import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_b_mess/provider/settings.dart';
import "package:permission_handler/permission_handler.dart";
import "package:vit_b_mess/models/settings.dart";
import "package:vit_b_mess/screen/tabs.dart";

class NotificationPermissionScreen extends ConsumerStatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  ConsumerState<NotificationPermissionScreen> createState() {
    return _NotificationPermissionScreenState();
  }
}

class _NotificationPermissionScreenState
    extends ConsumerState<NotificationPermissionScreen> {
  bool isLoading = false;
  Settings? settings;
  @override
  void initState() {
    super.initState();
    settings = ref.read(settingsNotifier.notifier).getSettings();
  }

  void requestNotificationPermission(WidgetRef ref) async {
    final status = await Permission.notification.request();
    print("Notification permission status: $status");
    if (status.isGranted) {
      final alarmStatus = await Permission.scheduleExactAlarm.request();
      print("Schedule Exact Alarm permission status: $alarmStatus");
      if (alarmStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notification permission granted")),
        );
        setState(() {
          settings!.notificationPermission = true;
        });
        print(settings!.notificationPermission);
        await ref.read(settingsNotifier.notifier).saveSettings(settings!);
        Navigator.of(
          context,
        ).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => const Tabs(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Schedule Exact Alarm permission denied"),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notification permission denied")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Notification Permission",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "To receive notifications about mess updates, please enable notification permissions in your device settings.",
                  ),
                  const SizedBox(height: 16),

                  if (settings!.notificationPermission == true) ...[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (ctx) => const Tabs()),
                        );
                      },
                      child: const Text("Continue"),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Notification permission is already granted.",
                      style: TextStyle(color: Colors.green),
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: () {
                        requestNotificationPermission(ref);
                      },
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text("Request Permission"),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        settings!.notificationPermission = false;
                        await ref
                            .read(settingsNotifier.notifier)
                            .saveSettings(settings!);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (ctx) => const Tabs()),
                        );
                      },
                      child: const Text("Skip"),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
