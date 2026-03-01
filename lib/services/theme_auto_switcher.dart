import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeAutoSwitcher {
  static const String _autoThemeKey = 'auto_theme_enabled';
  static const String _lightThemeKey = 'light_theme_id';
  static const String _darkThemeKey = 'dark_theme_id';
  
  static bool _isAutoThemeEnabled = false;
  static String _lightThemeId = 'midnight';
  static String _darkThemeId = 'dark_night';

  // Getters
  static bool get isAutoThemeEnabled => _isAutoThemeEnabled;
  static String get lightThemeId => _lightThemeId;
  static String get darkThemeId => _darkThemeId;

  // Ayarları yükle
  static Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAutoThemeEnabled = prefs.getBool(_autoThemeKey) ?? false;
      _lightThemeId = prefs.getString(_lightThemeKey) ?? 'midnight';
      _darkThemeId = prefs.getString(_darkThemeKey) ?? 'dark_night';
    } catch (e) {
      print('Auto theme settings loading error: $e');
    }
  }

  // Ayarları kaydet
  static Future<void> saveSettings({
    bool? autoThemeEnabled,
    String? lightThemeId,
    String? darkThemeId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (autoThemeEnabled != null) {
        _isAutoThemeEnabled = autoThemeEnabled!;
        await prefs.setBool(_autoThemeKey, autoThemeEnabled!);
      }
      
      if (lightThemeId != null) {
        _lightThemeId = lightThemeId!;
        await prefs.setString(_lightThemeKey, lightThemeId!);
      }
      
      if (darkThemeId != null) {
        _darkThemeId = darkThemeId!;
        await prefs.setString(_darkThemeKey, darkThemeId!);
      }
    } catch (e) {
      print('Auto theme settings saving error: $e');
    }
  }

  // Otomatik tema geçişini kontrol et
  static String getCurrentTheme() {
    if (!_isAutoThemeEnabled) {
      return _darkThemeId; // Varsayılan olarak koyu tema
    }

    final now = DateTime.now();
    final hour = now.hour;

    // Sabah 6:00 - Akşam 18:00 arası aydınlık tema
    if (hour >= 6 && hour < 18) {
      return _lightThemeId;
    }
    
    // Akşam 18:00 - Sabah 6:00 arası koyu tema
    return _darkThemeId;
  }

  // Gece modu mu kontrol et
  static bool isDarkTheme() {
    final currentTheme = getCurrentTheme();
    final darkThemes = [
      'midnight',
      'dark_night',
      'deep_space',
      'northern_lights',
      'ocean_blue',
      'forest_green',
      'royal_purple',
    ];
    
    return darkThemes.contains(currentTheme);
  }

  // Aydınlık tema mı kontrol et
  static bool isLightTheme() {
    return !isDarkTheme();
  }

  // Saate göre tema adını al
  static String getThemeNameByTime() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 12) {
      return 'Sabah';
    } else if (hour >= 12 && hour < 18) {
      return 'Öğleden Sonra';
    } else if (hour >= 18 && hour < 22) {
      return 'Akşam';
    } else {
      return 'Gece';
    }
  }

  // Tema geçiş zamanını al
  static String getNextThemeSwitchTime() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 18) {
      return '18:00';
    } else {
      return '06:00';
    }
  }

  // Otomatik tema geçişini başlat
  static Future<void> startAutoThemeSwitching({
    required Function(String) onThemeChanged,
  }) async {
    await loadSettings();
    
    if (!_isAutoThemeEnabled) return;

    // Başlangıçta temayı ayarla
    final currentTheme = getCurrentTheme();
    onThemeChanged(currentTheme);

    // Her dakika kontrol et
    Stream.periodic(const Duration(minutes: 1)).listen((_) {
      final newTheme = getCurrentTheme();
      onThemeChanged(newTheme);
    });
  }

  // Otomatik tema geçişini durdur
  static void stopAutoThemeSwitching() {
    // Bu metod implementasyonu gerekiyorsa
  }

  // Tema geçişini manuel olarak tetikle
  static Future<void> triggerThemeSwitch({
    required Function(String) onThemeChanged,
  }) async {
    if (!_isAutoThemeEnabled) return;

    final newTheme = getCurrentTheme();
    await saveSettings(
      lightThemeId: newTheme,
      darkThemeId: newTheme,
    );
    
    onThemeChanged(newTheme);
  }

  // Tema geçişini test et
  static void testThemeSwitch() {
    print('Auto Theme Enabled: $_isAutoThemeEnabled');
    print('Light Theme: $_lightThemeId');
    print('Dark Theme: $_darkThemeId');
    print('Current Theme: ${getCurrentTheme()}');
    print('Is Dark Theme: ${isDarkTheme()}');
    print('Next Switch: ${getNextThemeSwitchTime()}');
  }
}
