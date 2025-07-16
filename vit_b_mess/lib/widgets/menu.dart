import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_b_mess/models/meals.dart';
import 'package:vit_b_mess/provider/mess_data.dart';
import 'package:vit_b_mess/provider/settings.dart';
import 'package:vit_b_mess/widgets/meal.dart';
import 'package:vit_b_mess/widgets/meal_changer.dart';
import 'package:vit_b_mess/widgets/week_days.dart';

class Menu extends ConsumerStatefulWidget {
  const Menu({super.key});

  @override
  ConsumerState<Menu> createState() => _MenuState();
}

class _MenuState extends ConsumerState<Menu> {
  Meals? messMenu;
  DateTime todayDate = DateTime.now();
  Meal? currentMeal;

  int todayIndex = 0;

  String currentMealTime = "";
  @override
  void initState() {
    super.initState();
    todayIndex = todayDate.weekday - 1;
    messMenu = ref.read(messDataNotifier.notifier).getDayMeal(todayIndex);
    currentMeal = getCurrentMeal(messMenu!);
    currentMealTime = getMealTimeString;
    print(ref.read(settingsNotifier).updatedTill);
  }

  Meal getCurrentMeal(Meals meals) {
    final currentTime = DateTime.now();
    if (currentTime.hour < 10) {
      return meals.breakfast;
    } else if (currentTime.hour < 15) {
      return meals.lunch;
    } else if (currentTime.hour < 18) {
      return meals.snacks;
    } else {
      return meals.dinner;
    }
  }

  String get getMealTimeString {
    if (todayDate.hour < 10) {
      return "Breakfast";
    } else if (todayDate.hour < 15) {
      return "Lunch";
    } else if (todayDate.hour < 18) {
      return "Snacks";
    } else {
      return "Dinner";
    }
  }

  void changeDay(int day) {
    setState(() {
      todayIndex = day;
      messMenu = ref.read(messDataNotifier.notifier).getDayMeal(day);
      currentMeal = getCurrentMeal(messMenu!);
      currentMealTime = getMealTimeString;
    });
  }

  void changeMeal(Meal meal, String mealTime) {
    setState(() {
      currentMeal = meal;
      currentMealTime = mealTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "${ref.watch(settingsNotifier).selectedMess.name}'s Menu",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          WeekDays(selectedDay: todayIndex, onDaySelected: changeDay),
          const SizedBox(height: 20),
          MealWidget(currentMeal: currentMeal!),
          const SizedBox(height: 20),
          MealChanger(
            currentMeals: messMenu!,
            onMealChanged: changeMeal,
            currentMeal: currentMealTime,
          ),
        ],
      ),
    );
  }
}
