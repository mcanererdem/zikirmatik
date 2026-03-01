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
    // Safir Altın (Varsayılan)
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
        colors: [Color(0xFF0A2239), Color(0xFF173F6E), Color(0xFF2A64A3)],
      ),
      buttonGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A4E84), Color(0xFF2E6CB5)],
      ),
      goldGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
      ),
      accentColor: const Color(0xFFFFD700),
      primaryColor: const Color(0xFF1A5490),
      textColor: const Color(0xFFFFFFFF),
      darkBackgroundAsset: 'assets/backgrounds/dark_bg.png',
    ),
    
    // Zümrüt Parıltı
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
        colors: [Color(0xFF0D3B2E), Color(0xFF1F5F42), Color(0xFF2F7A57)],
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
      textColor: const Color(0xFFFFFFFF),
      darkBackgroundAsset: 'assets/backgrounds/dark_bg.png',
    ),
    
    // Kraliyet Gül (White + Rose)
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
        colors: [Color(0xFFFFFFFF), Color(0xFFF6F7FA), Color(0xFFEFF2F7)],
      ),
      buttonGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE091A9), Color(0xFFD76D8A)],
      ),
      goldGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEFB9C8), Color(0xFFE091A9)],
      ),
      accentColor: const Color(0xFFD76D8A),
      primaryColor: const Color(0xFFE5E8EF),
      textColor: const Color(0xFF1A1F3A),
      lightBackgroundAsset: 'assets/backgrounds/light_bg.png',
    ),
    
    // Dark Night (Yeni Gece Modu)
    ThemeConfig(
      id: 'dark_night',
      nameTr: 'Karan Gece',
      nameEn: 'Dark Night',
      nameAr: 'ليل مظلم',
      nameId: 'Malam Gelap',
      mode: AppThemeMode.darkBlue,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF000000),
          Color(0xFF0A0A0A),
          Color(0xFF141414),
        ],
      ),
      buttonGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF141414),
          Color(0xFF1E1E1E),
          Color(0xFF282828),
        ],
      ),
      goldGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE0AAFF),
          Color(0xFFC77DFF),
          Color(0xFF9D4EDD),
        ],
      ),
      accentColor: Color(0xFFE0AAFF),
      primaryColor: Color(0xFF141414),
      textColor: Colors.white,
      darkBackgroundAsset: 'assets/backgrounds/dark_bg.png',
    ),
    
    // Moonlight (Yeni Gece Modu)
    ThemeConfig(
      id: 'moonlight',
      nameTr: 'Ay Işığı',
      nameEn: 'Moonlight',
      nameAr: 'ضوء القمر',
      nameId: 'Cahaya Bulan',
      mode: AppThemeMode.darkBlue,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A1A2E),
          Color(0xFF2D3748),
          Color(0xFF4A5568),
        ],
      ),
      buttonGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2D3748),
          Color(0xFF4A5568),
          Color(0xFF6774A4),
        ],
      ),
      goldGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE0AAFF),
          Color(0xFFC77DFF),
          Color(0xFF9D4EDD),
        ],
      ),
      accentColor: Color(0xFFE0AAFF),
      primaryColor: Color(0xFF2D3748),
      textColor: Colors.white,
      darkBackgroundAsset: 'assets/backgrounds/light_bg.png',
    ),
    
    // Deep Space (Yeni Gece Modu)
    ThemeConfig(
      id: 'deep_space',
      nameTr: 'Derin Uzay',
      nameEn: 'Deep Space',
      nameAr: 'الفضاء العميق',
      nameId: 'Ruang Dalam',
      mode: AppThemeMode.darkBlue,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF000000),
          Color(0xFF0F0F0F),
          Color(0xFF1A1A1A),
        ],
      ),
      buttonGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0F0F0F),
          Color(0xFF1A1A1A),
          Color(0xFF2A2A2A),
        ],
      ),
      goldGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE0AAFF),
          Color(0xFFC77DFF),
          Color(0xFF9D4EDD),
        ],
      ),
      accentColor: Color(0xFFE0AAFF),
      primaryColor: Color(0xFF0F0F0F),
      textColor: Colors.white,
      darkBackgroundAsset: 'assets/backgrounds/dark_bg.png',
    ),
    
    // Northern Lights (Yeni Gece Modu)
    ThemeConfig(
      id: 'northern_lights',
      nameTr: 'Kuzey Işıkları',
      nameEn: 'Northern Lights',
      nameAr: 'الأضواء الشمال',
      nameId: 'Cahaya Işıkları',
      mode: AppThemeMode.darkBlue,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0F172A),
          Color(0xFF1E3A3A),
          Color(0xFF2E5E5E),
        ],
      ),
      buttonGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1E3A3A),
          Color(0xFF2E5E5E),
          Color(0xFF3F7F7F),
        ],
      ),
      goldGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE0AAFF),
          Color(0xFFC77DFF),
          Color(0xFF9D4EDD),
        ],
      ),
      accentColor: Color(0xFFE0AAFF),
      primaryColor: Color(0xFF1E3A3A),
      textColor: Colors.white,
      darkBackgroundAsset: 'assets/backgrounds/dark_bg.png',
    ),
    
    // Yıldızlı Gece
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
      textColor: const Color(0xFFFFFFFF),
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
