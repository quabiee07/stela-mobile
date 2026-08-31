import 'package:flutter/material.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/colors/snack_bar_colors.dart';
import 'package:stela_mobile/core/presentation/theme/my_text_theme.dart';

mixin AppTheme {
  ThemeData lightTheme() {
    return ThemeData.from(
      colorScheme: const ColorScheme.light(
        surface: Colors.white,
        onSurface: textColorLight,
        onSurfaceVariant: grey500,
        tertiary: primaryColor,
        secondary: cardBackgorund,
        onSecondary: Color(0xFF777777),
        onSecondaryContainer: Color(0xFFF9F9F9),
        surfaceContainerHighest: grey100,
        outline: grey300,
      ),
    ).copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      dividerColor: const Color(0xFFE5E5E5),
      primaryColor: orange,
      splashFactory: NoSplash.splashFactory,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: orange,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      appBarTheme: const AppBarTheme(
        foregroundColor: textColorLight,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: grey100,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        prefixIconConstraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        hintStyle: const TextStyle(
          color: grey500,
          fontFamily: 'SFProRounded',
          fontWeight: FontWeight.w300,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 16,
        ),
        filled: true,
        fillColor: grey100,
        errorStyle: const TextStyle(
          color: errorForeground,
          fontFamily: 'SFProRounded',
          fontSize: 14,
        ),
        focusedErrorBorder: _inputBorderLight.copyWith(
          borderSide: const BorderSide(color: errorForeground),
        ),
        border: _inputBorderLight,
        enabledBorder: _inputBorderLight,
        focusedBorder: _inputBorderLight,
        disabledBorder: _inputBorderLight,
        errorBorder: _inputBorderLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orange,
          disabledBackgroundColor: disabledGrey,
          minimumSize: const Size(double.infinity, double.infinity),
          foregroundColor: Colors.white,
          shadowColor: buttonColor.withValues(alpha: 0.05),
          textStyle: const TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          overlayColor: Colors.white,
          splashFactory: NoSplash.splashFactory,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: textColorLight,
        selectionColor: textColorLight.withValues(alpha: 0.5),
        selectionHandleColor: textColorLight.withValues(alpha: 0.7),
      ),
      textTheme: MyTextTheme.lightTextTheme,
    );
  }

  ThemeData darkTheme() {
    return ThemeData.from(
      colorScheme: const ColorScheme.dark(
        surface: darkSurface,
        onSurface: darkOnSurface,
        onSurfaceVariant: darkMuted,
        tertiary: orange,
        secondary: darkSurfaceElevated,
        onSecondary: darkMuted,
        onSecondaryContainer: darkChip,
        surfaceContainerHighest: darkSurfaceElevated,
        outline: darkBorder,
        primary: orange,
      ),
    ).copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      dividerColor: darkBorder,
      primaryColor: orange,
      splashFactory: NoSplash.splashFactory,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: orange,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      appBarTheme: const AppBarTheme(
        foregroundColor: darkOnSurface,
        backgroundColor: darkBackground,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(
          color: darkMuted,
          fontFamily: 'SFProRounded',
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        filled: true,
        fillColor: darkSurface,
        errorStyle: const TextStyle(
          color: errorForeground,
          fontFamily: 'SFProRounded',
          fontSize: 14,
        ),
        border: _inputBorderDark,
        enabledBorder: _inputBorderDark,
        focusedBorder: _inputBorderDark,
        disabledBorder: _inputBorderDark,
        errorBorder: _inputBorderDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orange,
          disabledBackgroundColor: darkChip,
          minimumSize: const Size(double.infinity, double.infinity),
          foregroundColor: Colors.white,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          textStyle: const TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          splashFactory: NoSplash.splashFactory,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: darkOnSurface,
        selectionColor: orange.withValues(alpha: 0.35),
        selectionHandleColor: orange,
      ),
      textTheme: MyTextTheme.darkTextTheme,
    );
  }

  static final _inputBorderLight = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  );

  static final _inputBorderDark = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  );
}
