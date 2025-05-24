import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_b_mess/models/settings.dart';
import 'package:vit_b_mess/provider/mess_data.dart';
import 'package:vit_b_mess/provider/settings.dart';


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
  @override
  void initState() {
    super.initState();
    settings = ref.read(settingsNotifier);
    selectedHostel = settings!.hostelType;
    selectedMess = settings!.selectedMess;
    isVeg = settings!.onlyVeg;
  }

  void onClickOkay() async{
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
      setState(() {
        allowSave = true;
      });
      return;
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
    );

    if (userSettings == settings) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No Changes Made"),
          duration: Duration(seconds: 2),
        ),
      );
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
      const SnackBar(
        content: Text("Settings Saved"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          Text(
            "Preferences",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Hostel Type:",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
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
                    const SizedBox(height: 8),
                    const Text("Select Mess"),
                    SizedBox(
                      height: 100,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16.0,
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
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Only Veg"),
                    SizedBox(width: 8,),
                    Switch(
                      value: isVeg!,
                      onChanged: (bool value) {
                        setState(() {
                          isVeg = value;
                        });
                      },
                    ),
                      ],
                    ),
                    FilledButton.tonalIcon(
                    onPressed: allowSave ? onClickOkay : null,
                    label: Text("Okay"),
                    

                  ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
