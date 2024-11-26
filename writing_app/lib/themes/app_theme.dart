import 'package:flutter/material.dart';

class AppTheme {
  static const Color backgroundColor = Color(0xFFFFF8E1);
  static const Color primaryColor = Colors.pinkAccent;
  static const Color textColor = Colors.brown;

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    textTheme: const TextTheme(
      bodyText1: TextStyle(color: textColor),
    ),
  );
}
