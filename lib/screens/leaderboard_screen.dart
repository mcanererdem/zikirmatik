import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';
import '../services/settings_service.dart';
import '../services/supabase_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String currentUserId;

  const LeaderboardScreen({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.currentUserId,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _leaderboardData = [];
  List<Map<String, dynamic>> _leaderboard = [];
  Map<String, dynamic>? _currentUserProfile;
  int _currentUserRank = 0;
  bool _isCurrentUserVisible = false;
  bool _isLoading = true;
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  String _selectedPeriod = 'all'; // all, daily, weekly, monthly
  String _leaderboardMode = 'zikr'; // zikr, cups
  String _selectedCupTab = 'total'; // total, bronze, silver, gold, diamond, platinum
  bool _showOfflineBanner = false;
  bool _offlineBannerAlreadyShown = false; // Sadece ilk ağ hatasında bir kez göster
  DateTime? _lastManualRefreshAt;
  bool _isRefreshCoolingDown = false;

  final SupabaseService _supabaseService = SupabaseService();
  final SettingsService _settingsService = SettingsService();

  /// Önbellek: sayfa her açıldığında yeniden indirmemek için (dönem -> liste).
  static final Map<String, List<Map<String, dynamic>>> _leaderboardCache = {};
  static const Duration _cacheMaxAge = Duration(minutes: 5);
  static final Map<String, DateTime> _leaderboardCacheTime = {};
  static DateTime? _globalLeaderboardFetchAt;
  static const Duration _minCloudSyncInterval = Duration(minutes: 2);
  static const Duration _minRefreshInterval = Duration(seconds: 4);

  void _showShortSnack(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(message),
      ),
    );
  }

  static bool _isNetworkError(dynamic e) {
    final s = e.toString().toLowerCase();
    return s.contains('socketexception') ||
        s.contains('host lookup') ||
        s.contains('no address associated') ||
        s.contains('connection') ||
        s.contains('network') ||
        s.contains('failed host lookup') ||
        s.contains('connection refused') ||
        s.contains('timed out');
  }

  String _getZikrDefaultDisplayName() {
    return DynamicLocalizationHelper.getText({
      'tr': 'Zikir',
      'en': 'Dhikr',
      'ar': 'الذكر',
      'id': 'Dzikir',
      'ur': 'ذکر',
      'bn': 'যিকির',
      'ms': 'Zikir',
      'fa': 'ذکر',
      'fr': 'Dhikr',
      'zh': 'ذكر',
      'ja': 'ズィクル',
      'ru': 'Зикр',
      'de': 'Dhikr',
      'sw': 'Dhikri',
      'ha': 'Zikir',
    });
  }

  @override
  void initState() {
    super.initState();
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));
    
    _initialLoad();
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _refreshLeaderboard() async {
    final now = DateTime.now();
    if (_lastManualRefreshAt != null) {
      final elapsed = now.difference(_lastManualRefreshAt!);
      if (elapsed < _minRefreshInterval) {
        final waitSec = (_minRefreshInterval - elapsed).inSeconds + 1;
        if (mounted) {
          _showShortSnack(
            DynamicLocalizationHelper.getText({
              'tr': 'Çok hızlı yenileme. Lütfen $waitSec sn bekleyin.',
              'en': 'Refreshing too quickly. Please wait $waitSec sec.',
              'ar': 'تحديث سريع جدًا. يرجى الانتظار $waitSec ثانية.',
              'id': 'Terlalu cepat menyegarkan. Tunggu $waitSec detik.',
              'ur': 'بہت تیزی سے ریفریش ہو رہا ہے۔ براہ کرم $waitSec سیکنڈ انتظار کریں۔',
              'bn': 'খুব দ্রুত রিফ্রেশ হচ্ছে। অনুগ্রহ করে $waitSec সেকেন্ড অপেক্ষা করুন।',
              'ms': 'Penyegaran terlalu laju. Sila tunggu $waitSec saat.',
              'fa': 'نوسازی خیلی سریع است. لطفا $waitSec ثانیه صبر کنید.',
              'fr': 'Rafraîchissement trop rapide. Attendez $waitSec s.',
              'zh': '刷新太频繁，请等待 $waitSec 秒。',
              'ja': '更新が速すぎます。$waitSec 秒待ってください。',
              'ru': 'Слишком частое обновление. Подождите $waitSec сек.',
              'de': 'Zu schnelles Aktualisieren. Bitte $waitSec Sek. warten.',
              'sw': 'Unasasisha haraka sana. Tafadhali subiri sek $waitSec.',
              'ha': 'Kana sabuntawa da sauri sosai. Da fatan a jira sakan $waitSec.',
            }),
          );
        }
        return;
      }
    }
    _lastManualRefreshAt = now;
    setState(() => _isRefreshCoolingDown = true);
    _leaderboardCache.clear();
    _leaderboardCacheTime.clear();
    _globalLeaderboardFetchAt = null;
    setState(() {
      _isLoading = true;
      _showOfflineBanner = false;
    });
    _slideAnimationController.reset();
    _fadeAnimationController.reset();
    await _initialLoad();
    if (mounted) {
      Future.delayed(_minRefreshInterval, () {
        if (mounted) setState(() => _isRefreshCoolingDown = false);
      });
    }
  }

  Future<void> _initialLoad() async {
    final shouldFetch = _globalLeaderboardFetchAt == null || _leaderboardCache.isEmpty;
    if (shouldFetch) {
      await _maybeSyncCloudBeforeLoad();
      await _fetchAndCacheAllDatasets();
      _globalLeaderboardFetchAt = DateTime.now();
    }
    await _showSelectedFromCache();
  }

  Future<void> _maybeSyncCloudBeforeLoad() async {
    try {
      if (!_supabaseService.isInitialized) return;
      final enabled = await _settingsService.getShowInLeaderboard();
      if (!enabled) return;

      final prefs = await SharedPreferences.getInstance();
      final key = 'leaderboard_last_cloud_sync_${widget.currentUserId}';
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final lastMs = prefs.getInt(key) ?? 0;
      if (nowMs - lastMs < _minCloudSyncInterval.inMilliseconds) {
        return;
      }
      final created = await _supabaseService.ensureUserExists(widget.currentUserId);
      if (created) {
        // no-op: sekme geçişlerinde ekstra bilgilendirme gösterme
      }

      final totalZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      final dailyCount = await _settingsService.getDailyCount(DateTime.now());
      final weeklyCount = await _settingsService.getWeeklyCount();
      final monthlyCount = await _settingsService.getMonthlyCount();
      await _supabaseService.updateUserZikrCount(
        widget.currentUserId,
        totalZikrs,
        updateLeaderboard: true,
        dailyCount: dailyCount,
        weeklyCount: weeklyCount,
        monthlyCount: monthlyCount,
      );
      await prefs.setInt(key, nowMs);
    } catch (e) {
      print('Leaderboard pre-load sync skipped: $e');
    }
  }

  /// Ham listeyi mevcut kullanıcı zikri/rank ile birleştirip state günceller. Önbelleğe yazmaz.
  Future<void> _applyLeaderboardData(List<Map<String, dynamic>> rawList) async {
    if (!mounted) return;
    final currentUuid = _supabaseService.toUuid(widget.currentUserId);
    final showInLeaderboard = await _settingsService.getShowInLeaderboard();
    final prefs = await SharedPreferences.getInstance();
    final currentUserZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
    List<Map<String, dynamic>> leaderboardData = List<Map<String, dynamic>>.from(rawList);
    if (!showInLeaderboard) {
      leaderboardData = leaderboardData.where((user) {
        final uid = user['user_id']?.toString() ?? '';
        return uid != widget.currentUserId && uid != currentUuid;
      }).toList();
    }

    final existingUserIndex = leaderboardData.indexWhere(
      (user) => user['user_id'] == widget.currentUserId || user['user_id'] == currentUuid,
    );
    Map<String, dynamic> currentUserProfile;
    if (existingUserIndex != -1) {
      currentUserProfile = Map<String, dynamic>.from(leaderboardData[existingUserIndex]);
      currentUserProfile['total_zikrs'] = currentUserZikrs;
      currentUserProfile['cup_count'] = currentUserProfile['cup_count'] ?? 0;
      currentUserProfile['bronze_count'] = currentUserProfile['bronze_count'] ?? 0;
      currentUserProfile['silver_count'] = currentUserProfile['silver_count'] ?? 0;
      currentUserProfile['gold_count'] = currentUserProfile['gold_count'] ?? 0;
      currentUserProfile['diamond_count'] = currentUserProfile['diamond_count'] ?? 0;
      currentUserProfile['platinum_count'] = currentUserProfile['platinum_count'] ?? 0;
      leaderboardData[existingUserIndex] = currentUserProfile;
    } else if (showInLeaderboard) {
      currentUserProfile = {
        'user_id': widget.currentUserId,
        'username': 'User_${widget.currentUserId.length >= 8 ? widget.currentUserId.substring(0, 8) : widget.currentUserId}',
        'display_name': _getZikrDefaultDisplayName(),
        'total_zikrs': currentUserZikrs,
        'cup_count': 0,
        'bronze_count': 0,
        'silver_count': 0,
        'gold_count': 0,
        'diamond_count': 0,
        'platinum_count': 0,
        'rank': 999,
      };
      leaderboardData.add(currentUserProfile);
    } else {
      currentUserProfile = <String, dynamic>{};
    }
    leaderboardData.sort((a, b) {
      if (_leaderboardMode == 'cups') {
        final bMetric = _cupMetricValue(b);
        final aMetric = _cupMetricValue(a);
        if (bMetric != aMetric) return bMetric.compareTo(aMetric);
        return ((b['total_zikrs'] ?? 0) as int).compareTo((a['total_zikrs'] ?? 0) as int);
      }
      return ((b['total_zikrs'] ?? 0) as int).compareTo((a['total_zikrs'] ?? 0) as int);
    });
    final userRank = leaderboardData.indexWhere((u) => u['user_id'] == widget.currentUserId || u['user_id'] == currentUuid) + 1;
    currentUserProfile['rank'] = userRank;

    if (!mounted) return;
    setState(() {
      _leaderboardData = leaderboardData;
      _leaderboard = leaderboardData;
      _currentUserProfile = currentUserProfile;
      _currentUserRank = userRank;
      _isCurrentUserVisible =
          showInLeaderboard &&
          currentUserProfile.isNotEmpty &&
          userRank > 0 &&
          leaderboardData.any((u) {
            final uid = u['user_id']?.toString() ?? '';
            return uid == widget.currentUserId || uid == currentUuid;
          });
      _isLoading = false;
      _showOfflineBanner = false;
      _offlineBannerAlreadyShown = false;
    });
    _slideAnimationController.forward();
    _fadeAnimationController.forward();
  }

  int _cupMetricValue(Map<String, dynamic> row) {
    switch (_selectedCupTab) {
      case 'bronze':
        return (row['bronze_count'] ?? 0) as int;
      case 'silver':
        return (row['silver_count'] ?? 0) as int;
      case 'gold':
        return (row['gold_count'] ?? 0) as int;
      case 'diamond':
        return (row['diamond_count'] ?? 0) as int;
      case 'platinum':
        return (row['platinum_count'] ?? 0) as int;
      case 'total':
      default:
        return (row['cup_count'] ?? 0) as int;
    }
  }

  Future<void> _fetchAndCacheAllDatasets() async {
    try {
      final now = DateTime.now();
      final all = await _supabaseService.getAllTimeLeaderboard(limit: 50);
      final daily = await _supabaseService.getDailyLeaderboard(limit: 50);
      final weekly = await _supabaseService.getWeeklyLeaderboard(limit: 50);
      final monthly = await _supabaseService.getMonthlyLeaderboard(limit: 50);
      final cups = await _supabaseService.getCupLeaderboard(limit: 50);

      _leaderboardCache['all'] = List<Map<String, dynamic>>.from(all);
      _leaderboardCache['daily'] = List<Map<String, dynamic>>.from(daily);
      _leaderboardCache['weekly'] = List<Map<String, dynamic>>.from(weekly);
      _leaderboardCache['monthly'] = List<Map<String, dynamic>>.from(monthly);
      _leaderboardCache['cups'] = List<Map<String, dynamic>>.from(cups);
      _leaderboardCacheTime['all'] = now;
      _leaderboardCacheTime['daily'] = now;
      _leaderboardCacheTime['weekly'] = now;
      _leaderboardCacheTime['monthly'] = now;
      _leaderboardCacheTime['cups'] = now;

      // sekme degisiminde ek bilgilendirme yok
    } catch (e) {
      if (_isNetworkError(e) && mounted && !_offlineBannerAlreadyShown) {
        setState(() {
          _showOfflineBanner = true;
          _offlineBannerAlreadyShown = true;
        });
      }
      if (_leaderboardCache.isEmpty) {
        await _loadLocalLeaderboard();
      }
    }
  }

  Future<void> _showSelectedFromCache() async {
    final selectedKey = _leaderboardMode == 'cups' ? 'cups' : _selectedPeriod;
    final cached = _leaderboardCache[selectedKey];
    final cacheTime = _leaderboardCacheTime[selectedKey];
    final cacheValid = cached != null &&
        cached.isNotEmpty &&
        cacheTime != null &&
        (DateTime.now().difference(cacheTime) <= _cacheMaxAge);

    if (cacheValid) {
      await _applyLeaderboardData(List<Map<String, dynamic>>.from(cached));
      return;
    }

    if (_leaderboardCache.isNotEmpty) {
      // Veri mevcut ama seçilen segment boşsa spinner'da kalmayalım.
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLocalLeaderboard() async {
    try {
      print('=== LOCAL LEADERBOARD DEBUG ===');
      print('Loading local leaderboard...');
      
      final prefs = await SharedPreferences.getInstance();
      final currentUserZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      final showInLeaderboard = await _settingsService.getShowInLeaderboard();
      
      print('Current user local zikrs: $currentUserZikrs');
      
      final sampleData = [
        {'user_id': 'sample1', 'username': 'Ahmet', 'display_name': 'Ahmet Yılmaz', 'total_zikrs': 1500, 'rank': 1},
        {'user_id': 'sample2', 'username': 'Mehmet', 'display_name': 'Mehmet Kaya', 'total_zikrs': 1200, 'rank': 2},
        {'user_id': 'sample3', 'username': 'Ayşe', 'display_name': 'Ayşe Demir', 'total_zikrs': 800, 'rank': 3},
        {'user_id': 'sample4', 'username': 'Fatma', 'display_name': 'Fatma Öz', 'total_zikrs': 600, 'rank': 4},
        {'user_id': 'sample5', 'username': 'Mustafa', 'display_name': 'Mustafa Çelik', 'total_zikrs': 400, 'rank': 5},
      ];
      
      final currentUserProfile = <String, dynamic>{
        'user_id': widget.currentUserId,
        'username': 'User_${widget.currentUserId.substring(0, 8)}',
        'display_name': _getZikrDefaultDisplayName(),
        'total_zikrs': currentUserZikrs,
        'rank': 999,
      };

      final allUsers = List<Map<String, dynamic>>.from(sampleData);
      if (showInLeaderboard) {
        allUsers.add(currentUserProfile);
      }
      allUsers.sort((a, b) => (b['total_zikrs'] as int).compareTo(a['total_zikrs'] as int));
      
      final userRank = allUsers.indexWhere((user) => user['user_id'] == widget.currentUserId) + 1;
      currentUserProfile['rank'] = userRank;
      
      setState(() {
        _leaderboardData = allUsers;
        _leaderboard = allUsers;
        _currentUserProfile = showInLeaderboard ? currentUserProfile : <String, dynamic>{};
        _currentUserRank = userRank;
        _isCurrentUserVisible =
            showInLeaderboard &&
            userRank > 0 &&
            allUsers.any((u) => u['user_id'] == widget.currentUserId);
        _isLoading = false;
        // _showOfflineBanner zaten catch'te set edildi
      });
      
      print('=== LOCAL LEADERBOARD RESULTS ===');
      print('Sample users: ${sampleData.length}');
      print('Total users (with current): ${allUsers.length}');
      print('Current user zikrs: $currentUserZikrs');
      print('Current user rank: $userRank');
      print('==============================');
    } catch (e) {
      print('=== LOCAL LEADERBOARD ERROR ===');
      print('Error loading local leaderboard: $e');
      print('==============================');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.themeConfig.primaryColor,
      appBar: AppBar(
        title: Text(
          DynamicLocalizationHelper.leaderboard,
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: widget.themeConfig.primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: widget.themeConfig.textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: widget.themeConfig.textColor),
            onPressed: (_isLoading || _isRefreshCoolingDown) ? null : () => _refreshLeaderboard(),
            tooltip: DynamicLocalizationHelper.getText({
              'tr': 'Yenile',
              'en': 'Refresh',
              'ar': 'تحديث',
              'id': 'Segarkan',
              'zh': '刷新',
              'ja': '更新',
              'ru': 'Обновить',
              'de': 'Aktualisieren',
            }),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: widget.themeConfig.backgroundGradient,
        ),
        child: Column(
          children: [
            if (_showOfflineBanner) _buildOfflineBanner(),
            _buildModeSelector(),
            if (_leaderboardMode == 'zikr') _buildPeriodSelector(),
            if (_leaderboardMode == 'cups') _buildCupTypeSelector(),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(widget.themeConfig.accentColor),
                      ),
                    )
                  : Column(
                      children: [
                        if (_isCurrentUserVisible && _currentUserProfile != null) _buildCurrentUserCard(),
                        Expanded(
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(_slideAnimationController),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildLeaderboardList(),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    final closeLabel = DynamicLocalizationHelper.getText({
      'tr': 'Kapat',
      'en': 'Dismiss',
      'ar': 'إغلاق',
      'id': 'Tutup',
      'fa': 'بستن',
      'zh': '关闭',
      'ja': '閉じる',
      'ru': 'Закрыть',
      'de': 'Schließen',
    });
    final content = Material(
      color: Colors.orange.shade800,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showOfflineBanner = false),
                  child: Text(
                    DynamicLocalizationHelper.getText({
                      'tr': 'İnternet kapalı veya ayarlardan sıralama kapatılmış olabilir. Wi‑Fi/veriyi açın veya Ayarlar\'da kontrol edin.',
                      'en': 'Internet may be off or leaderboard disabled in settings. Turn on Wi‑Fi/mobile data or check Settings.',
                      'ar': 'قد يكون الإنترنت مغلقاً أو تم تعطيل لوحة المتصدرين من الإعدادات. شغّل Wi‑Fi/البيانات أو تحقق من الإعدادات.',
                      'id': 'Internet mungkin mati atau papan peringkat dinonaktifkan di pengaturan. Nyalakan Wi‑Fi/data atau periksa Pengaturan.',
                      'fa': 'اینترنت خاموش است یا جدول امتیازات در تنظیمات غیرفعال است. وای‌فای/داده را روشن کنید یا تنظیمات را بررسی کنید.',
                      'zh': '可能未联网或已在设置中关闭排行榜。请开启 Wi‑Fi/移动数据或检查设置。',
                      'ja': 'インターネットがオフか、設定でランキングが無効です。Wi‑Fi/モバイルデータをオンにするか設定を確認してください。',
                      'ru': 'Возможно, интернет выключен или таблица лидеров отключена в настройках. Включите Wi‑Fi/мобильные данные или проверьте настройки.',
                      'de': 'Internet ist aus oder Bestenliste in Einstellungen deaktiviert. Wi‑Fi/Mobildaten einschalten oder Einstellungen prüfen.',
                    }),
                    style: GoogleFonts.notoSans(fontSize: 13, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _showOfflineBanner = false),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(closeLabel, style: GoogleFonts.notoSans(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () => setState(() => _showOfflineBanner = false),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
    return Dismissible(
      key: const ValueKey('offline_banner'),
      direction: DismissDirection.up,
      onDismissed: (_) => setState(() => _showOfflineBanner = false),
      child: content,
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildPeriodChip(
            DynamicLocalizationHelper.getText({
              'tr': 'Tüm Zamanlar',
              'en': 'All Time',
              'ar': 'كل الأوقات',
              'id': 'Semua Waktu',
              'ur': 'تمام اوقات',
              'bn': 'সব সময়',
              'ms': 'Semua Masa',
              'fa': 'همه زمان ها',
              'fr': 'Tous les Temps',
              'zh': '所有时间',
              'ja': '全期間',
              'ru': 'Все Время',
              'de': 'Alle Zeiten',
              'sw': 'Nyakati Zote',
              'ha': 'Duk Duka Saka',
            }), 
            'all'
          ),
          _buildPeriodChip(
            DynamicLocalizationHelper.getText({
              'tr': 'Günlük',
              'en': 'Daily',
              'ar': 'يومي',
              'id': 'Harian',
              'ur': 'روزانہ',
              'bn': 'দৈনিক',
              'ms': 'Harian',
              'fa': 'روزانه',
              'fr': 'Quotidien',
              'zh': '每日',
              'ja': '日次',
              'ru': 'Ежедневно',
              'de': 'Täglich',
              'sw': 'Kila Siku',
              'ha': 'Tsakila',
            }), 
            'daily'
          ),
          _buildPeriodChip(
            DynamicLocalizationHelper.getText({
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
            'weekly'
          ),
          _buildPeriodChip(
            DynamicLocalizationHelper.getText({
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
            'monthly'
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    final zikrLabel = DynamicLocalizationHelper.getText({
      'tr': 'Zikir Sıralaması',
      'en': 'Dhikr Ranking',
      'ar': 'ترتيب الذكر',
      'id': 'Peringkat Zikir',
      'ur': 'ذکر درجہ بندی',
      'bn': 'জিকির র‌্যাঙ্কিং',
      'ms': 'Kedudukan Zikir',
      'fa': 'رتبه‌بندی ذکر',
      'fr': 'Classement Dhikr',
      'zh': '赞念排行',
      'ja': 'ジクル順位',
      'ru': 'Рейтинг зикра',
      'de': 'Dhikr-Rangliste',
      'sw': 'Orodha ya Dhikr',
      'ha': 'Matsayin Zikiri',
    });
    final cupLabel = DynamicLocalizationHelper.getText({
      'tr': 'Kupa Sıralaması',
      'en': 'Cup Ranking',
      'ar': 'ترتيب الكؤوس',
      'id': 'Peringkat Piala',
      'ur': 'کپ درجہ بندی',
      'bn': 'কাপ র‌্যাঙ্কিং',
      'ms': 'Kedudukan Piala',
      'fa': 'رتبه‌بندی جام‌ها',
      'fr': 'Classement Coupes',
      'zh': '奖杯排行',
      'ja': 'カップ順位',
      'ru': 'Рейтинг кубков',
      'de': 'Pokal-Rangliste',
      'sw': 'Orodha ya Kombe',
      'ha': 'Matsayin Kofuna',
    });
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeChip(zikrLabel, 'zikr'),
          ),
          Expanded(
            child: _buildModeChip(cupLabel, 'cups'),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(String label, String value) {
    final selected = _leaderboardMode == value;
    return GestureDetector(
      onTap: () {
        if (_leaderboardMode == value) return;
        setState(() {
          _leaderboardMode = value;
        });
        _showSelectedFromCache();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: selected
              ? LinearGradient(
                  colors: [
                    widget.themeConfig.accentColor,
                    widget.themeConfig.accentColor.withOpacity(0.8),
                  ],
                )
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? Colors.white : widget.themeConfig.textColor.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedPeriod == value) return;
          setState(() {
            _selectedPeriod = value;
          });
          _showSelectedFromCache();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected 
                ? LinearGradient(
                    colors: [
                      widget.themeConfig.accentColor,
                      widget.themeConfig.accentColor.withOpacity(0.8),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : widget.themeConfig.textColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildCupTypeSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCupTypeChip(DynamicLocalizationHelper.getText({'tr': 'Toplam Kupa', 'en': 'Total Cups', 'ar': 'إجمالي الكؤوس', 'id': 'Total Piala', 'ur': 'کل کپ', 'bn': 'মোট কাপ', 'ms': 'Jumlah Piala', 'fa': 'مجموع جام‌ها', 'fr': 'Coupes Totales', 'zh': '总奖杯', 'ja': '合計カップ', 'ru': 'Всего кубков', 'de': 'Gesamtpokale', 'sw': 'Jumla ya Kombe', 'ha': 'Jimillar Kofuna'}), 'total'),
            _buildCupTypeChip(DynamicLocalizationHelper.getText({'tr': 'Bronz', 'en': 'Bronze', 'ar': 'برونزي', 'id': 'Perunggu', 'ur': 'کانسی', 'bn': 'ব্রোঞ্জ', 'ms': 'Gangsa', 'fa': 'برنز', 'fr': 'Bronze', 'zh': '青铜', 'ja': 'ブロンズ', 'ru': 'Бронза', 'de': 'Bronze', 'sw': 'Shaba', 'ha': 'Tagulla'}), 'bronze'),
            _buildCupTypeChip(DynamicLocalizationHelper.getText({'tr': 'Gümüş', 'en': 'Silver', 'ar': 'فضي', 'id': 'Perak', 'ur': 'چاندی', 'bn': 'রূপা', 'ms': 'Perak', 'fa': 'نقره', 'fr': 'Argent', 'zh': '白银', 'ja': 'シルバー', 'ru': 'Серебро', 'de': 'Silber', 'sw': 'Fedha', 'ha': 'Azurfa'}), 'silver'),
            _buildCupTypeChip(DynamicLocalizationHelper.getText({'tr': 'Altın', 'en': 'Gold', 'ar': 'ذهبي', 'id': 'Emas', 'ur': 'سونا', 'bn': 'সোনা', 'ms': 'Emas', 'fa': 'طلا', 'fr': 'Or', 'zh': '黄金', 'ja': 'ゴールド', 'ru': 'Золото', 'de': 'Gold', 'sw': 'Dhahabu', 'ha': 'Zinariya'}), 'gold'),
            _buildCupTypeChip(DynamicLocalizationHelper.getText({'tr': 'Elmas', 'en': 'Diamond', 'ar': 'ألماسي', 'id': 'Berlian', 'ur': 'ہیرا', 'bn': 'হীরা', 'ms': 'Berlian', 'fa': 'الماس', 'fr': 'Diamant', 'zh': '钻石', 'ja': 'ダイヤ', 'ru': 'Алмаз', 'de': 'Diamant', 'sw': 'Almasi', 'ha': 'Lu\'ulu\'u'}), 'diamond'),
            _buildCupTypeChip(DynamicLocalizationHelper.getText({'tr': 'Platin', 'en': 'Platinum', 'ar': 'بلاتيني', 'id': 'Platina', 'ur': 'پلاٹینم', 'bn': 'প্লাটিনাম', 'ms': 'Platinum', 'fa': 'پلاتین', 'fr': 'Platine', 'zh': '铂金', 'ja': 'プラチナ', 'ru': 'Платина', 'de': 'Platin', 'sw': 'Platinamu', 'ha': 'Platinum'}), 'platinum'),
          ],
        ),
      ),
    );
  }

  Widget _buildCupTypeChip(String label, String value) {
    final selected = _selectedCupTab == value;
    return GestureDetector(
      onTap: () {
        if (_selectedCupTab == value) return;
        setState(() => _selectedCupTab = value);
        _showSelectedFromCache();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: selected
              ? LinearGradient(
                  colors: [
                    widget.themeConfig.accentColor,
                    widget.themeConfig.accentColor.withOpacity(0.8),
                  ],
                )
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? Colors.white : widget.themeConfig.textColor.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentUserCard() {
    if (!_isCurrentUserVisible ||
        _currentUserRank <= 0 ||
        _currentUserProfile == null ||
        _currentUserProfile!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.themeConfig.primaryColor,
            widget.themeConfig.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: widget.themeConfig.accentColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildRankBadge(_currentUserRank),
          const SizedBox(width: 9),
          _buildUserAvatar(_currentUserProfile!),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        DynamicLocalizationHelper.getText({
                          'tr': 'Sen',
                          'en': 'You',
                          'ar': 'أنت',
                          'id': 'Anda',
                          'ur': 'آپ',
                          'bn': 'আপনি',
                          'ms': 'Anda',
                          'fa': 'شما',
                          'fr': 'Vous',
                          'zh': '你',
                          'ja': 'あなた',
                          'ru': 'Вы',
                          'de': 'Sie',
                          'sw': 'Wewe',
                          'ha': 'Kai',
                        }),
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: widget.themeConfig.textColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: widget.themeConfig.accentColor.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        DynamicLocalizationHelper.getText({
                          'tr': 'Sen',
                          'en': 'You',
                          'ar': 'أنت',
                          'id': 'Anda',
                        }),
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: widget.themeConfig.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      _leaderboardMode == 'cups' ? Icons.workspace_premium : Icons.trending_up,
                      size: 14,
                      color: _leaderboardMode == 'cups'
                          ? Colors.amber.shade400
                          : widget.themeConfig.textColor.withOpacity(0.72),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _leaderboardMode == 'cups'
                          ? '${_currentUserProfile!['cup_count'] ?? 0} ${DynamicLocalizationHelper.getText({'tr': 'kupa', 'en': 'cups', 'ar': 'كؤوس', 'id': 'piala'})}'
                          : '${_currentUserProfile!['total_zikrs'] ?? 0} ${DynamicLocalizationHelper.getText({'tr': 'zikir', 'en': 'dhikr', 'ar': 'ذكر', 'id': 'zikir', 'ur': 'ذکر', 'bn': 'জিকির', 'ms': 'zikir', 'fa': 'ذکر', 'fr': 'dhikr', 'zh': '赞念', 'ja': 'ジクル', 'ru': 'зикр', 'de': 'Dhikr', 'sw': 'dhikr', 'ha': 'zikiri'})}',
                      style: GoogleFonts.notoSans(
                        fontSize: 11.5,
                        color: widget.themeConfig.textColor.withOpacity(0.84),
                      ),
                    ),
                  ],
                ),
                if (_leaderboardMode == 'cups') ...[
                  const SizedBox(height: 4),
                  _buildCupBadges(_currentUserProfile!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    if (_leaderboard.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard,
              size: 64,
              color: widget.themeConfig.textColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz liderlik tablosu yok',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                color: widget.themeConfig.textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    print('_buildLeaderboardList: building ${_leaderboard.length} items');
    final children = <Widget>[];
    for (int index = 0; index < _leaderboard.length; index++) {
      final user = _leaderboard[index];
      final rank = index + 1;
      final userId = user['user_id'] is String ? user['user_id'] as String : user['user_id']?.toString() ?? '';
      final isCurrentUser = userId == widget.currentUserId ||
          userId == _supabaseService.toUuid(widget.currentUserId);
      children.add(_buildLeaderboardItem(user, rank, isCurrentUser));
    }

    return ListView(
      key: ValueKey<int>(_leaderboard.length),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: children,
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> user, int rank, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: isCurrentUser 
            ? LinearGradient(
                colors: [
                  widget.themeConfig.accentColor.withOpacity(0.3),
                  widget.themeConfig.accentColor.withOpacity(0.1),
                ],
              )
            : LinearGradient(
                colors: [
                  widget.themeConfig.primaryColor,
                  widget.themeConfig.primaryColor.withOpacity(0.8),
                ],
              ),
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser 
            ? Border.all(
                color: widget.themeConfig.accentColor,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: (isCurrentUser ? widget.themeConfig.accentColor : widget.themeConfig.primaryColor)
                .withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildRankBadge(rank),
            const SizedBox(width: 9),
            _buildUserAvatar(user),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          (() {
                            final displayName = user['display_name'] as String?;
                            if (displayName != null && displayName.trim().isNotEmpty) return displayName.trim();
                            final username = user['username'] as String?;
                            if (username != null && username.trim().isNotEmpty) return username.trim();
                            return _getZikrDefaultDisplayName();
                          })(),
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: widget.themeConfig.textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: widget.themeConfig.accentColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            DynamicLocalizationHelper.getText({
                              'tr': 'Sen',
                              'en': 'You',
                              'ar': 'أنت',
                              'id': 'Anda',
                            }),
                            style: GoogleFonts.notoSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: widget.themeConfig.textColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (_leaderboardMode == 'cups')
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.workspace_premium, size: 12, color: Colors.amber.shade300),
                              const SizedBox(width: 4),
                              Text(
                                '${user['cup_count'] ?? 0} ${DynamicLocalizationHelper.getText({'tr': 'kupa', 'en': 'cups', 'ar': 'كؤوس', 'id': 'piala'})}',
                                style: GoogleFonts.notoSans(
                                  fontSize: 10.5,
                                  color: widget.themeConfig.textColor.withOpacity(0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (user['current_streak'] != null && user['current_streak'] > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_fire_department, size: 12, color: Colors.orange),
                                const SizedBox(width: 3),
                                Text(
                                  '${user['current_streak']}',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 10.5,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 14,
                          color: widget.themeConfig.textColor.withOpacity(0.72),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${user['total_zikrs'] ?? 0} ${DynamicLocalizationHelper.getText({'tr': 'zikir', 'en': 'dhikr', 'ar': 'ذكر', 'id': 'zikir'})}',
                          style: GoogleFonts.notoSans(
                            fontSize: 11,
                            color: widget.themeConfig.textColor.withOpacity(0.82),
                          ),
                        ),
                        if (user['current_streak'] != null && user['current_streak'] > 0) ...[
                          const SizedBox(width: 10),
                          Icon(
                            Icons.local_fire_department,
                            size: 13,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${user['current_streak']}',
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  if (_leaderboardMode == 'cups') ...[
                    const SizedBox(height: 4),
                    _buildCupBadges(user),
                  ],
                  if (_leaderboardMode == 'cups' && user['top_cup'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _getCupLabel(user['top_cup']?.toString()),
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        color: widget.themeConfig.textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    String rankText;
    
    if (rank == 1) {
      badgeColor = Colors.amber;
      rankText = '🥇';
    } else if (rank == 2) {
      badgeColor = Colors.grey.shade300;
      rankText = '🥈';
    } else if (rank == 3) {
      badgeColor = Colors.brown.shade300;
      rankText = '🥉';
    } else {
      badgeColor = widget.themeConfig.accentColor;
      rankText = '$rank';
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            badgeColor,
            badgeColor.withOpacity(0.7),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.5),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: rank <= 3 
            ? Text(
                rankText,
                style: const TextStyle(fontSize: 16),
              )
            : Text(
                rankText,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: widget.themeConfig.textColor,
                ),
              ),
      ),
    );
  }

  Widget _buildUserAvatar(Map<String, dynamic> user) {
    final avatarUrl = user['avatar_url'];
    final name = (user['display_name'] ?? user['username'] ?? 'Anonymous') as String?;
    final initialName = (name != null && name.trim().isNotEmpty) ? name.trim() : 'Anonymous';
    
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: widget.themeConfig.buttonGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.themeConfig.accentColor.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: avatarUrl != null && avatarUrl.isNotEmpty
          ? ClipOval(
              child: Image.network(
                avatarUrl,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildAvatarInitial(initialName);
                },
              ),
            )
          : _buildAvatarInitial(initialName),
    );
  }

  Widget _buildAvatarInitial(String username) {
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
    
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  String _getCupLabel(String? cupId) {
    switch (cupId) {
      case 'bronze_kupa':
        return DynamicLocalizationHelper.getText({'tr': 'En yüksek kupa: Bronz', 'en': 'Top cup: Bronze'});
      case 'silver_kupa':
        return DynamicLocalizationHelper.getText({'tr': 'En yüksek kupa: Gümüş', 'en': 'Top cup: Silver'});
      case 'gold_kupa':
        return DynamicLocalizationHelper.getText({'tr': 'En yüksek kupa: Altın', 'en': 'Top cup: Gold'});
      case 'diamond_kupa':
        return DynamicLocalizationHelper.getText({'tr': 'En yüksek kupa: Elmas', 'en': 'Top cup: Diamond'});
      case 'platinum_kupa':
        return DynamicLocalizationHelper.getText({'tr': 'En yüksek kupa: Platin', 'en': 'Top cup: Platinum'});
      default:
        return DynamicLocalizationHelper.getText({'tr': 'En yüksek kupa: Yok', 'en': 'Top cup: None'});
    }
  }

  Widget _buildCupBadges(Map<String, dynamic> user) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        _buildCupBadge('🥉', (user['bronze_count'] ?? 0).toString()),
        _buildCupBadge('🥈', (user['silver_count'] ?? 0).toString()),
        _buildCupBadge('🥇', (user['gold_count'] ?? 0).toString()),
        _buildCupBadge('💎', (user['diamond_count'] ?? 0).toString()),
        _buildCupBadge('🏆', (user['platinum_count'] ?? 0).toString()),
      ],
    );
  }

  Widget _buildCupBadge(String emoji, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: widget.themeConfig.accentColor.withOpacity(0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: widget.themeConfig.accentColor.withOpacity(0.25)),
      ),
      child: Text(
        '$emoji $count',
        style: GoogleFonts.notoSans(
          fontSize: 10,
          color: widget.themeConfig.textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
