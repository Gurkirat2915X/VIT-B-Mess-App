import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vit_b_mess/models/meals.dart';
import 'package:vit_b_mess/provider/settings.dart';

class MealWidget extends ConsumerStatefulWidget {
  const MealWidget({super.key, required this.currentMeal});
  final Meal currentMeal;

  @override
  ConsumerState<MealWidget> createState() => _MealWidgetState();
}

class _MealWidgetState extends ConsumerState<MealWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ScrollController _scrollController;
  
  bool _showTopIndicator = false;
  bool _showBottomIndicator = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollIndicators);
    _animationController.forward();
    
    // Check if scrolling is possible after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _updateScrollIndicators();
      }
    });
  }

  void _updateScrollIndicators() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    
    // Only show indicators if content is actually scrollable
    final isScrollable = maxScroll > 0;
    
    setState(() {
      _showTopIndicator = isScrollable && currentScroll > 20;
      _showBottomIndicator = isScrollable && currentScroll < maxScroll - 20;
    });
  }

  @override
  void didUpdateWidget(MealWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart animation when meal changes
    if (oldWidget.currentMeal != widget.currentMeal) {
      _animationController.reset();
      _animationController.forward();
      
      // Reset scroll position and update indicators for new meal
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
        // Update indicators after the content has rebuilt
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _updateScrollIndicators();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicators);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsNotifier);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate responsive dimensions
    final containerWidth = screenWidth > 600 
        ? screenWidth * 0.8 
        : screenWidth - 32; // 16px margin on each side
    final fixedHeight = screenHeight * 0.35; // 35% of screen height (reduced from 45%)
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(12),
          width: containerWidth,
          height: fixedHeight,
          constraints: const BoxConstraints(
            minHeight: 250,
            maxHeight: 350,
            maxWidth: 800,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surfaceContainerHighest,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Column(
                  children: [
                    // Fixed content area with scrolling
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Vegetarian section
                            if (widget.currentMeal.veg.isNotEmpty)
                              _buildModernSection(
                                context,
                                "Vegetarian",
                                Icons.eco_rounded,
                                colorScheme.tertiary,
                                widget.currentMeal.veg,
                                settings.onlyVeg,
                              ),
                            
                            if (widget.currentMeal.veg.isNotEmpty && 
                                widget.currentMeal.nonVeg.isNotEmpty && 
                                !settings.onlyVeg)
                              const SizedBox(height: 16),
                            
                            // Non-vegetarian section
                            if (widget.currentMeal.nonVeg.isNotEmpty && !settings.onlyVeg)
                              _buildModernSection(
                                context,
                                "Non-Vegetarian",
                                FontAwesomeIcons.drumstickBite,
                                colorScheme.error,
                                widget.currentMeal.nonVeg,
                                false,
                              ),
                            
                            // Empty state
                            if (widget.currentMeal.veg.isEmpty && 
                                (widget.currentMeal.nonVeg.isEmpty || settings.onlyVeg))
                              _buildEmptyState(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Top scroll indicator
                if (_showTopIndicator)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _buildScrollIndicator(
                      colorScheme,
                      isTop: true,
                    ),
                  ),
                // Bottom scroll indicator
                if (_showBottomIndicator)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildScrollIndicator(
                      colorScheme,
                      isTop: false,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernSection(
    BuildContext context,
    String title,
    IconData icon,
    Color accentColor,
    List<String> items,
    bool isHighlighted,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive padding based on screen size
    final horizontalPadding = screenWidth > 600 ? 16.0 : 12.0;
    final verticalPadding = screenWidth > 600 ? 16.0 : 12.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: isHighlighted 
            ? accentColor.withValues(alpha: 0.1)
            : colorScheme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: screenWidth > 600 ? 24 : 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                    fontSize: screenWidth > 600 ? 18 : 16,
                  ),
                ),
              ),
              if (isHighlighted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Preferred",
                    style: TextStyle(
                      fontSize: screenWidth > 600 ? 11 : 10,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: screenWidth > 600 ? 16 : 12),
          _buildItemsGrid(context, items, accentColor),
        ],
      ),
    );
  }

  Widget _buildItemsGrid(
    BuildContext context,
    List<String> items,
    Color accentColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final textTheme = Theme.of(context).textTheme;
    
    // Responsive spacing and sizing
    final spacing = screenWidth > 600 ? 8.0 : 6.0;
    final horizontalPadding = screenWidth > 600 ? 12.0 : 10.0;
    final verticalPadding = screenWidth > 600 ? 8.0 : 6.0;
    final fontSize = screenWidth > 600 ? 15.0 : 14.0;
    
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: spacing,
      runSpacing: spacing,
      children: items.map((item) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          constraints: BoxConstraints(
            minWidth: screenWidth > 600 ? 80 : 60,
            maxWidth: screenWidth * 0.4, // Max 40% of screen width
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            item,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
              fontSize: fontSize,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing
    final iconSize = screenWidth > 600 ? 56.0 : 40.0;
    final padding = screenWidth > 600 ? 32.0 : 24.0;
    final titleFontSize = screenWidth > 600 ? 20.0 : 18.0;
    final bodyFontSize = screenWidth > 600 ? 16.0 : 14.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: iconSize,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            "No items available",
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
              fontSize: titleFontSize,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check back later for today's menu",
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: bodyFontSize,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScrollIndicator(ColorScheme colorScheme, {required bool isTop}) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: Container(
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
            end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
            colors: [
              colorScheme.surface.withValues(alpha: 0.95),
              colorScheme.surface.withValues(alpha: 0.0),
            ],
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isTop ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  size: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  isTop ? "Scroll up" : "Scroll down",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
