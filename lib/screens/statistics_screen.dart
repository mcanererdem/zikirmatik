import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../models/theme_model.dart';
import '../models/goal_model.dart';
import '../utils/localizations.dart';
import '../services/settings_service.dart';

class StatisticsScreen extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;

  const StatisticsScreen({
    super.key,
    required this.themeConfig,
    required this.localizations,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final SettingsService _settingsService = SettingsService();
  int _todayCount = 0;
  int _totalCount = 0;
  int _streakCount = 0;
  Map<DateTime, int> _weekData = {};
  Map<int, int> _monthData = {};
  Map<int, int> _yearData = {};
  List<Goal> _completedGoals = [];
  Map<String, int> _goalStreaks = {};
  String _selectedPeriod = 'week'; // week, month, year
  String _chartType = 'bar'; // bar, line

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final today = DateTime.now();
    final todayCount = await _settingsService.getDailyCount(today);
    final totalCount = await _settingsService.getTotalCount();
    final streakCount = await _settingsService.getStreak();

    final weekData = <DateTime, int>{};
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final count = await _settingsService.getDailyCount(date);
      weekData[date] = count;
    }

    // Son 4 hafta
    final monthData = <int, int>{};
    for (int i = 3; i >= 0; i--) {
      final weekStart = today.subtract(Duration(days: today.weekday - 1 + (i * 7)));
      int weekTotal = 0;
      for (int j = 0; j < 7; j++) {
        final day = weekStart.add(Duration(days: j));
        weekTotal += await _settingsService.getDailyCount(day);
      }
      monthData[i] = weekTotal;
    }

    // Son 12 ay
    final yearData = <int, int>{};
    for (int i = 11; i >= 0; i--) {
      final month = DateTime(today.year, today.month - i, 1);
      int monthTotal = 0;
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
      for (int j = 1; j <= daysInMonth; j++) {
        final day = DateTime(month.year, month.month, j);
        monthTotal += await _settingsService.getDailyCount(day);
      }
      yearData[i] = monthTotal;
    }

    final allGoals = await _settingsService.getGoals();
    final completedGoals = allGoals.where((g) => g.isCompleted).toList();
    final goalStreaks = await _settingsService.getGoalStreaks();

    setState(() {
      _todayCount = todayCount;
      _totalCount = totalCount;
      _streakCount = streakCount;
      _weekData = weekData;
      _monthData = monthData;
      _yearData = yearData;
      _completedGoals = completedGoals;
      _goalStreaks = goalStreaks;
    });
  }

  int _getGoalCount(String type) {
    return _completedGoals.where((g) => g.type == type).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: widget.themeConfig.backgroundGradient,
          image: (() {
            final isLightTheme = widget.themeConfig.textColor.computeLuminance() < 0.5;
            final asset = isLightTheme ? widget.themeConfig.lightBackgroundAsset : widget.themeConfig.darkBackgroundAsset;
            return asset != null
                ? DecorationImage(
                    image: AssetImage(asset),
                    fit: BoxFit.cover,
                    opacity: 0.12,
                  )
                : null;
          })(),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildStatCard(widget.localizations.today, _todayCount, Icons.today, Colors.blue),
                      const SizedBox(height: 12),
                      _buildStatCard(widget.localizations.total, _totalCount, Icons.all_inclusive, Colors.purple),
                      const SizedBox(height: 12),
                      _buildStatCard(widget.localizations.streak, _streakCount, Icons.local_fire_department, Colors.orange, isStreak: true),
                      const SizedBox(height: 20),
                      _buildStreakSection(),
                      const SizedBox(height: 20),
                      _buildTrophySection(),
                      const SizedBox(height: 20),
                      _buildPeriodSelector(),
                      const SizedBox(height: 8),
                      _buildChartTypeSelector(),
                      const SizedBox(height: 12),
                      _buildChart(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: widget.themeConfig.textColor),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Text(
            widget.localizations.statistics,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.themeConfig.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color, {bool isStreak = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.accentColor.withValues(alpha: 0.25),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.themeConfig.textColor.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  count.toString() + (isStreak ? ' ${widget.localizations.days}' : ''),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: widget.themeConfig.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildStreakSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.2),
            Colors.red.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.localizations.translate('achievement_streaks') ?? 'Achievement Streaks',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStreakItem(widget.localizations.dailyGoal, _goalStreaks['daily'] ?? 0, _goalStreaks['daily_best'] ?? 0, '🔥')),
              const SizedBox(width: 12),
              Expanded(child: _buildStreakItem(widget.localizations.weeklyGoal, _goalStreaks['weekly'] ?? 0, _goalStreaks['weekly_best'] ?? 0, '🎯')),
              const SizedBox(width: 12),
              Expanded(child: _buildStreakItem(widget.localizations.monthlyGoal, _goalStreaks['monthly'] ?? 0, _goalStreaks['monthly_best'] ?? 0, '⭐')),
            ],
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildStreakItem(String label, int current, int best, String emoji) {
    return Container(
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            current.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: widget.themeConfig.textColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (best > 0) const SizedBox(height: 2),
          if (best > 0)
            Text(
              '🏆 $best',
              style: TextStyle(
                fontSize: 10,
                color: Colors.yellow.withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrophySection() {
    final dailyCount = _getGoalCount('daily');
    final weeklyCount = _getGoalCount('weekly');
    final monthlyCount = _getGoalCount('monthly');

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.themeConfig.accentColor.withValues(alpha: 0.2),
            widget.themeConfig.primaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: widget.themeConfig.accentColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.localizations.trophies,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.themeConfig.accentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTrophyItem(widget.localizations.dailyGoal, dailyCount, '🏆', Colors.amber)),
              const SizedBox(width: 12),
              Expanded(child: _buildTrophyItem(widget.localizations.weeklyGoal, weeklyCount, '🥇', Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildTrophyItem(widget.localizations.monthlyGoal, monthlyCount, '👑', Colors.purple)),
            ],
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildTrophyItem(String label, int count, String emoji, Color color) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 6),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: widget.themeConfig.textColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPeriodButton('7 ${widget.localizations.days}', 'week'),
        const SizedBox(width: 8),
        _buildPeriodButton('4 ${widget.localizations.translate('weeks') ?? 'Weeks'}', 'month'),
        const SizedBox(width: 8),
        _buildPeriodButton('12 ${widget.localizations.translate('months') ?? 'Months'}', 'year'),
      ],
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? widget.themeConfig.goldGradient : null,
          color: isSelected ? null : widget.themeConfig.textColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? widget.themeConfig.accentColor : widget.themeConfig.textColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: widget.themeConfig.textColor,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChartTypeButton(Icons.bar_chart_rounded, 'bar'),
        const SizedBox(width: 8),
        _buildChartTypeButton(Icons.show_chart_rounded, 'line'),
      ],
    );
  }

  Widget _buildChartTypeButton(IconData icon, String type) {
    final isSelected = _chartType == type;
    return GestureDetector(
      onTap: () => setState(() => _chartType = type),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected ? widget.themeConfig.goldGradient : null,
          color: isSelected ? null : widget.themeConfig.textColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? widget.themeConfig.accentColor : widget.themeConfig.textColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: widget.themeConfig.textColor,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildChart() {
    switch (_selectedPeriod) {
      case 'month':
        return _chartType == 'line' ? _buildMonthLineChart() : _buildMonthChart();
      case 'year':
        return _chartType == 'line' ? _buildYearLineChart() : _buildYearChart();
      default:
        return _chartType == 'line' ? _buildWeekLineChart() : _buildWeekChart();
    }
  }

  Widget _buildMonthChart() {
    if (_monthData.isEmpty) return const SizedBox();

    final maxCount = _monthData.values.reduce((a, b) => a > b ? a : b);
    final maxY = math.max(10.0, maxCount.toDouble() * 1.2);
    final w = widget.localizations.translate('week_short') ?? 'W';
    final labels = ['${w}1', '${w}2', '${w}3', '${w}4'];
    final bars = _monthData.entries.map((entry) {
      final idx = 3 - entry.key;
      return BarChartGroupData(
        x: idx,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            gradient: widget.themeConfig.goldGradient,
            borderRadius: BorderRadius.circular(8),
            width: 16,
          ),
        ],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.localizations.translate('last_4_weeks') ?? 'Last 4 Weeks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.themeConfig.accentColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: widget.themeConfig.textColor.withOpacity(0.9),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                      rod.toY.toInt().toString(),
                      TextStyle(color: widget.themeConfig.accentColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i >= 0 && i < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(labels[i], style: TextStyle(color: widget.themeConfig.textColor.withValues(alpha: 0.7), fontSize: 10)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barGroups: bars,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthLineChart() {
    if (_monthData.isEmpty) return const SizedBox();

    final maxCount = _monthData.values.reduce((a, b) => a > b ? a : b);
    final maxY = math.max(10.0, maxCount.toDouble() * 1.2);
    final w = widget.localizations.translate('week_short') ?? 'W';
    final labels = ['${w}1', '${w}2', '${w}3', '${w}4'];

    final spots = <FlSpot>[];
    for (int i = 0; i < 4; i++) {
      final idx = i;
      final value = _monthData[3 - i]?.toDouble() ?? 0.0;
      spots.add(FlSpot(idx.toDouble(), value));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.localizations.translate('last_4_weeks') ?? 'Last 4 Weeks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.themeConfig.accentColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 3,
                minY: 0,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: widget.themeConfig.textColor.withValues(alpha: 0.9),
                    getTooltipItems: (touchedSpots) => touchedSpots
                        .map((ts) => LineTooltipItem(
                              ts.y.toInt().toString(),
                              TextStyle(color: widget.themeConfig.accentColor, fontWeight: FontWeight.bold),
                            ))
                        .toList(),
                  ),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i >= 0 && i < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(labels[i], style: TextStyle(color: widget.themeConfig.textColor.withValues(alpha: 0.7), fontSize: 10)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: widget.themeConfig.goldGradient,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearChart() {
    if (_yearData.isEmpty) return const SizedBox();

    final maxCount = _yearData.values.reduce((a, b) => a > b ? a : b);
    final maxY = math.max(10.0, maxCount.toDouble() * 1.2);
    final monthNames = [
      widget.localizations.translate('jan') ?? 'Jan',
      widget.localizations.translate('feb') ?? 'Feb',
      widget.localizations.translate('mar') ?? 'Mar',
      widget.localizations.translate('apr') ?? 'Apr',
      widget.localizations.translate('may') ?? 'May',
      widget.localizations.translate('jun') ?? 'Jun',
      widget.localizations.translate('jul') ?? 'Jul',
      widget.localizations.translate('aug') ?? 'Aug',
      widget.localizations.translate('sep') ?? 'Sep',
      widget.localizations.translate('oct') ?? 'Oct',
      widget.localizations.translate('nov') ?? 'Nov',
      widget.localizations.translate('dec') ?? 'Dec',
    ];
    final bars = <BarChartGroupData>[];
    int idx = 0;
    for (final entry in _yearData.entries) {
      bars.add(
        BarChartGroupData(
          x: idx,
          barRods: [
            BarChartRodData(
              toY: entry.value.toDouble(),
              gradient: widget.themeConfig.goldGradient,
              borderRadius: BorderRadius.circular(8),
              width: 12,
            ),
          ],
        ),
      );
      idx++;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.accentColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.localizations.translate('last_12_months') ?? 'Last 12 Months',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.themeConfig.accentColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: widget.themeConfig.textColor.withValues(alpha: 0.9),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                      rod.toY.toInt().toString(),
                      TextStyle(color: widget.themeConfig.accentColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i >= 0 && i < monthNames.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(monthNames[i], style: TextStyle(color: widget.themeConfig.textColor.withValues(alpha: 0.7), fontSize: 10)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barGroups: bars,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearLineChart() {
    if (_yearData.isEmpty) return const SizedBox();

    final maxCount = _yearData.values.reduce((a, b) => a > b ? a : b);
    final maxY = math.max(10.0, maxCount.toDouble() * 1.2);
    final monthNames = [
      widget.localizations.translate('jan') ?? 'Jan',
      widget.localizations.translate('feb') ?? 'Feb',
      widget.localizations.translate('mar') ?? 'Mar',
      widget.localizations.translate('apr') ?? 'Apr',
      widget.localizations.translate('may') ?? 'May',
      widget.localizations.translate('jun') ?? 'Jun',
      widget.localizations.translate('jul') ?? 'Jul',
      widget.localizations.translate('aug') ?? 'Aug',
      widget.localizations.translate('sep') ?? 'Sep',
      widget.localizations.translate('oct') ?? 'Oct',
      widget.localizations.translate('nov') ?? 'Nov',
      widget.localizations.translate('dec') ?? 'Dec',
    ];

    final spots = <FlSpot>[];
    int idx = 0;
    for (final entry in _yearData.entries) {
      spots.add(FlSpot(idx.toDouble(), entry.value.toDouble()));
      idx++;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.localizations.translate('last_12_months') ?? 'Last 12 Months',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.themeConfig.accentColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 11,
                minY: 0,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: widget.themeConfig.textColor.withValues(alpha: 0.9),
                    getTooltipItems: (touchedSpots) => touchedSpots
                        .map((ts) => LineTooltipItem(
                              ts.y.toInt().toString(),
                              TextStyle(color: widget.themeConfig.accentColor, fontWeight: FontWeight.bold),
                            ))
                        .toList(),
                  ),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i >= 0 && i < monthNames.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(monthNames[i], style: TextStyle(color: widget.themeConfig.textColor.withValues(alpha: 0.7), fontSize: 10)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: widget.themeConfig.goldGradient,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar2(String label, int count, double height) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 12,
            color: widget.themeConfig.textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: height.clamp(20, 100),
          decoration: BoxDecoration(
            gradient: widget.themeConfig.goldGradient,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: widget.themeConfig.textColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekChart() {
    if (_weekData.isEmpty) return const SizedBox();

    final maxCount = _weekData.values.reduce((a, b) => a > b ? a : b);
    final maxY = math.max(10.0, maxCount.toDouble() * 1.2);
    final dayLabels = [
      widget.localizations.mon,
      widget.localizations.tue,
      widget.localizations.wed,
      widget.localizations.thu,
      widget.localizations.fri,
      widget.localizations.sat,
      widget.localizations.sun,
    ];

    final bars = <BarChartGroupData>[];
    int index = 0;
    for (final entry in _weekData.entries) {
      final value = entry.value.toDouble();
      bars.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value,
              gradient: widget.themeConfig.goldGradient,
              borderRadius: BorderRadius.circular(8),
              width: 14,
            ),
          ],
        ),
      );
      index++;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.accentColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.localizations.last7Days,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.themeConfig.accentColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                   tooltipBgColor: widget.themeConfig.textColor.withValues(alpha: 0.85),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final count = rod.toY.toInt();
                      return BarTooltipItem(
                        count.toString(),
                        TextStyle(color: widget.themeConfig.accentColor, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (() {
                    final interval = maxCount.toDouble() / 4.0;
                    return interval < 1.0 ? 1.0 : interval;
                  })(),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (() {
                        final interval = maxCount.toDouble() / 4.0;
                        return interval < 1.0 ? 1.0 : interval;
                      })(),
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(color: widget.themeConfig.textColor.withOpacity(0.6), fontSize: 10),
                      ),
                      reservedSize: 28,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i >= 0 && i < dayLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(dayLabels[i], style: TextStyle(color: widget.themeConfig.textColor.withValues(alpha: 0.7), fontSize: 10)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                barGroups: bars,
                alignment: BarChartAlignment.spaceAround,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekLineChart() {
    if (_weekData.isEmpty) return const SizedBox();

    final maxCount = _weekData.values.reduce((a, b) => a > b ? a : b);
    final maxY = math.max(10.0, maxCount.toDouble() * 1.2);
    final dayLabels = [
      widget.localizations.mon,
      widget.localizations.tue,
      widget.localizations.wed,
      widget.localizations.thu,
      widget.localizations.fri,
      widget.localizations.sat,
      widget.localizations.sun,
    ];

    final spots = <FlSpot>[];
    int index = 0;
    for (final entry in _weekData.entries) {
      spots.add(FlSpot(index.toDouble(), entry.value.toDouble()));
      index++;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.localizations.last7Days,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.themeConfig.accentColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: widget.themeConfig.textColor.withValues(alpha: 0.85),
                    getTooltipItems: (touchedSpots) => touchedSpots
                        .map((ts) => LineTooltipItem(
                              ts.y.toInt().toString(),
                              TextStyle(color: widget.themeConfig.accentColor, fontWeight: FontWeight.bold),
                            ))
                        .toList(),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (() {
                    final interval = maxCount.toDouble() / 4.0;
                    return interval < 1.0 ? 1.0 : interval;
                  })(),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (() {
                        final interval = maxCount.toDouble() / 4.0;
                        return interval < 1.0 ? 1.0 : interval;
                      })(),
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(color: widget.themeConfig.textColor.withValues(alpha: 0.6), fontSize: 10),
                      ),
                      reservedSize: 28,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i >= 0 && i < dayLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(dayLabels[i], style: TextStyle(color: widget.themeConfig.textColor.withValues(alpha: 0.7), fontSize: 10)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: widget.themeConfig.goldGradient,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(DateTime date, int count, double height) {
    final dayNames = [
      widget.localizations.mon,
      widget.localizations.tue,
      widget.localizations.wed,
      widget.localizations.thu,
      widget.localizations.fri,
      widget.localizations.sat,
      widget.localizations.sun,
    ];
    final dayName = dayNames[date.weekday - 1];
    
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 12,
            color: widget.themeConfig.textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: height.clamp(20, 100),
          decoration: BoxDecoration(
            gradient: widget.themeConfig.goldGradient,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          dayName,
          style: TextStyle(
            fontSize: 10,
            color: widget.themeConfig.textColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
