import 'package:flutter/material.dart';
import 'package:vit_b_mess/widgets/first_setup_options.dart';

class FirstBootScreen extends StatelessWidget {
  const FirstBootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: ValueKey("Icon"),
              child: Icon(
                Icons.dining,
                size: 150,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Welcome to VIT-B Mess",
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 20,),
            FirstSetupOptions()
          ],
        ),
      ),
    );
  }
}
