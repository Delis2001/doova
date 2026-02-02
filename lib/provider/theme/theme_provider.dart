import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'isDarkMode';
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider();

  ThemeMode get themeMode => _themeMode;

  Future<void> toggleTheme(bool isDarkMode) async {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    await _saveTheme();
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
  }

  /// ✅ Make this method public so it can be accessed from `main.dart`
  Future<void> loadTheme() async { 
    final prefs = await SharedPreferences.getInstance();
    _themeMode = (prefs.getBool(_themeKey) ?? false) ? ThemeMode.dark : ThemeMode.light;
  }
}
