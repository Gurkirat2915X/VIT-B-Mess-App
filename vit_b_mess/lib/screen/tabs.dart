import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vit_b_mess/provider/settings.dart';
import 'package:vit_b_mess/screen/update.dart';
import 'package:vit_b_mess/widgets/about.dart';
import 'package:vit_b_mess/widgets/menu.dart';
import 'package:vit_b_mess/widgets/preference.dart';
import 'package:vit_b_mess/mess_app_info.dart' as app_info;

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
    final settings = ref.watch(settingsNotifier);

    if (settings.newUpdate!) {
      return UpdateScreen();
    }

    if (pageIndex == 0) {
      page = const Menu();
    } else if (pageIndex == 1) {
      page = const Preference();
    } else {
      page = const About();
    }

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
