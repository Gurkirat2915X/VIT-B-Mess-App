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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _slideAnimation,
      child: Row(
        children: List.generate(7, (index) {
          final isSelected = widget.selectedDay == index;
          return Expanded(
            child: _buildDayButton(context, index, isSelected),
          );
        }),
      ),
    );
  }

  Widget _buildDayButton(BuildContext context, int dayIndex, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return GestureDetector(
      onTap: () => widget.onDaySelected(dayIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color:
                isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.2,
            fontSize: 15,
            inherit: false,
          ),
          child: Text(
            dayNames[dayIndex],
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
