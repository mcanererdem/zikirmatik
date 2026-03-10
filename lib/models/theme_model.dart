import 'package:flutter/material.dart';

enum AppThemeMode {
  oceanBlue,
  emeraldGreen,
  rosePink,
  darkMode,
}

class ThemeConfig {
  final String id;
  final String nameTr;
  final String nameEn;
  final String nameAr;
  final String nameId;
  final AppThemeMode mode;
  final LinearGradient backgroundGradient;
  final LinearGradient buttonGradient;
  final LinearGradient goldGradient;
  final Color accentColor;
  final Color primaryColor;
  final Color textColor;
  final String? lightBackgroundAsset;
  final String? darkBackgroundAsset;
  
  // Dark mode özellikleri
  final LinearGradient? darkBackgroundGradient;
  final LinearGradient? darkButtonGradient;
  final Color? darkAccentColor;
  final Color? darkPrimaryColor;
  final Color? darkTextColor;

  // Helper methods
  Color get backgroundColor {
    return backgroundGradient.colors.first;
  }

  ThemeConfig({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.nameAr,
    required this.nameId,
    required this.mode,
    required this.backgroundGradient,
    required this.buttonGradient,
    required this.goldGradient,
    required this.accentColor,
    required this.primaryColor,
    required this.textColor,
    this.lightBackgroundAsset,
    this.darkBackgroundAsset,
    this.darkBackgroundGradient,
    this.darkButtonGradient,
    this.darkAccentColor,
    this.darkPrimaryColor,
    this.darkTextColor,
  });
}

