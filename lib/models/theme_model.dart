import 'package:flutter/material.dart';

enum AppThemeMode {
  blueGold,
  greenGold,
  purpleGold,
  darkBlue,
}

class ThemeConfig {
  final String id;
  final String nameTr;
  final String nameEn;
  final AppThemeMode mode;
  final LinearGradient backgroundGradient;
  final LinearGradient buttonGradient;
  final LinearGradient goldGradient;
  final Color accentColor;
  final Color primaryColor;

  ThemeConfig({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.mode,
    required this.backgroundGradient,
    required this.buttonGradient,
    required this.goldGradient,
    required this.accentColor,
    required this.primaryColor,
  });
}

class AppThemes {
  static final List<ThemeConfig> themes = [
    // Mavi-Altın (Varsayılan)
    ThemeConfig(
      id: 'blue_gold',
      nameTr: 'Mavi & Altın',
      nameEn: 'Blue & Gold',
      mode: AppThemeMode.blueGold,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A2239), Color(0xFF1A5490), Color(0xFF2E6CB5)],
      ),
      buttonGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A5490), Color(0xFF2E6CB5)],
      ),
      goldGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
      ),
      accentColor: const Color(0xFFFFD700),
      primaryColor: const Color(0xFF1A5490),
    ),
    
    // Yeşil-Altın
    ThemeConfig(
      id: 'green_gold',
      nameTr: 'Yeşil & Altın',
      nameEn: 'Green & Gold',
      mode: AppThemeMode.greenGold,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0D3B2E), Color(0xFF1B5E3F), Color(0xFF2D8659)],
      ),
      buttonGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1B5E3F), Color(0xFF2D8659)],
      ),
      goldGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
      ),
      accentColor: const Color(0xFFFFD700),
      primaryColor: const Color(0xFF1B5E3F),
    ),
    
    // Mor-Altın
    ThemeConfig(
      id: 'purple_gold',
      nameTr: 'Mor & Altın',
      nameEn: 'Purple & Gold',
      mode: AppThemeMode.purpleGold,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2C1A4D), Color(0xFF4A2C6B), Color(0xFF6A4C8C)],
      ),
      buttonGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4A2C6B), Color(0xFF6A4C8C)],
      ),
      goldGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
      ),
      accentColor: const Color(0xFFFFD700),
      primaryColor: const Color(0xFF4A2C6B),
    ),
    
    // Koyu Mavi
    ThemeConfig(
      id: 'dark_blue',
      nameTr: 'Koyu Mavi',
      nameEn: 'Dark Blue',
      mode: AppThemeMode.darkBlue,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF2A3F5F)],
      ),
      buttonGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A1F3A), Color(0xFF2A3F5F)],
      ),
      goldGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)],
      ),
      accentColor: const Color(0xFF64B5F6),
      primaryColor: const Color(0xFF1A1F3A),
    ),
  ];

  static ThemeConfig getTheme(String themeId) {
    return themes.firstWhere(
      (theme) => theme.id == themeId,
      orElse: () => themes[0],
    );
  }
}