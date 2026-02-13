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
    return prefs.getString(_languageKey) ?? 'tr';
  }

  // Vibration
  Future<void> saveVibration(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, enabled);
  }

  Future<bool> getVibration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationKey) ?? true;
  }

  // Sound
  Future<void> saveSound(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, enabled);
  }

  Future<bool> getSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundKey) ?? true;
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
}