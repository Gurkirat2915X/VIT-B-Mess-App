import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_b_mess/provider/mess_data.dart';
import 'package:vit_b_mess/screen/tabs.dart';

class FirstSetupOptions extends ConsumerStatefulWidget {
  const FirstSetupOptions({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _FirstSetupOptionsState();
  }
}

class _FirstSetupOptionsState extends ConsumerState<FirstSetupOptions> {
  Hostels selected_hostel = Hostels.Boys;
  int mess = 0;
  Widget? available_mess;
  dynamic selected_mess;
  bool isVeg = false;

  void onClickOkay(){
    if(selected_mess == null){
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Select a Mess"),duration: Duration(seconds: 2),)
      );
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx)=>const Tabs()));
  }

  @override
  Widget build(BuildContext context) {
    selected_hostel == Hostels.Boys ? mess = 0 : mess = 1;

    if (mess == 0) {
      if (selected_mess is! BoysMess) selected_mess = null;
      available_mess = Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0,
        children:
            BoysMess.values
                .map(
                  (mess) => ChoiceChip(
                    label: Text(mess.name),
                    selected: selected_mess == mess,
                    onSelected: (bool selected) {
                      setState(() {
                        selected_mess = mess;
                      });
                    },
                  ),
                )
                .toList(),
      );
    } else {
      if (selected_mess is! GirlsMess) selected_mess = null;
      available_mess = Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0,
        children:
            GirlsMess.values
                .map(
                  (mess) => ChoiceChip(
                    label: Text(mess.name),
                    selected: selected_mess == mess,
                    onSelected: (bool selected) {
                      setState(() {
                        selected_mess = mess;
                      });
                    },
                  ),
                )
                .toList(),
      );
    }

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
                                selected: selected_hostel == hostel,
                                onSelected: (bool selected) {
                                  if (selected) {
                                    setState(() {
                                      selected_hostel = hostel;
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
                    child: available_mess!),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Only Veg"),
                      Checkbox(
                        value: isVeg,
                        onChanged: (value) {
                          setState(() {
                            isVeg = !isVeg;
                          });
                        },
                      ),
                    ],
                  ),
                  FilledButton.tonalIcon(onPressed:onClickOkay, label: Text("Okay"),)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
