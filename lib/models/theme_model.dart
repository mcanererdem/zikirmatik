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
  });
}

class AppThemes {
  static final List<ThemeConfig> themes = [
    // Safir Altın (Varsayılan - Geliştirilmiş)
    ThemeConfig(
      id: 'blue_gold',
      nameTr: 'Safir Altın',
      nameEn: 'Sapphire Gold',
      nameAr: 'ياقوت ذهبي',
      nameId: 'Safir Emas',
      mode: AppThemeMode.blueGold,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F2042), Color(0xFF203A6B), Color(0xFF2C5F8D)],
      ),
      buttonGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2C5F8D), Color(0xFF4A7BA7)],
      ),
      goldGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFD4AF37), Color(0xFFFCF6BA)],
      ),
      accentColor: const Color(0xFFD4AF37),
      primaryColor: const Color(0xFF2C5F8D),
      textColor: const Color(0xFFF8F8FF),
      darkBackgroundAsset: 'assets/backgrounds/dark_bg.png',
    ),
    
    // Zümrüt Parıltı (Geliştirilmiş)
    ThemeConfig(
      id: 'green_gold',
      nameTr: 'Zümrüt Parıltı',
      nameEn: 'Emerald Shine',
      nameAr: 'تألّق الزمرد',
      nameId: 'Zamrud Bersinar',
      mode: AppThemeMode.greenGold,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0B3B2E), Color(0xFF1F5F42), Color(0xFF2F7A57)],
      ),
      buttonGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2F7A57), Color(0xFF4A9B6F)],
      ),
      goldGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFC9B037), Color(0xFFE6D690)],
      ),
      accentColor: const Color(0xFFC9B037),
      primaryColor: const Color(0xFF2F7A57),
      textColor: const Color(0xFFF0FFF0),
      darkBackgroundAsset: 'assets/backgrounds/dark_bg.png',
    ),
    
    // Kraliyet Gül (Geliştirilmiş)
    ThemeConfig(
      id: 'purple_gold',
      nameTr: 'Kraliyet Gül',
      nameEn: 'Royal Rose',
      nameAr: 'وردة ملكية',
      nameId: 'Mawar Kerajaan',
      mode: AppThemeMode.purpleGold,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFDFBFB), Color(0xFFEEDDD6), Color(0xFFF5E6E6)],
      ),
      buttonGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFD63384), Color(0xFFE91E63)],
      ),
      goldGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
      ),
      accentColor: const Color(0xFFD63384),
      primaryColor: const Color(0xFFEEDDD6),
      textColor: const Color(0xFF2C1810),
      lightBackgroundAsset: 'assets/backgrounds/light_bg.png',
    ),
    
    // Karan Gece (Yeni Kimlik)
    ThemeConfig(
      id: 'dark_night',
      nameTr: 'Karan Gece',
      nameEn: 'Dark Night',
      nameAr: 'ليل مظلم',
      nameId: 'Malam Gelap',
      mode: AppThemeMode.darkBlue,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D0D0D), Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
      ),
      buttonGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
      ),
      goldGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7B1FA2), Color(0xFFBA68C8)],
      ),
      accentColor: const Color(0xFF4A148C),
      primaryColor: const Color(0xFF1A1A1A),
      textColor: const Color(0xFFE8EAF6),
      darkBackgroundAsset: 'assets/backgrounds/dark_bg.png',
    ),
    
    // Ay Işığı (Yeni Kimlik)
    ThemeConfig(
      id: 'moonlight',
      nameTr: 'Ay Işığı',
      nameEn: 'Moonlight',
      nameAr: 'ضوء القمر',
      nameId: 'Cahaya Bulan',
      mode: AppThemeMode.darkBlue,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3949AB)],
      ),
      buttonGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)],
      ),
      goldGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD54F), Color(0xFFFFE082)],
      ),
      accentColor: const Color(0xFFFFD54F),
      primaryColor: const Color(0xFF283593),
      textColor: const Color(0xFFE8EAF6),
      darkBackgroundAsset: 'assets/backgrounds/light_bg.png',
    ),
    
    // Derin Uzay (Yeni Kimlik)
    ThemeConfig(
      id: 'deep_space',
      nameTr: 'Derin Uzay',
      nameEn: 'Deep Space',
      nameAr: 'الفضاء العميق',
      nameId: 'Ruang Dalam',
      mode: AppThemeMode.darkBlue,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF000428), Color(0xFF004e92), Color(0xFF1A237E)],
      ),
      buttonGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF004e92), Color(0xFF1A237E)],
      ),
      goldGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
      ),
      accentColor: const Color(0xFF00BCD4),
      primaryColor: const Color(0xFF004e92),
      textColor: const Color(0xFFE1F5FE),
      darkBackgroundAsset: 'assets/backgrounds/dark_bg.png',
    ),
    
    // Kuzey Işıkları (Yeni Kimlik)
    ThemeConfig(
      id: 'northern_lights',
      nameTr: 'Kuzey Işıkları',
      nameEn: 'Northern Lights',
      nameAr: 'الأضواء الشمال',
      nameId: 'Cahaya Işıkları',
      mode: AppThemeMode.darkBlue,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF006064), Color(0xFF00838F), Color(0xFF0097A7)],
      ),
      buttonGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0097A7), Color(0xFF26C6DA)],
      ),
      goldGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF00E676), Color(0xFF69F0AE)],
      ),
      accentColor: const Color(0xFF00E676),
      primaryColor: const Color(0xFF00838F),
      textColor: const Color(0xFFE0F2F1),
      darkBackgroundAsset: 'assets/backgrounds/dark_bg.png',
    ),
    
    // Yıldızlı Gece (Yeni Kimlik)
    ThemeConfig(
      id: 'dark_blue',
      nameTr: 'Yıldızlı Gece',
      nameEn: 'Starry Night',
      nameAr: 'ليل نجمي',
      nameId: 'Malam Berbintang',
      mode: AppThemeMode.darkBlue,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
      ),
      buttonGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E293B), Color(0xFF334155)],
      ),
      goldGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF59E0B), Color(0xFFFCD34D)],
      ),
      accentColor: const Color(0xFFF59E0B),
      primaryColor: const Color(0xFF1E293B),
      textColor: const Color(0xFFF8FAFC),
      darkBackgroundAsset: 'assets/backgrounds/dark_bg.png',
    ),
  ];

  static ThemeConfig getTheme(String themeId) {
    return themes.firstWhere(
      (theme) => theme.id == themeId,
      orElse: () => themes[0],
    );
  }
}
