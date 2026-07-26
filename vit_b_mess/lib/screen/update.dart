import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_b_mess/mess_app_info.dart' as app_info;
import 'package:vit_b_mess/provider/settings.dart';
import 'package:vit_b_mess/screen/notification_permission_screen.dart';

class UpdateScreen extends ConsumerStatefulWidget {
  const UpdateScreen({super.key});

  @override
  ConsumerState<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends ConsumerState<UpdateScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _checkController;
  late AnimationController _glowController;
  late AnimationController _breathController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowScale;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    final glowCurved = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeOutCubic,
    );
    _glowScale = Tween<double>(begin: 0.35, end: 1).animate(glowCurved);
    _glowOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: const Interval(0, 0.55, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      _checkController.forward();
      // Same open + breathe glow as About, timed with the check mark.
      await _glowController.forward();
      if (mounted) _breathController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _checkController.dispose();
    _glowController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  Future<void> onClickOkay() async {
    final settings = ref.read(settingsNotifier);
    settings.newUpdate = false;
    settings.newUpdateVersion = app_info.appVersion;
    await ref.read(settingsNotifier.notifier).saveSettings(settings);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (ctx) => const NotificationPermissionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // App header — same logo chip as the main AppBar / About.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Icon(
                                Icons.restaurant,
                                size: 28,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "VIT-B Mess",
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 60),

                        // Success icon — radial glow opens then breathes (like About).
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: ScaleTransition(
                            scale: _checkAnimation,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  left: -88,
                                  top: -88,
                                  right: -88,
                                  bottom: -88,
                                  child: IgnorePointer(
                                    child: FadeTransition(
                                      opacity: _glowOpacity,
                                      child: ScaleTransition(
                                        scale: _glowScale,
                                        child: AnimatedBuilder(
                                          animation: _breathController,
                                          builder: (context, child) {
                                            final breath =
                                                _breathController.value;
                                            final scale = 1.0 + (0.08 * breath);
                                            final core = 0.20 + (0.06 * breath);
                                            final mid = 0.09 + (0.04 * breath);
                                            final outer =
                                                0.025 + (0.02 * breath);

                                            return Transform.scale(
                                              scale: scale,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: RadialGradient(
                                                    colors: [
                                                      colorScheme.primary
                                                          .withValues(
                                                            alpha: core,
                                                          ),
                                                      colorScheme.primary
                                                          .withValues(
                                                            alpha: mid,
                                                          ),
                                                      colorScheme.primary
                                                          .withValues(
                                                            alpha: outer,
                                                          ),
                                                      colorScheme.surface
                                                          .withValues(alpha: 0),
                                                    ],
                                                    stops: const [
                                                      0.0,
                                                      0.35,
                                                      0.65,
                                                      1.0,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface.withValues(
                                      alpha: 0.92,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    size: 80,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          "Successfully Updated!",
                          style: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Version ${app_info.appVersion}",
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // What's New — bordered surface card, no shadow.
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.restaurant,
                                      color: colorScheme.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "What's New",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                app_info.updateNotes,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  height: 1.6,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: onClickOkay,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ),
    );
  }
}
