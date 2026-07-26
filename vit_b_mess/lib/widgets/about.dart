import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_b_mess/mess_app_info.dart' as app_info;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class About extends ConsumerStatefulWidget {
  const About({super.key});

  @override
  ConsumerState<About> createState() => _AboutState();
}

class _AboutState extends ConsumerState<About> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: const ValueKey("Icon"),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.restaurant,
                  size: 50,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "VIT-B Mess",
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            _SurfaceCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text("Version", style: textTheme.titleMedium),
                    subtitle: Text(app_info.appVersion),
                  ),
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
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
            _SurfaceCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const FaIcon(FontAwesomeIcons.whatsapp),
                    title: Text("WhatsApp Group", style: textTheme.titleMedium),
                    subtitle: const Text("Join the community"),
                    onTap: () async {
                      final Uri url = Uri.parse(app_info.whatsappGroupLink);
                      if (!await launchUrl(url)) {
                        throw Exception('Could not launch $url');
                      }
                    },
                  ),
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit_document),
                    title: Text(
                      "Suggestions Form",
                      style: textTheme.titleMedium,
                    ),
                    subtitle: const Text("Share your feedback"),
                    onTap: () async {
                      final Uri url = Uri.parse(app_info.suggestionsFormLink);
                      if (!await launchUrl(url)) {
                        throw Exception('Could not launch $url');
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SurfaceCard(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Update Notes",
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(app_info.updateNotes, style: textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SurfaceCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text("Developed by", style: textTheme.titleMedium),
                    subtitle: Text(app_info.developedBy),
                  ),
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
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
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opaque [Material] card so [ListTile] ink splashes have a valid surface.
class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainer,
      elevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );
  }
}
