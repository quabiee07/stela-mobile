import 'package:flutter/material.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';

extension StelaThemeX on BuildContext {
  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;

  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Card / list-row surface (continue reading, settings groups, etc.)
  Color get cardSurface =>
      isDarkTheme ? darkSurface : grey100;

  Color get elevatedSurface =>
      isDarkTheme ? darkSurfaceElevated : Colors.white;

  Color get mutedText =>
      isDarkTheme ? darkMuted : grey500;

  Color get softBorder =>
      isDarkTheme ? darkBorder : grey300;

  Color get chipFill =>
      isDarkTheme ? darkChip : grey100;

  Color get iconMuted =>
      isDarkTheme ? darkMuted : const Color(0xFFCAD5E2);

  LinearGradient get inactiveChipGradient => isDarkTheme
      ? darkChipGradient
      : greyGradient;

  Color get divider =>
      isDarkTheme ? darkBorder : greyDivider;

  Color get popButtonFill =>
      isDarkTheme ? darkSurfaceElevated : grey100;
}
