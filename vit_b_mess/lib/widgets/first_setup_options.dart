import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_b_mess/mess_app_info.dart' as app_info;
import 'package:vit_b_mess/models/settings.dart';
import 'package:vit_b_mess/provider/mess_data.dart';
import 'package:vit_b_mess/provider/settings.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:vit_b_mess/screen/update.dart';

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
  bool _isLoading = false;

  Future onClickOkay() async {
    setState(() {
      _isLoading = true;
    });

    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No Internet Connection, Please connect to internet for first time setup",
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (selectedMess == null) {
      setState(() {
        _isLoading = false;
      });
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
    final settingsManager = ref.read(settingsNotifier.notifier);
    
    final Settings userSettings = settingsManager.getSettings();
    userSettings.hostelType = selectedHostel;
    userSettings.selectedMess = selectedMess!;
    userSettings.onlyVeg = isVeg;
    userSettings.isFirstBoot = false;
    userSettings.version = app_info.appVersion;
    userSettings.newUpdate = true;
    await settingsManager.saveSettings(userSettings);
    await ref.read(messDataNotifier.notifier).loadData(ref);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const UpdateScreen()),
    );
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
                    onPressed:
                        _isLoading
                            ? null
                            : () async {
                              await onClickOkay();
                            },
                    icon:
                        _isLoading
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                            : const Icon(Icons.check),
                    label: Text(_isLoading ? "Setting up..." : "Okay"),
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
