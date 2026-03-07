import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryGreen = Color(0xFF1B4332);
  static const _primaryPink = Color(0xFFAD1457);

  // ── Light ──────────────────────────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _primaryGreen,
      secondary: _primaryPink,
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1A1A1A),
    ),
    scaffoldBackgroundColor: const Color(0xFFF9F6F0),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFEEE8DE),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryPink,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _primaryPink),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F2EE),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: _primaryGreen,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // ── Dark ───────────────────────────────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF52B788), // lighter green — readable on dark
      secondary: Color(0xFFE91E8C), // brighter pink — pops on dark bg
      surface: Color(0xFF1E1E2A),
      onSurface: Color(0xFFF0F0F0),
    ),
    scaffoldBackgroundColor: const Color(0xFF0F0F17),
    cardColor: const Color(0xFF1A1A26),
    dividerColor: const Color(0xFF2A2A3A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A26),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFFF0F0F0)),
      titleTextStyle: TextStyle(
        color: Color(0xFFF0F0F0),
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFAD1457),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFFE91E8C)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF252535),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      labelStyle: const TextStyle(color: Color(0xFF888899)),
      hintStyle: const TextStyle(color: Color(0xFF555566)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1A26),
      selectedItemColor: Color(0xFF52B788),
      unselectedItemColor: Color(0xFF666677),
      type: BottomNavigationBarType.fixed,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? const Color(0xFFAD1457)
            : const Color(0xFF555566),
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? const Color(0xFFAD1457).withOpacity(0.4)
            : const Color(0xFF333344),
      ),
    ),
  );
}
