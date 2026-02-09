// ignore_for_file: non_constant_identifier_names, prefer_const_constructors, file_names

import 'package:flutter/material.dart';

//------------------Updated colors-----------------------//
Color defoultColor = const Color.fromARGB(255, 30, 97, 204);
Color bgcolor = Colors.white;
Color bg1Color = const Color(0xFFF8F9FB);
Color gradientColor = const Color.fromARGB(255, 30, 97, 204);
Color yelloColor = const Color.fromARGB(255, 255, 187, 13);
Color redColor = const Color.fromARGB(255, 255, 70, 70);
Color lightGrey = const Color.fromARGB(255, 218, 218, 218);
Color blackColor = const Color.fromARGB(255, 17, 19, 17);
Color whiteColor = Colors.white;
Color greyColor = Colors.grey;
Color greyColorWithOpacity0_4 = Colors.grey.withOpacity(0.4);
Color greenColor = Colors.green;
Color amberColor = Colors.amber;
Color themeColor = const Color.fromARGB(255, 30, 97, 204);
Color appColor = const Color.fromARGB(255, 30, 97, 204);
//Color gradientC=

//------------------------------------------//#1E61CC

class GradientColors {
  static const Gradient btnGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 30, 97, 204),
      Color.fromARGB(255, 64, 113, 191),
      Color.fromARGB(255, 47, 105, 198)
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static const Gradient lightGradient = LinearGradient(
    colors: [Color(0xffdaedfd), Color(0xffdaedfd)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  static const Gradient transpharantGradient = LinearGradient(
    colors: [Colors.transparent, Colors.transparent],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  //static const Color defoultColor = Color(0xff1EBC5D);
  static const Color defoultColor = Color.fromARGB(255, 30, 97, 204);

  static const Color blueLightColor = Colors.lightBlue;
}

extension ThemeColors on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  Color get scaffoldBg => theme.scaffoldBackgroundColor;
  Color get surfaceColor => colorScheme.surface;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get primaryColor => colorScheme.primary;
  Color get textColor => isDarkMode ? whiteColor : blackColor;
  Color get subTextColor => isDarkMode ? Colors.white70 : Colors.grey.shade600;
  Color get dividerColor =>
      theme.dividerTheme.color ??
      (isDarkMode ? Colors.white10 : greyColor.withOpacity(0.4));

  Color get shimmerBaseColor =>
      isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300;
  Color get shimmerHighlightColor =>
      isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;
}
