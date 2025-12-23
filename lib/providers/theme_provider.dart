import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeProvider(bool isDarkMode)
      : _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDarkMode);
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', mode == ThemeMode.dark);
    
    notifyListeners();
  }
}