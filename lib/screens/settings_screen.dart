import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';
import '../services/settings_service.dart';
import '../widgets/dialog_manager.dart';
import 'home_page.dart' as home;

class SettingsScreen extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String currentUserId;
  final Function()? onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.currentUserId,
    this.onSettingsChanged,
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
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Tema & Dil
                    _buildModernSection(
                      title: _getThemeLanguageSectionTitle(),
                      icon: Icons.palette,
                      children: [
                        _buildModernNavigationSetting(
                          title: _getThemeSettingTitle(),
                          subtitle: _getThemeSettingSubtitle(),
                          icon: Icons.palette,
                          onTap: _showThemeSelector,
                        ),
                        _buildModernNavigationSetting(
                          title: _getLanguageSettingTitle(),
                          subtitle: _getLanguageSettingSubtitle(),
                          icon: Icons.language,
                          onTap: _showLanguageSelector,
                        ),
                      ],
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

  Widget _buildModernSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.textColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: widget.themeConfig.accentColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    color: widget.themeConfig.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernNavigationSetting({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: widget.themeConfig.accentColor,
      ),
      title: Text(
        title,
        style: GoogleFonts.notoSans(
          color: widget.themeConfig.textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.notoSans(
          color: widget.themeConfig.textColor.withOpacity(0.7),
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: widget.themeConfig.textColor.withOpacity(0.5),
        size: 16,
      ),
      onTap: onTap,
    );
  }

  // Dil metodları
  String _getThemeLanguageSectionTitle() {
    return DynamicLocalizationHelper.getText({
      'tr': 'Tema & Dil',
      'en': 'Theme & Language',
      'ar': 'السمة واللغة',
      'id': 'Tema & Bahasa',
    });
  }

  String _getThemeSettingTitle() {
    return DynamicLocalizationHelper.theme;
  }

  String _getThemeSettingSubtitle() {
    return DynamicLocalizationHelper.getText({
      'tr': 'Uygulama temasını değiştir',
      'en': 'Change app theme',
      'ar': 'تغيير سمة التطبيق',
      'id': 'Ubah tema aplikasi',
    });
  }

  String _getLanguageSettingTitle() {
    return DynamicLocalizationHelper.language;
  }

  String _getLanguageSettingSubtitle() {
    return DynamicLocalizationHelper.getText({
      'tr': 'Uygulama dilini değiştir',
      'en': 'Change app language',
      'ar': 'تغيير لغة التطبيق',
      'id': 'Ubah bahasa aplikasi',
    });
  }

  String _getThemeDialogTitle() {
    return DynamicLocalizationHelper.getText({
      'tr': 'Tema Seç',
      'en': 'Select Theme',
      'ar': 'اختر السمة',
      'id': 'Pilih Tema',
    });
  }

  String _getLanguageDialogTitle() {
    return DynamicLocalizationHelper.getText({
      'tr': 'Dil Seç',
      'en': 'Select Language',
      'ar': 'اختر اللغة',
      'id': 'Pilih Bahasa',
    });
  }

  String _getCancelButton() {
    return DynamicLocalizationHelper.cancel;
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
      default:
        return theme.nameTr;
    }
  }

  void _showThemeSelector() {
    if (!DialogManager.canShowDialog()) return;
    
    DialogManager.onDialogOpened();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        title: Text(
          _getThemeDialogTitle(), 
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          decoration: BoxDecoration(
            color: widget.themeConfig.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AppThemes.themes.map((theme) {
                final isSelected = _currentTheme.id == theme.id;
                return ListTile(
                  title: Text(
                    _getThemeName(theme),
                    style: GoogleFonts.notoSans(
                      color: widget.themeConfig.textColor,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: widget.themeConfig.accentColor)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    DialogManager.onDialogClosed();
                    _changeTheme(theme.id);
                  },
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              DialogManager.onDialogClosed();
            },
            child: Text(
              _getCancelButton(),
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.accentColor,
              ),
            ),
          ),
        ],
      ),
    ).then((_) => DialogManager.onDialogClosed());
  }

  void _showLanguageSelector() {
    if (!DialogManager.canShowDialog()) return;
    
    DialogManager.onDialogOpened();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        title: Text(
          _getLanguageDialogTitle(), 
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          decoration: BoxDecoration(
            color: widget.themeConfig.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                {'code': 'tr', 'name': 'Türkçe'},
                {'code': 'en', 'name': 'English'},
                {'code': 'ar', 'name': 'العربية'},
                {'code': 'id', 'name': 'Bahasa Indonesia'},
                {'code': 'ur', 'name': 'اردو'},
                {'code': 'bn', 'name': 'বাংলা'},
                {'code': 'ms', 'name': 'Bahasa Melayu'},
                {'code': 'fa', 'name': 'فارسی'},
                {'code': 'fr', 'name': 'Français'},
                {'code': 'zh', 'name': '中文'},
                {'code': 'ja', 'name': '日本語'},
                {'code': 'ru', 'name': 'Русский'},
                {'code': 'de', 'name': 'Deutsch'},
                {'code': 'sw', 'name': 'Swahili'},
                {'code': 'ha', 'name': 'Hausa'},
              ].map((lang) {
                final isSelected = _currentLanguage == lang['code'];
                return ListTile(
                  title: Text(
                    lang['name']!,
                    style: GoogleFonts.notoSans(
                      color: widget.themeConfig.textColor,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: widget.themeConfig.accentColor)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    DialogManager.onDialogClosed();
                    _changeLanguage(lang['code']!);
                  },
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              DialogManager.onDialogClosed();
            },
            child: Text(
              _getCancelButton(),
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.accentColor,
              ),
            ),
          ),
        ],
      ),
    ).then((_) => DialogManager.onDialogClosed());
  }

  void _changeTheme(String themeId) async {
    setState(() {
      _currentTheme = AppThemes.getTheme(themeId);
    });
    await _settingsService.saveTheme(themeId);
    
    // Ana sayfaya geri dön ve uygulamayı yenile
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

  void _changeLanguage(String language) async {
    print('🔄 _changeLanguage started with: $language');
    
    setState(() {
      _currentLanguage = language;
    });
    
    await _settingsService.saveLanguage(language);
    print('🔄 Language saved to settings: $language');
    
    // Dynamic localization helper'ı güncelle
    await DynamicLocalizationHelper.setLanguage(language);
    
    // Ana sayfaya geri dön ve uygulamayı tamamen yenile
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
    
    print('🔄 Navigation completed - app should restart with new language');
  }
}
