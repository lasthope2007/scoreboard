import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kumite_scoreboard/state/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('first launch defaults to English and dark theme', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final s = SettingsController(prefs)..load();
    expect(s.languageCode, 'en');
    expect(s.locale, const Locale('en'));
    expect(s.themeMode, ThemeMode.dark);
  });

  test('a saved Persian choice is kept', () async {
    SharedPreferences.setMockInitialValues({'language': 'fa'});
    final prefs = await SharedPreferences.getInstance();
    final s = SettingsController(prefs)..load();
    expect(s.languageCode, 'fa');
  });
}
