import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:vit_b_mess/notification.dart';
import 'package:vit_b_mess/models/settings.dart';
import 'package:vit_b_mess/provider/mess_data.dart';
import 'package:vit_b_mess/provider/settings.dart';
import 'package:vit_b_mess/routines/mess_notification.dart';
import 'package:vit_b_mess/screen/notification_permission_screen.dart';
import 'package:vit_b_mess/screen/tabs.dart';
import 'package:vit_b_mess/widgets/animated_page_background.dart';

class Preference extends ConsumerStatefulWidget {
  const Preference({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PreferenceState();
  }
}

class _PreferenceState extends ConsumerState<Preference> {
  Settings? settings;
  Hostels? selectedHostel;
  MessType? selectedMess;
  bool? isVeg;
  bool allowSave = true;
  bool _isUpdating = false;
  bool? notificationEnabled;
  bool? useMaterialTheme;

  @override
  void initState() {
    super.initState();
    settings = ref.read(settingsNotifier);
    selectedHostel = settings!.hostelType;
    selectedMess = settings!.selectedMess;
    isVeg = settings!.onlyVeg;
    notificationEnabled = settings!.notificationPermission;
    useMaterialTheme = settings!.useMaterialTheme;
  }

  void onClickOkay() async {
    setState(() {
      allowSave = false;
    });
    if (selectedMess == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Theme.of(context).colorScheme.onError),
              const SizedBox(width: 8),
              const Text("Please Select a Mess"),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      setState(() {
        allowSave = true;
      });
      return;
    }
    if (notificationEnabled!) {
      bool isGranted = await checkPermissionGranted();
      if (!isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  const SizedBox(width: 8),
                  const Text("Please enable notifications in settings"),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (ctx) => const NotificationPermissionScreen(),
            ),
          );
        }
        return;
      }
      if (settings!.notificationPermission != notificationEnabled!) {
        notificationSetup(setup: true);
        dailyNotificationInitializer();
      }
    } else {
      cancelNotification();
    }
    final userSettings = Settings(
      isFirstBoot: false,
      hostelType: selectedHostel!,
      selectedMess: selectedMess!,
      onlyVeg: isVeg!,
      version: settings!.version,
      newUpdate: settings!.newUpdate,
      messDataVersion: settings!.messDataVersion,
      newUpdateVersion: settings!.newUpdateVersion,
      updatedTill: settings!.updatedTill,
      notificationPermission: notificationEnabled!,
      dataLastUpdatedOn: settings!.dataLastUpdatedOn,
      useMaterialTheme: useMaterialTheme ?? true,
    );

    if (userSettings == settings) {
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                const SizedBox(width: 8),
                const Text("No Changes Made"),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      setState(() {
        allowSave = true;
      });
      return;
    }
    await ref.read(settingsNotifier.notifier).saveSettings(userSettings);
    await ref.read(messDataNotifier.notifier).loadData(ref);
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(width: 8),
            const Text("Settings Saved"),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    settings = userSettings;
    setState(() {
      allowSave = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedPageBackground(
      drift: true,
      // Let the route transition settle so the curtain is visible.
      startDelay: const Duration(milliseconds: 180),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SurfaceCard(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Hostel Type", style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children:
                        Hostels.values
                            .map(
                              (hostel) => ChoiceChip(
                                label: Text(hostel.name),
                                selected: selectedHostel == hostel,
                                selectedColor: colorScheme.primaryContainer,
                                backgroundColor: colorScheme.surface,
                                labelStyle: TextStyle(
                                  color:
                                      selectedHostel == hostel
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurface,
                                ),
                                side: BorderSide(
                                  color:
                                      selectedHostel == hostel
                                          ? colorScheme.primary
                                          : colorScheme.outline.withValues(
                                            alpha: 0.2,
                                          ),
                                  width: selectedHostel == hostel ? 2 : 1,
                                ),
                                onSelected: (bool selected) {
                                  if (selected) {
                                    setState(() {
                                      selectedMess = null;
                                      selectedHostel = hostel;
                                    });
                                  }
                                },
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text("Select Mess", style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children:
                        MessType.getMess(selectedHostel!)
                            .map(
                              (mess) => ChoiceChip(
                                label: Text(mess.name),
                                selected: selectedMess == mess,
                                selectedColor: colorScheme.primaryContainer,
                                backgroundColor: colorScheme.surface,
                                labelStyle: TextStyle(
                                  color:
                                      selectedMess == mess
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurface,
                                ),
                                side: BorderSide(
                                  color:
                                      selectedMess == mess
                                          ? colorScheme.primary
                                          : colorScheme.outline.withValues(
                                            alpha: 0.2,
                                          ),
                                  width: selectedMess == mess ? 2 : 1,
                                ),
                                onSelected: (bool selected) {
                                  setState(() {
                                    selectedMess = mess;
                                  });
                                },
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: Text(
                      "Vegetarian Only",
                      style: textTheme.titleMedium,
                    ),
                    value: isVeg!,
                    onChanged: (bool value) {
                      setState(() {
                        isVeg = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: Text(
                      "Enable Notifications",
                      style: textTheme.titleMedium,
                    ),
                    value: notificationEnabled ?? false,
                    onChanged: (bool value) {
                      setState(() {
                        notificationEnabled = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: Text(
                      "Use System Color Scheme",
                      style: textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      "Use colors from your device",
                      style: textTheme.bodySmall,
                    ),
                    value: useMaterialTheme ?? true,
                    onChanged: (bool value) {
                      setState(() {
                        useMaterialTheme = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: allowSave ? onClickOkay : null,
                      child: const Text("Save Changes"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sync, color: colorScheme.primary, size: 28),
                const SizedBox(width: 8),
                Text(
                  "Data Sync",
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SurfaceCard(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "Server data updated: ${settings!.updatedTill}",
                    ),
                    trailing: IconButton(
                      icon:
                          _isUpdating
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.refresh),
                      color: colorScheme.primary,
                      onPressed: _isUpdating ? null : _updateMessData,
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  ListTile(
                    leading: Icon(Icons.schedule, color: colorScheme.primary),
                    title: Text(
                      "Weekly Update Checks",
                      style: textTheme.titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Menu data is automatically checked for updates weekly",
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        if (settings!.dataLastUpdatedOn != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "Last checked: ${settings!.dataLastUpdatedOn!.toString().split(' ')[0]}",
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _updateMessData() async {
    setState(() {
      _isUpdating = true;
    });
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "No Internet Connection. Please connect to fetch mess updates.",
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      setState(() {
        _isUpdating = false;
      });
      return;
    }
    final List<bool> updateInfo = await updateMessData(ref);
    var updateMessage = '';
    if (updateInfo[0] & updateInfo[1]) {
      updateMessage += "App Update Available and Mess Data Updated. ";
    } else if (updateInfo[0]) {
      updateMessage += "App Update Available. ";
    } else if (updateInfo[1]) {
      updateMessage += "Mess Data Updated. ";
    } else {
      updateMessage += "No New Updates Available. ";
    }
    if (updateInfo.length > 2 && updateInfo[2]) {
      updateMessage = "Error updating mess data. Please try again later.";
    }

    if (!mounted) return;
    setState(() {
      _isUpdating = false;
    });

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              updateInfo.length > 2 && updateInfo[2]
                  ? Icons.error
                  : updateInfo[0] || updateInfo[1]
                  ? Icons.check_circle
                  : Icons.info,
              color:
                  updateInfo.length > 2 && updateInfo[2]
                      ? Theme.of(context).colorScheme.onError
                      : updateInfo[0] || updateInfo[1]
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(updateMessage)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Opaque [Material] card so [ListTile]/[SwitchListTile] ink has a valid surface.
class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainer,
      elevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );
  }
}
