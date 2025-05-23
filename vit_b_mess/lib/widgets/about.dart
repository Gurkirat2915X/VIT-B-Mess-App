import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_b_mess/mess_app_info.dart' as app_info;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class About extends ConsumerWidget {
  const About({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dining,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(width: 10),
              Text(
                "VIT B Mess",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Repo:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 5),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.github),
                onPressed: () async {
                  final Uri url = Uri.parse(app_info.projectLink);
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                tooltip: 'GitHub',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Version: ${app_info.appVersion}",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text("Update Notes", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: SingleChildScrollView(child: Text(app_info.updateNotes)),
          ),
          const SizedBox(height: 20),
          Text(
            "Developed by: ${app_info.developedBy}",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(width: 16),
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
          const SizedBox(height: 10),
          Text(
            "This app is not affiliated with VIT.",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
