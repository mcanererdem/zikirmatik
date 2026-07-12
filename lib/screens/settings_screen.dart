import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';
import '../services/settings_service.dart';
import '../services/ad_service.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';
import '../screens/home_page.dart' as home;
import '../screens/about_screen_new.dart';
import '../screens/support_screen_new.dart';
import '../screens/import_export_screen.dart';
import '../widgets/notification_settings_dialog.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String currentUserId;
  final Function()? onSettingsChanged;
  final Function(String)? onLanguageChanged;
  /// theme_mode: 'system' | 'light' | 'dark' — MyApp ThemeMode güncellemesi için
  final Function(String)? onThemeModeChanged;

  const SettingsScreen({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.currentUserId,
    this.onSettingsChanged,
    this.onLanguageChanged,
    this.onThemeModeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeConfig _currentTheme;
  bool _isDarkMode = false;
  bool _isVibrationOn = true;
  bool _isSoundOn = true;
  bool _isConfettiOn = true;
  bool _isTtsOn = false;
  bool _isReminderEnabled = false;
  bool _isLeaderboardEnabled = false;
  String _currentLanguage = 'tr';
  bool _isAdLoading = false;
  String _themeModeSelection = 'system';
  final SettingsService _settingsService = SettingsService();
  final AdService _adService = AdService();
  final NotificationService _notificationService = NotificationService();
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.themeConfig;
    _loadSettings();
    _preloadRewardedAd();
  }

  void _preloadRewardedAd() {
    if (!_adService.isRewardedAdLoaded) {
      _adService.loadRewardedAd(onAdLoaded: () {}, onAdFailedToLoad: (_) {});
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final vibration = await _settingsService.getVibration();
    final sound = await _settingsService.getSound();
    final confetti = await _settingsService.getConfetti();
    final ttsEnabled = await _settingsService.getTtsEnabled();
    final reminderEnabled = await _settingsService.getReminderEnabled();
    final currentLanguage = await _settingsService.getLanguage();
    final themeMode = await _settingsService.getThemeMode();

    // Tema modu: theme_mode kaydına göre (Dark seçili kalır)
    final isSystemDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    final isDarkMode = themeMode == 'dark' || (themeMode == 'system' && isSystemDark);

    // Dynamic localization helper'ı güncelle
    await DynamicLocalizationHelper.setLanguage(currentLanguage);

    final showInLeaderboard = await _settingsService.getShowInLeaderboard();

    setState(() {
      _isVibrationOn = vibration;
      _isSoundOn = sound;
      _isConfettiOn = confetti;
      _isTtsOn = ttsEnabled;
      _isReminderEnabled = reminderEnabled;
      _isLeaderboardEnabled = showInLeaderboard;
      _currentLanguage = currentLanguage;
      _themeModeSelection = themeMode;
      _isDarkMode = isDarkMode;
      _currentTheme = AppThemes.getThemeForMode(_currentTheme.id, _isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: widget.themeConfig.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              RepaintBoundary(child: _buildHeader()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  cacheExtent: 200,
                  addRepaintBoundaries: true,
                  children: [
                    RepaintBoundary(child: _buildThemeSection()),
                    RepaintBoundary(child: _buildLanguageSection()),
                    RepaintBoundary(child: _buildNotificationSection()),
                    RepaintBoundary(child: _buildSoundSection()),
                    RepaintBoundary(child: _buildAdvancedSection()),
                    RepaintBoundary(child: _buildSupportUsSection()),
                    RepaintBoundary(child: _buildMoreSection()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
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
            DynamicLocalizationHelper.settings,
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static const Map<String, Map<String, String>> _themeNames = {
    'ocean_blue': {'tr': 'Azur Gece', 'en': 'Azure Night', 'ar': 'ليلة لازوردية', 'id': 'Malam Azure', 'ur': 'ازور رات', 'bn': 'অ্যাজুর রাত', 'ms': 'Malam Azure', 'fa': 'شب لاجوردی', 'fr': 'Nuit Azur', 'zh': '蔚蓝之夜', 'ja': 'アズールナイト', 'ru': 'Лазурная Ночь', 'de': 'Azur Nacht', 'sw': 'Usiku wa Samawati', 'ha': 'Daren Azure'},
    'emerald_green': {'tr': 'Yeşil Vadi', 'en': 'Verdant', 'ar': 'أخضر يانع', 'id': 'Hijau Segar', 'ur': 'سرسبز', 'bn': 'সজীব সবুজ', 'ms': 'Hijau Segar', 'fa': 'سبزِ شاداب', 'fr': 'Verdoyant', 'zh': '青翠', 'ja': 'ヴァーダント', 'ru': 'Сочная Зелень', 'de': 'Sattes Grün', 'sw': 'Kijani Kibichi', 'ha': 'Kore Mai Yawa'},
    'rose_pink': {'tr': 'Gün Batımı Gülü', 'en': 'Sunset Rose', 'ar': 'وردة الغروب', 'id': 'Mawar Senja', 'ur': 'غروب گلاب', 'bn': 'সানসেট রোজ', 'ms': 'Mawar Senja', 'fa': 'رزِ غروب', 'fr': 'Rose du Crépuscule', 'zh': '晚霞玫瑰', 'ja': 'サンセットローズ', 'ru': 'Роза Заката', 'de': 'Abendrose', 'sw': 'Waridi la Jioni', 'ha': 'Furen Faduwar Rana'},
    'pure_dark': {'tr': 'Grafit', 'en': 'Graphite', 'ar': 'جرافيت', 'id': 'Grafit', 'ur': 'گریفائٹ', 'bn': 'গ্রাফাইট', 'ms': 'Grafit', 'fa': 'گرافیت', 'fr': 'Graphite', 'zh': '石墨', 'ja': 'グラファイト', 'ru': 'Графит', 'de': 'Graphit', 'sw': 'Grafiti', 'ha': 'Graphite'},
  };

  String _getThemeDisplayName(String themeId) {
    final names = _themeNames[themeId];
    if (names == null) return themeId;
    return DynamicLocalizationHelper.getText(names);
  }

  Future<void> _showThemePickerSheet() async {
    final textColor = widget.themeConfig.textColor;
    final selectedId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: widget.themeConfig.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: textColor.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DynamicLocalizationHelper.getText({'tr': 'Tema seçin', 'en': 'Choose theme', 'ar': 'اختر السمة', 'id': 'Pilih tema', 'fr': 'Choisir le thème', 'zh': '选择主题', 'ja': 'テーマを選択', 'ru': 'Выберите тему', 'de': 'Design wählen'}),
              style: GoogleFonts.notoSans(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _buildThemeCardForSheet('ocean_blue', ctx),
                _buildThemeCardForSheet('emerald_green', ctx),
                _buildThemeCardForSheet('rose_pink', ctx),
                _buildThemeCardForSheet('pure_dark', ctx),
              ],
            ),
          ],
        ),
      ),
    );
    if (selectedId != null && mounted) _changeTheme(selectedId);
  }

  Widget _buildThemeCardForSheet(String themeId, BuildContext sheetContext) {
    final name = _getThemeDisplayName(themeId);
    final isSelected = _currentTheme.id == themeId;
    final theme = AppThemes.getThemeForMode(themeId, _isDarkMode);
    final gradient = theme.backgroundGradient;
    return GestureDetector(
      onTap: () => Navigator.of(sheetContext).pop(themeId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: isSelected ? 0.35 : 0.15),
              blurRadius: isSelected ? 14 : 8,
              offset: const Offset(0, 4),
              spreadRadius: isSelected ? 1 : 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(gradient: gradient),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
                      ),
                    ),
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSans(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(0, 1))],
                      ),
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Icon(Icons.check_rounded, size: 18, color: theme.primaryColor),
                    ),
                  ),
                if (isSelected)
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.localizations.theme,
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _showThemePickerSheet,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppThemes.getThemeForMode(_currentTheme.id, _isDarkMode).backgroundGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _currentTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _currentTheme.id == 'pure_dark'
                        ? null
                        : Icon(Icons.palette_outlined, color: Colors.white.withValues(alpha: 0.9), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getThemeDisplayName(_currentTheme.id),
                          style: GoogleFonts.notoSans(
                            color: widget.themeConfig.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DynamicLocalizationHelper.getText({'tr': 'Dokunun ve tema seçin', 'en': 'Tap to choose theme', 'ar': 'انقر لاختيار السمة', 'id': 'Ketuk untuk memilih tema', 'fr': 'Appuyez pour choisir', 'zh': '点击选择主题', 'ja': 'タップしてテーマを選択', 'ru': 'Нажмите для выбора', 'de': 'Tippen zum Auswählen'}),
                          style: GoogleFonts.notoSans(color: widget.themeConfig.textColor.withValues(alpha: 0.65), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: widget.themeConfig.textColor.withValues(alpha: 0.6), size: 28),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Görünüm',
              'en': 'Appearance',
              'ar': 'مظهر',
              'id': 'Tampilan',
              'ur': 'ظاہر',
              'ms': 'Penampilan',
              'fr': 'Apparence',
              'zh': '外观',
              'ja': '表示',
              'ru': 'Вид',
              'de': 'Darstellung',
            }),
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor.withValues(alpha: 0.85),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildThemeModeChip(
                'system',
                DynamicLocalizationHelper.getText({
                  'tr': 'Sistem',
                  'en': 'System',
                  'ar': 'النظام',
                  'id': 'Sistem',
                  'ur': 'سسٹم',
                  'bn': 'সিস্টেম',
                  'ms': 'Sistem',
                  'fa': 'سیستم',
                  'fr': 'Système',
                  'zh': '系统',
                  'ja': 'システム',
                  'ru': 'Система',
                  'de': 'System',
                  'sw': 'Mfumo',
                  'ha': 'Tsari',
                }),
              )),
              const SizedBox(width: 8),
              Expanded(child: _buildThemeModeChip(
                'light',
                DynamicLocalizationHelper.getText({
                  'tr': 'Açık',
                  'en': 'Light',
                  'ar': 'فاتح',
                  'id': 'Terang',
                  'ur': 'روشن',
                  'bn': 'হালকা',
                  'ms': 'Terang',
                  'fa': 'روشن',
                  'fr': 'Clair',
                  'zh': '浅色',
                  'ja': 'ライト',
                  'ru': 'Светлая',
                  'de': 'Hell',
                  'sw': 'Nuru',
                  'ha': 'Haske',
                }),
              )),
              const SizedBox(width: 8),
              Expanded(child: _buildThemeModeChip(
                'dark',
                DynamicLocalizationHelper.getText({
                  'tr': 'Koyu',
                  'en': 'Dark',
                  'ar': 'الوضع الداكن',
                  'id': 'Mode Gelap',
                  'ur': 'ڈارک موڈ',
                  'bn': 'ডার্ক মোড',
                  'ms': 'Mod Gelap',
                  'fa': 'حالت تیره',
                  'fr': 'Mode sombre',
                  'zh': '深色模式',
                  'ja': 'ダークモード',
                  'ru': 'Тёмный режим',
                  'de': 'Dunkelmodus',
                  'sw': 'Hali ya giza',
                  'ha': 'Yanayin duhu',
                }),
              )),
            ],
          ),
        ],
      ),
    );
  }


  static const Map<String, String> _languageNames = {
    'tr': '🇹🇷 Türkçe',
    'en': '🇬🇧 English',
    'ar': '🇸🇦 العربية',
    'id': '🇮🇩 Bahasa Indonesia',
    'ur': '🇵🇰 اردو',
    'bn': '🇧🇩 বাংলা',
    'ms': '🇲🇾 Bahasa Melayu',
    'fa': '🇮🇷 فارسی',
    'fr': '🇫🇷 Français',
    'zh': '🇨🇳 中文',
    'ja': '🇯🇵 日本語',
    'ru': '🇷🇺 Русский',
    'de': '🇩🇪 Deutsch',
    'sw': '🇰🇪 Swahili',
    'ha': '🇳🇬 Hausa',
  };

  Future<void> _showLanguagePickerSheet() async {
    final textColor = widget.themeConfig.textColor;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: widget.themeConfig.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: textColor.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.localizations.language,
              style: GoogleFonts.notoSans(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildLanguageOption('tr', '🇹🇷 Türkçe', onTap: () { Navigator.pop(ctx); _changeLanguage('tr'); }),
                    _buildLanguageOption('en', '🇬🇧 English', onTap: () { Navigator.pop(ctx); _changeLanguage('en'); }),
                    _buildLanguageOption('ar', '🇸🇦 العربية', onTap: () { Navigator.pop(ctx); _changeLanguage('ar'); }),
                    _buildLanguageOption('id', '🇮🇩 Bahasa Indonesia', onTap: () { Navigator.pop(ctx); _changeLanguage('id'); }),
                    _buildLanguageOption('ur', '🇵🇰 اردو', onTap: () { Navigator.pop(ctx); _changeLanguage('ur'); }),
                    _buildLanguageOption('bn', '🇧🇩 বাংলা', onTap: () { Navigator.pop(ctx); _changeLanguage('bn'); }),
                    _buildLanguageOption('ms', '🇲🇾 Bahasa Melayu', onTap: () { Navigator.pop(ctx); _changeLanguage('ms'); }),
                    _buildLanguageOption('fa', '🇮🇷 فارسی', onTap: () { Navigator.pop(ctx); _changeLanguage('fa'); }),
                    _buildLanguageOption('fr', '🇫🇷 Français', onTap: () { Navigator.pop(ctx); _changeLanguage('fr'); }),
                    _buildLanguageOption('zh', '🇨🇳 中文', onTap: () { Navigator.pop(ctx); _changeLanguage('zh'); }),
                    _buildLanguageOption('ja', '🇯🇵 日本語', onTap: () { Navigator.pop(ctx); _changeLanguage('ja'); }),
                    _buildLanguageOption('ru', '🇷🇺 Русский', onTap: () { Navigator.pop(ctx); _changeLanguage('ru'); }),
                    _buildLanguageOption('de', '🇩🇪 Deutsch', onTap: () { Navigator.pop(ctx); _changeLanguage('de'); }),
                    _buildLanguageOption('sw', '🇰🇪 Swahili', onTap: () { Navigator.pop(ctx); _changeLanguage('sw'); }),
                    _buildLanguageOption('ha', '🇳🇬 Hausa', onTap: () { Navigator.pop(ctx); _changeLanguage('ha'); }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection() {
    final currentName = _languageNames[_currentLanguage] ?? _currentLanguage;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.localizations.language,
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _showLanguagePickerSheet,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: widget.themeConfig.textColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        _currentLanguage.toUpperCase(),
                        style: GoogleFonts.notoSans(
                          color: widget.themeConfig.textColor.withValues(alpha: 0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentName,
                          style: GoogleFonts.notoSans(
                            color: widget.themeConfig.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DynamicLocalizationHelper.getText({
                            'tr': 'Dokunun ve dil seçin',
                            'en': 'Tap to choose language',
                            'ar': 'انقر لاختيار اللغة',
                            'id': 'Ketuk untuk memilih bahasa',
                            'ur': 'زبان منتخب کرنے کے لیے دبائیں',
                            'ms': 'Ketuk untuk memilih bahasa',
                            'fr': 'Appuyez pour choisir la langue',
                            'zh': '点击选择语言',
                            'ja': 'タップして言語を選択',
                            'ru': 'Нажмите для выбора языка',
                            'de': 'Tippen zum Sprachwechsel',
                          }),
                          style: GoogleFonts.notoSans(color: widget.themeConfig.textColor.withValues(alpha: 0.65), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: widget.themeConfig.textColor.withValues(alpha: 0.6), size: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeChip(String mode, String label) {
    final isSelected = _themeModeSelection == mode;
    final textColor = widget.themeConfig.textColor;
    final borderColor = textColor.withValues(alpha: isSelected ? 0.9 : 0.4);
    return GestureDetector(
      onTap: () => _changeThemeMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: textColor.withValues(alpha: isSelected ? 0.2 : 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSans(
              color: textColor,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, {VoidCallback? onTap}) {
    final isSelected = _currentLanguage == code;
    return GestureDetector(
      onTap: onTap ?? () => _changeLanguage(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? widget.themeConfig.accentColor : widget.themeConfig.textColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          name,
          style: GoogleFonts.notoSans(
            color: isSelected ? Colors.white : widget.themeConfig.textColor,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Bildirimler',
              'en': 'Notifications',
              'ar': 'الإشعارات',
              'id': 'Notifikasi',
              'ur': 'نوٹیفکیشنز',
              'ms': 'Pemberitahuan',
              'fa': 'اعلان‌ها',
              'zh': '通知',
              'ja': '通知',
              'ru': 'Уведомления',
              'de': 'Benachrichtigungen',
            }),
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Hatırlatıcılar',
                'en': 'Reminders',
                'ar': 'التذكيرات',
                'id': 'Pengingat',
                'ur': 'یاد دہانیاں',
                'ms': 'Peringatan',
                'fa': 'یادآورها',
                'zh': '提醒',
                'ja': 'リマインダー',
                'ru': 'Напоминания',
                'de': 'Erinnerungen',
              }),
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor,
              ),
            ),
            subtitle: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Zikir hatırlatıcıları',
                'en': 'Dhikr reminders',
                'ar': 'تذكيرات الذكر',
                'id': 'Pengingat Dhikr',
                'ur': 'ذکر یاد دہانیاں',
                'ms': 'Peringatan Zikir',
                'fa': 'یادآور ذکر',
                'zh': '赞念提醒',
                'ja': 'ズィクルリマインダー',
                'ru': 'Напоминания о зикре',
                'de': 'Dhikr-Erinnerungen',
              }),
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            value: _isReminderEnabled,
            onChanged: (value) async {
              setState(() {
                _isReminderEnabled = value;
              });
              await _settingsService.saveReminderEnabled(value);

              if (!value) {
                // Kullanıcı kapattıysa, daha önce planlanmış bildirimleri iptal et.
                await _notificationService.cancelReminderNotifications();
              } else {
                // Açıldığında bildirimleri hemen planla; aksi halde uygulama
                // yeniden başlatılana veya "Hatırlatıcı Ayarla" diyaloğundan
                // kaydedilene kadar hiçbir bildirim planlanmıyordu.
                final days = await _settingsService.getNotificationDays();
                if (days.isNotEmpty) {
                  final morningTime = await _settingsService.getMorningNotificationTime();
                  final eveningTime = await _settingsService.getEveningNotificationTime();
                  final morningEnabled = await _settingsService.getMorningNotificationEnabled();
                  final eveningEnabled = await _settingsService.getEveningNotificationEnabled();
                  await _notificationService.requestExactAlarmsPermission();
                  await _notificationService.scheduleReminderNotifications(
                    selectedDays: days,
                    morningTime: morningTime,
                    eveningTime: eveningTime,
                    morningEnabled: morningEnabled,
                    eveningEnabled: eveningEnabled,
                  );
                }
              }
            },
            activeThumbColor: widget.themeConfig.accentColor,
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.schedule, color: widget.themeConfig.accentColor, size: 22),
            title: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Hatırlatıcı Ayarla',
                'en': 'Set Reminder',
                'ar': 'تعيين تذكير',
                'id': 'Atur Pengingat',
                'ur': 'یاد دہانی ترتیب دیں',
                'ms': 'Tetapkan Peringatan',
                'fa': 'تنظیم یادآور',
                'zh': '设置提醒',
                'ja': 'リマインダー設定',
                'ru': 'Установить напоминание',
                'de': 'Erinnerung festlegen',
              }),
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Saat ve gün seçerek hatırlatıcı ekleyin',
                'en': 'Add reminder by choosing time and days',
                'ar': 'أضف تذكيراً باختيار الوقت والأيام',
                'id': 'Tambah pengingat dengan memilih waktu dan hari',
                'ur': 'وقت اور دن منتخب کرکے یاد دہانی شامل کریں',
                'bn': 'সময় ও দিন নির্বাচন করে অনুস্মারক যোগ করুন',
                'ms': 'Tambah peringatan dengan memilih masa dan hari',
                'fa': 'با انتخاب زمان و روزها یادآور اضافه کنید',
                'fr': 'Ajouter un rappel en choisissant l\'heure et les jours',
                'zh': '选择时间和星期添加提醒',
                'ja': '時間と曜日を選んでリマインダーを追加',
                'ru': 'Добавить напоминание, выбрав время и дни',
                'de': 'Erinnerung mit Zeit und Tagen hinzufügen',
                'sw': 'Ongeza kikumbusho kwa kuchagua saa na siku',
                'ha': 'Ƙara tunatarwa ta zaɓar lokaci da kwanaki',
              }),
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: widget.themeConfig.textColor.withValues(alpha: 0.6)),
            onTap: () async {
              await _loadSettings();
              if (!mounted) return;
              showDialog(
                context: context,
                builder: (context) => NotificationSettingsDialog(
                  themeConfig: widget.themeConfig,
                  localizations: widget.localizations,
                ),
              ).then((_) => _loadSettings());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSoundSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.localizations.soundVibration,
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(
              widget.localizations.vibration,
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor,
              ),
            ),
            subtitle: Text(
              widget.localizations.vibrateWhileCounting,
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            value: _isVibrationOn,
            onChanged: (value) {
              setState(() {
                _isVibrationOn = value;
              });
              _settingsService.saveVibration(value);
            },
            activeThumbColor: widget.themeConfig.accentColor,
          ),
          SwitchListTile(
            title: Text(
              widget.localizations.sound,
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor,
              ),
            ),
            subtitle: Text(
              widget.localizations.soundWhileCounting,
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            value: _isSoundOn,
            onChanged: (value) {
              setState(() {
                _isSoundOn = value;
              });
              _settingsService.saveSound(value);
            },
            activeThumbColor: widget.themeConfig.accentColor,
          ),
          SwitchListTile(
            title: Text(
              widget.localizations.confettiEffect,
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor,
              ),
            ),
            subtitle: Text(
              widget.localizations.confettiEffectDescription,
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            value: _isConfettiOn,
            onChanged: (value) {
              setState(() {
                _isConfettiOn = value;
              });
              _settingsService.saveConfetti(value);
            },
            activeThumbColor: widget.themeConfig.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.localizations.advanced,
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(
              widget.localizations.textToSpeech,
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor,
              ),
            ),
            subtitle: Text(
              widget.localizations.readDhikrTextsAloud,
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            value: _isTtsOn,
            onChanged: (value) {
              setState(() {
                _isTtsOn = value;
              });
              _settingsService.saveTtsEnabled(value);
            },
            activeThumbColor: widget.themeConfig.accentColor,
          ),
          SwitchListTile(
            title: Text(
              widget.localizations.leaderboard,
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor,
              ),
            ),
            subtitle: Text(
              widget.localizations.showLeaderboard,
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            value: _isLeaderboardEnabled,
            onChanged: (value) {
              if (value) {
                _showLeaderboardOptInDialog();
              } else {
                setState(() => _isLeaderboardEnabled = false);
                _settingsService.saveShowInLeaderboard(false);
                // Kullanıcı paylaşımı kapattıysa Supabase'te leaderboard kayıtlarını da temizleyelim.
                _supabaseService
                    .setLeaderboardVisibility(widget.currentUserId, false)
                    .catchError((_) {});
              }
            },
            activeThumbColor: widget.themeConfig.accentColor,
          ),
          ListTile(
            leading: Icon(Icons.share, color: widget.themeConfig.accentColor),
            title: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Kazanımları paylaş',
                'en': 'Share your progress',
                'ar': 'شارك تقدمك',
                'id': 'Bagikan progres Anda',
                'ur': 'اپنی پیشرفت شیئر کریں',
                'fa': 'پیشرفت خود را به اشتراک بگذارید',
                'fr': 'Partager votre progression',
                'zh': '分享您的进度',
                'ja': '進捗を共有',
                'ru': 'Поделиться прогрессом',
                'de': 'Fortschritt teilen',
              }),
              style: GoogleFonts.notoSans(color: widget.themeConfig.textColor),
            ),
            subtitle: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Kupaları ve zikir sayınızı WhatsApp, sosyal medya vb. ile paylaşın',
                'en': 'Share your cups and zikr count via WhatsApp, social media, etc.',
                'ar': 'شارك كؤوسك وعدد أذكارك عبر واتساب أو وسائل التواصل.',
                'id': 'Bagikan piala dan jumlah zikir melalui WhatsApp, media sosial, dll.',
                'fr': 'Partagez vos coupes et votre nombre de dhikr via WhatsApp, réseaux sociaux, etc.',
                'zh': '通过 WhatsApp、社交媒体等分享您的奖杯和赞念数。',
                'ja': 'WhatsAppやSNSでカップとジクル数を共有。',
                'ru': 'Поделитесь кубками и счётчиком зикров через WhatsApp, соцсети и т.д.',
                'de': 'Kupas und Zikir-Anzahl über WhatsApp, Soziale Medien usw. teilen.',
              }),
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            onTap: _shareProgress,
          ),
        ],
      ),
    );
  }

  Future<void> _shareProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final totalZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
    int cups = 0;
    for (final key in ['bronze_kupa_unlocked', 'silver_kupa_unlocked', 'gold_kupa_unlocked', 'diamond_kupa_unlocked', 'platinum_kupa_unlocked']) {
      if (prefs.getBool('${key}_${widget.currentUserId}') ?? false) cups++;
    }
    final msg = DynamicLocalizationHelper.getText({
      'tr': '🏆 Achievement Unlocked!\n\n$cups kupa kazandım • $totalZikrs zikir\nZikirmatik ile zikir sayıyorum.',
      'en': '🏆 Achievement Unlocked!\n\n$cups trophies earned • $totalZikrs dhikrs\nI count dhikr with Zikirmatik.',
      'ar': '🏆 إنجاز جديد!\n\n$cups كؤوس • $totalZikrs ذكر\nأعدد الذكر مع Zikirmatik.',
      'id': '🏆 Achievement Unlocked!\n\n$cups piala • $totalZikrs zikir\nSaya hitung zikir dengan Zikirmatik.',
      'fr': '🏆 Succès débloqué!\n\n$cups trophées • $totalZikrs dhikrs\nJe compte le dhikr avec Zikirmatik.',
      'zh': '🏆 成就达成！\n\n$cups 个奖杯 • $totalZikrs 赞念\n我用 Zikirmatik 数赞念。',
      'ja': '🏆 実績解除！\n\n$cups 個のトロフィー • $totalZikrs ジクル\nZikirmatikでジクルを数えています。',
      'ru': '🏆 Достижение разблокировано!\n\n$cups трофеев • $totalZikrs зикров\nСчитаю зикр в Zikirmatik.',
      'de': '🏆 Erfolg freigeschaltet!\n\n$cups Trophäen • $totalZikrs Zikr\nIch zähle Dhikr mit Zikirmatik.',
    });
    await Share.share(msg);
  }

  String _getThemeName(ThemeConfig theme) {
    switch (_currentLanguage) {
      case 'tr':
        return theme.nameTr;
      case 'en':
        return theme.nameEn;
      case 'ar':
        return theme.nameAr;
      case 'id':
        return theme.nameId;
      case 'ur':
        return theme.nameUr;
      case 'bn':
        return theme.nameBn;
      case 'ms':
        return theme.nameMs;
      case 'fa':
        return theme.nameFa;
      case 'fr':
        return theme.nameFr;
      case 'zh':
        return theme.nameZh;
      case 'ja':
        return theme.nameJa;
      case 'ru':
        return theme.nameRu;
      case 'de':
        return theme.nameDe;
      case 'sw':
        return theme.nameSw;
      case 'ha':
        return theme.nameHa;
      default:
        return theme.nameTr;
    }
  }

  void _changeTheme(String themeId) async {
    setState(() {
      _currentTheme = AppThemes.getTheme(themeId);
    });
    await _settingsService.saveTheme(themeId);

    // Ana sayfaya geri dön; HomePage zaten bu route'un .then() callback'inde
    // _loadSettings() çağırıp temayı güncelliyor. Tüm HomePage'i (AdMob, TTS,
    // Supabase init dahil) sıfırdan yeniden kurmaya gerek yok — bu, tema
    // değişiminde gözlemlenen donmanın sebebiydi.
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _changeThemeMode(String mode) async {
    setState(() {
      _themeModeSelection = mode;
    });
    await _settingsService.saveThemeMode(mode);
    // MyApp ThemeMode güncellemesi (Dark seçili kalır)
    widget.onThemeModeChanged?.call(mode);
    if (mounted) {
      Navigator.of(context).pop(context);
    }
  }

  void _changeLanguage(String language) async {
    try {
      debugPrint('🔄 _changeLanguage started with: $language');
      debugPrint('🔄 Current _currentLanguage before change: $_currentLanguage');
      
      // Önce SharedPreferences'e kaydet
      await _settingsService.saveLanguage(language);
      
      // Dynamic localization helper'ı güncelle
      await DynamicLocalizationHelper.setLanguage(language);
      
      setState(() {
        _currentLanguage = language;
      });

      // Üst widget (MyApp) dil güncellemesini alsın ki MaterialApp locale değişsin
      widget.onLanguageChanged?.call(language);

      debugPrint('🌐 Language changed to: $language');

      // Ana sayfaya geri dön ve uygulamayı tamamen yenile
      if (mounted) {
        // Loading indicator göster - basit versiyon
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: widget.themeConfig.primaryColor,
            content: Row(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(widget.themeConfig.accentColor),
                ),
                const SizedBox(width: 16),
                Text(
                  DynamicLocalizationHelper.getText({
                    'tr': 'Yükleniyor...',
                    'en': 'Loading...',
                    'ar': 'جاري التحميل...',
                    'id': 'Memuat...',
                    'ur': 'لوڈ ہو رہا ہے...',
                    'bn': 'লোড হচ্ছে...',
                    'ms': 'Memuat...',
                    'fa': 'در حال بارگذاری...',
                    'fr': 'Chargement...',
                    'zh': '加载中...',
                    'ja': '読み込み中...',
                    'ru': 'Загрузка...',
                    'de': 'Laden...',
                    'sw': 'Inapakia...',
                    'ha': 'Ana lodawa...',
                  }),
                  style: TextStyle(color: widget.themeConfig.textColor),
                ),
              ],
            ),
          ),
        );
        
        // Daha uzun bekleme - kırmızı ekranı azaltmak için
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Dialog kapat
        if (mounted) Navigator.pop(context);
        
        Navigator.of(context).popUntil((route) => route.isFirst);
        
        // Tamamen yeni bir HomePage oluştur - force refresh
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => home.HomePage(
              onThemeModeChanged: (themeMode) {
                // Tema değişikliği burada işlenebilir
              },
              onLanguageChanged: (language) {
                // Dil değişimini callback olarak al
                debugPrint('🔄 HomePage language callback received: $language');
              },
            ),
          ),
        );
      }
      
      debugPrint('🔄 Navigation completed - app should restart with new language');
    } catch (e) {
      debugPrint('❌ Error during language change: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Dil değiştirme hatası: $e',
                'en': 'Language change error: $e',
                'ar': 'خطأ في تغيير اللغة: $e',
                'id': 'Kesalahan mengubah bahasa: $e',
                'ur': 'زبان تبدیل کرنے میں خرابی: $e',
                'bn': 'ভাষা পরিবর্তন ত্রুটি: $e',
                'ms': 'Ralah menukar bahasa: $e',
                'fa': 'خطا در تغییر زبان: $e',
                'fr': 'Erreur de changement de langue: $e',
                'zh': '语言切换错误: $e',
                'ja': '言語変更エラー: $e',
                'ru': 'Ошибка смены языка: $e',
                'de': 'Sprachwechsel fehler: $e',
                'sw': 'Kosa la kubadilisha lugha: $e',
                'ha': 'Kuskure a canza harshe: $e',
              }),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _watchSupportAd() async {
    if (_isAdLoading) return;
    setState(() => _isAdLoading = true);

    if (_adService.isRewardedAdLoaded) {
      setState(() => _isAdLoading = false);
      _adService.showRewardedAd(
        onUserEarnedReward: () {
          if (!mounted) return;
          _showThankYouDialog();
        },
        onAdDismissed: () {},
      );
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: widget.themeConfig.primaryColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                DynamicLocalizationHelper.getText({
                  'tr': 'Reklam yükleniyor, lütfen bekleyin...',
                  'en': 'Loading ad, please wait...',
                  'ar': 'جاري تحميل الإعلان، يرجى الانتظار...',
                  'id': 'Memuat iklan, harap tunggu...',
                  'ur': 'اشتہار لوڈ ہو رہا ہے، براہ کرم انتظار کریں...',
                  'fa': 'در حال بارگذاری تبلیغ، لطفاً صبر کنید...',
                  'fr': 'Chargement de la pub, veuillez patienter...',
                  'zh': '正在加载广告，请稍候...',
                  'ja': '広告を読み込み中、お待ちください...',
                  'ru': 'Загрузка рекламы, подождите...',
                  'de': 'Anzeige wird geladen, bitte warten...',
                }),
                style: GoogleFonts.notoSans(
                  color: widget.themeConfig.textColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    final loaded = await _adService.loadRewardedAdWithTimeout(timeout: const Duration(seconds: 15));
    if (!mounted) return;
    setState(() => _isAdLoading = false);
    Navigator.of(context, rootNavigator: true).pop();

    if (!loaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Reklam yüklenemedi. İnternet bağlantınızı kontrol edin veya daha sonra tekrar deneyin.',
              'en': 'Ad could not load. Check your internet connection or try again later.',
              'ar': 'تعذر تحميل الإعلان. تحقق من اتصالك بالإنترنت أو حاول لاحقاً.',
              'id': 'Iklan tidak dapat dimuat. Periksa koneksi internet atau coba lagi nanti.',
              'ur': 'اشتہار لوڈ نہیں ہو سکا۔ انٹرنیٹ کنکشن چیک کریں یا بعد میں دوبارہ کوشش کریں۔',
              'fa': 'تبلیغ بارگذاری نشد. اتصال اینترنت را بررسی کنید یا بعداً تلاش کنید.',
              'fr': 'La pub n\'a pas pu se charger. Vérifiez votre connexion ou réessayez plus tard.',
              'zh': '广告无法加载。请检查网络连接或稍后重试。',
              'ja': '広告を読み込めませんでした。接続を確認するか、後でもう一度お試しください。',
              'ru': 'Не удалось загрузить рекламу. Проверьте интернет или попробуйте позже.',
              'de': 'Anzeige konnte nicht geladen werden. Internet prüfen oder später erneut versuchen.',
            }),
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    _adService.showRewardedAd(
      onUserEarnedReward: () {
        if (!mounted) return;
        _showThankYouDialog();
      },
      onAdDismissed: () {},
    );
  }

  void _showLeaderboardOptInDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.themeConfig.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          DynamicLocalizationHelper.getText({
            'tr': 'Liderlik tablosunda paylaş',
            'en': 'Share on leaderboard',
            'ar': 'المشاركة في لوحة المتصدرين',
            'id': 'Bagikan di papan peringkat',
            'ur': 'لیڈر بورڈ پر شیئر کریں',
            'fa': 'اشتراک در جدول امتیازات',
            'fr': 'Partager sur le classement',
            'zh': '在排行榜上分享',
            'ja': 'リーダーボードで共有',
            'ru': 'Поделиться в таблице лидеров',
            'de': 'In Bestenliste teilen',
          }),
          style: GoogleFonts.notoSans(color: widget.themeConfig.textColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          DynamicLocalizationHelper.getText({
            'tr': 'Açtığınızda zikir sayınız (kullanıcı adıyla birlikte) herkese açık liderlik tablosunda görünür. Diğer kullanıcılar sıralamayı görebilir. İstediğiniz zaman ayarlardan kapatabilirsiniz.',
            'en': 'When enabled, your zikr count (with your username) will appear on the public leaderboard. Other users can see the ranking. You can turn this off anytime in settings.',
            'ar': 'عند التفعيل، سيظهر عدد أذكارك (مع اسم المستخدم) في لوحة المتصدرين العامة. يمكنك إيقاف ذلك في أي وقت من الإعدادات.',
            'id': 'Saat diaktifkan, jumlah zikir Anda (dengan nama pengguna) akan muncul di papan peringkat umum. Anda dapat mematikan ini kapan saja di pengaturan.',
            'ur': 'جب فعال کریں گے تو آپ کے ذکر کی تعداد (صارف نام کے ساتھ) عوام لیڈر بورڈ پر دکھائی دے گی۔ آپ کسی بھی وقت ترتیبات سے بند کر سکتے ہیں۔',
            'fa': 'با فعال‌سازی، تعداد اذکار شما (همراه نام کاربری) در جدول امتیازات عمومی نمایش داده می‌شود. هر زمان از تنظیمات می‌توانید غیرفعال کنید.',
            'fr': 'Une fois activé, votre nombre de dhikrs (avec votre pseudo) sera visible sur le classement public. Vous pouvez le désactiver à tout moment dans les paramètres.',
            'zh': '开启后，您的赞念数（与用户名一起）将显示在公开排行榜上。您可随时在设置中关闭。',
            'ja': '有効にすると、ジクル数（ユーザー名付き）が公開リーダーボードに表示されます。設定でいつでもオフにできます。',
            'ru': 'При включении ваш счётчик зикров (с именем пользователя) будет отображаться в общей таблице лидеров. Вы можете отключить это в настройках в любой момент.',
            'de': 'Wenn aktiviert, erscheint Ihre Zikir-Anzahl (mit Benutzername) in der öffentlichen Bestenliste. Sie können dies jederzeit in den Einstellungen deaktivieren.',
          }),
          style: GoogleFonts.notoSans(color: widget.themeConfig.textColor.withValues(alpha: 0.9), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'İptal',
                'en': 'Cancel',
                'ar': 'إلغاء',
                'id': 'Batal',
                'ur': 'منسوخ',
                'fa': 'انصراف',
                'fr': 'Annuler',
                'zh': '取消',
                'ja': 'キャンセル',
                'ru': 'Отмена',
                'de': 'Abbrechen',
              }),
              style: TextStyle(color: widget.themeConfig.textColor.withValues(alpha: 0.8)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _isLeaderboardEnabled = true);
              _settingsService.saveShowInLeaderboard(true);
              _pushCurrentStatsToLeaderboard();
              _supabaseService
                  .setLeaderboardVisibility(widget.currentUserId, true)
                  .catchError((_) {});
            },
            child: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Paylaş',
                'en': 'Share',
                'ar': 'مشاركة',
                'id': 'Bagikan',
                'ur': 'شیئر کریں',
                'fa': 'اشتراک',
                'fr': 'Partager',
                'zh': '分享',
                'ja': '共有',
                'ru': 'Поделиться',
                'de': 'Teilen',
              }),
              style: TextStyle(color: widget.themeConfig.accentColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pushCurrentStatsToLeaderboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
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
    } catch (e) {
      debugPrint('Error pushing current stats to leaderboard: $e');
    }
  }

  void _showThankYouDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.themeConfig.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          DynamicLocalizationHelper.getText({
            'tr': 'Teşekkürler! 🙏',
            'en': 'Thank you! 🙏',
            'ar': 'شكراً! 🙏',
            'id': 'Terima kasih! 🙏',
            'ur': 'شکریہ! 🙏',
            'bn': 'ধন্যবাদ! 🙏',
            'ms': 'Terima kasih! 🙏',
            'fa': 'متشکریم! 🙏',
            'fr': 'Merci ! 🙏',
            'zh': '谢谢！🙏',
            'ja': 'ありがとうございます！🙏',
            'ru': 'Спасибо! 🙏',
            'de': 'Danke! 🙏',
            'sw': 'Asante! 🙏',
            'ha': 'Na gode! 🙏',
          }),
          style: GoogleFonts.notoSans(color: widget.themeConfig.textColor),
        ),
        content: Text(
          DynamicLocalizationHelper.getText({
            'tr': 'Reklamı izlediğiniz için teşekkür ederiz. Desteğiniz uygulamanın ücretsiz kalmasına yardımcı oluyor.',
            'en': 'Thank you for watching the ad. Your support helps keep the app free.',
            'ar': 'شكراً لمشاهدة الإعلان. دعمك يساعد في إبقاء التطبيق مجانياً.',
            'id': 'Terima kasih telah menonton iklan. Dukungan Anda membantu menjaga aplikasi tetap gratis.',
            'ur': 'اشتہار دیکھنے کا شکریہ۔ آپ کی حمایت ایپ کو مفت رکھنے میں مدد کرتی ہے۔',
            'bn': 'বিজ্ঞাপন দেখার জন্য ধন্যবাদ। আপনার সমর্থন অ্যাপটি বিনামূল্যে রাখতে সাহায্য করে।',
            'ms': 'Terima kasih kerana menonton iklan. Sokongan anda membantu mengekalkan aplikasi percuma.',
            'fa': 'از تماشای تبلیغ متشکریم. حمایت شما به رایگان ماندن برنامه کمک می‌کند.',
            'fr': 'Merci d\'avoir regardé la pub. Votre soutien permet de garder l\'app gratuite.',
            'zh': '感谢您观看广告。您的支持有助于保持应用免费。',
            'ja': '広告をご覧いただきありがとうございます。ご支援でアプリを無料で提供し続けられます。',
            'ru': 'Спасибо, что посмотрели рекламу. Ваша поддержка помогает сохранять приложение бесплатным.',
            'de': 'Danke fürs Ansehen der Anzeige. Ihre Unterstützung hilft, die App kostenlos zu halten.',
            'sw': 'Asante kwa kutazama tangazo. Msaada wako unasaidia kuweka programu bure.',
            'ha': 'Na gode da kallon talla. Goyon bayanku yana taimaka ajiye app kyauta.',
          }),
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor.withValues(alpha: 0.9),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Tamam',
                'en': 'OK',
                'ar': 'حسناً',
                'id': 'OK',
                'ur': 'ٹھیک ہے',
                'bn': 'ঠিক আছে',
                'ms': 'OK',
                'fa': 'باشه',
                'fr': 'OK',
                'zh': '确定',
                'ja': 'OK',
                'ru': 'ОК',
                'de': 'OK',
                'sw': 'Sawa',
                'ha': 'To',
              }),
              style: TextStyle(color: widget.themeConfig.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportUsSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.themeConfig.accentColor.withValues(alpha: 0.2),
            widget.themeConfig.accentColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.themeConfig.accentColor.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.volunteer_activism, color: widget.themeConfig.accentColor, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  DynamicLocalizationHelper.getText({
                    'tr': 'Bize Destek Ol',
                    'en': 'Support Us',
                    'ar': 'ادعمنا',
                    'id': 'Dukung Kami',
                    'ur': 'ہمیں سپورٹ کریں',
                    'bn': 'আমাদের সমর্থন করুন',
                    'ms': 'Sokong Kami',
                    'fa': 'از ما حمایت کنید',
                    'fr': 'Soutenez-nous',
                    'zh': '支持我们',
                    'ja': '私たちをサポート',
                    'ru': 'Поддержите нас',
                    'de': 'Unterstützen Sie uns',
                    'sw': 'Tusaidie',
                    'ha': 'Tallafa Mu',
                  }),
                  style: GoogleFonts.notoSans(
                    color: widget.themeConfig.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Kısa bir reklam izleyerek uygulamanın ücretsiz kalmasına katkıda bulunun.',
              'en': 'Watch a short ad to help keep the app free.',
              'ar': 'شاهد إعلاناً قصيراً للمساعدة في إبقاء التطبيق مجانياً.',
              'id': 'Tonton iklan singkat untuk membantu menjaga aplikasi tetap gratis.',
              'ur': 'ایپ کو مفت رکھنے میں مدد کے لیے ایک مختصر اشتہار دیکھیں۔',
              'bn': 'অ্যাপটি বিনামূল্যে রাখতে একটি সংক্ষিপ্ত বিজ্ঞাপন দেখুন।',
              'ms': 'Tonton iklan pendek untuk mengekalkan aplikasi percuma.',
              'fa': 'یک تبلیغ کوتاه تماشا کنید تا برنامه رایگان بماند.',
              'fr': 'Regardez une courte pub pour garder l\'app gratuite.',
              'zh': '观看短视频广告，帮助保持应用免费。',
              'ja': '短い広告を見てアプリを無料で維持しましょう。',
              'ru': 'Посмотрите короткую рекламу, чтобы приложение оставалось бесплатным.',
              'de': 'Sehen Sie eine kurze Anzeige, um die App kostenlos zu halten.',
              'sw': 'Tazama tangazo fupi kuweka programu bure.',
              'ha': 'Kalli talla gajere don taimaka ajiye app kyauta.',
            }),
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isAdLoading ? null : _watchSupportAd,
              icon: _isAdLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: widget.themeConfig.primaryColor,
                      ),
                    )
                  : Icon(Icons.play_circle_filled, color: widget.themeConfig.primaryColor, size: 22),
              label: Text(
                _isAdLoading
                    ? DynamicLocalizationHelper.getText({
                        'tr': 'Yükleniyor...',
                        'en': 'Loading...',
                        'ar': 'جاري التحميل...',
                        'id': 'Memuat...',
                        'ur': 'لوڈ ہو رہا ہے...',
                        'bn': 'লোড হচ্ছে...',
                        'ms': 'Memuat...',
                        'fa': 'در حال بارگذاری...',
                        'fr': 'Chargement...',
                        'zh': '加载中...',
                        'ja': '読み込み中...',
                        'ru': 'Загрузка...',
                        'de': 'Laden...',
                        'sw': 'Inapakia...',
                        'ha': 'Ana ɗauka...',
                      })
                    : DynamicLocalizationHelper.getText({
                        'tr': 'Reklam İzle',
                        'en': 'Watch Ad',
                        'ar': 'شاهد الإعلان',
                        'id': 'Tonton Iklan',
                        'ur': 'اشتہار دیکھیں',
                        'bn': 'বিজ্ঞাপন দেখুন',
                        'ms': 'Tonton Iklan',
                        'fa': 'تماشای تبلیغ',
                        'fr': 'Regarder la pub',
                        'zh': '观看广告',
                        'ja': '広告を見る',
                        'ru': 'Смотреть рекламу',
                        'de': 'Anzeige ansehen',
                        'sw': 'Tazama tangazo',
                        'ha': 'Kalli Talla',
                      }),
                style: GoogleFonts.notoSans(
                  color: widget.themeConfig.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeConfig.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Daha Fazla',
              'en': 'More',
              'ar': 'المزيد',
              'id': 'Lebih Lanjut',
              'ur': 'مزید',
              'bn': 'আরও',
              'ms': 'Lagi',
              'fa': 'بیشتر',
              'fr': 'Plus',
              'zh': '更多',
              'ja': 'もっと見る',
              'ru': 'Ещё',
              'de': 'Mehr',
              'sw': 'Zaidi',
              'ha': 'Sabo',
            }),
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildMoreTile(
            DynamicLocalizationHelper.getText({
              'tr': 'Hakkında',
              'en': 'About',
              'ar': 'حول',
              'id': 'Tentang',
              'ur': 'کے بارے میں',
              'bn': 'সম্পর্কে',
              'ms': 'Mengenai',
              'fa': 'درباره',
              'fr': 'À propos',
              'zh': '关于',
              'ja': 'について',
              'ru': 'О приложении',
              'de': 'Über',
              'sw': 'Kuhusu',
              'ha': 'Game da',
            }),
            Icons.info_outline,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AboutScreenNew(
                  themeConfig: _currentTheme,
                  localizations: widget.localizations,
                  appVersion: '1.0.0',
                ),
              ),
            ),
          ),
          _buildMoreTile(
            DynamicLocalizationHelper.getText({
              'tr': 'Bize Ulaşın',
              'en': 'Contact Us',
              'ar': 'تواصل معنا',
              'id': 'Hubungi Kami',
              'ur': 'ہم سے رابطہ کریں',
              'bn': 'আমাদের সাথে যোগাযোগ করুন',
              'ms': 'Hubungi Kami',
              'fa': 'با ما تماس بگیرید',
              'fr': 'Nous contacter',
              'zh': '联系我们',
              'ja': 'お問い合わせ',
              'ru': 'Связаться с нами',
              'de': 'Kontakt',
              'sw': 'Wasiliana Nasi',
              'ha': 'Tuntube Mu',
            }),
            Icons.contact_support,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SupportScreenNew(
                  themeConfig: widget.themeConfig,
                  localizations: widget.localizations,
                ),
              ),
            ),
          ),
          _buildMoreTile(
            DynamicLocalizationHelper.getText({
              'tr': 'İçe/Dışa Aktar',
              'en': 'Import/Export',
              'ar': 'استيراد/تصدير',
              'id': 'Impor/Ekspor',
              'ur': 'درآمد/برآمد',
              'bn': 'আমদানি/রপ্তানি',
              'ms': 'Import/Eksport',
              'fa': 'وارد/صادر',
              'fr': 'Importer/Exporter',
              'zh': '导入/导出',
              'ja': 'インポート/エクスポート',
              'ru': 'Импорт/Экспорт',
              'de': 'Importieren/Exportieren',
              'sw': 'Uagizaji/Utoaji',
              'ha': 'Fito/Fito',
            }),
            Icons.import_export,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImportExportScreen(
                  themeConfig: widget.themeConfig,
                  localizations: widget.localizations,
                  currentUserId: widget.currentUserId,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreTile(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: widget.themeConfig.accentColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.notoSans(
                  color: widget.themeConfig.textColor,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: widget.themeConfig.textColor.withValues(alpha: 0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}  
