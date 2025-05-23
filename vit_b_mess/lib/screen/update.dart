import 'package:flutter/Material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_b_mess/mess_app_info.dart' as app_info;
import 'package:vit_b_mess/provider/settings.dart';
import 'package:vit_b_mess/screen/tabs.dart';

class UpdateScreen extends ConsumerStatefulWidget {
  const UpdateScreen({super.key});

  @override
  ConsumerState<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends ConsumerState<UpdateScreen> {
  Future<void> onClickOkay() async {
    final settings = ref.read(settingsProvider);
    settings.newUpdate = false;
    await ref.read(settingsProvider.notifier).saveSettings(settings);
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (ctx) => const Tabs()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: ValueKey("Icon"),
                  child: Icon(
                    Icons.dining,
                    size: 50,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "VIT B Mess",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),

            Text(
              "Updated to ${app_info.appVersion}",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              "Version Notes",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 100,
              child: SingleChildScrollView(child: Text(app_info.updateNotes)),
            ),
            ElevatedButton(onPressed: onClickOkay, child: Text("Okay")),
          ],
        ),
      ),
    );
  }
}
