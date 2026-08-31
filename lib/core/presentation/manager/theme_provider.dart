import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/domain/models/custom_theme_mode.dart';
import 'package:stela_mobile/core/presentation/manager/custom_provider.dart';
import 'package:stela_mobile/core/presentation/theme/app_theme.dart';

import '../../di/core_module_container.dart';

class ThemeProvider extends CustomProvider with AppTheme {
  final _pref = getIt.getAsync<SharedPreferences>();
  bool isDark = true;
  ThemeOptions currentTheme = ThemeOptions.dark;
  late ThemeData theme = lightTheme();
  late ThemeData darkThemeData = darkTheme();
  ThemeMode themeMode = ThemeMode.dark;

  ThemeProvider() {
    _pref.then((_) => getTheme());
  }

  void getTheme() {
    _pref.then((value) {
      final themePref = value.getString(_themeKey) ?? 'Dark';
      currentTheme =
          CustomThemeMode.customThemes[themePref]?.value ?? ThemeOptions.dark;
      setTheme();
    });
  }

  void setTheme() {
    theme = lightTheme();
    darkThemeData = darkTheme();

    switch (currentTheme) {
      case ThemeOptions.light:
        isDark = false;
        themeMode = ThemeMode.light;
      case ThemeOptions.dark:
        isDark = true;
        themeMode = ThemeMode.dark;
      case ThemeOptions.system:
        final platformDark =
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark;
        isDark = platformDark;
        themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  void setThemeMode(CustomThemeMode themeModeOption) {
    currentTheme = themeModeOption.value;
    setTheme();
    _pref.then((value) {
      value.setString(_themeKey, themeModeOption.title);
    });
  }

  void setLightMode(bool enabled) {
    setThemeMode(
      enabled
          ? CustomThemeMode.customThemes['Light']!
          : CustomThemeMode.customThemes['Dark']!,
    );
  }

  final _themeKey = 'isDark';
}
