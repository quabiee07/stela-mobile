class CustomThemeMode {
  final String title;
  final ThemeOptions value;

  const CustomThemeMode({
    required this.title,
    required this.value,
  });

  static const Map<String, CustomThemeMode> customThemes = {
    "System": CustomThemeMode(title: 'System', value: ThemeOptions.system),
    "Light": CustomThemeMode(title: 'Light', value: ThemeOptions.light),
    "Dark": CustomThemeMode(title: 'Dark', value: ThemeOptions.dark),
  };
}

enum ThemeOptions { light, dark, system }
