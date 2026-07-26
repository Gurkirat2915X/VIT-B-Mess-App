import 'package:flutter/material.dart';
import 'package:vit_b_mess/widgets/animated_page_background.dart';
import 'package:vit_b_mess/widgets/first_setup_options.dart';

class FirstBootScreen extends StatefulWidget {
  const FirstBootScreen({super.key});

  @override
  State<FirstBootScreen> createState() => _FirstBootScreenState();
}

class _FirstBootScreenState extends State<FirstBootScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final AnimationController _iconController;
  late final AnimationController _glowController;
  late final AnimationController _breathController;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _iconAnimation;
  late final Animation<double> _glowScale;
  late final Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
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
    _iconController.forward();
    Future<void>.delayed(const Duration(milliseconds: 280), () async {
      if (!mounted) return;
      await _glowController.forward();
      if (mounted) _breathController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _iconController.dispose();
    _glowController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: AnimatedPageBackground(
        drift: true,
        startDelay: const Duration(milliseconds: 80),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _iconAnimation,
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
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.25,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 64,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            "Welcome to",
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "VIT-B Mess",
                            style: Theme.of(
                              context,
                            ).textTheme.headlineLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Text(
                              "Your daily meal companion",
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 48),
                          const FirstSetupOptions(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
