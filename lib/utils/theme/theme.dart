import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return ThemeData.dark().copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: const Color(0xff6F24E9),
        ),
      ),
      textTheme: ThemeData().textTheme.copyWith(
        titleMedium: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white),
        titleSmall: TextStyle(
          fontSize: screenWidth * 0.06,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontSize: screenWidth * 0.08,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData lightTheme(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return ThemeData.light().copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: const Color(0xff6F24E9),
        ),
      ),
      textTheme: ThemeData().textTheme.copyWith(
        titleMedium: TextStyle(fontSize: screenWidth * 0.04, color: Colors.black),
        titleSmall: TextStyle(
          fontSize: screenWidth * 0.06,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontSize: screenWidth * 0.08,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
