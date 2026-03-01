import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import 'dart:math';

class StatisticsScreenNew extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String currentUserId;

  const StatisticsScreenNew({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.currentUserId,
  });

  @override
  State<StatisticsScreenNew> createState() => _StatisticsScreenNewState();
}

class _StatisticsScreenNewState extends State<StatisticsScreenNew> {
  int _totalZikrs = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;
  DateTime? _lastZikrDate;
  bool _isLoading = true;
  
  // Yeni özellikler
  int _weeklyZikrs = 0;
  int _monthlyZikrs = 0;
  int _yearlyZikrs = 0;
  double _dailyAverage = 0.0;
  List<Map<String, dynamic>> _weeklyData = [];
  List<Map<String, dynamic>> _monthlyData = [];
  Map<String, int> _hourlyDistribution = {};
  String _mostProductiveDay = '';
  String _mostProductiveHour = '';

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final totalZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      final lastZikrDateStr = prefs.getString('last_zikr_date_${widget.currentUserId}');
      
      DateTime? lastZikrDate;
      if (lastZikrDateStr != null) {
        lastZikrDate = DateTime.parse(lastZikrDateStr);
      }
      
      // Gelişmiş streak hesaplaması
      int currentStreak = 0;
      int longestStreak = 0;
      
      if (lastZikrDate != null) {
        final now = DateTime.now();
        final difference = now.difference(lastZikrDate!).inDays;
        
        if (difference <= 1) {
          currentStreak = 1; // Bugün veya dün zikir çekilmiş
        }
        
        // En uzun streak (basit hesaplama)
        longestStreak = (totalZikrs / 100).floor(); // Her 100 zikirde 1 gün varsayımı
      }
      
      // Haftalık ve aylık veriler
      final weeklyZikrs = _calculateWeeklyZikrs(prefs);
      final monthlyZikrs = _calculateMonthlyZikrs(prefs);
      final yearlyZikrs = _calculateYearlyZikrs(prefs);
      
      // Günlük ortalama
      final dailyAverage = _calculateDailyAverage(totalZikrs);
      
      // Haftalık ve aylık veri listeleri
      final weeklyData = _generateWeeklyData();
      final monthlyData = _generateMonthlyData();
      
      // Saatlik dağılım
      final hourlyDistribution = _generateHourlyDistribution();
      
      // En verimli gün ve saat
      final mostProductiveDay = _findMostProductiveDay();
      final mostProductiveHour = _findMostProductiveHour();
      
      setState(() {
        _totalZikrs = totalZikrs;
        _currentStreak = currentStreak;
        _longestStreak = longestStreak;
        _lastZikrDate = lastZikrDate;
        _weeklyZikrs = weeklyZikrs;
        _monthlyZikrs = monthlyZikrs;
        _yearlyZikrs = yearlyZikrs;
        _dailyAverage = dailyAverage;
        _weeklyData = weeklyData;
        _monthlyData = monthlyData;
        _hourlyDistribution = hourlyDistribution;
        _mostProductiveDay = mostProductiveDay;
        _mostProductiveHour = mostProductiveHour;
        _isLoading = false;
      });
      
      print('Statistics loaded: total=$totalZikrs, weekly=$weeklyZikrs, monthly=$monthlyZikrs');
      
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Yeni yardımcı metodlar
  int _calculateWeeklyZikrs(SharedPreferences prefs) {
    final totalZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
    return (totalZikrs * 0.3).round(); // Yaklaşık %30'u bu hafta
  }

  int _calculateMonthlyZikrs(SharedPreferences prefs) {
    final totalZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
    return (totalZikrs * 0.7).round(); // Yaklaşık %70'i bu ay
  }

  int _calculateYearlyZikrs(SharedPreferences prefs) {
    final totalZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
    return totalZikrs; // Toplam zikirler (yıl başında sıfırlanmadı)
  }

  double _calculateDailyAverage(int totalZikrs) {
    final days = max(1, DateTime.now().difference(DateTime(2024, 1, 1)).inDays);
    return totalZikrs / days;
  }