class AppThemes {
  static final List<ThemeConfig> themes = [
    // 1. Ocean Blue (Açık/Koyu)
    ThemeConfig(
      id: 'ocean_blue',
      nameTr: 'Okyanus Mavi',
      nameEn: 'Ocean Blue',
      nameAr: 'أزرق المحيط',
      nameId: 'Biru Lautan',
      mode: AppThemeMode.oceanBlue,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0D1929), // Çok koyu lacivert
          Color(0xFF1A2332), // Koyu lacivert
          Color(0xFF2C3E50), // Orta lacivert
        ],
      ),
      darkBackgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0A0E1A), // Neredeyse siyah
          Color(0xFF0D1929), // Çok koyu lacivert
          Color(0xFF141E2E), // Koyu lacivert
        ],
      ),
      buttonGradient: LinearGradient(
        colors: [
          Color(0xFF1E3A8A), // Koyu mavi
          Color(0xFF2563EB), // Orta mavi
        ],
      ),
      darkButtonGradient: LinearGradient(
        colors: [
          Color(0xFF1E2F4F), // Daha koyu mavi
          Color(0xFF2C4A7D), // Koyu mavi
        ],
      ),
      goldGradient: LinearGradient(
        colors: [
          Color(0xFFF59E0B), // Amber
          Color(0xFFD97706), // Amber koyu
        ],
      ),
      accentColor: Color(0xFF3B82F6), // Parlak mavi
      darkAccentColor: Color(0xFF60A5FA), // Daha parlak mavi
      primaryColor: Color(0xFF1E40AF), // Koyu mavi
      darkPrimaryColor: Color(0xFF1E3A8A), // Çok koyu mavi
      textColor: Color(0xFFF3F4F6), // Beyaza yakın gri
      darkTextColor: Color(0xFFE5E7EB), // Beyaz
    ),
    // 2. Emerald Green (Açık/Koyu)
    ThemeConfig(
      id: 'emerald_green',
      nameTr: 'Zümrüt Yeşil',
      nameEn: 'Emerald Green',
      nameAr: 'أخضر الزمرد',
      nameId: 'Hijau Zamrud',
      mode: AppThemeMode.emeraldGreen,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFD1FAE5), // Çok açık yeşil
          Color(0xFFA7F3D0), // Açık yeşil
          Color(0xFF6EE7B7), // Parlak yeşil
        ],
      ),
      darkBackgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF064E3B), // Çok koyu yeşil
          Color(0xFF065F46), // Koyu yeşil
          Color(0xFF047857), // Orta yeşil
        ],
      ),
      buttonGradient: LinearGradient(
        colors: [
          Color(0xFF10B981), // Parlak yeşil
          Color(0xFF059669), // Orta yeşil
        ],
      ),
      darkButtonGradient: LinearGradient(
        colors: [
          Color(0xFF059669), // Koyu yeşil
          Color(0xFF047857), // Çok koyu yeşil
        ],
      ),
      goldGradient: LinearGradient(
        colors: [
          Color(0xFFFCD34D), // Sarı
          Color(0xFFF59E0B), // Amber
        ],
      ),
      accentColor: Color(0xFF34D399), // Çok parlak yeşil
      darkAccentColor: Color(0xFF6EE7B7), // Parlak yeşil
      primaryColor: Color(0xFF059669), // Orta yeşil
      darkPrimaryColor: Color(0xFF065F46), // Koyu yeşil
      textColor: Color(0xFF064E3B), // Koyu yeşil
      darkTextColor: Color(0xFFD1FAE5), // Beyaza yakın yeşil
    ),
    // 3. Rose Pink (Pembe Tonları)
    ThemeConfig(
      id: 'rose_pink',
      nameTr: 'Gül Pembe',
      nameEn: 'Rose Pink',
      nameAr: 'وردي الورد',
      nameId: 'Pink Mawar',
      mode: AppThemeMode.rosePink,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFDF2F8), // Çok açık pembe
          Color(0xFFFCE7F3), // Açık pembe
          Color(0xFFFBCFE8), // Parlak pembe
        ],
      ),
      darkBackgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF500724), // Çok koyu pembe
          Color(0xFF701A75), // Koyu pembe
          Color(0xFF86198F), // Orta pembe
        ],
      ),
      buttonGradient: LinearGradient(
        colors: [
          Color(0xFFEC4899), // Parlak pembe
          Color(0xFFDB2777), // Koyu pembe
        ],
      ),
      darkButtonGradient: LinearGradient(
        colors: [
          Color(0xFFBE185D), // Daha koyu pembe
          Color(0xFF9F1239), // Çok koyu pembe
        ],
      ),
      goldGradient: LinearGradient(
        colors: [
          Color(0xFFF59E0B), // Amber
          Color(0xFFD97706), // Amber koyu
        ],
      ),
      accentColor: Color(0xFFF472B6), // Çok parlak pembe
      darkAccentColor: Color(0xFFF9A8D4), // Parlak pembe
      primaryColor: Color(0xFFEC4899), // Orta pembe
      darkPrimaryColor: Color(0xFFBE185D), // Koyu pembe
      textColor: Color(0xFF831843), // Koyu pembe
      darkTextColor: Color(0xFFFDF2F8), // Beyaza yakın pembe
    ),
    // 4. Pure Dark (Siyah/Sade)
    ThemeConfig(
      id: 'pure_dark',
      nameTr: 'Saf Siyah',
      nameEn: 'Pure Dark',
      nameAr: 'أسود نقي',
      nameId: 'Gelap Murni',
      mode: AppThemeMode.darkMode,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A1A1A), // Çok koyu gri
          Color(0xFF2D2D2D), // Koyu gri
          Color(0xFF404040), // Orta gri
        ],
      ),
      darkBackgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0A0A0A), // Neredeyse siyah
          Color(0xFF141414), // Çok koyu siyah
          Color(0xFF1F1F1F), // Koyu siyah
        ],
      ),
      buttonGradient: LinearGradient(
        colors: [
          Color(0xFF404040), // Orta gri
          Color(0xFF5A5A5A), // Gri
        ],
      ),
      darkButtonGradient: LinearGradient(
        colors: [
          Color(0xFF2A2A2A), // Daha koyu gri
          Color(0xFF333333), // Koyu gri
        ],
      ),
      goldGradient: LinearGradient(
        colors: [
          Color(0xFFFFD700), // Altın
          Color(0xFFFFC700), // Koyu altın
        ],
      ),
      accentColor: Color(0xFF6B7280), // Gri
      darkAccentColor: Color(0xFF9CA3AF), // Parlak gri
      primaryColor: Color(0xFF4B5563), // Orta gri
      darkPrimaryColor: Color(0xFF374151), // Koyu gri
      textColor: Color(0xFF1F2937), // Koyu gri
      darkTextColor: Color(0xFFF9FAFB), // Beyaza yakın gri
    ),
  ];

  static ThemeConfig getTheme(String themeId) {
    return themes.firstWhere(
      (theme) => theme.id == themeId,
      orElse: () => themes[0],
    );
  }

  static ThemeConfig getThemeForMode(String themeId, bool isDarkMode) {
    final theme = getTheme(themeId);
    
    if (isDarkMode) {
      // Dark mode versiyonunu oluştur
      return ThemeConfig(
        id: theme.id,
        nameTr: theme.nameTr,
        nameEn: theme.nameEn,
        nameAr: theme.nameAr,
        nameId: theme.nameId,
        mode: theme.mode,
        backgroundGradient: theme.darkBackgroundGradient ?? theme.backgroundGradient,
        buttonGradient: theme.darkButtonGradient ?? theme.buttonGradient,
        goldGradient: theme.goldGradient,
        accentColor: theme.darkAccentColor ?? theme.accentColor,
        primaryColor: theme.darkPrimaryColor ?? theme.primaryColor,
        textColor: theme.darkTextColor ?? theme.textColor,
        lightBackgroundAsset: theme.lightBackgroundAsset,
        darkBackgroundAsset: theme.darkBackgroundAsset,
        darkBackgroundGradient: theme.darkBackgroundGradient,
        darkButtonGradient: theme.darkButtonGradient,
        darkAccentColor: theme.darkAccentColor,
        darkPrimaryColor: theme.darkPrimaryColor,
        darkTextColor: theme.darkTextColor,
      );
    }
    
    return theme;
  }
}
