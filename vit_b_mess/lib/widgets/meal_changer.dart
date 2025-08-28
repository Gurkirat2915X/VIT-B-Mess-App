import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_b_mess/models/meals.dart';

class MealChanger extends ConsumerStatefulWidget {
  const MealChanger({
    super.key,
    required this.currentMeals,
    required this.onMealChanged,
    required this.currentMeal,
  });
  final Meals currentMeals;
  final String currentMeal;
  final void Function(Meal, String) onMealChanged;

  @override
  ConsumerState<MealChanger> createState() => _MealChangerState();
}

class _MealChangerState extends ConsumerState<MealChanger>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> mealOptions = [
    {'name': 'Breakfast', 'icon': Icons.free_breakfast},
    {'name': 'Lunch', 'icon': Icons.lunch_dining},
    {'name': 'Snacks', 'icon': Icons.cookie},
    {'name': 'Dinner', 'icon': Icons.dinner_dining},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleMealSelection(String selectedMeal) {
    switch (selectedMeal) {
      case "Breakfast":
        widget.onMealChanged(widget.currentMeals.breakfast, selectedMeal);
        break;
      case "Lunch":
        widget.onMealChanged(widget.currentMeals.lunch, selectedMeal);
        break;
      case "Snacks":
        widget.onMealChanged(widget.currentMeals.snacks, selectedMeal);
        break;
      case "Dinner":
        widget.onMealChanged(widget.currentMeals.dinner, selectedMeal);
        break;
      default:
        throw Exception("Unknown meal time: $selectedMeal");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children:
              mealOptions.map((meal) {
                final isSelected = widget.currentMeal == meal['name'];
                return Expanded(
                  child: _buildMealOption(context, meal, isSelected),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildMealOption(
    BuildContext context,
    Map<String, dynamic> meal,
    bool isSelected,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _handleMealSelection(meal['name']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? colorScheme.onPrimary.withValues(alpha: 0.2)
                        : colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                meal['icon'] as IconData,
                color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                size: 16,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style:
                  textTheme.labelMedium?.copyWith(
                    color:
                        isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface.withValues(alpha: 0.8),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 10,
                  ) ??
                  const TextStyle(),
              child: Text(meal['name'], textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
