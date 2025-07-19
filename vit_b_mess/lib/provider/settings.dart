import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vit_b_mess/mess_app_info.dart' as app_info;
import 'package:vit_b_mess/models/settings.dart';
import 'package:vit_b_mess/provider/mess_data.dart';



Box<Settings> settingsBox = Hive.box<Settings>('mess_app_settings');
Future<Settings> loadSettingsFromStorage() async {
  Settings? _settings = settingsBox.get('settings');
  if (_settings == null) {
    log("Settings not found in storage, creating default settings");
    return Settings(
      isFirstBoot: true,
      hostelType: Hostels.Boys,
      selectedMess: MessType.BoysMayuri,
      onlyVeg: false,
      version: app_info.appVersion,
      newUpdate: true,
      messDataVersion: "0",
      newUpdateVersion: app_info.appVersion,
      updatedTill: "",
      notificationPermission: null,
    );
  }
  if (_settings.version != app_info.appVersion) {
    log("App version changed, updating settings");
    _settings.version = app_info.appVersion;
    _settings.newUpdate = true;
  }
  await saveSettingsToStorage(_settings);
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
          version: app_info.appVersion,
          isFirstBoot: true,
          newUpdate: false,
          messDataVersion: "0",
          newUpdateVersion: app_info.appVersion,
          updatedTill: "",
          notificationPermission: null, 
        ),
      );

  Future loadSettings() async {
    log("Loading settings from storage");
    final settings = await loadSettingsFromStorage();
    log("Settings loaded from storage: ${settings.getAllInfo()}");
    state = settings;
  }
  Future saveSettings(Settings settings) async {
    log("Saving settings: ${settings.getAllInfo()}");
    await saveSettingsToStorage(settings);
    state = settings;
  }

 

  Settings getSettings() {
    return state;
  }
}

final settingsNotifier = StateNotifierProvider<SettingsProvider, Settings>((
  ref,
) {
  return SettingsProvider();
});
