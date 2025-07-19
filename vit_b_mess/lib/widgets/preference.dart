import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:vit_b_mess/notification.dart';
import 'package:vit_b_mess/models/settings.dart';
import 'package:vit_b_mess/provider/mess_data.dart';
import 'package:vit_b_mess/provider/settings.dart';
import 'package:vit_b_mess/screen/notification_permission_screen.dart';
import 'package:vit_b_mess/screen/tabs.dart';

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

  @override
  void initState() {
    super.initState();
    settings = ref.read(settingsNotifier);
    selectedHostel = settings!.hostelType;
    selectedMess = settings!.selectedMess;
    isVeg = settings!.onlyVeg;
    notificationEnabled = settings!.notificationPermission;
  }

  void onClickOkay() async {
    setState(() {
      allowSave = false;
    });
    if (selectedMess == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please Select a Mess"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (notificationEnabled!) {
      bool isGranted = await checkPermissionGranted();
      if (!isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please enable notifications in settings"),
              duration: Duration(seconds: 2),
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
      notificationSetup();
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
      notificationPermission: notificationEnabled,
    );

    if (userSettings == settings) {
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No Changes Made"),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    await ref.read(settingsNotifier.notifier).saveSettings(userSettings);
    await ref.read(messDataNotifier.notifier).loadData(ref);
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Settings Saved"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Preferences", style: textTheme.headlineMedium),
            const SizedBox(height: 16),
            Card(
              child: Padding(
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
            ),
            const SizedBox(height: 24),
            Text("Data Sync", style: textTheme.headlineMedium),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: Text("Last updated: ${settings!.updatedTill}"),
                trailing: IconButton(
                  icon:
                      _isUpdating
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.refresh),
                  color: colorScheme.primary,
                  onPressed: _isUpdating ? null : _updateMessData,
                ),
              ),
            ),
          ],
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
        const SnackBar(
          content: Text(
            "No Internet Connection. Please connect to fetch mess updates.",
          ),
        ),
      );
      setState(() {
        _isUpdating = false;
      });
      return;
    }
    final bool updated = await updateMessData(ref);

    if (!mounted) return;
    setState(() {
      _isUpdating = false;
    });

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated ? "Mess Data Updated" : "No New Mess Updates Available",
        ),
      ),
    );
  }
}
