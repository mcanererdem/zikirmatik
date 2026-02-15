import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/zikr_model.dart';
import '../models/goal_model.dart';

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
  static const String _lastActivityDateKey = 'last_activity_date';
  static const String _streakCountKey = 'streak_count';
  static const String _goalsKey = 'goals';
  static const String _zikrCountPrefix = 'zikr_count_'; // zikr_count_{zikrId}_{date}

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
    final key = 'goal_streak_$type';
    final lastKey = 'goal_last_$type';
    final bestKey = 'goal_best_$type';
    final todayCountKey = 'goal_today_count_$type';
    
    final now = DateTime.now();
    final today = '${now.year}_${now.month}_${now.day}';
    final lastCompleted = prefs.getString(lastKey);
    final todayCount = prefs.getInt(todayCountKey) ?? 0;
    
    if (lastCompleted == null || lastCompleted != today) {
      // Yeni gün - streak kontrolü
      if (lastCompleted != null) {
        final last = DateTime.parse(lastCompleted.replaceAll('_', '-'));
        final isConsecutive = _isConsecutivePeriod(type, last, now);
        
        if (isConsecutive) {
          final current = prefs.getInt(key) ?? 0;
          final newStreak = current + 1;
          await prefs.setInt(key, newStreak);
          
          final best = prefs.getInt(bestKey) ?? 0;
          if (newStreak > best) {
            await prefs.setInt(bestKey, newStreak);
          }
        } else {
          await prefs.setInt(key, 1);
        }
      } else {
        await prefs.setInt(key, 1);
        await prefs.setInt(bestKey, 1);
      }
      
      await prefs.setString(lastKey, today);
      await prefs.setInt(todayCountKey, 1);
    } else {
      // Aynı gün - sadece sayıyı artır
      await prefs.setInt(todayCountKey, todayCount + 1);
    }
    
    final currentStreak = prefs.getInt(key) ?? 0;
    final bestStreak = prefs.getInt(bestKey) ?? 0;
    final isNewBest = currentStreak == bestStreak && currentStreak > 1;
    
    return {
      'streak': currentStreak,
      'best': bestStreak,
      'isNewBest': isNewBest,
      'todayCount': prefs.getInt(todayCountKey) ?? 0,
    };
  }

  bool _isConsecutivePeriod(String type, DateTime last, DateTime now) {
    switch (type) {
      case 'daily':
        return now.difference(last).inDays == 1;
      case 'weekly':
        return now.difference(last).inDays >= 7 && now.difference(last).inDays <= 14;
      case 'monthly':
        return (now.month == last.month + 1 && now.year == last.year) ||
               (now.month == 1 && last.month == 12 && now.year == last.year + 1);
      default:
        return false;
    }
  }

  Future<Map<String, int>> getGoalStreaks() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'daily': prefs.getInt('goal_streak_daily') ?? 0,
      'weekly': prefs.getInt('goal_streak_weekly') ?? 0,
      'monthly': prefs.getInt('goal_streak_monthly') ?? 0,
      'daily_best': prefs.getInt('goal_best_daily') ?? 0,
      'weekly_best': prefs.getInt('goal_best_weekly') ?? 0,
      'monthly_best': prefs.getInt('goal_best_monthly') ?? 0,
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