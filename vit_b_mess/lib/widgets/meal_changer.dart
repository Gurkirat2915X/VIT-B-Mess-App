import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_b_mess/models/meals.dart';

class MealChanger extends ConsumerWidget {
  const MealChanger({
    super.key,
    required this.currentMeals,
    required this.onMealChanged,
    required this.currentMeal,
  });
  final Meals currentMeals;
  final String currentMeal;
  final void Function(Meal, String) onMealChanged;
  final List<String> mealOptions = const [
    "Breakfast",
    "Lunch",
    "Snacks",
    "Dinner",
  ];

  void _handleMealSelection(String selectedMeal) {
    switch (selectedMeal) {
      case "Breakfast":
        onMealChanged(currentMeals.breakfast, selectedMeal);
        break;
      case "Lunch":
        onMealChanged(currentMeals.lunch, selectedMeal);
        break;
      case "Snacks":
        onMealChanged(currentMeals.snacks, selectedMeal);
        break;
      case "Dinner":
        onMealChanged(currentMeals.dinner, selectedMeal);
        break;
      default:
        throw Exception("Unknown meal time: $selectedMeal");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      width: double.infinity,
      child: SegmentedButton<String>(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return colorScheme.primaryContainer.withOpacity(0.5);
              }
              return theme.cardColor;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return colorScheme.primary;
              }
              return colorScheme.onSurface.withOpacity(0.7);
            },
          ),
          side: WidgetStatePropertyAll(
            BorderSide(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
        ),
        segments: mealOptions.map((meal) {
          return ButtonSegment<String>(value: meal, label: Text(meal));
        }).toList(),
        selected: {currentMeal},
        showSelectedIcon: false,
        onSelectionChanged: (Set<String> newSelection) {
          if (newSelection.isNotEmpty) {
            _handleMealSelection(newSelection.first);
          }
        
        },
      ),
    );
  }
}
