import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkMode = ThemeData(
  textTheme: GoogleFonts.interTightTextTheme(),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  colorScheme: ColorScheme.light(
    primary: Colors.blue,
    secondary: Colors.grey.shade600,
    tertiary: Colors.grey.shade700,
    inversePrimary: Colors.white,
    surface: Colors.grey.shade900,
    surfaceContainer: Colors.grey.shade800,
    outline: Colors.grey[200],
    onSurface: Colors.white,
  ),
);
