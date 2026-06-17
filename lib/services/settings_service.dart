import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/zikr_model.dart';
import '../models/goal_model.dart';
import 'package:flutter/material.dart';

class SettingsService {
  static const String _themeKey = 'theme_id';
  static const String _languageKey = 'language_code';
  static const String _legacyLanguageKey = 'language';
  static const String _vibrationKey = 'vibration_enabled';
  static const String _soundKey = 'sound_enabled';
  static const String _customZikrsKey = 'custom_zikrs';
  static const String _editedDefaultZikrsKey = 'edited_default_zikrs';
  static const String _selectedZikrKey = 'selected_zikr';
  static const String _dailyCountKey = 'daily_count_';
  static const String _totalCountKey = 'total_count';
  static const String _confettiKey = 'confetti_enabled';
  static const String _ttsEnabledKey = 'tts_enabled';
  static const String _ttsRateKey = 'tts_rate';
  static const String _ttsPitchKey = 'tts_pitch';
  static const String _ttsVoiceKey = 'tts_voice';
  static const String _reminderHourKey = 'reminder_hour';
  static const String _reminderMinuteKey = 'reminder_minute';
  static const String _reminderEnabledKey = 'reminder_enabled';
  static const String _currentCountKey = 'current_count';
  static const String _themeModeKey = 'theme_mode';
  static const String _showInLeaderboardKey = 'show_in_leaderboard';
  static const String _lastActivityDateKey = 'last_activity_date';
  static const String _streakCountKey = 'streak_count';
  static const String _goalsKey = 'goals';
  static const String _zikrCountPrefix = 'zikr_count_'; // zikr_count_{zikrId}_{date}
  static const String _zikrTargetPrefix = 'zikr_target_'; // zikr_target_{zikrId}

