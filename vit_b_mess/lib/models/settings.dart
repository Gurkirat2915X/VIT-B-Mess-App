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
    required this.newUpdate,
    required this.messDataVersion,
    required this.newUpdateVersion,
    required this.updatedTill,
    this.notificationPermission,
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

  @HiveField(5)
  bool? newUpdate;

  @HiveField(6)
  String? messDataVersion;

  @HiveField(7)
  String? newUpdateVersion;

  @HiveField(8)
  String? updatedTill;

  @HiveField(9)
  bool? notificationPermission;

  String getAllInfo() {
    return "Hostel: ${hostelType.name}, Mess: ${selectedMess.name}, Only Veg: $onlyVeg, Version: $version, First Boot: $isFirstBoot newUpdate: $newUpdate, messDataVersion: $messDataVersion, newUpdateVersion: $newUpdateVersion, updatedTill: $updatedTill, notificationPermission: $notificationPermission";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Settings &&
        other.isFirstBoot == isFirstBoot &&
        other.hostelType == hostelType &&
        other.selectedMess == selectedMess &&
        other.onlyVeg == onlyVeg &&
        other.version == version &&
        other.notificationPermission ==  notificationPermission;
  }

  @override
  int get hashCode {
    return Object.hash(isFirstBoot, hostelType, selectedMess, onlyVeg, version);
  }
}
