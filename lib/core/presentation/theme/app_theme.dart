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
        tertiary: primaryColor,
        secondary: cardBackgorund,
        onSecondary: Color(0xFF777777),
        onSecondaryContainer: Color(0xFFF9F9F9),
      ),
    ).copyWith(
      scaffoldBackgroundColor: Colors.white,
      dividerColor: const Color(0xFFE5E5E5),
      primaryColor: _buttonLightColor,
      splashFactory: NoSplash.splashFactory,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _buttonLightColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      appBarTheme: AppBarTheme(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFF9F9F9),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        prefixIconConstraints: BoxConstraints(minWidth: 20, minHeight: 20),

        hintStyle: const TextStyle(
          color: textColorLight,
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
        surface: Color(0xff010101),
        onSurface: textColorDark,
        tertiary: primaryColor,
        secondary: walletTopDark,
      ),
    ).copyWith(
      scaffoldBackgroundColor: const Color(0xff010101),
      primaryColor: _buttonDarkColor,
      splashFactory: NoSplash.splashFactory,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _buttonDarkColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      cardTheme: CardThemeData(
        color: cardBackgroundDark,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(
          color: Color(0xFF959595),
          fontFamily: 'SFProRounded',
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        filled: true,
        fillColor: cardBackgroundDark,
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
          backgroundColor: _buttonDarkColor,
          disabledBackgroundColor: Colors.grey,
          minimumSize: const Size(double.infinity, double.infinity),
          foregroundColor: Colors.white,
          shadowColor: buttonColor.withValues(alpha: 0.05),
          textStyle: const TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColorDark,
          ),
          splashFactory: NoSplash.splashFactory,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: textColorDark,
        selectionColor: textColorDark.withValues(alpha: 0.5),
        selectionHandleColor: textColorDark.withValues(alpha: 0.7),
      ),
      textTheme: MyTextTheme.darkTextTheme,
    );
  }

  static const _buttonLightColor = Color(0xFF000000);
  static const _buttonDarkColor = Color(0xFFFFFFFF);

  static final _inputBorderLight = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  );

  static final _inputBorderDark = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide.none,
  );
}
