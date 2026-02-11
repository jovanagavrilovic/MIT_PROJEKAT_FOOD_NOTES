import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemeProvider extends ChangeNotifier {
  bool _isDark;

  bool get isDark => _isDark;
  ThemeProvider({bool initialIsDark = false}) : _isDark = initialIsDark;

  static Future<bool> loadInitialTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDark') ?? false;
  }

  Future<void> toggleTheme(bool value) async{
    _isDark = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
  }
}
