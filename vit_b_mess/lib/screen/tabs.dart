import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_b_mess/provider/settings.dart';
import 'package:vit_b_mess/screen/update.dart';
import 'package:vit_b_mess/widgets/about.dart';
import 'package:vit_b_mess/widgets/preference.dart';

class Tabs extends ConsumerStatefulWidget {
  const Tabs({super.key});

  @override
  ConsumerState<Tabs> createState() => _TabsState();
}

class _TabsState extends ConsumerState<Tabs> {
  int pageIndex = 0;
  Widget? page;
  void _onSelectBottom(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    if (settings.newUpdate!) {
      return UpdateScreen();
    }

    if (pageIndex == 0) {
      page = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Hostel: ${settings.hostelType.name}"),
            Text("Mess: ${settings.selectedMess.name}"),
            Text("Only Veg: ${settings.onlyVeg}"),
            Text("Version: ${settings.version}"),
            Text("First Boot: ${settings.isFirstBoot}"),
            Text("New Update: ${settings.newUpdate}"),
          ],
        ),
      );
    } else if (pageIndex == 1) {
      page = const Preference();
    } else {
      page = const About();
    }

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color(0xFF4CAF50),
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
      body: page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: _onSelectBottom,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank_rounded),
            label: "Menu",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_applications),
            label: "Preference",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
        ],
      ),
    );
  }
}
