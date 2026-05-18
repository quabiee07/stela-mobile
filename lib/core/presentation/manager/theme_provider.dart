import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/domain/models/custom_theme_mode.dart';
import 'package:stela_mobile/core/presentation/manager/custom_provider.dart';
import 'package:stela_mobile/core/presentation/theme/app_theme.dart';

import '../../di/core_module_container.dart';

class ThemeProvider extends CustomProvider with AppTheme {
  final _pref = getIt.getAsync<SharedPreferences>();
  bool isDark = true;
  ThemeOptions? currentTheme;
  ThemeData? theme;
  ThemeData? darkThemeData;

  ThemeProvider() {
    _pref.then((value) {
      // isDark = value.getBool(_themeKey) ?? true;
      getTheme();
    });
  }

  getTheme() {
    _pref.then((value) {
      final themePref = value.getString(_themeKey) ?? 'Light';
      currentTheme =
          CustomThemeMode.customThemes[themePref]?.value ?? ThemeOptions.light;
      setTheme();
    });
  }

  setTheme() {
    switch (currentTheme!) {
      case ThemeOptions.light:
        darkThemeData = null;
        theme = lightTheme();
        break;
      case ThemeOptions.dark:
        darkThemeData = null;
        theme = darkTheme();
        break;
      case ThemeOptions.system:
        darkThemeData = darkTheme();
        theme = lightTheme();
        break;
    }

    notifyListeners();
  }

  setThemeMode(CustomThemeMode themeMode) {
    currentTheme = themeMode.value;
    setTheme();
    _pref.then((value) {
      value.setString(_themeKey, themeMode.title);
    });
  }

  final _themeKey = 'isDark';
}
