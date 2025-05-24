import 'package:hive_flutter/hive_flutter.dart';
import 'package:vit_b_mess/provider/mess_data.dart';
part 'meals.g.dart';

@HiveType(typeId: 3)
class Meals {
  Meals({
    required this.breakfast,
    required this.lunch,
    required this.snacks,
    required this.dinner,
  });
  @HiveField(0)
  Meal breakfast;
  @HiveField(1)
  Meal lunch;
  @HiveField(2)
  Meal snacks;
  @HiveField(3)
  Meal dinner;
}

@HiveType(typeId: 4)
class MessMealDays {
  MessMealDays({
    required this.mess,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });
  @HiveField(0)
  MessType mess;
  @HiveField(1)
  Meals monday;
  @HiveField(2)
  Meals tuesday;
  @HiveField(3)
  Meals wednesday;
  @HiveField(4)
  Meals thursday;
  @HiveField(5)
  Meals friday;
  @HiveField(6)
  Meals saturday;
  @HiveField(7)
  Meals sunday;
}

@HiveType(typeId: 5)
class Meal {
  Meal({required this.nonVeg, required this.veg});
  @HiveField(0)
  List<String> nonVeg;
  @HiveField(1)
  List<String> veg;
}