  List<Map<String, dynamic>> _generateWeeklyData() {
    final now = DateTime.now();
    final weekData = <Map<String, dynamic>>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final zikrs = Random().nextInt(100); // Simüle edilmiş veri
      weekData.add({
        'day': _getDayName(date.weekday),
        'date': date,
        'zikrs': zikrs,
      });
    }
    
    return weekData;
  }

  List<Map<String, dynamic>> _generateMonthlyData() {
    final now = DateTime.now();
    final monthData = <Map<String, dynamic>>[];
    
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final zikrs = Random().nextInt(500); // Simüle edilmiş veri
      monthData.add({
        'month': _getMonthName(date.month),
        'date': date,
        'zikrs': zikrs,
      });
    }
    
    return monthData;
  }

  Map<String, int> _generateHourlyDistribution() {
    final distribution = <String, int>{};
    
    for (int hour = 0; hour < 24; hour++) {
      distribution['$hour:00'] = Random().nextInt(50); // Simüle edilmiş veri
    }
    
    return distribution;
  }

  String _findMostProductiveDay() {
    if (_weeklyData.isEmpty) return 'Pazartesi';
    
    final maxEntry = _weeklyData.reduce((a, b) => 
        (a['zikrs'] as int) > (b['zikrs'] as int) ? a : b);
    return maxEntry['day'] as String;
  }

  String _findMostProductiveHour() {
    if (_hourlyDistribution.isEmpty) return '06:00';
    
    final maxEntry = _hourlyDistribution.entries.reduce((a, b) => 
        a.value > b.value ? a : b);
    return maxEntry.key;
  }

  String _getDayName(int weekday) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: widget.themeConfig.backgroundGradient,
        ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.themeConfig.accentColor,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: widget.themeConfig.textColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'İstatistikler',
                          style: GoogleFonts.notoSans(
                            color: widget.themeConfig.textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Ana İstatistikler
                    _buildMainStats(),
                    
                    const SizedBox(height: 20),
                    
                    // Haftalık Grafik
                    _buildWeeklyChart(),
                    
                    const SizedBox(height: 20),
                    
                    // Detaylı İstatistikler
                    _buildDetailedStats(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMainStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.themeConfig.accentColor.withOpacity(0.2),
            widget.themeConfig.accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.accentColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Toplam', '$_totalZikrs', Icons.auto_awesome),
              _buildStatItem('Haftalık', '$_weeklyZikrs', Icons.date_range),
              _buildStatItem('Aylık', '$_monthlyZikrs', Icons.calendar_month),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Günlük Ort.', '${_dailyAverage.toStringAsFixed(1)}', Icons.trending_up),
              _buildStatItem('Streak', '$_currentStreak', Icons.local_fire_department),
              _buildStatItem('Seviye', '${_calculateUserLevel()}', Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: widget.themeConfig.accentColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Haftalık Grafiği',
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _weeklyData.length,
              itemBuilder: (context, index) {
                final data = _weeklyData[index];
                return Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 10),
                  child: Column(
                    children: [
                      Text(
                        data['day'],
                        style: GoogleFonts.notoSans(
                          color: widget.themeConfig.textColor.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 80,
                        width: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.themeConfig.accentColor,
                              widget.themeConfig.accentColor.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: (data['zikrs'] as int) / 100.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: widget.themeConfig.accentColor.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${data['zikrs']}',
                        style: GoogleFonts.notoSans(
                          color: widget.themeConfig.textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detaylı İstatistikler',
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow('En Verimli Gün', _mostProductiveDay),
          _buildDetailRow('En Verimli Saat', _mostProductiveHour),
          _buildDetailRow('Son Zikir', _lastZikrDate != null 
              ? '${_lastZikrDate!.day}/${_lastZikrDate!.month}/${_lastZikrDate!.year}'
              : 'Yok'),
          _buildDetailRow('Toplam Gün', _lastZikrDate != null 
              ? '${DateTime.now().difference(_lastZikrDate!).inDays + 1}'
              : '0'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateUserLevel() {
    if (_totalZikrs >= 10000) return 5;
    if (_totalZikrs >= 5000) return 4;
    if (_totalZikrs >= 1000) return 3;
    if (_totalZikrs >= 500) return 2;
    if (_totalZikrs >= 100) return 1;
    return 0;
  }
}
