import 'package:flutter/material.dart';
import '../models/theme_model.dart';
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

    setState(() {
      _todayCount = todayCount;
      _totalCount = totalCount;
      _streakCount = streakCount;
      _weekData = weekData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: widget.themeConfig.backgroundGradient,
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
                      _buildStatCard('Today', _todayCount, Icons.today),
                      const SizedBox(height: 16),
                      _buildStatCard('Total', _totalCount, Icons.all_inclusive),
                      const SizedBox(height: 16),
                      _buildStatCard('Streak', _streakCount, Icons.local_fire_department, isStreak: true),
                      const SizedBox(height: 24),
                      _buildWeekChart(),
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
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Text(
            'Statistics',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, {bool isStreak = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.accentColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: widget.themeConfig.goldGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                count.toString() + (isStreak ? ' days' : ''),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: widget.themeConfig.accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekChart() {
    if (_weekData.isEmpty) return const SizedBox();

    final maxCount = _weekData.values.reduce((a, b) => a > b ? a : b);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
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
            'Last 7 Days',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.themeConfig.accentColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _weekData.entries.map((entry) {
              final height = maxCount > 0 ? (entry.value / maxCount) * 100.0 : 0.0;
              return _buildBar(entry.key, entry.value, height);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(DateTime date, int count, double height) {
    final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
    
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
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
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}
