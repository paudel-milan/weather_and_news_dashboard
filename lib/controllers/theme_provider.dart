// lib/controllers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // To persist theme mode

class ThemeProvider with ChangeNotifier {
  static const String themeBoxName = 'appSettings';
  static const String _themeModeKey = 'themeMode';

  ThemeMode _themeMode = ThemeMode.system; // Default to system theme
  late final Box _appSettingsBox;

  ThemeProvider() {
    _initHive();
  }

  // Initialize Hive box and load saved theme preference
  Future<void> _initHive() async {
    // Ensure Hive is initialized before opening boxes
    if (!Hive.isBoxOpen(themeBoxName)) {
      _appSettingsBox = await Hive.openBox(themeBoxName);
    } else {
      _appSettingsBox = Hive.box(themeBoxName);
    }

    final savedThemeMode = _appSettingsBox.get(_themeModeKey) as String?;
    if (savedThemeMode != null) {
      _themeMode = _stringToThemeMode(savedThemeMode);
    }
    notifyListeners(); // Notify listeners after loading state
  }

  ThemeMode get themeMode => _themeMode;

  // Toggle theme to next mode: System -> Light -> Dark -> System
  void toggleTheme() {
    switch (_themeMode) {
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
        break;
    }
    _saveThemeMode(_themeMode); // Save the new theme mode
    notifyListeners();
  }

  // Set theme to a specific mode
  void setTheme(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _saveThemeMode(_themeMode);
      notifyListeners();
    }
  }

  // Save theme mode to Hive
  void _saveThemeMode(ThemeMode mode) {
    _appSettingsBox.put(_themeModeKey, mode.toString());
  }

  // Helper to convert string back to ThemeMode enum
  ThemeMode _stringToThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.system':
      default:
        return ThemeMode.system;
    }
  }
}