import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';
import '../utils/trophy_assets.dart';
import '../services/settings_service.dart';

class KupaScreenNew extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String currentUserId;
  final int currentZikrCount;

  const KupaScreenNew({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.currentUserId,
    this.currentZikrCount = 0,
  });

  @override
  State<KupaScreenNew> createState() => _KupaScreenNewState();
}

class _KupaScreenNewState extends State<KupaScreenNew> {
  int _totalZikrs = 0;
  List<Map<String, dynamic>> _allCups = [];
  Map<String, bool> _unlockedCups = {};
  String _nextCupName = '';
  int _nextCupRequirement = 0;
  bool _hasShownNotification = false;
  String _currentLanguage = 'tr'; // Dil değişkeni eklendi
  int _userLevel = 0;
  double _progressToNextCup = 0.0;
  DateTime? _lastCupUnlocked;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında hemen güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
    _loadZikrCount();
  }

  @override
  void didUpdateWidget(KupaScreenNew oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget güncellendiğinde (zikir sayısı değiştiğinde) veriyi yenile
    if (oldWidget.currentZikrCount != widget.currentZikrCount) {
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final totalZikrs = widget.currentZikrCount > 0
          ? widget.currentZikrCount
          : prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;

      // Daha önce kazanılmış kupaları yükle (bildirim sadece yeni kazanılanlarda gösterilsin)
      final previouslyUnlocked = {
        'bronze_kupa': prefs.getBool('bronze_kupa_unlocked_${widget.currentUserId}') ?? false,
        'silver_kupa': prefs.getBool('silver_kupa_unlocked_${widget.currentUserId}') ?? false,
        'gold_kupa': prefs.getBool('gold_kupa_unlocked_${widget.currentUserId}') ?? false,
        'diamond_kupa': prefs.getBool('diamond_kupa_unlocked_${widget.currentUserId}') ?? false,
        'platinum_kupa': prefs.getBool('platinum_kupa_unlocked_${widget.currentUserId}') ?? false,
      };

      final currentLanguage = prefs.getString('language_code') ?? prefs.getString('language') ?? 'tr';

      setState(() {
        _totalZikrs = totalZikrs;
        _currentLanguage = currentLanguage;
        _unlockedCups = Map<String, bool>.from(previouslyUnlocked);

        _allCups = [
          {
            'id': 'bronze_kupa',
            'name': _getKupaName('bronze'),
            'trophyAsset': TrophyAssets.bronze,
            'icon': '🥉',
            'requirement': 100,
            'description': _getKupaDescription('bronze'),
            'color': Colors.brown,
            'unlocked': totalZikrs >= 100,
          },
          {
            'id': 'silver_kupa',
            'name': _getKupaName('silver'),
            'trophyAsset': TrophyAssets.silver,
            'icon': '🥈',
            'requirement': 500,
            'description': _getKupaDescription('silver'),
            'color': Colors.grey,
            'unlocked': totalZikrs >= 500,
          },
          {
            'id': 'gold_kupa',
            'name': _getKupaName('gold'),
            'trophyAsset': TrophyAssets.gold,
            'icon': '🥇',
            'requirement': 1000,
            'description': _getKupaDescription('gold'),
            'color': Colors.yellow,
            'unlocked': totalZikrs >= 1000,
          },
          {
            'id': 'diamond_kupa',
            'name': _getKupaName('diamond'),
            'trophyAsset': TrophyAssets.diamond,
            'icon': '💎',
            'requirement': 5000,
            'description': _getKupaDescription('diamond'),
            'color': Colors.blue,
            'unlocked': totalZikrs >= 5000,
          },
          {
            'id': 'platinum_kupa',
            'name': _getKupaName('platinum'),
            'trophyAsset': TrophyAssets.platinum,
            'icon': '🏆',
            'requirement': 10000,
            'description': _getKupaDescription('platinum'),
            'color': Colors.purple,
            'unlocked': totalZikrs >= 10000,
          },
        ];
      });
      
      _calculateNextCup();

      // Yeni kazanılan kupalar için bildirim; kazanıldığında prefs'e yaz
      _checkForNewUnlocks();
      _persistUnlockedCups(prefs);
      
    } catch (e) {
      print('Error refreshing kupa screen: $e');
    }
  }

  String _getTrophiesTitle() {
    return DynamicLocalizationHelper.getText({
      'tr': 'Kupalar',
      'en': 'Trophies',
      'ar': 'الكؤوس',
      'id': 'Piala',
      'ur': 'ٹرافیاں',
      'bn': 'ট্রফি',
      'ms': 'Piala',
      'fa': 'جام ها',
      'fr': 'Trophées',
      'zh': '奖杯',
      'ja': 'トロフィー',
      'ru': 'Трофеи',
      'de': 'Trophäen',
      'sw': 'Tuzo',
      'ha': 'Kofuna',
    });
  }

  String _getKupaName(String type) {
    final names = {
      'bronze': {
        'tr': 'Bronz Kupa',
        'en': 'Bronze Cup',
        'ar': 'كأس برونزي',
        'id': 'Piala Perunggu',
        'ur': 'برانز کپ',
        'bn': 'ব্রোঞ্জ কাপ',
        'ms': 'Piala Gangsa',
        'fa': 'جام برنزی',
        'fr': 'Coupe de bronze',
        'zh': '铜杯',
        'ja': '銅杯',
        'ru': 'Бронзовая чаша',
        'de': 'Bronzepokal',
        'sw': 'Kombe la Shaba',
        'ha': 'Kofin Bronze',
      },
      'silver': {
        'tr': 'Gümüş Kupa',
        'en': 'Silver Cup',
        'ar': 'كأس فضي',
        'id': 'Piala Perak',
        'ur': 'سلور کپ',
        'bn': 'রৌপ্য কাপ',
        'ms': 'Piala Perak',
        'fa': 'جام نقره',
        'fr': 'Coupe d\'argent',
        'zh': '银杯',
        'ja': '銀杯',
        'ru': 'Серебряная чаша',
        'de': 'Silberpokal',
        'sw': 'Kombe la Fedha',
        'ha': 'Kofin Azurfa',
      },
      'gold': {
        'tr': 'Altın Kupa',
        'en': 'Gold Cup',
        'ar': 'كأس ذهبي',
        'id': 'Piala Emas',
        'ur': 'گولڈ کپ',
        'bn': 'স্বর্ণ কাপ',
        'ms': 'Piala Emas',
        'fa': 'جام طلا',
        'fr': 'Coupe d\'or',
        'zh': '金杯',
        'ja': '金杯',
        'ru': 'Золотая чаша',
        'de': 'Goldpokal',
        'sw': 'Kombe la Dhahabu',
        'ha': 'Kofin Zinariya',
      },
      'diamond': {
        'tr': 'Elmas Kupa',
        'en': 'Diamond Cup',
        'ar': 'كأس ماسي',
        'id': 'Piala Berlian',
        'ur': 'ڈائمنڈ کپ',
        'bn': 'হীরা কাপ',
        'ms': 'Piala Berlian',
        'fa': 'جام الماس',
        'fr': 'Coupe diamant',
        'zh': '钻石杯',
        'ja': 'ダイヤモンド杯',
        'ru': 'Бриллиантовая чаша',
        'de': 'Diamantpokal',
        'sw': 'Kombe la Almasi',
        'ha': 'Kofin Lu\'u',
      },
      'platinum': {
        'tr': 'Platin Kupa',
        'en': 'Platinum Cup',
        'ar': 'كأس بلاتيني',
        'id': 'Piala Platinum',
        'ur': 'پلاٹینم کپ',
        'bn': 'প্ল্যাটিনাম কাপ',
        'ms': 'Piala Platinum',
        'fa': 'جام پلاتین',
        'fr': 'Coupe platine',
        'zh': '白金杯',
        'ja': 'プラチナ杯',
        'ru': 'Платиновая чаша',
        'de': 'Platinpokal',
        'sw': 'Kombe la Platini',
        'ha': 'Kofin Platinum',
      },
    };

    return DynamicLocalizationHelper.getText(names[type] ?? {'tr': type});
  }

  String _getKupaDescription(String type) {
    final descriptions = {
      'bronze': {
        'tr': 'İlk 100 zikir için',
        'en': 'For first 100 dhikr',
        'ar': 'لأول 100 ذكر',
        'id': 'Untuk 100 dhikr pertama',
        'ur': 'پہلے 100 ذکر کے لیے',
        'bn': 'প্রথম ১০০ জিকরের জন্য',
        'ms': 'Untuk 100 dhikr pertama',
        'fa': 'برای ۱۰۰ ذکر اول',
        'fr': 'Pour les 100 premiers dhikr',
        'zh': '首次100赞念',
        'ja': '初回100ズィクル',
        'ru': 'За первые 100 зикров',
        'de': 'Für die ersten 100 Dhikr',
        'sw': 'Kwa Dhikr 100 za kwanza',
        'ha': 'Don dhikr 100 na farko',
      },
      'silver': {
        'tr': '500 zikir için',
        'en': 'For 500 dhikr',
        'ar': 'لـ 500 ذكر',
        'id': 'Untuk 500 dhikr',
        'ur': '500 ذکر کے لیے',
        'bn': '৫০০ জিকরের জন্য',
        'ms': 'Untuk 500 dhikr',
        'fa': 'برای ۵۰۰ ذکر',
        'fr': 'Pour 500 dhikr',
        'zh': '500赞念',
        'ja': '500ズィクル',
        'ru': 'За 500 зикров',
        'de': 'Für 500 Dhikr',
        'sw': 'Kwa Dhikr 500',
        'ha': 'Don dhikr 500',
      },
      'gold': {
        'tr': '1000 zikir için',
        'en': 'For 1000 dhikr',
        'ar': 'لـ 1000 ذكر',
        'id': 'Untuk 1000 dhikr',
        'ur': '1000 ذکر کے لیے',
        'bn': '১০০০ জিকরের জন্য',
        'ms': 'Untuk 1000 dhikr',
        'fa': 'برای ۱۰۰۰ ذکر',
        'fr': 'Pour 1000 dhikr',
        'zh': '1000赞念',
        'ja': '1000ズィクル',
        'ru': 'За 1000 зикров',
        'de': 'Für 1000 Dhikr',
        'sw': 'Kwa Dhikr 1000',
        'ha': 'Don dhikr 1000',
      },
      'diamond': {
        'tr': '5000 zikir için',
        'en': 'For 5000 dhikr',
        'ar': 'لـ 5000 ذكر',
        'id': 'Untuk 5000 dhikr',
        'ur': '5000 ذکر کے لیے',
        'bn': '৫০০০ জিকরের জন্য',
        'ms': 'Untuk 5000 dhikr',
        'fa': 'برای ۵۰۰۰ ذکر',
        'fr': 'Pour 5000 dhikr',
        'zh': '5000赞念',
        'ja': '5000ズィクル',
        'ru': 'За 5000 зикров',
        'de': 'Für 5000 Dhikr',
        'sw': 'Kwa Dhikr 5000',
        'ha': 'Don dhikr 5000',
      },
      'platinum': {
        'tr': '10000 zikir için',
        'en': 'For 10000 dhikr',
        'ar': 'لـ 10000 ذكر',
        'id': 'Untuk 10000 dhikr',
        'ur': '10000 ذکر کے لیے',
        'bn': '১০০০০ জিকরের জন্য',
        'ms': 'Untuk 10000 dhikr',
        'fa': 'برای ۱۰۰۰۰ ذکر',
        'fr': 'Pour 10000 dhikr',
        'zh': '10000赞念',
        'ja': '10000ズィクル',
        'ru': 'За 10000 зикров',
        'de': 'Für 10000 Dhikr',
        'sw': 'Kwa Dhikr 10000',
        'ha': 'Don dhikr 10000',
      },
    };

    return DynamicLocalizationHelper.getText(descriptions[type] ?? {'tr': type});
  }

  void _checkForNewUnlocks() {
    for (var cup in _allCups) {
      if (cup['unlocked'] == true) {
        final wasUnlocked = _unlockedCups[cup['id']] ?? false;
        if (!wasUnlocked) {
          _unlockedCups[cup['id']] = true;
          if (mounted && !_hasShownNotification) {
            _showCupUnlockedNotification(cup);
            _hasShownNotification = true;
          }
        }
      }
    }
  }

  Future<void> _persistUnlockedCups(SharedPreferences prefs) async {
    final uid = widget.currentUserId;
    await prefs.setBool('bronze_kupa_unlocked_$uid', _unlockedCups['bronze_kupa'] ?? false);
    await prefs.setBool('silver_kupa_unlocked_$uid', _unlockedCups['silver_kupa'] ?? false);
    await prefs.setBool('gold_kupa_unlocked_$uid', _unlockedCups['gold_kupa'] ?? false);
    await prefs.setBool('diamond_kupa_unlocked_$uid', _unlockedCups['diamond_kupa'] ?? false);
    await prefs.setBool('platinum_kupa_unlocked_$uid', _unlockedCups['platinum_kupa'] ?? false);
  }

  void _showCupUnlockedNotification(Map<String, dynamic> cup) {
    if (!mounted) return;
    
    String message = DynamicLocalizationHelper.getText({
      'tr': '🎉 Tebrikler! ${cup['name']} kazandınız!',
      'en': '🎉 Congratulations! You won ${cup['name']}!',
      'ar': '🎉 مبروك! لقد فزت بـ ${cup['name']}!',
      'id': '🎉 Selamat! Anda memenangkan ${cup['name']}!',
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            _buildCupSnackIcon(cup),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _loadZikrCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final totalZikrs = widget.currentZikrCount > 0 
          ? widget.currentZikrCount 
          : prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      
      setState(() {
        _totalZikrs = totalZikrs;
      });
      
      // Tüm kupaları tanımla
      _allCups = [
        {
          'id': 'bronze_kupa',
          'trophyAsset': TrophyAssets.bronze,
          'name': DynamicLocalizationHelper.getText({
            'tr': 'Bronz Kupa',
            'en': 'Bronze Trophy',
            'ar': 'كأس برونزي',
            'id': 'Piala Perunggu',
            'ur': 'کانسی ٹرافی',
            'bn': 'ব্রোঞ্জ ট্রফি',
            'ms': 'Piala Gangsa',
            'fa': 'جام برنزی',
            'fr': 'Trophée de Bronze',
            'zh': '青铜奖杯',
            'ja': 'ブロンズトロフィー',
            'ru': 'Бронзовый Трофей',
            'de': 'Bronze Trophäe',
            'sw': 'Tuzo ya Shaba',
            'ha': 'Kofin Tagulla',
          }),
          'icon': '🥉',
          'requirement': 100,
          'description': DynamicLocalizationHelper.getText({
            'tr': 'İlk 100 zikir için',
            'en': 'For first 100 dhikr',
            'ar': 'أول 100 ذكر',
            'id': 'Untuk 100 zikir pertama',
            'ur': 'پہلے 100 ذکر کے لیے',
            'bn': 'প্রথম 100 জিকিরের জন্য',
            'ms': 'Untuk 100 zikir pertama',
            'fa': 'برای 100 ذکر اول',
            'fr': 'Pour les 100 premiers dhikr',
            'zh': '前100个赞念',
            'ja': '最初の100ジクル',
            'ru': 'За первые 100 зикров',
            'de': 'Für die ersten 100 Dhikr',
            'sw': 'Kwa dhikr 100 za kwanza',
            'ha': 'Don zikiri 100 na farko',
          }),
          'color': Colors.brown,
          'unlocked': totalZikrs >= 100,
        },
        {
          'id': 'silver_kupa',
          'trophyAsset': TrophyAssets.silver,
          'name': DynamicLocalizationHelper.getText({
            'tr': 'Gümüş Kupa',
            'en': 'Silver Trophy',
            'ar': 'كأس فضي',
            'id': 'Piala Perak',
            'ur': 'چاندی ٹرافی',
            'bn': 'রৌপ্য ট্রফি',
            'ms': 'Piala Perak',
            'fa': 'جام نقره ای',
            'fr': 'Trophée d\'Argent',
            'zh': '白银奖杯',
            'ja': 'シルバートロフィー',
            'ru': 'Серебряный Трофей',
            'de': 'Silberne Trophäe',
            'sw': 'Tuzu ya Fedha',
            'ha': 'Kofin Azurfa',
          }),
          'icon': '🥈',
          'requirement': 500,
          'description': DynamicLocalizationHelper.getText({
            'tr': '500 zikir için',
            'en': 'For 500 dhikr',
            'ar': 'لـ 500 ذكر',
            'id': 'Untuk 500 zikir',
            'ur': '500 ذکر کے لیے',
            'bn': '500 জিকিরের জন্য',
            'ms': 'Untuk 500 zikir',
            'fa': 'برای 500 ذکر',
            'fr': 'Pour 500 dhikr',
            'zh': '500个赞念',
            'ja': '500ジクル',
            'ru': 'За 500 зикров',
            'de': 'Für 500 Dhikr',
            'sw': 'Kwa dhikr 500',
            'ha': 'Don zikiri 500',
          }),
          'color': Colors.grey,
          'unlocked': totalZikrs >= 500,
        },
        {
          'id': 'gold_kupa',
          'trophyAsset': TrophyAssets.gold,
          'name': DynamicLocalizationHelper.getText({
            'tr': 'Altın Kupa',
            'en': 'Gold Trophy',
            'ar': 'كأس ذهبي',
            'id': 'Piala Emas',
            'ur': 'سونے ٹرافی',
            'bn': 'স্বর্ণ ট্রফি',
            'ms': 'Piala Emas',
            'fa': 'جام طلایی',
            'fr': 'Trophée d\'Or',
            'zh': '黄金奖杯',
            'ja': 'ゴールドトロフィー',
            'ru': 'Золотой Трофей',
            'de': 'Goldene Trophäe',
            'sw': 'Tuzo ya Dhahabu',
            'ha': 'Kofin Zinare',
          }),
          'icon': '🥇',
          'requirement': 1000,
          'description': DynamicLocalizationHelper.getText({
            'tr': '1000 zikir için',
            'en': 'For 1000 dhikr',
            'ar': 'لـ 1000 ذكر',
            'id': 'Untuk 1000 zikir',
            'ur': '1000 ذکر کے لیے',
            'bn': '1000 জিকিরের জন্য',
            'ms': 'Untuk 1000 zikir',
            'fa': 'برای 1000 ذکر',
            'fr': 'Pour 1000 dhikr',
            'zh': '1000个赞念',
            'ja': '1000ジクル',
            'ru': 'За 1000 зикров',
            'de': 'Für 1000 Dhikr',
            'sw': 'Kwa dhikr 1000',
            'ha': 'Don zikiri 1000',
          }),
          'color': Colors.yellow,
          'unlocked': totalZikrs >= 1000,
        },
        {
          'id': 'diamond_kupa',
          'trophyAsset': TrophyAssets.diamond,
          'name': DynamicLocalizationHelper.getText({
            'tr': 'Elmas Kupa',
            'en': 'Diamond Trophy',
            'ar': 'كأس ألماس',
            'id': 'Piala Berlian',
            'ur': 'ہیرے ٹرافی',
            'bn': 'হীরা ট্রফি',
            'ms': 'Piala Intan',
            'fa': 'جام الماسی',
            'fr': 'Trophée de Diamant',
            'zh': '钻石奖杯',
            'ja': 'ダイヤモンドトロフィー',
            'ru': 'Алмазный Трофей',
            'de': 'Diamant-Trophäe',
            'sw': 'Tuzo ya Almasi',
            'ha': 'Kofin Lu\'ulu',
          }),
          'icon': '💎',
          'requirement': 5000,
          'description': DynamicLocalizationHelper.getText({
            'tr': '5000 zikir için',
            'en': 'For 5000 dhikr',
            'ar': 'لـ 5000 ذكر',
            'id': 'Untuk 5000 zikir',
            'ur': '5000 ذکر کے لیے',
            'bn': '5000 জিকিরের জন্য',
            'ms': 'Untuk 5000 zikir',
            'fa': 'برای 5000 ذکر',
            'fr': 'Pour 5000 dhikr',
            'zh': '5000个赞念',
            'ja': '5000ジクル',
            'ru': 'За 5000 зикров',
            'de': 'Für 5000 Dhikr',
            'sw': 'Kwa dhikr 5000',
            'ha': 'Don zikiri 5000',
          }),
          'color': Colors.blue,
          'unlocked': totalZikrs >= 5000,
        },
        {
          'id': 'platinum_kupa',
          'trophyAsset': TrophyAssets.platinum,
          'name': DynamicLocalizationHelper.getText({
            'tr': 'Platin Kupa',
            'en': 'Platinum Trophy',
            'ar': 'كأس بلاتيني',
            'id': 'Piala Platinum',
            'ur': 'پلاٹینم ٹرافی',
            'bn': 'প্লাটিনাম ট্রফি',
            'ms': 'Piala Platinum',
            'fa': 'جام پلاتینی',
            'fr': 'Trophée de Platine',
            'zh': '铂金奖杯',
            'ja': 'プラチナトロフィー',
            'ru': 'Платиновый Трофей',
            'de': 'Platin-Trophäe',
            'sw': 'Tuzo ya Platinum',
            'ha': 'Kofin Fula',
          }),
          'icon': '🏆',
          'requirement': 10000,
          'description': DynamicLocalizationHelper.getText({
            'tr': '10000 zikir için',
            'en': 'For 10000 dhikr',
            'ar': 'لـ 10000 ذكر',
            'id': 'Untuk 10000 zikir',
            'ur': '10000 ذکر کے لیے',
            'bn': '10000 জিকিরের জন্য',
            'ms': 'Untuk 10000 zikir',
            'fa': 'برای 10000 ذکر',
            'fr': 'Pour 10000 dhikr',
            'zh': '10000个赞念',
            'ja': '10000ジクル',
            'ru': 'За 10000 зикров',
            'de': 'Für 10000 Dhikr',
            'sw': 'Kwa dhikr 10000',
            'ha': 'Don zikiri 10000',
          }),
          'color': Colors.purple,
          'unlocked': totalZikrs >= 10000,
        },
      ];
      
      // Sonraki kupa bilgisini hesapla
      _calculateNextCup();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading zikr count: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateNextCup() {
    String nextCup = '';
    int nextRequirement = 0;
    double progress = 0.0;
    
    for (final cup in _allCups) {
      if (!cup['unlocked']) {
        nextCup = cup['name'];
        nextRequirement = cup['requirement'];
        progress = _totalZikrs / nextRequirement;
        break;
      }
    }
    
    // Kalan zikir sayısını hesapla
    final remainingForNext = nextRequirement - _totalZikrs;
    
    setState(() {
      _nextCupName = nextCup;
      _nextCupRequirement = remainingForNext;
      _progressToNextCup = progress.clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.themeConfig.primaryColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
                          _getTrophiesTitle(),
                          style: GoogleFonts.notoSans(
                            color: widget.themeConfig.textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // Refresh butonu kaldırıldı
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Sonraki Kupa İlerlemesi
                    _buildNextCupProgress(),
                    
                    const SizedBox(height: 20),
                    
                    // Kupalar Grid
                    _buildCupsGrid(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildNextCupProgress() {
    if (_nextCupName.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Tüm kupaları kazandınız!',
                'en': 'You won all trophies!',
                'ar': 'لقد فزت بكل الجوائز!',
                'id': 'Anda memenangkan semua piala!',
                'ur': 'آپ نے تمام ٹرافیاں جیتیں!',
                'bn': 'আপনি সব ট্রফি জিতেছেন!',
                'ms': 'Anda memenangi semua piala!',
                'fa': 'شما تمام جام ها را برنده شدید!',
                'fr': 'Vous avez gagné tous les trophées!',
                'zh': '你赢得了所有奖杯！',
                'ja': 'すべてのトロフィーを獲得しました！',
                'ru': 'Вы выиграли все трофеи!',
                'de': 'Sie haben alle Trophäen gewonnen!',
                'sw': 'Umeshinda tuzo zote!',
                'ha': 'Ka ci kofuna duka!',
              }),
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Tebrikler! Zikir ustası oldunuz.',
                'en': 'Congratulations! You became a dhikr master.',
                'ar': 'مبارك! لقد أصبحت خبيرًا في الذكر.',
                'id': 'Selamat! Anda menjadi master zikir.',
                'ur': 'مبارک! آپ ذکر کا استاد بن گئے.',
                'bn': 'অভিনন্দন! আপনি একজন জিকির মাস্টার হয়েছেন.',
                'ms': 'Tahniah! Anda menjadi tuan zikir.',
                'fa': 'تبریک! شما استاد ذکر شدید.',
                'fr': 'Félicitations ! Vous êtes devenu un maître du dhikr.',
                'zh': '恭喜！你成为了赞念大师。',
                'ja': 'おめでとうございます！あなたはジクルのマスターになりました。',
                'ru': 'Поздравляем! Вы стали мастером зикра.',
                'de': 'Herzlichen Glückwunsch! Sie sind ein Dhikr-Meister geworden.',
                'sw': 'Hongera! Umekuwa mkuu wa dhikr.',
                'ha': 'Mabarka! Ka zama mai zikiri.',
              }),
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Sonraki Kupa: $_nextCupName',
              'en': 'Next Trophy: $_nextCupName',
              'ar': 'الكأس التالي: $_nextCupName',
              'id': 'Piala Berikutnya: $_nextCupName',
              'ur': 'اگلا ٹرافی: $_nextCupName',
              'bn': 'পরবর্তী ট্রফি: $_nextCupName',
              'ms': 'Piala Seterusnya: $_nextCupName',
              'fa': 'جام بعدی: $_nextCupName',
              'fr': 'Trophée Suivant: $_nextCupName',
              'zh': '下一个奖杯: $_nextCupName',
              'ja': '次のトロフィー: $_nextCupName',
              'ru': 'Следующий Трофей: $_nextCupName',
              'de': 'Nächster Pokal: $_nextCupName',
              'sw': 'Tuzo Inayofuata: $_nextCupName',
              'ha': 'Kofin Gaba: $_nextCupName',
            }),
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _progressToNextCup,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Kalan: $_nextCupRequirement zikir',
              'en': 'Remaining: $_nextCupRequirement dhikr',
              'ar': 'المتبقي: $_nextCupRequirement ذكر',
              'id': 'Tersisa: $_nextCupRequirement zikir',
              'ur': 'بقیہ: $_nextCupRequirement ذکر',
              'bn': 'অবশিষ্ট: $_nextCupRequirement জিকির',
              'ms': 'Berbaki: $_nextCupRequirement zikir',
              'fa': 'باقیمانده: $_nextCupRequirement ذکر',
              'fr': 'Restant: $_nextCupRequirement dhikr',
              'zh': '剩余: $_nextCupRequirement 个赞念',
              'ja': '残り: $_nextCupRequirement ジクル',
              'ru': 'Осталось: $_nextCupRequirement зикров',
              'de': 'Verbleibend: $_nextCupRequirement Dhikr',
              'sw': 'Zilizobaki: $_nextCupRequirement dhikr',
              'ha': 'Mai gudun: $_nextCupRequirement zikiri',
            }),
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCupSnackIcon(Map<String, dynamic> cup) {
    final asset = cup['trophyAsset'] as String?;
    final emoji = cup['icon'] as String? ?? '🏆';
    if (asset != null && asset.isNotEmpty) {
      return Image.asset(
        asset,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Text(emoji, style: const TextStyle(fontSize: 24));
        },
      );
    }
    return Text(emoji, style: const TextStyle(fontSize: 24));
  }

  Widget _buildCupIconBadge({
    required String trophyAsset,
    required String fallbackEmoji,
    required Color tierColor,
    required bool unlocked,
  }) {
    final backgroundColor = unlocked
        ? tierColor.withOpacity(0.22)
        : Colors.grey.withOpacity(0.08);
    final borderColor = unlocked
        ? tierColor.withOpacity(0.55)
        : Colors.grey.withOpacity(0.28);

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1.2),
        gradient: unlocked
            ? LinearGradient(
                colors: [
                  tierColor.withOpacity(0.35),
                  tierColor.withOpacity(0.12),
                ],
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: (unlocked ? tierColor : Colors.grey).withOpacity(unlocked ? 0.25 : 0.12),
            blurRadius: 14,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Opacity(
          opacity: unlocked ? 1.0 : 0.65,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              trophyAsset,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  fallbackEmoji,
                  style: const TextStyle(
                    fontSize: 28,
                    height: 1,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCupsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0, // 1.0'dan 1.2'ye değiştirdik
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _allCups.length,
      itemBuilder: (context, index) {
        final cup = _allCups[index];
        final isUnlocked = cup['unlocked'] as bool;
        
        return Container(
          decoration: BoxDecoration(
            color: isUnlocked 
                ? (cup['color'] as Color).withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnlocked 
                  ? (cup['color'] as Color).withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCupIconBadge(
                trophyAsset: cup['trophyAsset'] as String? ?? TrophyAssets.pathForCupId(cup['id'] as String),
                fallbackEmoji: cup['icon'] as String,
                tierColor: cup['color'] as Color,
                unlocked: isUnlocked,
              ),
              const SizedBox(height: 6), // 8'den 6'ya düşürdük
              Text(
                cup['name'] as String,
                style: GoogleFonts.notoSans(
                  fontSize: 12, // 14'ten 12'ye düşürdük
                  fontWeight: FontWeight.w600,
                  color: isUnlocked 
                      ? Colors.white
                      : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2), // 4'ten 2'ye düşürdük
              Text(
                cup['description'] as String,
                style: GoogleFonts.notoSans(
                  fontSize: 8, // 10'den 8'e düşürdük
                  color: isUnlocked 
                      ? Colors.white.withOpacity(0.8)
                      : Colors.grey.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 1, // maxLines: 1 ekledik
                overflow: TextOverflow.ellipsis, // overflow ekle
              ),
              const SizedBox(height: 4), // 8'den 4'e düşürdük
              if (isUnlocked)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16, // 20'den 16'ya düşürdük
                )
              else
                Icon(
                  Icons.lock,
                  color: Colors.grey,
                  size: 16, // 20'den 16'ya düşürdük
                ),
            ],
          ),
        );
      },
    );
  }
}
