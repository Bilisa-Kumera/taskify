import 'package:flutter/material.dart';
import 'package:task/provider/db.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  ThemeProvider() {
    _loadThemePreference();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme(bool isOn) {
    _isDarkMode = isOn;
    _dbHelper.saveThemeMode(isOn);
    notifyListeners();
  }

  Future<void> _loadThemePreference() async {
    _isDarkMode = await _dbHelper.getThemeMode();
    notifyListeners();
  }
}
