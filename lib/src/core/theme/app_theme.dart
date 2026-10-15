import 'package:flutter/material.dart';

abstract final class AppPalette {
  static const ink = Color(0xFF17231F);
  static const forest = Color(0xFF0E4D3D);
  static const forestSoft = Color(0xFF216754);
  static const mint = Color(0xFFE3F0E9);
  static const mintStrong = Color(0xFFCDE5D9);
  static const paper = Color(0xFFF8F5ED);
  static const coral = Color(0xFFFF8058);
  static const line = Color(0xFFDCE3DD);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppPalette.forest,
    brightness: Brightness.light,
    surface: AppPalette.paper,
  ).copyWith(
    primary: AppPalette.forest,
    secondary: AppPalette.coral,
    tertiary: AppPalette.mint,
    onSurface: AppPalette.ink,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppPalette.paper,
    fontFamily: 'sans-serif',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.paper,
      foregroundColor: AppPalette.ink,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppPalette.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppPalette.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppPalette.forest, width: 1.5),
      ),
    ),
  );
}
