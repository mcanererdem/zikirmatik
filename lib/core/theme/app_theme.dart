import 'package:flutter/material.dart';

class AppTheme {
  // Renk Paleti
  static const Color primaryBlue = Color(0xFF1A5490);
  static const Color deepBlue = Color(0xFF0D2F5C);
  static const Color lightBlue = Color(0xFF2E6CB5);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color darkGold = Color(0xFFFFA500);
  static const Color softGold = Color(0xFFFFE57F);
  
  // Gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A2239),
      Color(0xFF1A5490),
      Color(0xFF2E6CB5),
    ],
  );
  
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A5490),
      Color(0xFF2E6CB5),
    ],
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD700),
      Color(0xFFFFA500),
    ],
  );
  
  // Shadow
  static List<BoxShadow> goldShadow = [
    BoxShadow(
      color: accentGold.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> blueShadow = [
    BoxShadow(
      color: primaryBlue.withOpacity(0.4),
      blurRadius: 15,
      spreadRadius: 1,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Theme Data
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.transparent,
  );
}