import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';
import '../services/settings_service.dart';
import '../screens/home_page.dart' as home;
import '../screens/about_screen.dart';
import '../screens/support_screen_new.dart';
import '../screens/import_export_screen.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String currentUserId;
  final Function()? onSettingsChanged;
  final Function(String)? onLanguageChanged;

  const SettingsScreen({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.currentUserId,
    this.onSettingsChanged,
    this.onLanguageChanged,
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
  bool _isLeaderboardEnabled = true;
  String _currentLanguage = 'tr';
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.themeConfig;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final vibration = await _settingsService.getVibration();
    final sound = await _settingsService.getSound();
    final confetti = await _settingsService.getConfetti();
    final ttsEnabled = await _settingsService.getTtsEnabled();
    final reminderEnabled = await _settingsService.getReminderEnabled();
    final currentLanguage = await _settingsService.getLanguage();
    final darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;

    // Dynamic localization helper'ı güncelle
    await DynamicLocalizationHelper.setLanguage(currentLanguage);

    setState(() {
      _isVibrationOn = vibration;
      _isSoundOn = sound;
      _isConfettiOn = confetti;
      _isTtsOn = ttsEnabled;
      _isReminderEnabled = reminderEnabled;
      _isLeaderboardEnabled = true;
      _currentLanguage = currentLanguage;
      _isDarkMode = darkModeEnabled;
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
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildThemeSection(),
                    _buildLanguageSection(),
                    _buildNotificationSection(),
                    _buildSoundSection(),
                    _buildAdvancedSection(),
                    _buildMoreSection(),
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
            widget.localizations.settings,
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

  Widget _buildThemeSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withOpacity(0.1),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildThemeOption('dark_blue', DynamicLocalizationHelper.getText({
                'tr': 'Koyu Mavi',
                'en': 'Dark Blue',
                'ar': 'أزرق داكن',
                'id': 'Biru Tua',
                'ur': 'گہرا نیلا',
                'bn': 'গাঢ নীল',
                'ms': 'Biru Tua',
                'fa': 'آبی تیره',
                'fr': 'Bleu Foncé',
                'zh': '深蓝色',
                'ja': 'ダークブルー',
                'ru': 'Темно-синий',
                'de': 'Dunkelblau',
                'sw': 'Buluu Giza',
                'ha': 'Biri Mai Gwaza',
              })),
              _buildThemeOption('dark_green', DynamicLocalizationHelper.getText({
                'tr': 'Koyu Yeşil',
                'en': 'Dark Green',
                'ar': 'أخضر داكن',
                'id': 'Hijau Tua',
                'ur': 'گہرا ہرا',
                'bn': 'গাঢ সবুজ',
                'ms': 'Hijau Tua',
                'fa': 'سبز تیره',
                'fr': 'Vert Foncé',
                'zh': '深绿色',
                'ja': 'ダークグリーン',
                'ru': 'Темно-зеленый',
                'de': 'Dunkelgrün',
                'sw': 'Kijani Giza',
                'ha': 'Green Mai Gwaza',
              })),
              _buildThemeOption('dark_purple', DynamicLocalizationHelper.getText({
                'tr': 'Koyu Mor',
                'en': 'Dark Purple',
                'ar': 'بنفسجي داكن',
                'id': 'Ungu Tua',
                'ur': 'گہرا جامنی',
                'bn': 'গাঢ বেগুনি',
                'ms': 'Ungu Tua',
                'fa': 'بنفش تیره',
                'fr': 'Violet Foncé',
                'zh': '深紫色',
                'ja': 'ダークパープル',
                'ru': 'Темно-фиолетовый',
                'de': 'Dunkellila',
                'sw': 'Uduha Giza',
                'ha': 'Zinari Mai Gwaza',
              })),
              _buildThemeOption('light_blue', DynamicLocalizationHelper.getText({
                'tr': 'Açık Mavi',
                'en': 'Light Blue',
                'ar': 'أزرق فاتح',
                'id': 'Biru Muda',
                'ur': 'ہلکا نیلا',
                'bn': 'হালকা নীল',
                'ms': 'Biru Muda',
                'fa': 'آبی روشن',
                'fr': 'Bleu Clair',
                'zh': '浅蓝色',
                'ja': 'ライトブルー',
                'ru': 'Светло-синий',
                'de': 'Hellblau',
                'sw': 'Buluu Nyeupe',
                'ha': 'Biri Mai Fice',
              })),
              _buildThemeOption('light_green', DynamicLocalizationHelper.getText({
                'tr': 'Açık Yeşil',
                'en': 'Light Green',
                'ar': 'أخضر فاتح',
                'id': 'Hijau Muda',
                'ur': 'ہلکا ہرا',
                'bn': 'হালকা সবুজ',
                'ms': 'Hijau Muda',
                'fa': 'سبز روشن',
                'fr': 'Vert Clair',
                'zh': '浅绿色',
                'ja': 'ライトグリーン',
                'ru': 'Светло-зеленый',
                'de': 'Hellgrün',
                'sw': 'Kijani Nyeupe',
                'ha': 'Green Mai Fice',
              })),
              _buildThemeOption('light_purple', DynamicLocalizationHelper.getText({
                'tr': 'Açık Mor',
                'en': 'Light Purple',
                'ar': 'بنفسجي فاتح',
                'id': 'Ungu Muda',
                'ur': 'ہلکا جامنی',
                'bn': 'হালকা বেগুনি',
                'ms': 'Ungu Muda',
                'fa': 'بنفش روشن',
                'fr': 'Violet Clair',
                'zh': '浅紫色',
                'ja': 'ライトパープル',
                'ru': 'Светло-фиолетовый',
                'de': 'Helllila',
                'sw': 'Uduha Nyeupe',
                'ha': 'Zinari Mai Fice',
              })),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withOpacity(0.1),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildLanguageOption('tr', '🇹🇷 Türkçe'),
              _buildLanguageOption('en', '🇬🇧 English'),
              _buildLanguageOption('ar', '🇸🇦 العربية'),
              _buildLanguageOption('id', '🇮🇩 Bahasa Indonesia'),
              _buildLanguageOption('ur', '🇵🇰 اردو'),
              _buildLanguageOption('bn', '🇧🇩 বাংলা'),
              _buildLanguageOption('ms', '🇲🇾 Bahasa Melayu'),
              _buildLanguageOption('fa', '🇮🇷 فارسی'),
              _buildLanguageOption('fr', '🇫🇷 Français'),
              _buildLanguageOption('zh', '🇨🇳 中文'),
              _buildLanguageOption('ja', '🇯🇵 日本語'),
              _buildLanguageOption('ru', '🇷🇺 Русский'),
              _buildLanguageOption('de', '🇩🇪 Deutsch'),
              _buildLanguageOption('sw', '🇰🇪 Swahili'),
              _buildLanguageOption('ha', '🇳🇬 Hausa'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String themeId, String name) {
    final isSelected = _currentTheme.id == themeId;
    return GestureDetector(
      onTap: () => _changeTheme(themeId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? widget.themeConfig.accentColor : widget.themeConfig.textColor.withOpacity(0.2),
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

  Widget _buildLanguageOption(String code, String name) {
    final isSelected = _currentLanguage == code;
    return GestureDetector(
      onTap: () => _changeLanguage(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? widget.themeConfig.accentColor : widget.themeConfig.textColor.withOpacity(0.2),
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
        color: widget.themeConfig.textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.localizations.notifications,
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(
              widget.localizations.reminders,
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor,
              ),
            ),
            subtitle: Text(
              widget.localizations.dhikrReminders,
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            value: _isReminderEnabled,
            onChanged: (value) {
              setState(() {
                _isReminderEnabled = value;
              });
              _settingsService.saveReminderEnabled(value);
            },
            activeColor: widget.themeConfig.accentColor,
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
        color: widget.themeConfig.textColor.withOpacity(0.1),
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
                color: widget.themeConfig.textColor.withOpacity(0.7),
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
            activeColor: widget.themeConfig.accentColor,
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
                color: widget.themeConfig.textColor.withOpacity(0.7),
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
            activeColor: widget.themeConfig.accentColor,
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
                color: widget.themeConfig.textColor.withOpacity(0.7),
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
            activeColor: widget.themeConfig.accentColor,
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
        color: widget.themeConfig.textColor.withOpacity(0.1),
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
                color: widget.themeConfig.textColor.withOpacity(0.7),
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
            activeColor: widget.themeConfig.accentColor,
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
                color: widget.themeConfig.textColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            value: _isLeaderboardEnabled,
            onChanged: (value) {
              setState(() {
                _isLeaderboardEnabled = value;
              });
              // _settingsService.saveLeaderboardEnabled(value);
            },
            activeColor: widget.themeConfig.accentColor,
          ),
        ],
      ),
    );
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
    
    // Ana sayfaya geri dön ve uygulamayı yenile
    if (mounted) {
      // Kısa bir bekleme ekle - flash'ı azaltmak için
      await Future.delayed(const Duration(milliseconds: 100));
      
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => home.HomePage(
            onThemeModeChanged: (themeMode) {
              // Tema değişikliği burada işlenebilir
            },
          ),
        ),
      );
    }
  }

  void _changeLanguage(String language) async {
    try {
      print('🔄 _changeLanguage started with: $language');
      print('🔄 Current _currentLanguage before change: $_currentLanguage');
      
      // Önce SharedPreferences'e kaydet
      await _settingsService.saveLanguage(language);
      
      // Dynamic localization helper'ı güncelle
      await DynamicLocalizationHelper.setLanguage(language);
      
      setState(() {
        _currentLanguage = language;
      });

      // Üst widget (MyApp) dil güncellemesini alsın ki MaterialApp locale değişsin
      widget.onLanguageChanged?.call(language);

      print('🌐 Language changed to: $language');

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
                print('🔄 HomePage language callback received: $language');
              },
            ),
          ),
        );
      }
      
      print('🔄 Navigation completed - app should restart with new language');
    } catch (e) {
      print('❌ Error during language change: $e');
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
          ),
        );
      }
    }
  }

  Widget _buildMoreSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withOpacity(0.1),
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
                builder: (context) => AboutScreen(
                  themeConfig: widget.themeConfig,
                  localizations: widget.localizations,
                ),
              ),
            ),
          ),
          _buildMoreTile(
            DynamicLocalizationHelper.getText({
              'tr': 'Destek Ol',
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
            Icons.favorite_outline,
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
              color: widget.themeConfig.textColor.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}  
