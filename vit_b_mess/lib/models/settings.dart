import 'package:vit_b_mess/provider/mess_data.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'settings.g.dart';

@HiveType(typeId: 0)
class Settings {
  Settings({
    required this.isFirstBoot,
    required this.hostelType,
    required this.selectedMess,
    required this.onlyVeg,
    required this.version,
  });

  @HiveField(0)
  bool isFirstBoot;

  @HiveField(1)
  Hostels hostelType;

  @HiveField(2)
  MessType selectedMess;

  @HiveField(3)
  bool onlyVeg;

  @HiveField(4)
  String version;

  String getAllInfo(){
    return "Hostel: ${hostelType.name}, Mess: ${selectedMess.name}, Only Veg: $onlyVeg, Version: $version, First Boot: $isFirstBoot";
  }
}
