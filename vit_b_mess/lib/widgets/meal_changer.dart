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
  final void Function(Meal,String) onMealChanged;
  final List<String> mealOptions = const [
    "Breakfast",
    "Lunch",
    "Snacks",
    "Dinner",
  ];
  
  void onClick(String time) {
    // This function can be used to handle any additional logic when a meal is selected.
    // Currently, it is not used in this widget.
    switch (time) {
      case "Breakfast":
        onMealChanged(currentMeals.breakfast, time);
        break;
      case "Lunch":
        onMealChanged(currentMeals.lunch, time);
        break;
      case "Snacks":
        onMealChanged(currentMeals.snacks, time);
        break;
      case "Dinner":
        onMealChanged(currentMeals.dinner, time);
        break;
      default:
        throw Exception("Unknown meal time: $time");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
      width: double.infinity,
      child: SegmentedButton<String>(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
        segments:
            mealOptions.map((meal) {
              return ButtonSegment<String>(value: meal, label: Text(meal));
            }).toList(),
        selected: {currentMeal},
        showSelectedIcon: false,
        onSelectionChanged: (Set<String> newSelection) {
          if (newSelection.isNotEmpty) {
            final selectedMeal = newSelection.first;
            print("Selected meal: $selectedMeal");
            onClick(selectedMeal);
          }
        },
      ),
    );
  }
}
