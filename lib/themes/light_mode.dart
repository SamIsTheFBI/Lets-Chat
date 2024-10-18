import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  textTheme: GoogleFonts.interTightTextTheme(),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  colorScheme: ColorScheme.light(
    primary: Colors.blue,
    secondary: Colors.grey.shade300,
    tertiary: Colors.grey.shade400,
    inversePrimary: Colors.white,
    surface: Colors.grey.shade100,
    surfaceContainer: Colors.white,
    outline: Colors.grey[200],
    onSurface: Colors.black,
  ),
);
