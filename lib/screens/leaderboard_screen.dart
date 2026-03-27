import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';
import '../utils/trophy_assets.dart';
import '../services/settings_service.dart';
import '../services/supabase_service.dart';

/// RPC/JSON alanları bazen `int`, bazen `num` veya string gelebilir; `as int` hataya düşmesin.
int _leaderboardInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

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
  static const double _leaderboardHorizontalInset = 14;
  static const double _selectorBottomGap = 10;

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
  String _selectedCupTab =
      'total'; // total, bronze, silver, gold, diamond, platinum
  bool _showOfflineBanner = false;
  bool _offlineBannerAlreadyShown =
      false; // Sadece ilk ağ hatasında bir kez göster
  DateTime? _lastManualRefreshAt;
  bool _isRefreshCoolingDown = false;

  /// Son `getShowInLeaderboard` değeri; `_resortCupLeaderboardAfterTabChange` senkron kalır.
  bool _includeInLeaderboard = true;

  /// Kupa alt sekmesinde (total dışı) metrik > 0 kimse yokken tam liste boş değildi.
  bool _cupCategoryEmpty = false;

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

  String _youLabel() {
    return DynamicLocalizationHelper.getText({
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
              'ur':
                  'بہت تیزی سے ریفریش ہو رہا ہے۔ براہ کرم $waitSec سیکنڈ انتظار کریں۔',
              'bn':
                  'খুব দ্রুত রিফ্রেশ হচ্ছে। অনুগ্রহ করে $waitSec সেকেন্ড অপেক্ষা করুন।',
              'ms': 'Penyegaran terlalu laju. Sila tunggu $waitSec saat.',
              'fa': 'نوسازی خیلی سریع است. لطفا $waitSec ثانیه صبر کنید.',
              'fr': 'Rafraîchissement trop rapide. Attendez $waitSec s.',
              'zh': '刷新太频繁，请等待 $waitSec 秒。',
              'ja': '更新が速すぎます。$waitSec 秒待ってください。',
              'ru': 'Слишком частое обновление. Подождите $waitSec сек.',
              'de': 'Zu schnelles Aktualisieren. Bitte $waitSec Sek. warten.',
              'sw': 'Unasasisha haraka sana. Tafadhali subiri sek $waitSec.',
              'ha':
                  'Kana sabuntawa da sauri sosai. Da fatan a jira sakan $waitSec.',
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
    final shouldFetch =
        _globalLeaderboardFetchAt == null || _leaderboardCache.isEmpty;
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
      final created =
          await _supabaseService.ensureUserExists(widget.currentUserId);
      if (created) {
        // no-op: sekme geçişlerinde ekstra bilgilendirme gösterme
      }

      final totalZikrs =
          prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
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
    final currentUserZikrs =
        prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
    List<Map<String, dynamic>> leaderboardData =
        List<Map<String, dynamic>>.from(rawList);
    for (var i = 0; i < leaderboardData.length; i++) {
      final m = Map<String, dynamic>.from(leaderboardData[i]);
      m['total_zikrs'] = _leaderboardInt(m['total_zikrs']);
      m['cup_count'] = _leaderboardInt(m['cup_count']);
      m['bronze_count'] = _leaderboardInt(m['bronze_count']);
      m['silver_count'] = _leaderboardInt(m['silver_count']);
      m['gold_count'] = _leaderboardInt(m['gold_count']);
      m['diamond_count'] = _leaderboardInt(m['diamond_count']);
      m['platinum_count'] = _leaderboardInt(m['platinum_count']);
      leaderboardData[i] = m;
    }
    if (!showInLeaderboard) {
      leaderboardData = leaderboardData.where((user) {
        final uid = user['user_id']?.toString() ?? '';
        return uid != widget.currentUserId && uid != currentUuid;
      }).toList();
    }

    final existingUserIndex = leaderboardData.indexWhere(
      (user) =>
          user['user_id'] == widget.currentUserId ||
          user['user_id'] == currentUuid,
    );
    Map<String, dynamic> currentUserProfile;
    if (existingUserIndex != -1) {
      currentUserProfile =
          Map<String, dynamic>.from(leaderboardData[existingUserIndex]);
      currentUserProfile['total_zikrs'] = currentUserZikrs;
      currentUserProfile['cup_count'] =
          _leaderboardInt(currentUserProfile['cup_count']);
      currentUserProfile['bronze_count'] =
          _leaderboardInt(currentUserProfile['bronze_count']);
      currentUserProfile['silver_count'] =
          _leaderboardInt(currentUserProfile['silver_count']);
      currentUserProfile['gold_count'] =
          _leaderboardInt(currentUserProfile['gold_count']);
      currentUserProfile['diamond_count'] =
          _leaderboardInt(currentUserProfile['diamond_count']);
      currentUserProfile['platinum_count'] =
          _leaderboardInt(currentUserProfile['platinum_count']);
      leaderboardData[existingUserIndex] = currentUserProfile;
    } else if (showInLeaderboard) {
      currentUserProfile = {
        'user_id': widget.currentUserId,
        'username':
            'User_${widget.currentUserId.length >= 8 ? widget.currentUserId.substring(0, 8) : widget.currentUserId}',
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
        return _leaderboardInt(b['total_zikrs'])
            .compareTo(_leaderboardInt(a['total_zikrs']));
      }
      return _leaderboardInt(b['total_zikrs'])
          .compareTo(_leaderboardInt(a['total_zikrs']));
    });
    final sortedFull = leaderboardData;
    final displayList = _leaderboardMode == 'cups'
        ? _filterCupRowsForCurrentTab(sortedFull)
        : sortedFull;
    final idx = displayList.indexWhere(
      (u) =>
          u['user_id'] == widget.currentUserId || u['user_id'] == currentUuid,
    );
    final fullIdx = sortedFull.indexWhere(
      (u) => u['user_id'] == widget.currentUserId || u['user_id'] == currentUuid,
    );
    final userRank = idx >= 0 ? idx + 1 : (fullIdx >= 0 ? fullIdx + 1 : 0);
    currentUserProfile['rank'] = userRank;

    if (!mounted) return;
    setState(() {
      _includeInLeaderboard = showInLeaderboard;
      _leaderboardData = sortedFull;
      _leaderboard = displayList;
      _currentUserProfile = currentUserProfile;
      _currentUserRank = userRank;
      _cupCategoryEmpty = _leaderboardMode == 'cups' &&
          _selectedCupTab != 'total' &&
          displayList.isEmpty &&
          sortedFull.isNotEmpty;
      _isCurrentUserVisible = showInLeaderboard &&
          currentUserProfile.isNotEmpty &&
          userRank > 0 &&
          sortedFull.any((u) {
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
        return _leaderboardInt(row['bronze_count']);
      case 'silver':
        return _leaderboardInt(row['silver_count']);
      case 'gold':
        return _leaderboardInt(row['gold_count']);
      case 'diamond':
        return _leaderboardInt(row['diamond_count']);
      case 'platinum':
        return _leaderboardInt(row['platinum_count']);
      case 'total':
      default:
        return _leaderboardInt(row['cup_count']);
    }
  }

  /// Kupa modunda belirli tür sekmesinde yalnızca ilgili sayısı > 0 olan satırlar gösterilir.
  List<Map<String, dynamic>> _filterCupRowsForCurrentTab(
      List<Map<String, dynamic>> rows) {
    if (_leaderboardMode != 'cups' || _selectedCupTab == 'total') return rows;
    return rows.where((u) => _cupMetricValue(u) > 0).toList();
  }

  /// Kupa alt sekmesi değişince ağ çağrısı beklemeden mevcut listeyi seçilen metriğe göre yeniden sırala.
  void _resortCupLeaderboardAfterTabChange() {
    if (_leaderboardMode != 'cups') return;
    final currentUuid = _supabaseService.toUuid(widget.currentUserId);
    if (_leaderboardData.isEmpty) {
      _showSelectedFromCache();
      return;
    }
    final raw = List<Map<String, dynamic>>.from(_leaderboardData);
    raw.sort((a, b) {
      final bMetric = _cupMetricValue(b);
      final aMetric = _cupMetricValue(a);
      if (bMetric != aMetric) return bMetric.compareTo(aMetric);
      return _leaderboardInt(b['total_zikrs'])
          .compareTo(_leaderboardInt(a['total_zikrs']));
    });
    final filtered = _filterCupRowsForCurrentTab(raw);
    final idx = filtered.indexWhere(
      (u) =>
          u['user_id'] == widget.currentUserId || u['user_id'] == currentUuid,
    );
    final fullIdx = raw.indexWhere(
      (u) => u['user_id'] == widget.currentUserId || u['user_id'] == currentUuid,
    );
    final userRank = idx >= 0 ? idx + 1 : (fullIdx >= 0 ? fullIdx + 1 : 0);
    if (_currentUserProfile != null && _currentUserProfile!.isNotEmpty) {
      _currentUserProfile!['rank'] = userRank;
    }
    setState(() {
      _leaderboardData = raw;
      _leaderboard = filtered;
      _currentUserRank = userRank;
      _cupCategoryEmpty =
          _selectedCupTab != 'total' && filtered.isEmpty && raw.isNotEmpty;
      _isCurrentUserVisible = _includeInLeaderboard &&
          _currentUserProfile != null &&
          _currentUserProfile!.isNotEmpty &&
          userRank > 0 &&
          raw.any((u) {
            final uid = u['user_id']?.toString() ?? '';
            return uid == widget.currentUserId || uid == currentUuid;
          });
    });
  }

  /// Kupa sekmesinde sağdaki büyük sayının alt etiketi (kısa).
  String _cupMetricSubtitle() {
    switch (_selectedCupTab) {
      case 'bronze':
        return DynamicLocalizationHelper.getText({
          'tr': 'Bronz',
          'en': 'Bronze',
          'ar': 'برونز',
          'id': 'Perunggu',
          'ur': 'برونز',
          'bn': 'ব্রোঞ্জ',
          'ms': 'Gangsa',
          'fa': 'برنز',
          'fr': 'Bronze',
          'zh': '青铜',
          'ja': '銅',
          'ru': 'Бронза',
          'de': 'Bronze',
          'sw': 'Shaba',
          'ha': 'Tagulla',
        });
      case 'silver':
        return DynamicLocalizationHelper.getText({
          'tr': 'Gümüş',
          'en': 'Silver',
          'ar': 'فضي',
          'id': 'Perak',
          'ur': 'چاندی',
          'bn': 'রৌপ্য',
          'ms': 'Perak',
          'fa': 'نقره',
          'fr': 'Argent',
          'zh': '银',
          'ja': '銀',
          'ru': 'Серебро',
          'de': 'Silber',
          'sw': 'Fedha',
          'ha': 'Azurfa',
        });
      case 'gold':
        return DynamicLocalizationHelper.getText({
          'tr': 'Altın',
          'en': 'Gold',
          'ar': 'ذهبي',
          'id': 'Emas',
          'ur': 'سونا',
          'bn': 'সোনা',
          'ms': 'Emas',
          'fa': 'طلا',
          'fr': 'Or',
          'zh': '金',
          'ja': '金',
          'ru': 'Золото',
          'de': 'Gold',
          'sw': 'Dhahabu',
          'ha': 'Zinariya',
        });
      case 'diamond':
        return DynamicLocalizationHelper.getText({
          'tr': 'Elmas',
          'en': 'Diamond',
          'ar': 'ألماس',
          'id': 'Berlian',
          'ur': 'ہیرا',
          'bn': 'হীরা',
          'ms': 'Berlian',
          'fa': 'الماس',
          'fr': 'Diamant',
          'zh': '钻',
          'ja': 'ダイヤ',
          'ru': 'Алмаз',
          'de': 'Diamant',
          'sw': 'Almasi',
          'ha': 'Lu\'u',
        });
      case 'platinum':
        return DynamicLocalizationHelper.getText({
          'tr': 'Platin',
          'en': 'Platinum',
          'ar': 'بلاتين',
          'id': 'Platina',
          'ur': 'پلاٹینم',
          'bn': 'প্লাটিনাম',
          'ms': 'Platinum',
          'fa': 'پلاتین',
          'fr': 'Platine',
          'zh': '铂金',
          'ja': 'プラチナ',
          'ru': 'Платина',
          'de': 'Platin',
          'sw': 'Platinamu',
          'ha': 'Platinum',
        });
      case 'total':
      default:
        return DynamicLocalizationHelper.getText({
          'tr': 'Toplam',
          'en': 'Total',
          'ar': 'الإجمالي',
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
          'ha': 'Jimilla',
        });
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
      final currentUserZikrs =
          prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      final showInLeaderboard = await _settingsService.getShowInLeaderboard();

      print('Current user local zikrs: $currentUserZikrs');

      final sampleData = [
        {
          'user_id': 'sample1',
          'username': 'Ahmet',
          'display_name': 'Ahmet Yılmaz',
          'total_zikrs': 1500,
          'rank': 1
        },
        {
          'user_id': 'sample2',
          'username': 'Mehmet',
          'display_name': 'Mehmet Kaya',
          'total_zikrs': 1200,
          'rank': 2
        },
        {
          'user_id': 'sample3',
          'username': 'Ayşe',
          'display_name': 'Ayşe Demir',
          'total_zikrs': 800,
          'rank': 3
        },
        {
          'user_id': 'sample4',
          'username': 'Fatma',
          'display_name': 'Fatma Öz',
          'total_zikrs': 600,
          'rank': 4
        },
        {
          'user_id': 'sample5',
          'username': 'Mustafa',
          'display_name': 'Mustafa Çelik',
          'total_zikrs': 400,
          'rank': 5
        },
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
      allUsers.sort((a, b) =>
          (b['total_zikrs'] as int).compareTo(a['total_zikrs'] as int));

      final userRank = allUsers
              .indexWhere((user) => user['user_id'] == widget.currentUserId) +
          1;
      currentUserProfile['rank'] = userRank;

      setState(() {
        _includeInLeaderboard = showInLeaderboard;
        _cupCategoryEmpty = false;
        _leaderboardData = allUsers;
        _leaderboard = allUsers;
        _currentUserProfile =
            showInLeaderboard ? currentUserProfile : <String, dynamic>{};
        _currentUserRank = userRank;
        _isCurrentUserVisible = showInLeaderboard &&
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
            onPressed: (_isLoading || _isRefreshCoolingDown)
                ? null
                : () => _refreshLeaderboard(),
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
                        valueColor: AlwaysStoppedAnimation(
                            widget.themeConfig.accentColor),
                      ),
                    )
                  : Column(
                      children: [
                        if (_isCurrentUserVisible &&
                            _currentUserProfile != null)
                          _buildCurrentUserCard(),
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
                      'tr':
                          'İnternet kapalı veya ayarlardan sıralama kapatılmış olabilir. Wi‑Fi/veriyi açın veya Ayarlar\'da kontrol edin.',
                      'en':
                          'Internet may be off or leaderboard disabled in settings. Turn on Wi‑Fi/mobile data or check Settings.',
                      'ar':
                          'قد يكون الإنترنت مغلقاً أو تم تعطيل لوحة المتصدرين من الإعدادات. شغّل Wi‑Fi/البيانات أو تحقق من الإعدادات.',
                      'id':
                          'Internet mungkin mati atau papan peringkat dinonaktifkan di pengaturan. Nyalakan Wi‑Fi/data atau periksa Pengaturan.',
                      'fa':
                          'اینترنت خاموش است یا جدول امتیازات در تنظیمات غیرفعال است. وای‌فای/داده را روشن کنید یا تنظیمات را بررسی کنید.',
                      'zh': '可能未联网或已在设置中关闭排行榜。请开启 Wi‑Fi/移动数据或检查设置。',
                      'ja':
                          'インターネットがオフか、設定でランキングが無効です。Wi‑Fi/モバイルデータをオンにするか設定を確認してください。',
                      'ru':
                          'Возможно, интернет выключен или таблица лидеров отключена в настройках. Включите Wi‑Fi/мобильные данные или проверьте настройки.',
                      'de':
                          'Internet ist aus oder Bestenliste in Einstellungen deaktiviert. Wi‑Fi/Mobildaten einschalten oder Einstellungen prüfen.',
                    }),
                    style:
                        GoogleFonts.notoSans(fontSize: 13, color: Colors.white),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(closeLabel,
                        style: GoogleFonts.notoSans(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
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
      margin: const EdgeInsets.fromLTRB(
        _leaderboardHorizontalInset,
        0,
        _leaderboardHorizontalInset,
        _selectorBottomGap,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
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
                  'all'),
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
                  'daily'),
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
                  'weekly'),
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
                  'monthly'),
            ],
          ),
        ),
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
      margin: const EdgeInsets.fromLTRB(
        _leaderboardHorizontalInset,
        12,
        _leaderboardHorizontalInset,
        8,
      ),
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
            color: selected
                ? Colors.white
                : widget.themeConfig.textColor.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          if (_selectedPeriod == value) return;
          setState(() {
            _selectedPeriod = value;
          });
          _showSelectedFromCache();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.themeConfig.accentColor.withOpacity(0.24)
                : widget.themeConfig.textColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                    ? widget.themeConfig.accentColor.withOpacity(0.8)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? widget.themeConfig.accentColor
                  : widget.themeConfig.textColor.withOpacity(0.9),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildCupTypeSelector() {
    final cupLabel =
        (Map<String, String> m) => DynamicLocalizationHelper.getText(m);
    return Container(
      margin: const EdgeInsets.fromLTRB(
        _leaderboardHorizontalInset,
        0,
        _leaderboardHorizontalInset,
        _selectorBottomGap,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Row(
            children: [
            _buildCupTabChip(
                cupLabel({
                  'tr': 'Toplam',
                  'en': 'Total',
                  'ar': 'الإجمالي',
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
                  'ha': 'Jimilla',
                }),
                'total'),
            _buildCupTabChip(
                cupLabel({
                  'tr': 'Bronz',
                  'en': 'Bronze',
                  'ar': 'برونز',
                  'id': 'Perunggu',
                  'ur': 'کانسی',
                  'bn': 'ব্রোঞ্জ',
                  'ms': 'Gangsa',
                  'fa': 'برنز',
                  'fr': 'Bronze',
                  'zh': '青铜',
                  'ja': 'ブロンズ',
                  'ru': 'Бронза',
                  'de': 'Bronze',
                  'sw': 'Shaba',
                  'ha': 'Tagulla',
                }),
                'bronze'),
            _buildCupTabChip(
                cupLabel({
                  'tr': 'Gümüş',
                  'en': 'Silver',
                  'ar': 'فضي',
                  'id': 'Perak',
                  'ur': 'چاندی',
                  'bn': 'রূপা',
                  'ms': 'Perak',
                  'fa': 'نقره',
                  'fr': 'Argent',
                  'zh': '白银',
                  'ja': 'シルバー',
                  'ru': 'Серебро',
                  'de': 'Silber',
                  'sw': 'Fedha',
                  'ha': 'Azurfa',
                }),
                'silver'),
            _buildCupTabChip(
                cupLabel({
                  'tr': 'Altın',
                  'en': 'Gold',
                  'ar': 'ذهبي',
                  'id': 'Emas',
                  'ur': 'سونا',
                  'bn': 'সোনা',
                  'ms': 'Emas',
                  'fa': 'طلا',
                  'fr': 'Or',
                  'zh': '黄金',
                  'ja': 'ゴールド',
                  'ru': 'Золото',
                  'de': 'Gold',
                  'sw': 'Dhahabu',
                  'ha': 'Zinariya',
                }),
                'gold'),
            _buildCupTabChip(
                cupLabel({
                  'tr': 'Elmas',
                  'en': 'Diamond',
                  'ar': 'ألماس',
                  'id': 'Berlian',
                  'ur': 'ہیرا',
                  'bn': 'হীরা',
                  'ms': 'Berlian',
                  'fa': 'الماس',
                  'fr': 'Diamant',
                  'zh': '钻石',
                  'ja': 'ダイヤ',
                  'ru': 'Алмаз',
                  'de': 'Diamant',
                  'sw': 'Almasi',
                  'ha': 'Lu\'u',
                }),
                'diamond'),
            _buildCupTabChip(
                cupLabel({
                  'tr': 'Platin',
                  'en': 'Platinum',
                  'ar': 'بلاتين',
                  'id': 'Platina',
                  'ur': 'پلاٹینم',
                  'bn': 'প্লাটিনাম',
                  'ms': 'Platinum',
                  'fa': 'پلاتین',
                  'fr': 'Platine',
                  'zh': '铂金',
                  'ja': 'プラチナ',
                  'ru': 'Платина',
                  'de': 'Platin',
                  'sw': 'Platinamu',
                  'ha': 'Platinum',
                }),
                'platinum'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCupTabChip(String label, String value) {
    final isSelected = _selectedCupTab == value;
    final tc = widget.themeConfig.textColor;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          if (_selectedCupTab == value) return;
          setState(() => _selectedCupTab = value);
          _resortCupLeaderboardAfterTabChange();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.themeConfig.accentColor.withOpacity(0.24)
                : tc.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? widget.themeConfig.accentColor.withOpacity(0.8)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: GoogleFonts.notoSans(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? widget.themeConfig.accentColor
                  : tc.withOpacity(0.9),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
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
      margin: const EdgeInsets.fromLTRB(
        _leaderboardHorizontalInset,
        0,
        _leaderboardHorizontalInset,
        4,
      ),
      child: _buildLeaderboardItem(
        Map<String, dynamic>.from(_currentUserProfile!)
          ..['display_name'] = _youLabel()
          ..['username'] = _youLabel(),
        _currentUserRank,
        true,
      ),
    );
  }

  Widget _buildLeaderboardTrailing(Map<String, dynamic> user) {
    final tc = widget.themeConfig.textColor;
    if (_leaderboardMode == 'zikr') {
      final z = user['total_zikrs'] ?? 0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$z',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: tc,
              height: 1.05,
            ),
          ),
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'zikir',
              'en': 'dhikr',
              'ar': 'ذكر',
              'id': 'zikir',
              'ur': 'ذکر',
              'bn': 'জিকির',
              'ms': 'zikir',
              'fa': 'ذکر',
              'fr': 'dhikr',
              'zh': '赞念',
              'ja': 'ジクル',
              'ru': 'зикр',
              'de': 'Dhikr',
              'sw': 'dhikr',
              'ha': 'zikiri',
            }),
            style: GoogleFonts.notoSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: tc.withOpacity(0.62),
            ),
          ),
        ],
      );
    }
    final m = _cupMetricValue(user);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$m',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: tc,
            height: 1.05,
          ),
        ),
        Text(
          _cupMetricSubtitle(),
          style: GoogleFonts.notoSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: tc.withOpacity(0.62),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList() {
    if (_leaderboard.isEmpty) {
      if (_cupCategoryEmpty && _leaderboardMode == 'cups') {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.workspace_premium_outlined,
                  size: 56,
                  color: widget.themeConfig.textColor.withOpacity(0.45),
                ),
                const SizedBox(height: 16),
                Text(
                  DynamicLocalizationHelper.getText({
                    'tr': 'Bu kupa türünde henüz kimse yok',
                    'en': 'No one in this cup category yet',
                    'ar': 'لا أحد في فئة الكأس هذه بعد',
                    'id': 'Belum ada siapa pun di kategori piala ini',
                    'ur': 'اس کپ زمرے میں ابھی کوئی نہیں',
                    'bn': 'এই কাপ বিভাগে এখনও কেউ নেই',
                    'ms': 'Belum ada sesiapa dalam kategori piala ini',
                    'fa': 'هنوز کسی در این دسته جام نیست',
                    'fr':
                        'Personne dans cette catégorie de coupe pour le moment',
                    'zh': '该奖杯类别中还没有人',
                    'ja': 'このカップ区分にはまだ誰もいません',
                    'ru': 'В этой категории кубков пока никого нет',
                    'de': 'In dieser Pokal-Kategorie ist noch niemand',
                    'sw': 'Hakuna mtu katika jamii hii ya kombe bado',
                    'ha': 'Babu kowa a wannan nau\'in kofuna tukuna',
                  }),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                    fontSize: 17,
                    color: widget.themeConfig.textColor.withOpacity(0.78),
                  ),
                ),
              ],
            ),
          ),
        );
      }
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
            Opacity(
              opacity: 0.95,
              child: Image.asset(
                'assets/generated/illustrations/leaderboard_empty.png',
                height: 120,
                width: 120,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Henüz liderlik tablosu yok',
                'en': 'No leaderboard yet',
                'ar': 'لا يوجد جدول صدارة بعد',
                'id': 'Belum ada papan peringkat',
                'ur': 'ابھی تک لیڈر بورڈ نہیں',
                'ms': 'Belum ada papan pemimpin',
              }),
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(
                fontSize: 18,
                color: widget.themeConfig.textColor.withOpacity(0.72),
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
      final userId = user['user_id'] is String
          ? user['user_id'] as String
          : user['user_id']?.toString() ?? '';
      final isCurrentUser = userId == widget.currentUserId ||
          userId == _supabaseService.toUuid(widget.currentUserId);
      children.add(_buildLeaderboardItem(user, rank, isCurrentUser));
    }

    return ListView(
      key: ValueKey<String>(
          '${_leaderboardMode}_${_selectedCupTab}_${_leaderboard.length}'),
      padding: const EdgeInsets.fromLTRB(
        _leaderboardHorizontalInset,
        0,
        _leaderboardHorizontalInset,
        0,
      ),
      children: children,
    );
  }

  Color _rankBorderColor(int rank) {
    if (rank == 1) return const Color(0xFFC59D3A);
    if (rank == 2) return const Color(0xFF9E9E9E);
    if (rank == 3) return const Color(0xFF9E6B3E);
    return Colors.transparent;
  }

  Widget _buildLeaderboardItem(
      Map<String, dynamic> user, int rank, bool isCurrentUser) {
    final name = (() {
      final displayName = user['display_name'] as String?;
      if (displayName != null && displayName.trim().isNotEmpty) {
        return displayName.trim();
      }
      final username = user['username'] as String?;
      if (username != null && username.trim().isNotEmpty) return username.trim();
      return _getZikrDefaultDisplayName();
    })();

    return _leaderboardMode == 'cups'
        ? _buildCupRow(
            user: user,
            rank: rank,
            name: name,
            isCurrentUser: isCurrentUser,
          )
        : _buildZikrRow(
            user: user,
            rank: rank,
            name: name,
            isCurrentUser: isCurrentUser,
          );
  }

  Widget _buildZikrRow({
    required Map<String, dynamic> user,
    required int rank,
    required String name,
    required bool isCurrentUser,
  }) {
    final tc = widget.themeConfig.textColor;
    final accent = widget.themeConfig.accentColor;
    final base = widget.themeConfig.primaryColor;
    final isTop3 = rank <= 3;
    final streak = user['current_streak'] as int? ?? 0;
    final zikrCount = _leaderboardInt(user['total_zikrs']);

    final Color borderColor;
    final Color bgColor;
    if (isCurrentUser) {
      borderColor = accent.withOpacity(0.55);
      bgColor = accent.withOpacity(0.10);
    } else if (isTop3) {
      borderColor = _rankBorderColor(rank).withOpacity(0.55);
      bgColor = base.withOpacity(0.58);
    } else {
      borderColor = tc.withOpacity(0.10);
      bgColor = base.withOpacity(0.42);
    }

    final Color scoreColor;
    if (isCurrentUser) {
      scoreColor = accent;
    } else if (rank == 1) {
      scoreColor = const Color(0xFFB08A2A);
    } else if (rank == 2) {
      scoreColor = const Color(0xFF7A7A7A);
    } else if (rank == 3) {
      scoreColor = const Color(0xFF8D5524);
    } else {
      scoreColor = tc;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: isTop3 || isCurrentUser ? 1.0 : 0.7,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 28, child: Center(child: _buildRankBadge(rank))),
            const SizedBox(width: 9),
            _buildUserAvatar(user, rank: rank, isCurrentUser: isCurrentUser),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: isTop3 ? FontWeight.w700 : FontWeight.w500,
                      color: tc,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (streak > 0) ...[
                    const SizedBox(height: 3),
                    _buildStreakRow(streak),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatNumber(zikrCount),
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  DynamicLocalizationHelper.getText({
                    'tr': 'zikir',
                    'en': 'dhikr',
                    'ar': 'ذكر',
                    'id': 'zikir',
                    'ur': 'ذکر',
                    'bn': 'জিকির',
                    'ms': 'zikir',
                    'fa': 'ذکر',
                    'fr': 'dhikr',
                    'zh': '赞念',
                    'ja': 'ジクル',
                    'ru': 'зикр',
                    'de': 'Dhikr',
                    'sw': 'dhikr',
                    'ha': 'zikiri',
                  }),
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: tc.withOpacity(0.48),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCupRow({
    required Map<String, dynamic> user,
    required int rank,
    required String name,
    required bool isCurrentUser,
  }) {
    final tc = widget.themeConfig.textColor;
    final accent = widget.themeConfig.accentColor;
    final base = widget.themeConfig.primaryColor;
    final isTop3 = rank <= 3;
    final metricValue = _cupMetricValue(user);

    final Color borderColor;
    final Color bgColor;
    if (isCurrentUser) {
      borderColor = accent.withOpacity(0.55);
      bgColor = accent.withOpacity(0.10);
    } else if (isTop3) {
      borderColor = _rankBorderColor(rank).withOpacity(0.55);
      bgColor = base.withOpacity(0.58);
    } else {
      borderColor = tc.withOpacity(0.10);
      bgColor = base.withOpacity(0.42);
    }

    final Color scoreColor;
    if (isCurrentUser) {
      scoreColor = accent;
    } else if (rank == 1) {
      scoreColor = const Color(0xFFB08A2A);
    } else if (rank == 2) {
      scoreColor = const Color(0xFF7A7A7A);
    } else if (rank == 3) {
      scoreColor = const Color(0xFF8D5524);
    } else {
      scoreColor = tc;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: isTop3 || isCurrentUser ? 1.0 : 0.7,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 28, child: Center(child: _buildRankBadge(rank))),
            const SizedBox(width: 9),
            _buildUserAvatar(user, rank: rank, isCurrentUser: isCurrentUser),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: isTop3 ? FontWeight.w700 : FontWeight.w500,
                      color: tc,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_selectedCupTab == 'total') ...[
                    const SizedBox(height: 5),
                    _buildCupDots(user),
                  ] else ...[
                    const SizedBox(height: 3),
                    _buildSingleCupTypeInfo(user),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$metricValue',
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _selectedCupTab == 'total'
                      ? DynamicLocalizationHelper.getText({
                          'tr': 'kupa',
                          'en': 'cups',
                          'ar': 'كؤوس',
                          'id': 'piala',
                          'ur': 'کپ',
                          'bn': 'কাপ',
                          'ms': 'piala',
                          'fa': 'جام',
                          'fr': 'coupes',
                          'zh': '奖杯',
                          'ja': 'カップ',
                          'ru': 'кубки',
                          'de': 'Pokale',
                          'sw': 'vikombe',
                          'ha': 'kofuna',
                        })
                      : _cupMetricSubtitle(),
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: tc.withOpacity(0.48),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakRow(int streak) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.local_fire_department_rounded,
          size: 12,
          color: Color(0xFFFF6B35),
        ),
        const SizedBox(width: 3),
        Text(
          DynamicLocalizationHelper.getText({
            'tr': '$streak gün',
            'en': '$streak day',
            'ar': '$streak يوم',
            'id': '$streak hari',
            'ur': '$streak دن',
            'bn': '$streak দিন',
            'ms': '$streak hari',
            'fa': '$streak روز',
            'fr': '$streak jour',
            'zh': '$streak 天',
            'ja': '$streak 日',
            'ru': '$streak дн.',
            'de': '$streak Tag',
            'sw': 'siku $streak',
            'ha': 'kwana $streak',
          }),
          style: GoogleFonts.notoSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFFF6B35),
          ),
        ),
      ],
    );
  }

  Widget _buildCupDots(Map<String, dynamic> user) {
    final cups = [
      (TrophyAssets.bronze, _leaderboardInt(user['bronze_count']), const Color(0xFFF5E6D8), const Color(0xFF9E6B3E)),
      (TrophyAssets.silver, _leaderboardInt(user['silver_count']), const Color(0xFFEFEFEF), const Color(0xFF7A7A7A)),
      (TrophyAssets.gold, _leaderboardInt(user['gold_count']), const Color(0xFFFFF4C2), const Color(0xFFB08A2A)),
      (TrophyAssets.diamond, _leaderboardInt(user['diamond_count']), const Color(0xFFDCEEFB), const Color(0xFF185FA5)),
      (TrophyAssets.platinum, _leaderboardInt(user['platinum_count']), const Color(0xFFF3E8FC), const Color(0xFF7B2FA8)),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: cups.map((c) {
        final asset = c.$1;
        final count = c.$2;
        final bg = c.$3;
        final fg = c.$4;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Container(
            width: 30,
            height: 18,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  asset,
                  width: 11,
                  height: 11,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.emoji_events_rounded, size: 10, color: fg),
                ),
                const SizedBox(width: 2),
                Text(
                  '$count',
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: fg,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleCupTypeInfo(Map<String, dynamic> user) {
    final color = _selectedCupTabColor();
    final asset = _selectedCupTabAsset();
    final count = _cupMetricValue(user);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: Image.asset(
            asset,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.emoji_events_rounded, size: 12, color: color),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          DynamicLocalizationHelper.getText({
            'tr': '$count adet',
            'en': '$count earned',
            'ar': '$count مكتسب',
            'id': '$count diraih',
            'ur': '$count حاصل',
            'bn': '$count অর্জিত',
            'ms': '$count diperoleh',
            'fa': '$count کسب شده',
            'fr': '$count obtenu',
            'zh': '获得$count个',
            'ja': '$count 獲得',
            'ru': '$count шт.',
            'de': '$count erhalten',
            'sw': '$count iliyopatikana',
            'ha': '$count da aka samu',
          }),
          style: GoogleFonts.notoSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color.withOpacity(0.85),
          ),
        ),
      ],
    );
  }

  Color _selectedCupTabColor() {
    switch (_selectedCupTab) {
      case 'bronze':
        return const Color(0xFF9E6B3E);
      case 'silver':
        return const Color(0xFF7A7A7A);
      case 'gold':
        return const Color(0xFFB08A2A);
      case 'diamond':
        return const Color(0xFF185FA5);
      case 'platinum':
        return const Color(0xFF7B2FA8);
      default:
        return widget.themeConfig.accentColor;
    }
  }

  String _selectedCupTabAsset() {
    switch (_selectedCupTab) {
      case 'bronze':
        return TrophyAssets.bronze;
      case 'silver':
        return TrophyAssets.silver;
      case 'gold':
        return TrophyAssets.gold;
      case 'diamond':
        return TrophyAssets.diamond;
      case 'platinum':
        return TrophyAssets.platinum;
      default:
        return TrophyAssets.gold;
    }
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
  }

  Widget _buildMetricChip({
    required int value,
    required String label,
    required Color textColor,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: GoogleFonts.notoSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: textColor,
              height: 1,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.62),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank, {bool cupMode = false}) {
    final tc = widget.themeConfig.textColor;
    if (rank <= 3) {
      final bg = rank == 1
          ? const Color(0xFFFFF4C2)
          : rank == 2
              ? const Color(0xFFEFEFEF)
              : const Color(0xFFF5E6D8);
      final emoji = rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉';
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 14, height: 1)),
        ),
      );
    }
    return SizedBox(
      width: 26,
      child: Text(
        '$rank',
        textAlign: TextAlign.center,
        style: GoogleFonts.notoSans(
          fontSize: rank >= 100 ? 10 : 12,
          fontWeight: FontWeight.w500,
          color: tc.withOpacity(0.4),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildUserAvatar(
    Map<String, dynamic> user, {
    int rank = 0,
    bool isCurrentUser = false,
  }) {
    final avatarUrl = user['avatar_url'];
    final raw = (user['display_name'] ?? user['username'] ?? '') as String?;
    final displayName =
        (raw != null && raw.trim().isNotEmpty) ? raw.trim() : 'Anonymous';

    final tc = widget.themeConfig.textColor;
    final accent = widget.themeConfig.accentColor;
    final Color ringColor;
    final double ringWidth;
    if (isCurrentUser) {
      ringColor = accent.withOpacity(0.7);
      ringWidth = 1.5;
    } else if (rank == 1) {
      ringColor = const Color(0xFFC59D3A);
      ringWidth = 1.4;
    } else if (rank == 2) {
      ringColor = const Color(0xFF9E9E9E);
      ringWidth = 1.4;
    } else if (rank == 3) {
      ringColor = const Color(0xFF9E6B3E);
      ringWidth = 1.4;
    } else {
      ringColor = tc.withOpacity(0.14);
      ringWidth = 0.8;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: widget.themeConfig.buttonGradient,
        border: Border.all(color: ringColor, width: ringWidth),
      ),
      child: ClipOval(
        child: avatarUrl != null && (avatarUrl as String).isNotEmpty
            ? Image.network(
                avatarUrl,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildAvatarInitial(displayName),
              )
            : _buildAvatarInitial(displayName),
      ),
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
        return DynamicLocalizationHelper.getText(
            {'tr': 'En yüksek kupa: Bronz', 'en': 'Top cup: Bronze'});
      case 'silver_kupa':
        return DynamicLocalizationHelper.getText(
            {'tr': 'En yüksek kupa: Gümüş', 'en': 'Top cup: Silver'});
      case 'gold_kupa':
        return DynamicLocalizationHelper.getText(
            {'tr': 'En yüksek kupa: Altın', 'en': 'Top cup: Gold'});
      case 'diamond_kupa':
        return DynamicLocalizationHelper.getText(
            {'tr': 'En yüksek kupa: Elmas', 'en': 'Top cup: Diamond'});
      case 'platinum_kupa':
        return DynamicLocalizationHelper.getText(
            {'tr': 'En yüksek kupa: Platin', 'en': 'Top cup: Platinum'});
      default:
        return DynamicLocalizationHelper.getText(
            {'tr': 'En yüksek kupa: Yok', 'en': 'Top cup: None'});
    }
  }

  String _topCupFromCounts(Map<String, dynamic> user) {
    final counts = <String, int>{
      'bronze': _leaderboardInt(user['bronze_count']),
      'silver': _leaderboardInt(user['silver_count']),
      'gold': _leaderboardInt(user['gold_count']),
      'diamond': _leaderboardInt(user['diamond_count']),
      'platinum': _leaderboardInt(user['platinum_count']),
    };
    String best = 'bronze';
    int max = -1;
    for (final e in counts.entries) {
      if (e.value > max) {
        max = e.value;
        best = e.key;
      }
    }
    return max > 0 ? best : '';
  }

  Widget _buildCupBadges(Map<String, dynamic> user,
      {bool highlightTopCup = false}) {
    final topCup = highlightTopCup ? _topCupFromCounts(user) : '';
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        _buildCupBadge(
          TrophyAssets.bronze,
          (user['bronze_count'] ?? 0).toString(),
          Colors.brown,
          isHighlighted: topCup == 'bronze',
        ),
        _buildCupBadge(
          TrophyAssets.silver,
          (user['silver_count'] ?? 0).toString(),
          Colors.grey,
          isHighlighted: topCup == 'silver',
        ),
        _buildCupBadge(
          TrophyAssets.gold,
          (user['gold_count'] ?? 0).toString(),
          Colors.yellow,
          isHighlighted: topCup == 'gold',
        ),
        _buildCupBadge(
          TrophyAssets.diamond,
          (user['diamond_count'] ?? 0).toString(),
          Colors.blue,
          isHighlighted: topCup == 'diamond',
        ),
        _buildCupBadge(
          TrophyAssets.platinum,
          (user['platinum_count'] ?? 0).toString(),
          Colors.purple,
          isHighlighted: topCup == 'platinum',
        ),
      ],
    );
  }

  Widget _buildCupBadge(
    String trophyAsset,
    String count,
    Color tierColor, {
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tierColor.withOpacity(isHighlighted ? 0.24 : 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: tierColor.withOpacity(isHighlighted ? 0.8 : 0.33),
          width: isHighlighted ? 1.2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tierColor.withOpacity(0.2),
              border: Border.all(color: tierColor.withOpacity(0.45)),
            ),
            child: Center(
              child: Image.asset(
                trophyAsset,
                width: 14,
                height: 14,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.emoji_events,
                    size: 12,
                    color: widget.themeConfig.textColor.withOpacity(0.95),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            count,
            style: GoogleFonts.notoSans(
              fontSize: 10.5,
              color: widget.themeConfig.textColor.withOpacity(0.95),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
