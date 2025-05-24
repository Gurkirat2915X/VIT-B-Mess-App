import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_b_mess/mess_app_info.dart' as app_info;
import 'package:vit_b_mess/models/settings.dart';
import 'package:vit_b_mess/provider/mess_data.dart';
import 'package:vit_b_mess/provider/settings.dart';
import 'package:vit_b_mess/screen/tabs.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class FirstSetupOptions extends ConsumerStatefulWidget {
  const FirstSetupOptions({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _FirstSetupOptionsState();
  }
}

class _FirstSetupOptionsState extends ConsumerState<FirstSetupOptions> {
  Hostels selectedHostel = Hostels.Boys;
  MessType? selectedMess;
  bool isVeg = false;

  void onClickOkay() async {
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No Internet Connection, Please connect to internet for first time setup"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (selectedMess == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please Select a Mess"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final userSettings = Settings(
      isFirstBoot: false,
      hostelType: selectedHostel,
      selectedMess: selectedMess!,
      onlyVeg: isVeg,
      version: app_info.appVersion,
      newUpdate: true,
      messDataVersion: "0",
      newUpdateVersion: app_info.appVersion,
    );

    await ref.read(settingsNotifier.notifier).saveSettings(userSettings);
    await ref.read(messDataNotifier.notifier).loadData(ref);

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (ctx) => const Tabs()));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Hostel Type:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
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
                  SizedBox(height: 8),
                  const Text("Select Mess"),
                  SizedBox(
                    height: 100,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16.0,

                      children:
                          MessType.getMess(selectedHostel)
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Only Veg"),
                      const SizedBox(width: 8),
                      Switch(
                        value: isVeg,
                        onChanged: (bool value) {
                          setState(() {
                            isVeg = value;
                          });
                        },
                      ),
                    ],
                  ),
                  FilledButton.tonalIcon(
                    onPressed: onClickOkay,
                    label: Text("Okay"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
