import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'mess_data.g.dart';

@HiveType(typeId: 1)
enum Hostels {
  @HiveField(0)
  Boys,
  @HiveField(1)
  Girls,
}

@HiveType(typeId: 2)
enum MessType {
  @HiveField(0)
  CRCL(hostel: Hostels.Boys),
  @HiveField(1)
  BoysMayuri(hostel: Hostels.Boys),
  @HiveField(2)
  Safal(hostel: Hostels.Boys),
  @HiveField(3)
  JMB(hostel: Hostels.Boys),
  @HiveField(4)
  GirlsMayuri(hostel: Hostels.Girls),
  @HiveField(5)
  AB(hostel: Hostels.Girls);

  final Hostels hostel;
  const MessType({required this.hostel});
  static List<MessType> getMess(Hostels hostel) {
    return MessType.values.where((mess) => mess.hostel == hostel).toList();
  }
}

class MessDataProvider extends StateNotifier {
  MessDataProvider() : super([]);
}
