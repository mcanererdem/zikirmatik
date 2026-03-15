import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dialog_manager.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';
import '../services/ad_service.dart';
import '../screens/support_screen_new.dart';
import '../screens/about_screen_new.dart';
import '../screens/import_export_screen.dart';
import '../screens/home_page.dart' as home;

class SettingsDialogNew extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String currentUserId;

  const SettingsDialogNew({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.currentUserId,
  });

  @override
  State<SettingsDialogNew> createState() => _SettingsDialogNewState();
}

class _SettingsDialogNewState extends State<SettingsDialogNew> {
  final SettingsService _settingsService = SettingsService();
  ThemeConfig _currentTheme = AppThemes.getTheme('dark_blue');
  String _currentLanguage = 'tr';
  bool _isVibrationOn = true;
  bool _isSoundOn = true;
  bool _isConfettiOn = true;
  bool _isReminderEnabled = false;
  bool _isTtsOn = false;
  String _appVersion = '1.0.0';
  
  // Yeni özellikler
  // bool _isAutoBackupEnabled = false;
  bool _isDarkModeOnly = false;
  double _textSize = 16.0;
  int _animationSpeed = 1; // 0: yavaş, 1: normal, 2: hızlı

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppVersion();
  }

  Future<void> _loadSettings() async {
    final themeId = await _settingsService.getTheme();
    final languageCode = await _settingsService.getLanguage();
    final vibration = await _settingsService.getVibration();
    final sound = await _settingsService.getSound();
    final confetti = await _settingsService.getConfetti();
    final reminderEnabled = await _settingsService.getReminderEnabled();
    final ttsEnabled = await _settingsService.getTtsEnabled();
    
    // Yeni ayarları yükle
    final prefs = await SharedPreferences.getInstance();
    // final autoBackup = prefs.getBool('auto_backup_enabled') ?? false;
    final darkModeOnly = prefs.getBool('dark_mode_only') ?? false;
    final textSize = prefs.getDouble('text_size') ?? 16.0;
    final animationSpeed = prefs.getInt('animation_speed') ?? 1;
    
    setState(() {
      _currentTheme = AppThemes.getTheme(themeId);
      _currentLanguage = languageCode;
      _isVibrationOn = vibration;
      _isSoundOn = sound;
      _isConfettiOn = confetti;
      _isReminderEnabled = reminderEnabled;
      _isTtsOn = ttsEnabled;
      // _isAutoBackupEnabled = autoBackup;
      _isDarkModeOnly = darkModeOnly;
      _textSize = textSize;
      _animationSpeed = animationSpeed;
    });
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      setState(() {
        _appVersion = '1.0.0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          gradient: widget.themeConfig.backgroundGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.themeConfig.accentColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.themeConfig.accentColor.withOpacity(0.3),
                    widget.themeConfig.accentColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Ayarlar',
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Settings List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tema Seçimi
          _buildSectionHeader('Tema', Icons.palette),
          _buildThemeSelection(),
          const SizedBox(height: 20),
          
          // Dil Seçimi
          _buildSectionHeader('Dil', Icons.language),
          _buildLanguageSelection(),
          const SizedBox(height: 20),
          
          // Temel Ayarlar
          _buildSectionHeader('Temel Ayarlar', Icons.settings),
          _buildBasicSettings(),
          const SizedBox(height: 20),
          
          // Gelişmiş Ayarlar
          _buildSectionHeader('Gelişmiş Ayarlar', Icons.tune),
          _buildAdvancedSettings(),
          const SizedBox(height: 20),
          
          // Navigasyon Ayarları
          _buildSectionHeader('Diğer', Icons.more_horiz),
          _buildNavigationSettings(),
          const SizedBox(height: 20),
          
          // Versiyon Bilgisi
          _buildVersionInfo(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(
            icon,
            color: widget.themeConfig.accentColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildThemeOption('blue_gold', _getThemeName('blue_gold')),
          _buildThemeOption('green_gold', _getThemeName('green_gold')),
          _buildThemeOption('purple_gold', _getThemeName('purple_gold')),
          _buildThemeOption('dark_night', _getThemeName('dark_night')),
          _buildThemeOption('moonlight', _getThemeName('moonlight')),
          _buildThemeOption('deep_space', _getThemeName('deep_space')),
          _buildThemeOption('northern_lights', _getThemeName('northern_lights')),
          _buildThemeOption('dark_blue', _getThemeName('dark_blue')),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String themeId, String themeName) {
    final isSelected = _currentTheme.id == themeId;
    return GestureDetector(
      onTap: () => _changeTheme(themeId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    widget.themeConfig.accentColor,
                    widget.themeConfig.accentColor.withOpacity(0.7),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? widget.themeConfig.accentColor
                : Colors.white.withOpacity(0.3),
          ),
        ),
        child: Text(
          themeName,
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: DropdownButton<String>(
        value: _currentLanguage,
        dropdownColor: widget.themeConfig.primaryColor,
        style: GoogleFonts.notoSans(color: Colors.white),
        items: const [
          DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
          DropdownMenuItem(value: 'en', child: Text('English')),
          DropdownMenuItem(value: 'ar', child: Text('العربية')),
          DropdownMenuItem(value: 'id', child: Text('Bahasa Indonesia')),
          DropdownMenuItem(value: 'ur', child: Text('اردو')),
          DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
          DropdownMenuItem(value: 'ms', child: Text('Bahasa Melayu')),
          DropdownMenuItem(value: 'fa', child: Text('فارسی')),
          DropdownMenuItem(value: 'fr', child: Text('Français')),
          DropdownMenuItem(value: 'zh', child: Text('中文')),
          DropdownMenuItem(value: 'ja', child: Text('日本語')),
          DropdownMenuItem(value: 'ru', child: Text('Русский')),
          DropdownMenuItem(value: 'de', child: Text('Deutsch')),
          DropdownMenuItem(value: 'sw', child: Text('Kiswahili')),
          DropdownMenuItem(value: 'ha', child: Text('Hausa')),
        ],
        onChanged: (value) {
          if (value != null) _changeLanguage(value);
        },
      ),
    );
  }

  Widget _buildBasicSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildToggleSetting(
            'Titreşim',
            _isVibrationOn,
            Icons.vibration,
            _toggleVibration,
          ),
          _buildToggleSetting(
            'Ses',
            _isSoundOn,
            Icons.volume_up,
            _toggleSound,
          ),
          _buildToggleSetting(
            'Konfeti Animasyonu',
            _isConfettiOn,
            Icons.celebration,
            _toggleConfetti,
          ),
          _buildToggleSetting(
            'TTS (Metin Okuma)',
            _isTtsOn,
            Icons.record_voice_over,
            _toggleTts,
          ),
          _buildToggleSetting(
            'Hatırlatıcılar',
            _isReminderEnabled,
            Icons.notifications,
            _toggleReminder,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildToggleSetting(
            'Sadece karanlık tema',
            _isDarkModeOnly,
            Icons.dark_mode,
            _toggleDarkModeOnly,
          ),
          _buildSliderSetting(
            'Metin Boyutu',
            _textSize,
            Icons.text_fields,
            _changeTextSize,
            12.0,
            24.0,
          ),
          _buildAnimationSpeedSetting(),
        ],
      ),
    );
  }

  Widget _buildNavigationSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildNavigationSetting(
            'İçe/Dışa Aktar',
            'Verilerinizi yedekleyin veya geri yükleyin',
            Icons.import_export,
            _navigateToImportExport,
          ),
          _buildNavigationSetting(
            'Bize Destek Olun',
            'Uygulamayı desteklemek için',
            Icons.favorite,
            _navigateToSupport,
          ),
          _buildNavigationSetting(
            'Hakkımızda',
            'Uygulama bilgileri ve lisans',
            Icons.info,
            _navigateToAbout,
          ),
          _buildNavigationSetting(
            'Reklam İzleme',
            'Reklam izleyerek destek olun',
            Icons.ads_click,
            _showAdSupportDialog,
          ),
          _buildNavigationSetting(
            'Puan Verin',
            'Uygulamayı puanlayın',
            Icons.star,
            _rateApp,
          ),
          _buildNavigationSetting(
            'Geri Bildirim',
            'Görüşlerinizi paylaşın',
            Icons.feedback,
            _sendFeedback,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(String title, bool value, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: widget.themeConfig.accentColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (value) => onTap(),
            activeColor: widget.themeConfig.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(String title, double value, IconData icon, Function(double) onChanged, double min, double max) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${value.toInt()}',
                style: GoogleFonts.notoSans(
                  color: widget.themeConfig.accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / 2).round(),
            activeColor: widget.themeConfig.accentColor,
            inactiveColor: Colors.white.withOpacity(0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationSpeedSetting() {
    final speeds = ['Yavaş', 'Normal', 'Hızlı'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed,
                color: widget.themeConfig.accentColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Animasyon Hızı',
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              final isSelected = _animationSpeed == index;
              return Flexible(
                child: GestureDetector(
                  onTap: () => _changeAnimationSpeed(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? widget.themeConfig.accentColor : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      speeds[index],
                      style: GoogleFonts.notoSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSetting(String title, String description, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(
              icon,
              color: widget.themeConfig.accentColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.notoSans(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info,
            color: widget.themeConfig.accentColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Versiyon $_appVersion',
            style: GoogleFonts.notoSans(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeName(String themeId) {
    final themeConfig = AppThemes.getTheme(themeId);
    switch (_currentLanguage) {
      case 'tr':
        return themeConfig.nameTr;
      case 'en':
        return themeConfig.nameEn;
      case 'ar':
        return themeConfig.nameAr;
      case 'id':
        return themeConfig.nameId;
      default:
        return themeConfig.nameTr;
    }
  }

  void _changeTheme(String themeId) async {
    setState(() {
      _currentTheme = AppThemes.getTheme(themeId);
    });
    await _settingsService.saveTheme(themeId);
  }

  void _changeLanguage(String language) async {
    setState(() {
      _currentLanguage = language;
    });
    await _settingsService.saveLanguage(language);
  }

  void _toggleVibration() async {
    setState(() => _isVibrationOn = !_isVibrationOn);
    await _settingsService.saveVibration(_isVibrationOn);
  }

  void _toggleSound() async {
    setState(() => _isSoundOn = !_isSoundOn);
    await _settingsService.saveSound(_isSoundOn);
  }

  void _toggleConfetti() async {
    setState(() => _isConfettiOn = !_isConfettiOn);
    await _settingsService.saveConfetti(_isConfettiOn);
  }

  void _toggleReminder() async {
    setState(() => _isReminderEnabled = !_isReminderEnabled);
    await _settingsService.saveReminderEnabled(_isReminderEnabled);
  }

  void _toggleTts() async {
    setState(() => _isTtsOn = !_isTtsOn);
    await _settingsService.saveTtsEnabled(_isTtsOn);
  }

  void _toggleDarkModeOnly() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDarkModeOnly = !_isDarkModeOnly);
    await prefs.setBool('dark_mode_only', _isDarkModeOnly);
  }

  void _changeTextSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _textSize = size);
    await prefs.setDouble('text_size', size);
  }

  void _changeAnimationSpeed(int speed) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _animationSpeed = speed);
    await prefs.setInt('animation_speed', speed);
  }

  void _navigateToImportExport() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImportExportScreen(
          themeConfig: widget.themeConfig,
          localizations: widget.localizations,
          currentUserId: widget.currentUserId,
        ),
      ),
    );
  }

  void _navigateToSupport() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupportScreenNew(
          themeConfig: widget.themeConfig,
          localizations: widget.localizations,
        ),
      ),
    );
  }

  void _navigateToAbout() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AboutScreenNew(
          themeConfig: widget.themeConfig,
          localizations: widget.localizations,
          appVersion: _appVersion,
        ),
      ),
    );
  }

  void _showAdSupportDialog() {
    if (!DialogManager.canShowDialog()) return;
    
    DialogManager.onDialogOpened();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.themeConfig.primaryColor,
        title: Text(
          'Reklam İzleme',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Reklam izleyerek uygulamayı destekleyebilirsiniz. Bu sayede geliştirme ve sunucu maliyetlerini karşılayabiliriz.',
          style: GoogleFonts.notoSans(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              DialogManager.onDialogClosed();
            },
            child: Text(
              'İptal',
              style: GoogleFonts.notoSans(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              DialogManager.onDialogClosed();
              // Reklam gösterme mantığı buraya eklenebilir
            },
            child: Text(
              'Reklam İzle',
              style: GoogleFonts.notoSans(color: widget.themeConfig.accentColor),
            ),
          ),
        ],
      ),
    ).then((_) => DialogManager.onDialogClosed());
  }

  void _rateApp() async {
    final url = 'https://play.google.com/store/apps/details?id=com.mcanererdem.zikirmatik';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _sendFeedback() async {
    final email = Uri.encodeComponent('mcanererdem@gmail.com');
    final subject = Uri.encodeComponent('Zikirmatik Geri Bildirim');
    final body = Uri.encodeComponent('Merhaba,\n\nUygulama hakkında geri bildirim:\n\n');
    final url = 'mailto:$email?subject=$subject&body=$body';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