  // Theme
  Future<void> saveTheme(String themeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeId);
  }

  Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'dark_blue';
  }

  // Language
  Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    // Legacy compatibility (older code reads from `language` key).
    await prefs.setString(_legacyLanguageKey, languageCode);
    debugPrint('🔧 SettingsService: Language saved to SharedPreferences: $languageCode');
    
    // Doğru kaydedildiğini kontrol et
    final savedLanguage = prefs.getString(_languageKey);
    debugPrint('🔧 SettingsService: Verification - saved language_code: $savedLanguage');
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    // Prefer `language_code`; fallback to legacy `language`.
    final languageCode = prefs.getString(_languageKey);
    final legacyLanguage = prefs.getString(_legacyLanguageKey);
    final language = languageCode ?? legacyLanguage ?? 'en'; // Default English

    // If only legacy key exists, resync the new key for consistency.
    if (languageCode == null && legacyLanguage != null && legacyLanguage.trim().isNotEmpty) {
      await prefs.setString(_languageKey, legacyLanguage.trim());
    }

    debugPrint('🔧 SettingsService: Language retrieved from SharedPreferences: $language');
    return language;
  }

  // Vibration
  Future<void> saveVibration(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, enabled);
  }

  Future<bool> getVibration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationKey) ?? false; // Default olarak kapalı
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

  Future<void> saveEditedDefaultZikrs(List<ZikrModel> zikrs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = zikrs.map((z) => jsonEncode(z.toJson())).toList();
    await prefs.setStringList(_editedDefaultZikrsKey, jsonList);
  }

  Future<List<ZikrModel>> getEditedDefaultZikrs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_editedDefaultZikrsKey) ?? [];
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

  static String _weekStartKey(DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    return 'weekly_${weekStart.year}_${weekStart.month}_${weekStart.day}';
  }

  static String _monthKey(DateTime date) => 'monthly_${date.year}_${date.month}';

  Future<int> getWeeklyCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_weekStartKey(DateTime.now())) ?? 0;
  }

  Future<void> saveWeeklyCount(DateTime date, int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_weekStartKey(date), count);
  }

  Future<int> getMonthlyCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_monthKey(DateTime.now())) ?? 0;
  }

  Future<void> saveMonthlyCount(DateTime date, int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_monthKey(date), count);
  }

  Future<void> incrementWeeklyCount() async {
    final now = DateTime.now();
    final n = await getWeeklyCount();
    await saveWeeklyCount(now, n + 1);
  }

  Future<void> incrementMonthlyCount() async {
    final now = DateTime.now();
    final n = await getMonthlyCount();
    await saveMonthlyCount(now, n + 1);
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
  
  Future<void> setTotalCount(int total) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_totalCountKey, total);
  }

  // Confetti
  Future<void> saveConfetti(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_confettiKey, enabled);
  }

  Future<bool> getConfetti() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_confettiKey) ?? true; // Default olarak açık
  }

  Future<void> saveTtsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ttsEnabledKey, enabled);
  }

  Future<bool> getTtsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_ttsEnabledKey) ?? false;
  }

  Future<void> saveTtsRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_ttsRateKey, rate);
  }

  Future<double> getTtsRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_ttsRateKey) ?? 0.4;
  }

  Future<void> saveTtsPitch(double pitch) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_ttsPitchKey, pitch);
  }

  Future<double> getTtsPitch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_ttsPitchKey) ?? 1.0;
  }

  Future<void> saveTtsVoice(String voiceName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ttsVoiceKey, voiceName);
  }

  Future<String?> getTtsVoice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ttsVoiceKey);
  }

  // Reminder Time
  Future<void> saveReminderTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderHourKey, hour);
    await prefs.setInt(_reminderMinuteKey, minute);
    await prefs.setBool(_reminderEnabledKey, true);
  }

  Future<Map<String, int>> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hour': prefs.getInt(_reminderHourKey) ?? 9,
      'minute': prefs.getInt(_reminderMinuteKey) ?? 0,
    };
  }

  Future<void> saveReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, enabled);
  }

  /// Hatırlatıcı (bildirim) — varsayılan: kapalı (pasif).
  Future<bool> getReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reminderEnabledKey) ?? false;
  }

  Future<void> saveNotificationDays(List<String> days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notification_days', days);
  }

  Future<List<String>> getNotificationDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('notification_days') ?? ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  }

  Future<void> saveMorningNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('morning_notification_time', '${time.hour}:${time.minute}');
  }

  Future<TimeOfDay> getMorningNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString('morning_notification_time') ?? '6:00';
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> saveEveningNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('evening_notification_time', '${time.hour}:${time.minute}');
  }

  Future<TimeOfDay> getEveningNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString('evening_notification_time') ?? '18:00';
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> saveMorningNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('morning_notification_enabled', enabled);
  }

  Future<bool> getMorningNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('morning_notification_enabled') ?? true;
  }

  Future<void> saveEveningNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('evening_notification_enabled', enabled);
  }

  Future<bool> getEveningNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('evening_notification_enabled') ?? true;
  }

  Future<void> clearReminder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_reminderHourKey);
    await prefs.remove(_reminderMinuteKey);
    await prefs.setBool(_reminderEnabledKey, false);
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

  // Per-zikr target
  Future<void> saveZikrTarget(String zikrId, int target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_zikrTargetPrefix$zikrId', target);
  }

  Future<int?> getZikrTarget(String zikrId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_zikrTargetPrefix$zikrId');
  }

  Future<void> saveShowInLeaderboard(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showInLeaderboardKey, value);
  }

  /// Liderlik tablosunda görünme — varsayılan: kapalı (pasif).
  Future<bool> getShowInLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showInLeaderboardKey) ?? false;
  }

  // Streak
  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString(_lastActivityDateKey);
    
    if (lastDate == null) {
      await prefs.setString(_lastActivityDateKey, today);
      await prefs.setInt(_streakCountKey, 1);
    } else if (lastDate != today) {
      final last = DateTime.parse(lastDate);
      final now = DateTime.parse(today);
      final diff = now.difference(last).inDays;
      
      if (diff == 1) {
        final streak = prefs.getInt(_streakCountKey) ?? 0;
        await prefs.setInt(_streakCountKey, streak + 1);
      } else if (diff > 1) {
        await prefs.setInt(_streakCountKey, 1);
      }
      await prefs.setString(_lastActivityDateKey, today);
    }
  }

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakCountKey) ?? 0;
  }

  // Goals
  Future<void> saveGoals(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = goals.map((g) => jsonEncode(g.toJson())).toList();
    await prefs.setStringList(_goalsKey, jsonList);
  }

  Future<List<Goal>> getGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_goalsKey) ?? [];
    return jsonList.map((json) => Goal.fromJson(jsonDecode(json))).toList();
  }

  Future<void> updateGoalProgress(String goalId, int progress) async {
    final goals = await getGoals();
    final index = goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      goals[index] = goals[index].copyWith(currentProgress: progress);
      await saveGoals(goals);
    }
  }

  Future<Map<String, dynamic>?> completeGoal(String goalId) async {
    final goals = await getGoals();
    final index = goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      goals[index] = goals[index].copyWith(
        isCompleted: true,
        completedDate: DateTime.now(),
      );
      await saveGoals(goals);
      return await _updateGoalStreaks(goals[index].type);
    }
    return null;
  }

  Future<Map<String, dynamic>> _updateGoalStreaks(String type) async {
    final prefs = await SharedPreferences.getInstance();
    final streakKey = 'trophy_streak_$type';
    final lastKey = 'trophy_last_$type';
    final bestKey = 'trophy_best_$type';
    final todayCountKey = 'trophy_completed_today_$type';
    
    final now = DateTime.now();
    final currentPeriod = _getPeriodString(type, now);
    final lastCompleted = prefs.getString(lastKey);
    
    int currentStreak = prefs.getInt(streakKey) ?? 0;
    int bestStreak = prefs.getInt(bestKey) ?? 0;
    int todayCount = prefs.getInt(todayCountKey) ?? 0;
    bool isNewBest = false;
    
    // İlk trophy tamamlama
    if (lastCompleted == null) {
      currentStreak = 0; // İlk gün streak yok
      await prefs.setInt(streakKey, currentStreak);
      await prefs.setString(lastKey, currentPeriod);
      await prefs.setInt(todayCountKey, 1);
      
      if (bestStreak == 0) {
        await prefs.setInt(bestKey, 0);
      }
      
      return {
        'streak': currentStreak,
        'best': bestStreak,
        'isNewBest': false,
        'todayCount': 1,
      };
    }
    
    // Aynı period - sadece count artır
    if (lastCompleted == currentPeriod) {
      todayCount++;
      await prefs.setInt(todayCountKey, todayCount);
      
      return {
        'streak': currentStreak,
        'best': bestStreak,
        'isNewBest': false,
        'todayCount': todayCount,
      };
    }
    
    // Yeni period - streak kontrolü
    final isConsecutive = _isConsecutivePeriod(type, lastCompleted, currentPeriod);
    
    if (isConsecutive) {
      // Ardışık - streak artır
      currentStreak++;
      await prefs.setInt(streakKey, currentStreak);
      
      // Best kontrolü
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
        await prefs.setInt(bestKey, bestStreak);
        isNewBest = true;
      }
    } else {
      // Ardışık değil - streak sıfırla
      currentStreak = 0;
      await prefs.setInt(streakKey, currentStreak);
    }
    
    // Period ve count güncelle
    await prefs.setString(lastKey, currentPeriod);
    await prefs.setInt(todayCountKey, 1);
    
    return {
      'streak': currentStreak,
      'best': bestStreak,
      'isNewBest': isNewBest,
      'todayCount': 1,
    };
  }
  
  String _getPeriodString(String type, DateTime date) {
    switch (type) {
      case 'daily':
        return '${date.year}_${date.month}_${date.day}';
      case 'weekly':
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        return 'W_${weekStart.year}_${weekStart.month}_${weekStart.day}';
      case 'monthly':
        return 'M_${date.year}_${date.month}';
      default:
        return '';
    }
  }

  bool _isConsecutivePeriod(String type, String lastPeriod, String currentPeriod) {
    try {
      switch (type) {
        case 'daily':
          final lastParts = lastPeriod.split('_');
          final currentParts = currentPeriod.split('_');
          final last = DateTime(int.parse(lastParts[0]), int.parse(lastParts[1]), int.parse(lastParts[2]));
          final current = DateTime(int.parse(currentParts[0]), int.parse(currentParts[1]), int.parse(currentParts[2]));
          return current.difference(last).inDays == 1;
          
        case 'weekly':
          final lastParts = lastPeriod.split('_');
          final currentParts = currentPeriod.split('_');
          final last = DateTime(int.parse(lastParts[1]), int.parse(lastParts[2]), int.parse(lastParts[3]));
          final current = DateTime(int.parse(currentParts[1]), int.parse(currentParts[2]), int.parse(currentParts[3]));
          final diff = current.difference(last).inDays;
          return diff >= 7 && diff <= 13;
          
        case 'monthly':
          final lastParts = lastPeriod.split('_');
          final currentParts = currentPeriod.split('_');
          final lastYear = int.parse(lastParts[1]);
          final lastMonth = int.parse(lastParts[2]);
          final currentYear = int.parse(currentParts[1]);
          final currentMonth = int.parse(currentParts[2]);
          
          if (currentYear == lastYear) {
            return currentMonth == lastMonth + 1;
          } else if (currentYear == lastYear + 1) {
            return lastMonth == 12 && currentMonth == 1;
          }
          return false;
          
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, int>> getGoalStreaks() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'daily': prefs.getInt('trophy_streak_daily') ?? 0,
      'weekly': prefs.getInt('trophy_streak_weekly') ?? 0,
      'monthly': prefs.getInt('trophy_streak_monthly') ?? 0,
      'daily_best': prefs.getInt('trophy_best_daily') ?? 0,
      'weekly_best': prefs.getInt('trophy_best_weekly') ?? 0,
      'monthly_best': prefs.getInt('trophy_best_monthly') ?? 0,
    };
  }

  Future<void> cleanExpiredGoals() async {
    final goals = await getGoals();
    final activeGoals = goals.where((g) => !g.isExpired()).toList();
    await saveGoals(activeGoals);
  }

  // Zikr-specific counts
  Future<void> incrementZikrCount(String zikrId, String period) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_zikrCountPrefix${zikrId}_$period';
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  Future<int> getZikrCount(String zikrId, String period) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_zikrCountPrefix${zikrId}_$period';
    return prefs.getInt(key) ?? 0;
  }

  String getPeriodKey(String type) {
    final now = DateTime.now();
    switch (type) {
      case 'daily':
        return '${now.year}_${now.month}_${now.day}';
      case 'weekly':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return 'week_${weekStart.year}_${weekStart.month}_${weekStart.day}';
      case 'monthly':
        return '${now.year}_${now.month}';
      default:
        return '';
    }
  }
}
