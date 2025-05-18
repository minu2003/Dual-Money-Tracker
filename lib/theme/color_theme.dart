import 'package:flutter/material.dart';

final ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    background: Color(0xFFF3F4F6), // background color like a white
    primary: Color(0xFF5efce8), //main blue
    secondary: Color(0xFF736efe), //other main blue
    tertiary: Color(0xFFF5F5F5),

  )
);

final ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF0072ff),
      secondary: Color(0xFF00c6ff),
      tertiary: Color(0xFF343434)
    )
);
