import 'package:flutter/material.dart';

final ThemeData messLightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.green,
    primary: Color(0xFF4CAF50), // Fresh Green
    secondary: Color(0xFFFFC107), // Amber
    surface: Color(0xFFF9F9F9),
    error: Color(0xFFD32F2F),
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: Color(0xFFF9F9F9),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF388E3C),
    foregroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  textTheme: TextTheme(
    headlineSmall: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Color(0xFF212121),
    ),
    bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF212121)),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF757575)),
    labelLarge: TextStyle(fontSize: 14, color: Colors.white),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF4CAF50),
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Color(0xFF4CAF50),
    unselectedItemColor: Colors.black54,
    backgroundColor: Colors.white,
  ),
);

final ThemeData messDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.green,
    brightness: Brightness.dark,
    primary: Color(0xFF81C784),
    secondary: Color(0xFFFFD54F),
    surface: Color(0xFF1E1E1E),
    error: Color(0xFFEF5350),
  ),
  scaffoldBackgroundColor: Color(0xFF121212),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  textTheme: TextTheme(
    headlineSmall: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFBDBDBD)),
    labelLarge: TextStyle(fontSize: 14, color: Colors.black),
  ),
  cardTheme: CardThemeData(
    color: Color(0xFF1E1E1E),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF81C784),
    foregroundColor: Colors.black,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF81C784),
      foregroundColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Color(0xFF81C784),
    unselectedItemColor: Colors.white70,
    backgroundColor: Color(0xFF1E1E1E),
  ),
);
