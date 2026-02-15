class TrophyStats {
  final int dailyGoalsCompleted;
  final int weeklyGoalsCompleted;
  final int monthlyGoalsCompleted;
  final int currentDailyStreak;
  final int currentWeeklyStreak;
  final int currentMonthlyStreak;
  final int bestDailyStreak;
  final int bestWeeklyStreak;
  final int bestMonthlyStreak;

  TrophyStats({
    this.dailyGoalsCompleted = 0,
    this.weeklyGoalsCompleted = 0,
    this.monthlyGoalsCompleted = 0,
    this.currentDailyStreak = 0,
    this.currentWeeklyStreak = 0,
    this.currentMonthlyStreak = 0,
    this.bestDailyStreak = 0,
    this.bestWeeklyStreak = 0,
    this.bestMonthlyStreak = 0,
  });

  Map<String, dynamic> toJson() => {
    'dailyGoalsCompleted': dailyGoalsCompleted,
    'weeklyGoalsCompleted': weeklyGoalsCompleted,
    'monthlyGoalsCompleted': monthlyGoalsCompleted,
    'currentDailyStreak': currentDailyStreak,
    'currentWeeklyStreak': currentWeeklyStreak,
    'currentMonthlyStreak': currentMonthlyStreak,
    'bestDailyStreak': bestDailyStreak,
    'bestWeeklyStreak': bestWeeklyStreak,
    'bestMonthlyStreak': bestMonthlyStreak,
  };

  factory TrophyStats.fromJson(Map<String, dynamic> json) => TrophyStats(
    dailyGoalsCompleted: json['dailyGoalsCompleted'] ?? 0,
    weeklyGoalsCompleted: json['weeklyGoalsCompleted'] ?? 0,
    monthlyGoalsCompleted: json['monthlyGoalsCompleted'] ?? 0,
    currentDailyStreak: json['currentDailyStreak'] ?? 0,
    currentWeeklyStreak: json['currentWeeklyStreak'] ?? 0,
    currentMonthlyStreak: json['currentMonthlyStreak'] ?? 0,
    bestDailyStreak: json['bestDailyStreak'] ?? 0,
    bestWeeklyStreak: json['bestWeeklyStreak'] ?? 0,
    bestMonthlyStreak: json['bestMonthlyStreak'] ?? 0,
  );

  TrophyStats copyWith({
    int? dailyGoalsCompleted,
    int? weeklyGoalsCompleted,
    int? monthlyGoalsCompleted,
    int? currentDailyStreak,
    int? currentWeeklyStreak,
    int? currentMonthlyStreak,
    int? bestDailyStreak,
    int? bestWeeklyStreak,
    int? bestMonthlyStreak,
  }) {
    return TrophyStats(
      dailyGoalsCompleted: dailyGoalsCompleted ?? this.dailyGoalsCompleted,
      weeklyGoalsCompleted: weeklyGoalsCompleted ?? this.weeklyGoalsCompleted,
      monthlyGoalsCompleted: monthlyGoalsCompleted ?? this.monthlyGoalsCompleted,
      currentDailyStreak: currentDailyStreak ?? this.currentDailyStreak,
      currentWeeklyStreak: currentWeeklyStreak ?? this.currentWeeklyStreak,
      currentMonthlyStreak: currentMonthlyStreak ?? this.currentMonthlyStreak,
      bestDailyStreak: bestDailyStreak ?? this.bestDailyStreak,
      bestWeeklyStreak: bestWeeklyStreak ?? this.bestWeeklyStreak,
      bestMonthlyStreak: bestMonthlyStreak ?? this.bestMonthlyStreak,
    );
  }
}
