import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color accent = Color(0xFFFF6F00);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB71C1C);
  static const Color danger = Color(0xFFD32F2F);
  static const Color textDark = Color(0xFF212121);
  static const Color textMedium = Color(0xFF616161);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          onPrimary: Colors.white,
          secondary: accent,
          onSecondary: Colors.white,
          background: background,
          surface: surface,
          error: error,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            minimumSize: const Size(double.infinity, 60),
            side: const BorderSide(color: primary, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          labelStyle: const TextStyle(fontSize: 18, color: textMedium),
          hintStyle: const TextStyle(fontSize: 18, color: Color(0xFF9E9E9E)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        textTheme: const TextTheme(
          displayLarge:
              TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textDark),
          displayMedium:
              TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
          displaySmall:
              TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
          headlineLarge:
              TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
          headlineMedium:
              TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
          headlineSmall:
              TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
          titleLarge:
              TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
          titleMedium:
              TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
          titleSmall:
              TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textDark),
          bodyLarge: TextStyle(fontSize: 18, color: textDark),
          bodyMedium: TextStyle(fontSize: 16, color: textDark),
          bodySmall: TextStyle(fontSize: 14, color: textMedium),
          labelLarge: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
        ),
        cardTheme: CardTheme(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          extendedTextStyle:
              TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: primary,
          unselectedItemColor: Color(0xFF9E9E9E),
          selectedLabelStyle:
              TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 13),
          showUnselectedLabels: true,
          elevation: 8,
        ),
      );
}
