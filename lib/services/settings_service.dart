import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/zikr_model.dart';

class SettingsService {
  static const String _themeKey = 'theme_id';
  static const String _languageKey = 'language_code';
  static const String _vibrationKey = 'vibration_enabled';
  static const String _soundKey = 'sound_enabled';
  static const String _customZikrsKey = 'custom_zikrs';
  static const String _selectedZikrKey = 'selected_zikr';
  static const String _dailyCountKey = 'daily_count_';
  static const String _totalCountKey = 'total_count';
  static const String _confettiKey = 'confetti_enabled';
  static const String _reminderHourKey = 'reminder_hour';
  static const String _reminderMinuteKey = 'reminder_minute';
  static const String _currentCountKey = 'current_count';
  static const String _themeModeKey = 'theme_mode';

  // Theme
  Future<void> saveTheme(String themeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeId);
  }

  Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'blue_gold';
  }

  // Language
  Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en'; // Default İngilizce
  }

  // Vibration
  Future<void> saveVibration(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, enabled);
  }

  Future<bool> getVibration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationKey) ?? false;
  }

  // Sound
  Future<void> saveSound(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, enabled);
  }

  Future<bool> getSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundKey) ?? false;
  }

  // Custom Zikrs
  Future<void> saveCustomZikrs(List<ZikrModel> zikrs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = zikrs.map((z) => jsonEncode(z.toJson())).toList();
    await prefs.setStringList(_customZikrsKey, jsonList);
  }

  Future<List<ZikrModel>> getCustomZikrs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_customZikrsKey) ?? [];
    return jsonList.map((json) => ZikrModel.fromJson(jsonDecode(json))).toList();
  }

  // Selected Zikr
  Future<void> saveSelectedZikr(String zikrId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedZikrKey, zikrId);
  }

  Future<String?> getSelectedZikr() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedZikrKey);
  }

  // Statistics
  Future<void> saveDailyCount(DateTime date, int count) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_dailyCountKey${date.year}_${date.month}_${date.day}';
    await prefs.setInt(key, count);
  }

  Future<int> getDailyCount(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_dailyCountKey${date.year}_${date.month}_${date.day}';
    return prefs.getInt(key) ?? 0;
  }

  Future<void> incrementTotalCount(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_totalCountKey) ?? 0;
    await prefs.setInt(_totalCountKey, current + amount);
  }

  Future<int> getTotalCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalCountKey) ?? 0;
  }

  // Confetti
  Future<void> saveConfetti(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_confettiKey, enabled);
  }

  Future<bool> getConfetti() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_confettiKey) ?? false;
  }

  // Reminder Time
  Future<void> saveReminderTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderHourKey, hour);
    await prefs.setInt(_reminderMinuteKey, minute);
  }

  Future<Map<String, int>> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hour': prefs.getInt(_reminderHourKey) ?? 9,
      'minute': prefs.getInt(_reminderMinuteKey) ?? 0,
    };
  }

  // Current Counter
  Future<void> saveCurrentCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentCountKey, count);
  }

  Future<int> getCurrentCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentCountKey) ?? 0;
  }

  // Theme Mode (system, light, dark)
  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode);
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey) ?? 'system';
  }
}