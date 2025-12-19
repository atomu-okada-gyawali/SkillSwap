import 'package:flutter/material.dart';
import 'package:skillswap/utils/my_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // Colors
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    ),

    // Scaffold
    scaffoldBackgroundColor: MyColors.color1,

    // AppBar
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: MyColors.color3,
      foregroundColor: MyColors.color1,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    ),

    // Text
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: "OpenSans Bold",
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: "OpenSans Medium",
      ),
      bodyLarge: TextStyle(fontSize: 16, fontFamily: "OpenSans Regular"),
      bodyMedium: TextStyle(fontSize: 14, fontFamily: "OpenSans Regular"),
    ),

    // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MyColors.color5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),

    // // Bottom Navigation
    // bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    //   selectedItemColor: Colors.indigo,
    //   unselectedItemColor: Colors.grey,
    //   showUnselectedLabels: true,
    // ),
  );
}
