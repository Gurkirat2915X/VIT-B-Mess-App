import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_b_mess/mess_app_info.dart' as app_info;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class About extends ConsumerWidget {
  const About({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: const ValueKey("Icon"),
              child: Icon(
                Icons.dining,
                size: 50,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "VIT-B Mess",
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text("Version", style: textTheme.titleMedium),
                    subtitle: Text(app_info.appVersion),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const FaIcon(FontAwesomeIcons.github),
                    title: Text("Source Code", style: textTheme.titleMedium),
                    subtitle: const Text("View on GitHub"),
                    onTap: () async {
                      final Uri url = Uri.parse(app_info.projectLink);
                      if (!await launchUrl(url)) {
                        throw Exception('Could not launch $url');
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Update Notes", style: textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Text(app_info.updateNotes, style: textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text("Developed by", style: textTheme.titleMedium),
                    subtitle: Text(app_info.developedBy),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.github),
                          onPressed: () async {
                            final Uri url = Uri.parse(app_info.githubLink);
                            if (!await launchUrl(url)) {
                              throw Exception('Could not launch $url');
                            }
                          },
                          tooltip: 'GitHub',
                        ),
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.linkedin),
                          onPressed: () async {
                            final Uri url = Uri.parse(app_info.linkedInLink);
                            if (!await launchUrl(url)) {
                              throw Exception('Could not launch $url');
                            }
                          },
                          tooltip: 'LinkedIn',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "This app is not affiliated with VIT.",
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
