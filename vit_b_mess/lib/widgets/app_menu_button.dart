import 'package:flutter/material.dart';

/// Themed AppBar overflow control with morphing icon and animated panel.
class AppMenuButton extends StatefulWidget {
  const AppMenuButton({
    super.key,
    required this.preferencesBuilder,
    required this.aboutBuilder,
    this.showUpdate = false,
    this.onUpdate,
  });

  final WidgetBuilder preferencesBuilder;
  final WidgetBuilder aboutBuilder;

  /// When true, shows a glowing badge on the button and an Update menu row.
  final bool showUpdate;
  final VoidCallback? onUpdate;

  @override
  State<AppMenuButton> createState() => _AppMenuButtonState();
}

class _AppMenuButtonState extends State<AppMenuButton>
    with TickerProviderStateMixin {
  late final AnimationController _iconController;
  late final AnimationController _glowController;
  final LayerLink _layerLink = LayerLink();
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.showUpdate) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AppMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showUpdate && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (!widget.showUpdate && _glowController.isAnimating) {
      _glowController
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_menuOpen) {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() => _menuOpen = true);

    await Navigator.of(context).push<void>(
      _AppMenuPopupRoute(
        link: _layerLink,
        iconController: _iconController,
        preferencesBuilder: widget.preferencesBuilder,
        aboutBuilder: widget.aboutBuilder,
        showUpdate: widget.showUpdate,
        onUpdate: widget.onUpdate,
        onClosed: () {
          if (!mounted) return;
          _iconController.value = 0;
          setState(() => _menuOpen = false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.18),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _toggle,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: AnimatedIcon(
                      icon: AnimatedIcons.menu_close,
                      progress: _iconController,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.showUpdate)
              Positioned(
                top: -2,
                right: -2,
                child: AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    final pulse = _glowController.value;
                    return Container(
                      width: 11 + (2 * pulse),
                      height: 11 + (2 * pulse),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(
                              alpha: 0.55 + (0.4 * pulse),
                            ),
                            blurRadius: 5 + (5 * pulse),
                            spreadRadius: 0.5 + pulse,
                          ),
                        ],
                        border: Border.all(
                          color: colorScheme.surfaceContainer,
                          width: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AppMenuPopupRoute extends PopupRoute<void> {
  _AppMenuPopupRoute({
    required this.link,
    required this.iconController,
    required this.preferencesBuilder,
    required this.aboutBuilder,
    required this.showUpdate,
    required this.onUpdate,
    required this.onClosed,
  });

  final LayerLink link;
  final AnimationController iconController;
  final WidgetBuilder preferencesBuilder;
  final WidgetBuilder aboutBuilder;
  final bool showUpdate;
  final VoidCallback? onUpdate;
  final VoidCallback onClosed;

  VoidCallback? _syncIcon;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss menu';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 280);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 200);

  @override
  TickerFuture didPush() {
    final result = super.didPush();
    _syncIcon = () {
      final value = animation?.value;
      if (value != null) iconController.value = value;
    };
    animation!.addListener(_syncIcon!);
    return result;
  }

  @override
  void dispose() {
    if (_syncIcon != null) {
      animation?.removeListener(_syncIcon!);
    }
    onClosed();
    super.dispose();
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _AppMenuPanel(
      link: link,
      animation: animation,
      preferencesBuilder: preferencesBuilder,
      aboutBuilder: aboutBuilder,
      showUpdate: showUpdate,
      onUpdate: onUpdate,
    );
  }
}

class _AppMenuPanel extends StatelessWidget {
  const _AppMenuPanel({
    required this.link,
    required this.animation,
    required this.preferencesBuilder,
    required this.aboutBuilder,
    required this.showUpdate,
    required this.onUpdate,
  });

  final LayerLink link;
  final Animation<double> animation;
  final WidgetBuilder preferencesBuilder;
  final WidgetBuilder aboutBuilder;
  final bool showUpdate;
  final VoidCallback? onUpdate;

  void _openPage(BuildContext context, WidgetBuilder builder) {
    final nav = Navigator.of(context);
    nav.pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nav.push<void>(MaterialPageRoute<void>(builder: builder));
    });
  }

  void _handleUpdate(BuildContext context) {
    final nav = Navigator.of(context);
    nav.pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onUpdate?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final panel = Material(
      color: colorScheme.surfaceContainer,
      elevation: 8,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 220),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Text(
                  'Quick links',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (showUpdate) ...[
                _MenuRow(
                  delay: 0.0,
                  animation: curved,
                  icon: Icons.system_update_rounded,
                  label: 'Update',
                  subtitle: 'New version available',
                  emphasize: true,
                  onTap: () => _handleUpdate(context),
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: colorScheme.outline.withValues(alpha: 0.12),
                ),
              ],
              _MenuRow(
                delay: showUpdate ? 0.08 : 0.05,
                animation: curved,
                icon: Icons.tune_rounded,
                label: 'Preferences',
                subtitle: 'Mess, veg, notifications',
                onTap: () => _openPage(context, preferencesBuilder),
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colorScheme.outline.withValues(alpha: 0.12),
              ),
              _MenuRow(
                delay: showUpdate ? 0.15 : 0.12,
                animation: curved,
                icon: Icons.info_outline_rounded,
                label: 'About',
                subtitle: 'Version & links',
                onTap: () => _openPage(context, aboutBuilder),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: FadeTransition(
                opacity: curved,
                child: ColoredBox(
                  color: colorScheme.scrim.withValues(alpha: 0.18),
                ),
              ),
            ),
          ),
          CompositedTransformFollower(
            link: link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, 10),
            child: FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.88, end: 1).animate(curved),
                alignment: Alignment.topRight,
                child: panel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.delay,
    required this.animation,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.emphasize = false,
  });

  final double delay;
  final Animation<double> animation;
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final itemAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(delay, 1, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: itemAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(itemAnimation),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(
                      alpha: emphasize ? 0.2 : 0.12,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        emphasize
                            ? Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.35),
                            )
                            : null,
                  ),
                  child: Icon(icon, color: colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  emphasize
                      ? Icons.open_in_new_rounded
                      : Icons.chevron_right_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
