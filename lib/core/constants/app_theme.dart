import 'package:flutter/material.dart';
import '../../util/colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: themeColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: themeColor,
      primary: themeColor,
      surface: Colors.white,
      onSurface: blackColor,
      background: bg1Color,
    ),
    scaffoldBackgroundColor: bg1Color,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: blackColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: blackColor,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade300,
      thickness: 1,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: themeColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: themeColor,
      primary: themeColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1E1E),
      onSurface: Colors.white,
      background: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2C2C2C),
      thickness: 1,
    ),
  );
}
