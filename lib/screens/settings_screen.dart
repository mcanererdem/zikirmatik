import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';
import '../screens/support_screen_new.dart';
import '../screens/about_screen_new.dart';
import '../screens/import_export_screen.dart';
import 'home_page.dart' as home;

class SettingsScreen extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String currentUserId;

  const SettingsScreen({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.currentUserId,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final NotificationService _notificationService = NotificationService();
  ThemeConfig _currentTheme = AppThemes.getTheme('dark_blue');
  String _currentLanguage = 'tr';
  bool _isVibrationOn = true;
  bool _isSoundOn = true;
  bool _isConfettiOn = true;
  bool _isReminderEnabled = false;
  bool _isTtsOn = false;
  String _appVersion = '1.0.0';
  
  // Yeni özellikler
  bool _isAutoBackupEnabled = false;
  int _animationSpeed = 0; // 0: kapalı, 1: yavaş, 2: normal, 3: hızlı
  
  // Bildirim zamanlama
  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);
  List<bool> _selectedDays = [true, true, true, true, true, true, true]; // Pzt-Pzr
  
  // Reward reklam
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppVersion();
    _loadRewardedAd();
  }

  Future<void> _loadSettings() async {
    final themeId = await _settingsService.getTheme();
    final languageCode = await _settingsService.getLanguage();
    final vibration = await _settingsService.getVibration();
    final sound = await _settingsService.getSound();
    final confetti = await _settingsService.getConfetti();
    final reminderEnabled = await _settingsService.getReminderEnabled();
    final ttsEnabled = await _settingsService.getTtsEnabled();
    
    // Yeni özellikleri SharedPreferences'ten yükle
    final prefs = await SharedPreferences.getInstance();
    final autoBackup = prefs.getBool('auto_backup_enabled') ?? false;
    final animationSpeed = prefs.getInt('animation_speed') ?? 0;
    
    // Bildirim zamanını yükle
    final reminderHour = prefs.getInt('reminder_hour') ?? 21;
    final reminderMinute = prefs.getInt('reminder_minute') ?? 0;
    final selectedDays = prefs.getStringList('selected_days') ?? 
        ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Pzr'];
    
    setState(() {
      _currentTheme = AppThemes.getTheme(themeId);
      _currentLanguage = languageCode;
      _isVibrationOn = vibration;
      _isSoundOn = sound;
      _isConfettiOn = confetti;
      _isReminderEnabled = reminderEnabled;
      _isTtsOn = ttsEnabled;
      _isAutoBackupEnabled = autoBackup;
      _animationSpeed = animationSpeed;
      _reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
      _selectedDays = selectedDays.map((day) => true).toList();
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

  Future<void> _loadRewardedAd() async {
    try {
      await RewardedAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/5224355221', // Test ID
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            setState(() {
              _rewardedAd = ad;
              _isAdLoaded = true;
            });
          },
          onAdFailedToLoad: (error) {
            print('Rewarded ad failed to load: $error');
            setState(() {
              _isAdLoaded = false;
            });
          },
        ),
      );
    } catch (e) {
      print('Error loading rewarded ad: $e');
    }
  }

  Future<void> _showRewardedAd() async {
    if (_rewardedAd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reklam henüz yüklenmedi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödül kazandınız! +${reward.amount} ${reward.type}'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
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
              // Modern Header
              _buildModernHeader(),
              
              // Settings List
              Expanded(
                child: _buildModernContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.themeConfig.accentColor.withOpacity(0.2),
            widget.themeConfig.accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.themeConfig.accentColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.themeConfig.accentColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.themeConfig.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: widget.themeConfig.textColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.localizations.settings ?? 'Ayarlar',
                  style: GoogleFonts.notoSans(
                    color: widget.themeConfig.textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Uygulamayı kişiselleştir',
                  style: GoogleFonts.notoSans(
                    color: widget.themeConfig.textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.themeConfig.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.settings_rounded,
              color: widget.themeConfig.textColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Tema & Dil
        _buildModernSection(
          title: 'Görünüm',
          icon: Icons.palette,
          children: [
            _buildThemeSelection(),
            _buildLanguageSelection(),
            _buildAnimationSpeedSetting(),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Temel Ayarlar
        _buildModernSection(
          title: 'Temel Ayarlar',
          icon: Icons.tune,
          children: [
            _buildModernToggleSetting(
              title: widget.localizations.vibration ?? 'Titreşim',
              subtitle: 'Zikir sayımında titreşim',
              icon: Icons.vibration,
              value: _isVibrationOn,
              onTap: _toggleVibration,
            ),
            _buildModernToggleSetting(
              title: widget.localizations.sound ?? 'Ses',
              subtitle: 'Zikir sayımında ses',
              icon: Icons.volume_up,
              value: _isSoundOn,
              onTap: _toggleSound,
            ),
            _buildModernToggleSetting(
              title: 'Konfeti Animasyonu',
              subtitle: 'Hedef tamamlandığında',
              icon: Icons.celebration,
              value: _isConfettiOn,
              onTap: _toggleConfetti,
            ),
            _buildModernToggleSetting(
              title: 'TTS (Metin Okuma)',
              subtitle: 'Zikirleri sesli oku',
              icon: Icons.record_voice_over,
              value: _isTtsOn,
              onTap: _toggleTts,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Bildirimler
        _buildModernSection(
          title: 'Bildirimler',
          icon: Icons.notifications,
          children: [
            _buildModernToggleSetting(
              title: 'Hatırlatıcı',
              subtitle: 'Günlük zikir hatırlatması',
              icon: Icons.alarm,
              value: _isReminderEnabled,
              onTap: _toggleReminder,
            ),
            if (_isReminderEnabled) _buildReminderSettings(),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Veri & Yedekleme
        _buildModernSection(
          title: 'Veri Yönetimi',
          icon: Icons.storage,
          children: [
            _buildModernToggleSetting(
              title: 'Otomatik Yedekleme',
              subtitle: 'Verileri otomatik yedekle',
              icon: Icons.backup,
              value: _isAutoBackupEnabled,
              onTap: _toggleAutoBackup,
            ),
            _buildModernNavigationSetting(
              title: 'İçe/Dışa Aktar',
              subtitle: 'Verilerinizi yönetin',
              icon: Icons.import_export,
              onTap: _navigateToImportExport,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Diğer
        _buildModernSection(
          title: 'Diğer',
          icon: Icons.more_horiz,
          children: [
            _buildModernNavigationSetting(
              title: 'Reklam İzle',
              subtitle: 'Ödül kazanın',
              icon: Icons.emoji_events,
              onTap: _showRewardedAd,
            ),
            _buildModernNavigationSetting(
              title: 'Destek',
              subtitle: 'Yardım ve geri bildirim',
              icon: Icons.support,
              onTap: _navigateToSupport,
            ),
            _buildModernNavigationSetting(
              title: 'Hakkımızda',
              subtitle: 'Uygulama bilgileri',
              icon: Icons.info,
              onTap: _navigateToAbout,
            ),
            _buildVersionInfo(),
          ],
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildModernSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: widget.themeConfig.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.themeConfig.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: widget.themeConfig.accentColor,
                    size: 20,
                  ),
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
          // Section Content
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeSelection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tema Seçimi',
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildThemeOption('blue_gold', 'Safir Altın'),
              _buildThemeOption('green_gold', 'Zümrüt Parıltı'),
              _buildThemeOption('purple_gold', 'Kraliyet Gül'),
              _buildThemeOption('dark_night', 'Karan Gece'),
              _buildThemeOption('moonlight', 'Ay Işığı'),
              _buildThemeOption('deep_space', 'Derin Uzay'),
              _buildThemeOption('northern_lights', 'Kuzey Işıkları'),
              _buildThemeOption('dark_blue', 'Yıldızlı Gece'),
            ],
          ),
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
                    widget.themeConfig.accentColor.withOpacity(0.8),
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
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          themeName,
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dil Seçimi',
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
              _buildLanguageOption('id', '🇮🇩 Bahasa'),
              _buildLanguageOption('fr', '🇫🇷 Français'),
              _buildLanguageOption('de', '🇩🇪 Deutsch'),
              _buildLanguageOption('es', '🇪🇸 Español'),
              _buildLanguageOption('ru', '🇷🇺 Русский'),
              _buildLanguageOption('ur', '🇵🇰 اردو'),
              _buildLanguageOption('fa', '🇮🇷 فارسی'),
              _buildLanguageOption('ha', '🇳🇬 Hausa'),
              _buildLanguageOption('sw', '🇰🇪 Swahili'),
              _buildLanguageOption('bn', '🇧🇩 বাংলা'),
              _buildLanguageOption('hi', '🇮🇳 हिन्दी'),
              _buildLanguageOption('zh', '🇨🇳 中文'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language, String displayName) {
    final isSelected = _currentLanguage == language;
    return GestureDetector(
      onTap: () => _changeLanguage(language),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    widget.themeConfig.accentColor,
                    widget.themeConfig.accentColor.withOpacity(0.8),
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
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          displayName,
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildModernToggleSetting({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.themeConfig.accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: widget.themeConfig.accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSans(
                      color: widget.themeConfig.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSans(
                      color: widget.themeConfig.textColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: (value) => onTap(),
              activeColor: widget.themeConfig.accentColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernNavigationSetting({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.themeConfig.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: widget.themeConfig.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSans(
                        color: widget.themeConfig.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.notoSans(
                        color: widget.themeConfig.textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: widget.themeConfig.textColor.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimationSpeedSetting() {
    final speeds = ['Kapalı', 'Yavaş', 'Normal', 'Hızlı'];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Animasyon Hızı',
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              final isSelected = _animationSpeed == index;
              return Flexible(
                child: GestureDetector(
                  onTap: () => _changeAnimationSpeed(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? widget.themeConfig.accentColor : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      speeds[index],
                      style: GoogleFonts.notoSans(
                        color: isSelected ? Colors.white : widget.themeConfig.textColor,
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

  Widget _buildReminderSettings() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Zaman Seçimi
          Text(
            'Hatırlatıcı Saati',
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _selectReminderTime,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.themeConfig.accentColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: widget.themeConfig.accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.notoSans(
                      color: widget.themeConfig.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_drop_down,
                    color: widget.themeConfig.textColor.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Gün Seçimi
          Text(
            'Hatırlatıcı Günleri',
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Pzr'
            ].asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              final isSelected = _selectedDays[index];
              
              return GestureDetector(
                onTap: () => _toggleDay(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? widget.themeConfig.accentColor : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    day,
                    style: GoogleFonts.notoSans(
                      color: isSelected ? Colors.white : widget.themeConfig.textColor,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 12),
          
          // Kaydet Butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveReminderSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeConfig.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Hatırlatıcıyı Kaydet',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
              color: widget.themeConfig.textColor.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Method implementations
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
    setState(() {
      _currentLanguage = language;
    });
    await _settingsService.saveLanguage(language);
    
    // Ana sayfaya geri dön ve uygulamayı yenile
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => home.HomePage(
          onThemeModeChanged: (themeMode) {
            // Dil değişikliği burada işlenebilir
          },
        ),
      ),
    );
  }

  void _toggleVibration() {
    setState(() => _isVibrationOn = !_isVibrationOn);
    _settingsService.saveVibration(_isVibrationOn);
  }

  void _toggleSound() {
    setState(() => _isSoundOn = !_isSoundOn);
    _settingsService.saveSound(_isSoundOn);
  }

  void _toggleConfetti() {
    setState(() => _isConfettiOn = !_isConfettiOn);
    _settingsService.saveConfetti(_isConfettiOn);
  }

  void _toggleTts() async {
    setState(() => _isTtsOn = !_isTtsOn);
    await _settingsService.saveTtsEnabled(_isTtsOn);
  }

  void _toggleReminder() {
    setState(() => _isReminderEnabled = !_isReminderEnabled);
    _settingsService.saveReminderEnabled(_isReminderEnabled);
    
    if (_isReminderEnabled) {
      _scheduleReminder();
    } else {
      _cancelReminder();
    }
  }

  void _toggleAutoBackup() async {
    setState(() => _isAutoBackupEnabled = !_isAutoBackupEnabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_backup_enabled', _isAutoBackupEnabled);
  }

  void _changeAnimationSpeed(int speed) async {
    setState(() => _animationSpeed = speed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('animation_speed', speed);
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _toggleDay(int index) {
    setState(() {
      _selectedDays[index] = !_selectedDays[index];
    });
  }

  Future<void> _saveReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', _reminderTime.hour);
    await prefs.setInt('reminder_minute', _reminderTime.minute);
    
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Pzr'];
    final selectedDays = days.where((day) {
      final index = days.indexOf(day);
      return _selectedDays[index];
    }).toList();
    
    await prefs.setStringList('selected_days', selectedDays);
    
    // Bildirimi yeniden planla
    if (_isReminderEnabled) {
      _scheduleReminder();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hatırlatıcı ayarları kaydedildi'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _scheduleReminder() async {
    await _notificationService.scheduleDailyReminder(
      hour: _reminderTime.hour,
      minute: _reminderTime.minute,
      title: 'Zikir Vakti',
      body: 'Günlük zikirlerinizi yapmayı unutmayın!',
    );
  }

  Future<void> _cancelReminder() async {
    await _notificationService.cancelAllNotifications();
  }

  void _navigateToImportExport() {
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
}
