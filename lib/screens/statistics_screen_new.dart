import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';

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
  // Streak sistemi kaldırıldı - kafa karıştırıcıydı
  int _currentStreak = 0; // Geriye dönük uyumluluk için
  int _longestStreak = 0; // Geriye dönük uyumluluk için
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
  int _activeDaysCount = 0;

  String get _notAvailableText => widget.localizations.translate('statistics_no_data');

  String _getStatisticsTitle() {
    return DynamicLocalizationHelper.statistics;
  }

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  @override
  void dispose() {
    // Route kapanırken SnackBar'ın önceki ekranda kalmaması için.
    try {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
    } catch (_) {
      // dispose sırasında context değişmiş olabilir.
    }
    super.dispose();
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
      
      // Haftalık ve aylık veriler (gerçek local sayaçlardan)
      final weeklyData = _generateWeeklyData(prefs);
      final monthlyData = _generateMonthlyData(prefs);
      final weeklyZikrs = weeklyData.fold<int>(0, (sum, item) => sum + ((item['zikrs'] as int?) ?? 0));
      final monthlyZikrs = monthlyData.isNotEmpty ? ((monthlyData.last['zikrs'] as int?) ?? 0) : 0;
      final yearlyZikrs = _calculateYearlyZikrs(prefs);
      
      // Günlük ortalama (ilk aktivite gününe göre)
      final dailyAverage = _calculateDailyAverage(totalZikrs, prefs);
      
      // Saatlik dağılım
      final hourlyDistribution = _generateHourlyDistribution(prefs);
      
      // En verimli gün ve saat
      final mostProductiveDay = _findMostProductiveDay();
      final mostProductiveHour = _findMostProductiveHour();
      final activeDaysCount = _calculateActiveDaysCount(prefs);
      
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
        _activeDaysCount = activeDaysCount;
        _isLoading = false;
      });
      
      debugPrint('Statistics loaded: total=$totalZikrs, weekly=$weeklyZikrs, monthly=$monthlyZikrs');
      
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Yeni yardımcı metodlar
  int _calculateYearlyZikrs(SharedPreferences prefs) {
    int yearly = 0;
    final now = DateTime.now();
    for (final key in prefs.getKeys()) {
      if (!key.startsWith('daily_count_')) continue;
      final parts = key.split('_');
      if (parts.length < 6) continue;
      final year = int.tryParse(parts[2]);
      if (year == now.year) {
        yearly += prefs.getInt(key) ?? 0;
      }
    }
    return yearly;
  }

  double _calculateDailyAverage(int totalZikrs, SharedPreferences prefs) {
    DateTime? firstDate;
    for (final key in prefs.getKeys()) {
      if (!key.startsWith('daily_count_')) continue;
      final parts = key.split('_');
      if (parts.length < 6) continue;
      final y = int.tryParse(parts[2]);
      final m = int.tryParse(parts[3]);
      final d = int.tryParse(parts[4]);
      if (y == null || m == null || d == null) continue;
      final value = prefs.getInt(key) ?? 0;
      if (value <= 0) continue;
      final date = DateTime(y, m, d);
      if (firstDate == null || date.isBefore(firstDate)) {
        firstDate = date;
      }
    }
    if (firstDate == null) return totalZikrs.toDouble();
    final activeDays = DateTime.now().difference(firstDate).inDays + 1;
    return totalZikrs / (activeDays <= 0 ? 1 : activeDays);
  }

  List<Map<String, dynamic>> _generateWeeklyData(SharedPreferences prefs) {
    final now = DateTime.now();
    final weekData = <Map<String, dynamic>>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = 'daily_count_${date.year}_${date.month}_${date.day}';
      final zikrs = prefs.getInt(key) ?? 0;
      weekData.add({
        'day': _getDayName(date.weekday),
        'date': date,
        'zikrs': zikrs,
      });
    }
    
    return weekData;
  }

  List<Map<String, dynamic>> _generateMonthlyData(SharedPreferences prefs) {
    final now = DateTime.now();
    final monthData = <Map<String, dynamic>>[];
    
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final key = 'monthly_${date.year}_${date.month}';
      final zikrs = prefs.getInt(key) ?? 0;
      monthData.add({
        'month': _getMonthName(date.month),
        'date': date,
        'zikrs': zikrs,
      });
    }
    
    return monthData;
  }

  Map<String, int> _generateHourlyDistribution(SharedPreferences prefs) {
    final distribution = <String, int>{};
    
    for (int hour = 0; hour < 24; hour++) {
      final key = 'hourly_count_${widget.currentUserId}_$hour';
      distribution['$hour:00'] = prefs.getInt(key) ?? 0;
    }
    
    return distribution;
  }

  String _findMostProductiveDay() {
    if (_weeklyData.isEmpty) {
      return _notAvailableText;
    }
    
    final maxEntry = _weeklyData.reduce((a, b) => 
        (a['zikrs'] as int) > (b['zikrs'] as int) ? a : b);
    if ((maxEntry['zikrs'] as int? ?? 0) <= 0) {
      return _notAvailableText;
    }
    return maxEntry['day'] as String;
  }

  String _findMostProductiveHour() {
    if (_hourlyDistribution.isEmpty) return _notAvailableText;
    
    final maxEntry = _hourlyDistribution.entries.reduce((a, b) => 
        a.value > b.value ? a : b);
    if (maxEntry.value <= 0) return _notAvailableText;
    return maxEntry.key;
  }

  int _calculateActiveDaysCount(SharedPreferences prefs) {
    int activeDays = 0;
    for (final key in prefs.getKeys()) {
      if (!key.startsWith('daily_count_')) continue;
      final value = prefs.getInt(key) ?? 0;
      if (value > 0) activeDays++;
    }
    return activeDays;
  }

  String _getDayName(int weekday) {
    final days = DynamicLocalizationHelper.getText({
      'tr': 'Pzt,Sal,Çar,Per,Cum,Cmt,Paz',
      'en': 'Mon,Tue,Wed,Thu,Fri,Sat,Sun',
      'ar': 'إث,ثلا,أرب,خم,جم,سب,أحد',
      'id': 'Sen,Sel,Rab,Kam,Jum,Sab,Ming',
      'ur': 'پیر,منگل,بدھ,جمعرات,جمعہ,ہفتہ,اتوار',
      'bn': 'সোম,মঙ্গল,বুধ,বৃহস্পতিবার,শুক্রবার,শনিবার,রবিবার',
      'ms': 'Isn,Sel,Rab,Kha,Jum,Sab,Ahd',
      'fa': 'دوشنبه,سه شنبه,چهارشنبه,پنجشنبه,جمعه,شنبه,یکشنبه',
      'fr': 'Lun,Mar,Mer,Jeu,Ven,Sam,Dim',
      'zh': '周一,周二,周三,周四,周五,周六,周日',
      'ja': '月,火,水,木,金,土,日',
      'ru': 'Пн,Вт,Ср,Чт,Пт,Сб,Вс',
      'de': 'Mo,Di,Mi,Do,Fr,Sa,So',
      'sw': 'Jtn,Jn,Jt,Alh,Ijm,Jum,Jkp',
      'ha': 'Lit,Tal,Lar,Alh,Jum,Asi,Lah',
    }).split(',');
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    final months = DynamicLocalizationHelper.getText({
      'tr': 'Oca,Şub,Mar,Nis,May,Haz,Tem,Ağu,Eyl,Eki,Kas,Ara',
      'en': 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec',
      'ar': 'يناير,فبراير,مارس,أبريل,مايو,يونيو,يوليو,أغسطس,سبتمبر,أكتوبر,نوفمبر,ديسمبر',
      'id': 'Jan,Feb,Mar,Apr,Mei,Jun,Jul,Agu,Sep,Okt,Nov,Des',
      'ur': 'جنوری,فروری,مارچ,اپریل,مئی,جون,جولائی,اگست,ستمبر,اکتوبر,نومبر,دسمبر',
      'bn': 'জানুয়ারী,ফেব্রুয়ারী,মার্চ,এপ্রিল,মে,জুন,জুলাই,আগস্ট,সেপ্টেম্বর,অক্টোবর,নভেম্বর,ডিসেম্বর',
      'ms': 'Jan,Feb,Mac,Apr,Mei,Jun,Jul,Ogos,Sept,Okt,Nov,Dis',
      'fa': 'ژانویه,فوریه,مارس,آوریل,مه,ژوئن,ژوئیه,اوت,سپتامبر,اکتبر,نوامبر,دسامبر',
      'fr': 'Jan,Fév,Mar,Avr,Mai,Juin,Juil,Août,Sep,Oct,Nov,Déc',
      'zh': '一月,二月,三月,四月,五月,六月,七月,八月,九月,十月,十一月,十二月',
      'ja': '1月,2月,3月,4月,5月,6月,7月,8月,9月,10月,11月,12月',
      'ru': 'Янв,Фев,Мар,Апр,Май,Июн,Июл,Авг,Сен,Окт,Ноя,Дек',
      'de': 'Jan,Feb,Mär,Apr,Mai,Jun,Jul,Aug,Sep,Okt,Nov,Dez',
      'sw': 'Jan,Feb,Mac,Apr,Mei,Jun,Jul,Ago,Sept,Okt,Nov,Dis',
      'ha': 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Okt,Nov,Dis',
    }).split(',');
    return months[month - 1];
  }

  Future<void> _exportStatistics() async {
    try {
      // Aynı anda birden fazla SnackBar birikmesin.
      try {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      } catch (_) {}

      // İstatistik verilerini oluştur
      final stats = {
        'total_zikrs': _totalZikrs,
        'current_streak': _currentStreak,
        'longest_streak': _longestStreak,
        'last_zikr_date': _lastZikrDate?.toIso8601String(),
        'export_date': DateTime.now().toIso8601String(),
        'weekly_zikrs': _weeklyZikrs,
        'monthly_zikrs': _monthlyZikrs,
        'yearly_zikrs': _yearlyZikrs,
        'daily_average': _dailyAverage,
        'weekly_data': _weeklyData,
        'monthly_data': _monthlyData,
        'hourly_distribution': _hourlyDistribution,
        'most_productive_day': _mostProductiveDay,
        'most_productive_hour': _mostProductiveHour,
      };

      // JSON formatında veriyi string'e çevir
      String jsonStats = _formatStatsAsJson(stats);

      final fileName = 'statistics_${DateTime.now().millisecondsSinceEpoch}.json';

      // 1) Önce platformun uygun "Downloads" dizinine yazmayı dene.
      // 2) Yazma başarısız olursa (Android scoped storage/izin) kullanıcıya kaydetme yeri seçtir.
      String? savedPath;
      try {
        final directory = await getDownloadsDirectory();
        if (directory != null) {
          final file = File('${directory.path}/$fileName');
          await file.writeAsString(jsonStats);
          savedPath = file.path;
        }
      } catch (_) {
        // Fallback'a geçilecek.
      }

      savedPath ??= await (() async {
        final bytes = Uint8List.fromList(utf8.encode(jsonStats));
        return await FilePicker.platform.saveFile(
          type: FileType.custom,
          allowedExtensions: ['json'],
          bytes: bytes,
          fileName: fileName,
        );
      })();

      if (savedPath != null && savedPath.isNotEmpty) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('İstatistikler kaydedildi: $savedPath'),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      TextButton(
                        onPressed: () {
                          messenger.removeCurrentSnackBar();
                          _shareStats(savedPath!);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text('Paylaş'),
                      ),
                      TextButton(
                        onPressed: () => messenger.removeCurrentSnackBar(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(DynamicLocalizationHelper.close),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('İstatistikler kaydedilemedi.'),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => messenger.removeCurrentSnackBar(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(DynamicLocalizationHelper.close),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error exporting statistics: $e');
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('İstatistikler kaydedilemedi.'),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => messenger.removeCurrentSnackBar(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(DynamicLocalizationHelper.close),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  String _formatStatsAsJson(Map<String, dynamic> stats) {
    String json = '{\n';
    stats.forEach((key, value) {
      json += '  "$key": ${value is String ? '"$value"' : value},\n';
    });
    if (stats.isNotEmpty) {
      json = json.substring(0, json.length - 2); // Son virgülü kaldır
    }
    json += '\n}';
    return json;
  }

  Future<void> _shareStats(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      debugPrint('Error sharing statistics: $e');
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Paylaşım başarısız.'),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => messenger.removeCurrentSnackBar(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(DynamicLocalizationHelper.close),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).removeCurrentSnackBar();
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: widget.themeConfig.textColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _getStatisticsTitle(),
                          style: GoogleFonts.notoSans(
                            color: widget.themeConfig.textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _exportStatistics,
                          icon: Icon(
                            Icons.download,
                            color: widget.themeConfig.textColor,
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
            children: [
              Expanded(
                child: _buildCoreStatCard(
                  icon: Icons.auto_awesome,
                  value: '$_totalZikrs',
                  title: DynamicLocalizationHelper.getText({
                    'tr': 'Toplam',
                    'en': 'Total',
                    'ar': 'المجموع',
                    'id': 'Total',
                    'ur': 'کل',
                    'bn': 'মোট',
                    'ms': 'Jumlah',
                    'fa': 'مجموع',
                    'fr': 'Total',
                    'zh': '总计',
                    'ja': '合計',
                    'ru': 'Всего',
                    'de': 'Gesamt',
                    'sw': 'Jumla',
                    'ha': 'Duka Cikin',
                  }),
                  subtitle: DynamicLocalizationHelper.getText({
                    'tr': 'Tüm zikirler',
                    'en': 'All dhikr',
                    'ar': 'كل الأذكار',
                    'id': 'Semua zikir',
                    'ur': 'تمام اذکار',
                    'bn': 'সকল জিকির',
                    'ms': 'Semua zikir',
                    'fa': 'کل ذکرها',
                    'fr': 'Tous les dhikr',
                    'zh': '全部赞念',
                    'ja': 'すべてのジクル',
                    'ru': 'Все зикры',
                    'de': 'Alle Dhikr',
                    'sw': 'Dhikr zote',
                    'ha': 'Dukkan zikiri',
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCoreStatCard(
                  icon: Icons.date_range,
                  value: '$_weeklyZikrs',
                  title: DynamicLocalizationHelper.getText({
                    'tr': 'Haftalık',
                    'en': 'Weekly',
                    'ar': 'أسبوعي',
                    'id': 'Mingguan',
                    'ur': 'ہفتہ وار',
                    'bn': 'সাপ্তাহিক',
                    'ms': 'Mingguan',
                    'fa': 'هفتگی',
                    'fr': 'Hebdomadaire',
                    'zh': '每周',
                    'ja': '週間',
                    'ru': 'Еженедельно',
                    'de': 'Wöchentlich',
                    'sw': 'Kila Wiki',
                    'ha': 'Makon Sati',
                  }),
                  subtitle: DynamicLocalizationHelper.getText({
                    'tr': 'Son 7 gün',
                    'en': 'Last 7 days',
                    'ar': 'آخر 7 أيام',
                    'id': '7 hari terakhir',
                    'ur': 'گزشتہ 7 دن',
                    'bn': 'শেষ ৭ দিন',
                    'ms': '7 hari terakhir',
                    'fa': '۷ روز اخیر',
                    'fr': '7 derniers jours',
                    'zh': '最近 7 天',
                    'ja': '直近7日間',
                    'ru': 'Последние 7 дней',
                    'de': 'Letzte 7 Tage',
                    'sw': 'Siku 7 zilizopita',
                    'ha': 'Kwanaki 7 da suka wuce',
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildCoreStatCard(
                  icon: Icons.calendar_month,
                  value: '$_monthlyZikrs',
                  title: DynamicLocalizationHelper.getText({
                    'tr': 'Aylık',
                    'en': 'Monthly',
                    'ar': 'شهري',
                    'id': 'Bulanan',
                    'ur': 'ماہانہ',
                    'bn': 'মাসিক',
                    'ms': 'Bulanan',
                    'fa': 'ماهانه',
                    'fr': 'Mensuel',
                    'zh': '每月',
                    'ja': '月次',
                    'ru': 'Ежемесячно',
                    'de': 'Monatlich',
                    'sw': 'Kila Mwezi',
                    'ha': 'Wata',
                  }),
                  subtitle: DynamicLocalizationHelper.getText({
                    'tr': 'Bu ay',
                    'en': 'This month',
                    'ar': 'هذا الشهر',
                    'id': 'Bulan ini',
                    'ur': 'اس ماہ',
                    'bn': 'এই মাস',
                    'ms': 'Bulan ini',
                    'fa': 'این ماه',
                    'fr': 'Ce mois-ci',
                    'zh': '本月',
                    'ja': '今月',
                    'ru': 'Этот месяц',
                    'de': 'Dieser Monat',
                    'sw': 'Mwezi huu',
                    'ha': 'Wannan wata',
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCoreStatCard(
                  icon: Icons.trending_up,
                  value: _dailyAverage <= 0 ? '0.0' : _dailyAverage.toStringAsFixed(1),
                  title: DynamicLocalizationHelper.getText({
                    'tr': 'Günlük Ort.',
                    'en': 'Daily Avg.',
                    'ar': 'المتوسط اليومي',
                    'id': 'Rata-rata Harian',
                    'ur': 'روزانہ اوسط',
                    'bn': 'দৈনিক গড়',
                    'ms': 'Purata Harian',
                    'fa': 'میانگین روزانه',
                    'fr': 'Moyenne Journalière',
                    'zh': '日均',
                    'ja': '日平均',
                    'ru': 'Среднее Дневное',
                    'de': 'Tagesdurchschnitt',
                    'sw': 'Wastani wa Siku',
                    'ha': 'Matsakaicin Tsakila',
                  }),
                  subtitle: DynamicLocalizationHelper.getText({
                    'tr': 'Aktif gün ortalaması',
                    'en': 'Active-day average',
                    'ar': 'متوسط الأيام النشطة',
                    'id': 'Rata-rata hari aktif',
                    'ur': 'فعال دنوں کی اوسط',
                    'bn': 'সক্রিয় দিনের গড়',
                    'ms': 'Purata hari aktif',
                    'fa': 'میانگین روزهای فعال',
                    'fr': 'Moyenne des jours actifs',
                    'zh': '活跃日均值',
                    'ja': 'アクティブ日平均',
                    'ru': 'Среднее за активные дни',
                    'de': 'Aktive-Tage-Durchschnitt',
                    'sw': 'Wastani wa siku hai',
                    'ha': 'Matsakaicin ranakun aiki',
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoreStatCard({
    required IconData icon,
    required String value,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: widget.themeConfig.accentColor, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor.withValues(alpha: 0.78),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor.withValues(alpha: 0.62),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final maxZikrs = _weeklyData.fold<int>(0, (max, item) {
      final v = item['zikrs'] as int? ?? 0;
      return v > max ? v : max;
    });
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
            DynamicLocalizationHelper.getText({
              'tr': 'Haftalık Grafiği',
              'en': 'Weekly Chart',
              'ar': 'رسم بياني أسبوعي',
              'id': 'Grafik Mingguan',
              'ur': 'ہفتہ وار گراف',
              'bn': 'সাপ্তাহিক গ্রাফ',
              'ms': 'Carta Mingguan',
              'fa': 'نمودار هفتگی',
              'fr': 'Graphique Hebdomadaire',
              'zh': '周图表',
              'ja': '週間チャート',
              'ru': 'Еженедельный График',
              'de': 'Wochengrafik',
              'sw': 'Chati ya Wiki',
              'ha': 'Makon Saiti',
            }),
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
                            heightFactor: maxZikrs <= 0
                                ? 0.0
                                : ((data['zikrs'] as int?) ?? 0) / maxZikrs,
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
            DynamicLocalizationHelper.getText({
              'tr': 'Detaylı İstatistikler',
              'en': 'Detailed Statistics',
              'ar': 'إحصائيات مفصلة',
              'id': 'Statistik Detail',
              'ur': 'تفصیلی احصائیات',
              'bn': 'বিস্তারিত পরিসংখ্যান',
              'ms': 'Statistik Terperinci',
              'fa': 'آمار دقیق',
              'fr': 'Statistiques Détaillées',
              'zh': '详细统计',
              'ja': '詳細な統計',
              'ru': 'Подробная Статистика',
              'de': 'Detaillierte Statistik',
              'sw': 'Takwimu Zaidi',
              'ha': 'Statistics Cikak',
            }),
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            DynamicLocalizationHelper.getText({
              'tr': 'En Verimli Gün',
              'en': 'Most Productive Day',
              'ar': 'أكثر يوم إنتاجية',
              'id': 'Hari Paling Produktif',
              'ur': 'سب سے زیادہ پیداوار دن',
              'bn': 'সবচেয়ে উৎপাদনশীল দিন',
              'ms': 'Hari Paling Produktif',
              'fa': 'مولدترین روز',
              'fr': 'Jour le Plus Productif',
              'zh': '最高效的一天',
              'ja': '最も生産性の高い日',
              'ru': 'Самый Продуктивный День',
              'de': 'Produktivster Tag',
              'sw': 'Siku Iliyozalisha Zaidi',
              'ha': 'Ran Mafi Yawwa',
            }), 
            _mostProductiveDay
          ),
          _buildDetailRow(
            DynamicLocalizationHelper.getText({
              'tr': 'En Verimli Saat',
              'en': 'Most Productive Hour', 
              'ar': 'أكثر ساعة إنتاجية',
              'id': 'Jam Paling Produktif',
              'ur': 'سب سے زیادہ پیداوار گھنٹہ',
              'bn': 'সবচেয়ে উৎপাদনশীল ঘন্টা',
              'ms': 'Jam Paling Produktif',
              'fa': 'مولدترین ساعت',
              'fr': 'Heure la Plus Productive',
              'zh': '最高效的一小时',
              'ja': '最も生産性の高い時間',
              'ru': 'Самый Продуктивный Час',
              'de': 'Produktivste Stunde',
              'sw': 'Saa Iliyozalisha Zaidi',
              'ha': 'Lokaci Mafi Yawwa',
            }), 
            _mostProductiveHour
          ),
          if (_mostProductiveHour != _notAvailableText) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                DynamicLocalizationHelper.getText({
                  'tr': 'Not: Bu değer cihaz içi toplulaştırılmış sayaçlardan üretilen tahmini bilgidir.',
                  'en': 'Note: This value is an estimate produced from on-device aggregated counters.',
                  'ar': 'ملاحظة: هذه القيمة تقديرية ومشتقة من عدادات مجمعة على الجهاز.',
                  'id': 'Catatan: Nilai ini adalah estimasi dari penghitung agregat di perangkat.',
                  'ur': 'نوٹ: یہ قدر ڈیوائس کے مجموعی کاؤنٹرز سے تیار کردہ تخمینی معلومات ہے۔',
                  'bn': 'নোট: এটি ডিভাইসের সমষ্টিগত কাউন্টার থেকে তৈরি একটি আনুমানিক মান।',
                  'ms': 'Nota: Nilai ini ialah anggaran daripada kaunter agregat pada peranti.',
                  'fa': 'توجه: این مقدار یک برآورد مبتنی بر شمارنده‌های تجمیعی داخل دستگاه است.',
                  'fr': 'Note: cette valeur est une estimation issue des compteurs agrégés sur l’appareil.',
                  'zh': '说明：该值为基于设备本地汇总计数的估算结果。',
                  'ja': '注: この値は端末内の集計カウンターから算出した推定値です。',
                  'ru': 'Примечание: это оценка на основе агрегированных счетчиков на устройстве.',
                  'de': 'Hinweis: Dieser Wert ist eine Schätzung aus aggregierten Geräte-Zählern.',
                  'sw': 'Kumbuka: Thamani hii ni makadirio kutoka kwa vihesabu vilivyojumlishwa ndani ya kifaa.',
                  'ha': 'Lura: Wannan kimantawa ce daga kididdigar da aka tara a cikin na’ura.',
                }),
                style: GoogleFonts.notoSans(
                  color: widget.themeConfig.textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ),
          ],
          _buildDetailRow(
            DynamicLocalizationHelper.getText({
              'tr': 'Son Zikir',
              'en': 'Last Dhikr',
              'ar': 'آخر ذكر',
              'id': 'Zikir Terakhir',
              'ur': 'آخری ذکر',
              'bn': 'সর্বশেষ জিকির',
              'ms': 'Zikir Terakhir',
              'fa': 'آخرین ذکر',
              'fr': 'Dernier Dhikr',
              'zh': '最后赞念',
              'ja': '最後のジクル',
              'ru': 'Последний Зикр',
              'de': 'Letzter Dhikr',
              'sw': 'Dhikr ya Mwisho',
              'ha': 'Zikir Na Karshe',
            }), 
            _lastZikrDate != null 
                ? '${_lastZikrDate!.day}/${_lastZikrDate!.month}/${_lastZikrDate!.year}'
                : DynamicLocalizationHelper.getText({
                    'tr': 'Yok',
                    'en': 'None',
                    'ar': 'لا شيء',
                    'id': 'Tidak Ada',
                    'ur': 'کچھ نہیں',
                    'bn': 'নেই',
                    'ms': 'Tiada',
                    'fa': 'هیچ',
                    'fr': 'Aucun',
                    'zh': '无',
                    'ja': 'なし',
                    'ru': 'Нет',
                    'de': 'Keine',
                    'sw': 'Hakuna',
                    'ha': 'Babu',
                  })
          ),
          _buildDetailRow(
            DynamicLocalizationHelper.getText({
              'tr': 'Toplam Gün',
              'en': 'Total Days',
              'ar': 'إجمالي الأيام',
              'id': 'Total Hari',
              'ur': 'کل دن',
              'bn': 'মোট দিন',
              'ms': 'Jumlah Hari',
              'fa': 'مجموع روزها',
              'fr': 'Total des Jours',
              'zh': '总天数',
              'ja': '総日数',
              'ru': 'Всего Дней',
              'de': 'Gesamte Tage',
              'sw': 'Jumla ya Siku',
              'ha': 'Dukkan Sako',
            }), 
            '$_activeDaysCount'),
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
