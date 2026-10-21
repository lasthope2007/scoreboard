import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs);

  final SharedPreferences _prefs;

  int durationSeconds = kDefaultDurationSeconds;
  bool soundOn = true;
  bool vibrationOn = true;
  bool pointGapRule = true;
  ThemeMode themeMode = ThemeMode.dark;
  String languageCode = 'en';
  String defaultRedName = '';
  String defaultBlueName = '';

  void load() {
    durationSeconds =
        _prefs.getInt('durationSeconds') ?? kDefaultDurationSeconds;
    soundOn = _prefs.getBool('soundOn') ?? true;
    vibrationOn = _prefs.getBool('vibrationOn') ?? true;
    pointGapRule = _prefs.getBool('pointGapRule') ?? true;
    themeMode = (_prefs.getString('theme') ?? 'dark') == 'light'
        ? ThemeMode.light
        : ThemeMode.dark;
    languageCode = _prefs.getString('language') ?? 'en';
    defaultRedName = _prefs.getString('defaultRedName') ?? '';
    defaultBlueName = _prefs.getString('defaultBlueName') ?? '';
  }

  Locale get locale => Locale(languageCode);

  void setDuration(int seconds) {
    durationSeconds = seconds.clamp(kMinDurationSeconds, kMaxDurationSeconds);
    _prefs.setInt('durationSeconds', durationSeconds);
    notifyListeners();
  }

  void setSound(bool v) {
    soundOn = v;
    _prefs.setBool('soundOn', v);
    notifyListeners();
  }

  void setVibration(bool v) {
    vibrationOn = v;
    _prefs.setBool('vibrationOn', v);
    notifyListeners();
  }

  void setPointGapRule(bool v) {
    pointGapRule = v;
    _prefs.setBool('pointGapRule', v);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    _prefs.setString('theme', mode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }

  void setLanguage(String code) {
    languageCode = code;
    _prefs.setString('language', code);
    notifyListeners();
  }

  void setDefaultNames({String? red, String? blue}) {
    if (red != null) {
      defaultRedName = red;
      _prefs.setString('defaultRedName', red);
    }
    if (blue != null) {
      defaultBlueName = blue;
      _prefs.setString('defaultBlueName', blue);
    }
    notifyListeners();
  }
}
