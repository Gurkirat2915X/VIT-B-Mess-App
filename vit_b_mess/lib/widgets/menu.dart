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
  int _previousDayIndex = 0;
  String currentMealTime = "";

  @override
  void initState() {
    super.initState();
    _initializeMenu();
  }

  void _initializeMenu() {
    todayIndex = todayDate.weekday - 1;
    messMenu = ref.read(messDataNotifier.notifier).getDayMeal(todayIndex);
    if (messMenu != null) {
      currentMeal = getCurrentMeal(messMenu!);
      currentMealTime = getMealTimeString;
    }
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
      _previousDayIndex = todayIndex;
      todayIndex = day;
      messMenu = ref.read(messDataNotifier.notifier).getDayMeal(day);
      if (messMenu != null) {
        currentMeal = getCurrentMeal(messMenu!);
        currentMealTime = getMealTimeString;
      }
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
    // Handle loading state
    if (messMenu == null || currentMeal == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading menu...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                "${ref.watch(settingsNotifier).selectedMess.name}'s Menu",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 16),
          WeekDays(selectedDay: todayIndex, onDaySelected: changeDay),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            layoutBuilder: (
              Widget? currentChild,
              List<Widget> previousChildren,
            ) {
              return Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (Widget child, Animation<double> animation) {
              final key = child.key;
              final isEntering =
                  key is ValueKey<int> && key.value == todayIndex;

              // Horizontal slide for day changes
              final offset =
                  isEntering
                      ? Offset(todayIndex > _previousDayIndex ? 1.0 : -1.0, 0.0)
                      : Offset(
                        todayIndex > _previousDayIndex ? -1.0 : 1.0,
                        0.0,
                      );

              return SlideTransition(
                position: Tween<Offset>(
                  begin: offset,
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            child: MealWidget(
              key: ValueKey<int>(todayIndex),
              currentMeal: currentMeal!,
            ),
          ),
          const SizedBox(height: 16),
          MealChanger(
            currentMeals: messMenu!,
            onMealChanged: changeMeal,
            currentMeal: currentMealTime,
          ),
          const SizedBox(height: 24), // Bottom padding for navigation bar
        ],
      ),
    );
  }
}
