import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
    textTheme: GoogleFonts.interTightTextTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.black,
      tertiary: Colors.grey,
      inversePrimary: Colors.white,
      surface: Colors.grey.shade300,
      outline: Colors.grey[200],
    ));
