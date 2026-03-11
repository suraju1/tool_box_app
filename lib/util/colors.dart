// ignore_for_file: non_constant_identifier_names, prefer_const_constructors, file_names

import 'package:flutter/material.dart';

//------------------Updated colors-----------------------//
Color defoultColor = Colors.black; // Deprecated, use context.primaryColor
Color bgcolor = Colors.white;
Color bg1Color = const Color(0xFFF8F9FB); // Light mode background
Color gradientColor = Colors.black;
Color yelloColor = const Color.fromARGB(255, 255, 187, 13);
Color redColor = const Color.fromARGB(255, 255, 70, 70);
Color lightGrey = const Color.fromARGB(255, 218, 218, 218);
Color blackColor = const Color.fromARGB(255, 17, 19, 17);
Color whiteColor = Colors.white;
Color greyColor = Colors.grey;
Color greyColorWithOpacity0_4 = Colors.grey.withOpacity(0.4);
Color greenColor = Colors.green;
Color amberColor = Colors.amber;
Color themeColor = Colors.black;
Color appColor = Colors.black; // Deprecated, use context.primaryColor

//------------------------------------------//#1E61CC

class GradientColors {
  // Use a slight gradient or just solid color based on current mode if possible
  // These solid fallbacks ensure backward compatibility if hardcoded
  static const Gradient btnGradient = LinearGradient(
    colors: [Colors.black, Colors.black87],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static const Gradient lightGradient = LinearGradient(
    colors: [Color(0xFFF0F0F0), Color(0xFFE0E0E0)], // Light grey
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static const Gradient transpharantGradient = LinearGradient(
    colors: [Colors.transparent, Colors.transparent],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static const Color defoultColor = Colors.black;
  static const Color blueLightColor =
      Colors.grey; // Replaced light blue with neutral grey
}

extension ThemeColors on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  Color get scaffoldBg => theme.scaffoldBackgroundColor;
  Color get surfaceColor => colorScheme.surface;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get primaryColor => colorScheme.primary;
  Color get onPrimaryColor =>
      colorScheme.onPrimary; // Usually white in light, black in dark
  Color get textColor => isDarkMode ? whiteColor : blackColor;
  Color get reverseTextColor =>
      isDarkMode ? blackColor : whiteColor; // For contrasting text
  Color get subTextColor => isDarkMode ? Colors.white70 : Colors.grey.shade600;
  Color get appBarColor => isDarkMode ? Colors.black : Colors.white;
  Color get dividerColor =>
      theme.dividerTheme.color ??
      (isDarkMode ? Colors.white10 : greyColor.withOpacity(0.4));

  Color get shimmerBaseColor =>
      isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300;
  Color get shimmerHighlightColor =>
      isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;
}
