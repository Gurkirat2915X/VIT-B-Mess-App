import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vit_b_mess/mess_app_info.dart' as appInfo;
import 'package:vit_b_mess/models/settings.dart';
import 'package:vit_b_mess/provider/mess_data.dart';

Box<Settings> settingsBox = Hive.box<Settings>('mess_app_settings');
Future<Settings> loadSettingsFromStorage() async {
  Settings? _settings = settingsBox.get('settings');
  if (_settings == null) {
    print("Settings not found in storage, creating default settings");
    return Settings(
      isFirstBoot: true,
      hostelType: Hostels.Boys,
      selectedMess: MessType.BoysMayuri,
      onlyVeg: false,
      version: appInfo.appVersion,
    );
  }
  return _settings;
}

Future saveSettingsToStorage(Settings settings) async {
  await settingsBox.put('settings', settings);
  await settingsBox.flush();
}

class SettingsProvider extends StateNotifier<Settings> {
  SettingsProvider()
    : super(
        Settings(
          hostelType: Hostels.Boys,
          selectedMess: MessType.BoysMayuri,
          onlyVeg: false,
          version: appInfo.appVersion,
          isFirstBoot: true,
        ),
      );

  Future<void> loadSettings() async {
    print("Loading settings from storage");
    final settings = await loadSettingsFromStorage();
    print("Settings loaded from storage: $settings");
    state = settings;
  }

  Future saveSettings(Settings settings) async {
    state = settings;
    await saveSettingsToStorage(settings);
  }

  Settings getSetting() {
    return state;
  }
}

final settingsProvider = StateNotifierProvider<SettingsProvider, Settings>((
  ref,
) {
  return SettingsProvider();
});
