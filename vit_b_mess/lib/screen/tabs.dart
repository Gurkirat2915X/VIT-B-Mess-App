import 'package:flutter/material.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {

  int pageIndex = 1;

  void _onSelectBottom(int index){
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: Text("This is the menu"),
      ),
     bottomNavigationBar: BottomNavigationBar(currentIndex: pageIndex,
     onTap: _onSelectBottom,
     items: [
      BottomNavigationBarItem(icon: Icon(Icons.food_bank_rounded),label: "Menu"),
      BottomNavigationBarItem(icon: Icon(Icons.settings_applications),label: "Preference"),
      BottomNavigationBarItem(icon: Icon(Icons.info),label: "About")
     ],
     ),
    );
  }
}
