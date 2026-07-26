import 'package:flutter/material.dart';

/// Soft page wash (`primary` ~2% → `surface`).
///
/// On open, the gradient curtain drops from above into place, then optionally
/// [drift]s the fade-out stop. Painted in a [Positioned.fill] layer so it
/// never affects layout or gesture hit-testing.
class AnimatedPageBackground extends StatefulWidget {
  const AnimatedPageBackground({
    super.key,
    required this.child,
    this.drift = false,
    this.startDelay = Duration.zero,
  });

  final Widget child;

  /// Slowly shifts the fade-out stop after the curtain lands.
  final bool drift;

  /// Wait before starting (e.g. let a route transition finish).
  final Duration startDelay;

  @override
  State<AnimatedPageBackground> createState() => _AnimatedPageBackgroundState();
}

class _AnimatedPageBackgroundState extends State<AnimatedPageBackground>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _driftController;
  late final Animation<double> _fall;
  late final Animation<double> _settleAlpha;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    );

    _fall = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    _settleAlpha = Tween<double>(begin: 0.10, end: 0.02).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.35, 1, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.startDelay > Duration.zero) {
        await Future<void>.delayed(widget.startDelay);
      }
      if (!mounted) return;
      await _introController.forward();
      if (!mounted || !widget.drift) return;
      _driftController.value = 0.5;
      _driftController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : MediaQuery.sizeOf(context).height;

          return Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _introController,
                      _driftController,
                    ]),
                    builder: (context, child) {
                      final t = _fall.value;
                      // Curtain starts above the body and drops into place.
                      final dy = (1 - t) * -height;

                      final driftT =
                          widget.drift && _driftController.isAnimating
                              ? _driftController.value
                              : 0.5;
                      final endStop = 0.25 + (0.10 * driftT);
                      final topAlpha =
                          _introController.isCompleted
                              ? 0.02
                              : _settleAlpha.value;

                      return Transform.translate(
                        offset: Offset(0, dy),
                        transformHitTests: false,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                colorScheme.primary.withValues(alpha: topAlpha),
                                colorScheme.surface,
                              ],
                              stops: [0.0, endStop],
                            ),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              widget.child,
            ],
          );
        },
      ),
    );
  }
}
