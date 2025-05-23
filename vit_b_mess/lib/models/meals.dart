import 'package:hive_flutter/hive_flutter.dart';
import 'package:vit_b_mess/provider/mess_data.dart';
part 'meals.g.dart';

@HiveType(typeId: 3)
class Meals {
  Meals({
    required this.messType,
    required this.breakfast,
    required this.lunch,
    required this.snacks,
    required this.dinner,
  });
  @HiveField(0)
  MessType messType;
  @HiveField(1)
  List<String> breakfast;
  @HiveField(2)
  List<String> lunch;
  @HiveField(3)
  List<String> snacks;
  @HiveField(4)
  List<String> dinner;
}
