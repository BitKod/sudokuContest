import 'package:sudokuContest/core/theme/appThemes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  ThemeData _themeData;

  final _kThemePreference = "theme_preference";

  ThemeManager() {
    _loadTheme();
  }

  void _loadTheme() {
    SharedPreferences.getInstance().then((prefs) {
      int preferredTheme = prefs.getInt(_kThemePreference) ?? 0;
      _themeData = appThemeData[AppTheme.values[preferredTheme]];
      notifyListeners();
    });
  }

  ThemeData getTheme() {
    if (_themeData == null) {
      _themeData = appThemeData[AppTheme.White];
    }
    return _themeData;
  }

  setTheme(AppTheme theme) async {
    _themeData = appThemeData[theme];
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt(_kThemePreference, AppTheme.values.indexOf(theme));
    notifyListeners();
  }
}
