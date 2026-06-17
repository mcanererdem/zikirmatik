import '../models/goal_model.dart';
import '../services/settings_service.dart';
import '../services/widget_service.dart';

class CounterLogic {
  final SettingsService _settingsService = SettingsService();
  
  Future<void> incrementCounter(int currentCount, String? selectedZikrId) async {
    final List<Future<dynamic>> futures = [
      _settingsService.saveCurrentCount(currentCount),
      _settingsService.updateStreak(),
      WidgetService.updateWidget(currentCount),
    ];

    final today = DateTime.now();
    final todayCount = await _settingsService.getDailyCount(today);
    
    futures.add(_settingsService.saveDailyCount(today, todayCount + 1));
    futures.add(_settingsService.incrementWeeklyCount());
    futures.add(_settingsService.incrementMonthlyCount());
    futures.add(_settingsService.incrementTotalCount(1));
    
    if (selectedZikrId != null) {
      for (var type in ['daily', 'weekly', 'monthly']) {
        final period = _settingsService.getPeriodKey(type);
        futures.add(_settingsService.incrementZikrCount(selectedZikrId, period));
      }
    }

    await Future.wait(futures);
  }

  Future<Map<String, dynamic>> updateGoalProgress(List<Goal> goals, String? selectedZikrId) async {
    final completedGoals = <Goal>[];
    
    for (var goal in goals) {
      if (!goal.isCompleted && !goal.isExpired() && goal.zikrId == selectedZikrId) {
        final newProgress = goal.currentProgress + 1;
        await _settingsService.updateGoalProgress(goal.id, newProgress);
        
        if (newProgress >= goal.targetCount) {
          completedGoals.add(goal);
        }
      }
    }
    
    final updatedGoals = await _settingsService.getGoals();
    
    // Sadece ilk tamamlanan goal için bildirim göster
    if (completedGoals.isNotEmpty) {
      final firstCompleted = completedGoals.first;
      final streakInfo = await _settingsService.completeGoal(firstCompleted.id);
      
      // Diğer tamamlanan goal'ları sessizce tamamla
      for (var i = 1; i < completedGoals.length; i++) {
        await _settingsService.completeGoal(completedGoals[i].id);
      }
      
      return {
        'goals': await _settingsService.getGoals(),
        'streakInfo': streakInfo,
        'goalType': firstCompleted.type,
      };
    }
    
    return {'goals': updatedGoals};
  }

  Future<void> resetCounter() async {
    await _settingsService.saveCurrentCount(0);
    await WidgetService.updateWidgetImmediate();
  }
}
