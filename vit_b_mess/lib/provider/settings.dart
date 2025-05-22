import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum Settings { hostel, mess, vegOnly, firstBoot }

Future<Map<Settings, dynamic>> loadSettingsFromStorage() async {
  await Hive.openBox('mess_app_data');
  await Hive.openBox('mess_app_settings');
  final settingsBox = Hive.box('mess_app_settings');
  final settingsValues = Map.fromEntries(
    Settings.values.map((setting) {
      return MapEntry(setting, settingsBox.get(setting.name));
    }).toList(),
  );
  for (var setting in Settings.values) {
    if (settingsValues[setting] == null) {
      settingsValues[Settings.firstBoot] = true;
    }
    break;
  }
  return settingsValues;
}

void saveSettingsToStorage(Map<Settings, dynamic> settings) async {
  final settingsBox = Hive.box('mess_app_settings');
  for (var entry in settings.entries) {
    await settingsBox.put(entry.key.name, entry.value);
  }
}

class SettingsProvider extends StateNotifier<Map<Settings, dynamic>> {
  SettingsProvider() : super({});

  Future<void> loadSettings() async {
    final settings = await loadSettingsFromStorage();
    state = settings;
  }

  void saveSettings(Map<Settings, dynamic> settings) {
    state = {...state, ...settings, Settings.firstBoot: false};
    saveSettingsToStorage(state);
  }

  void setSetting(Settings setting, dynamic value) {
    state = {...state, Settings.firstBoot: false, setting: value};
    saveSettingsToStorage(state);
  }

  dynamic getSetting(Settings setting) {
    return state[setting];
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsProvider, Map<Settings, dynamic>>((ref) {
      return SettingsProvider();
    });
