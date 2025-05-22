
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BoysMess{
  CRCL,
  Mayuri,
  Safal,
  JMB
}

enum GirlsMess{
  Mayuri
}

enum Hostels{
  Boys,
  Girls
}

class MessDataProvider extends StateNotifier{
  MessDataProvider(): super([]);

}