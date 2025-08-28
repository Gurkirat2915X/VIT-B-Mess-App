import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeekDays extends ConsumerStatefulWidget {
  const WeekDays({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });
  final int selectedDay;
  final void Function(int) onDaySelected;

  @override
  ConsumerState<WeekDays> createState() => _WeekDaysState();
}

class _WeekDaysState extends ConsumerState<WeekDays> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late ScrollController _scrollController;
  
  bool _showLeftIndicator = false;
  bool _showRightIndicator = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
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
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    
    setState(() {
      _showLeftIndicator = currentScroll > 10;
      _showRightIndicator = currentScroll < maxScroll - 10;
    });
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SlideTransition(
      position: _slideAnimation.drive(
        Tween<Offset>(
          begin: const Offset(0, -0.5),
          end: Offset.zero,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) {
                  final isSelected = widget.selectedDay == index;
                  return _buildDayButton(context, index, isSelected);
                }),
              ),
            ),
            // Left scroll indicator
            if (_showLeftIndicator)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: _buildScrollIndicator(
                  colorScheme, 
                  isLeft: true,
                ),
              ),
            // Right scroll indicator
            if (_showRightIndicator)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: _buildScrollIndicator(
                  colorScheme, 
                  isLeft: false,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayButton(BuildContext context, int dayIndex, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return GestureDetector(
      onTap: () => widget.onDaySelected(dayIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? colorScheme.primary 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: textTheme.labelLarge?.copyWith(
            color: isSelected 
                ? colorScheme.onPrimary 
                : colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.5,
          ) ?? const TextStyle(),
          child: Text(dayNames[dayIndex]),
        ),
      ),
    );
  }

  Widget _buildScrollIndicator(ColorScheme colorScheme, {required bool isLeft}) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: 1.0,
      child: Container(
        width: 24,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
            colors: [
              colorScheme.surfaceContainer.withValues(alpha: 0.9),
              colorScheme.surfaceContainer.withValues(alpha: 0.0),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isLeft ? Icons.chevron_left : Icons.chevron_right,
              size: 14,
              color: colorScheme.primary.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
