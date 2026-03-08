import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/theme_model.dart';
import '../models/user_profile_model.dart';
import '../utils/localizations.dart';
import '../utils/dialog_manager.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';
import '../services/ad_service.dart';
import '../services/supabase_service.dart';
import '../screens/support_screen_new.dart';
import '../screens/about_screen_new.dart';
import '../screens/import_export_screen.dart';
import 'home_page.dart' as home;

class SettingsScreen extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String currentUserId;
  final VoidCallback? onSettingsChanged;

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
  final SettingsService _settingsService = SettingsService();
  final NotificationService _notificationService = NotificationService();
  final AdService _adService = AdService();
  final SupabaseService _supabaseService = SupabaseService();
  ThemeConfig _currentTheme = AppThemes.getTheme('dark_blue');
  String _currentLanguage = 'tr';
  bool _isVibrationOn = true;
  bool _isSoundOn = true;
  bool _isConfettiOn = true;
  bool _isReminderEnabled = false;
  bool _isTtsOn = false;
  bool _isLeaderboardEnabled = true;
  String _appVersion = '1.0.0';
  
  // Yeni özellikler
  // bool _isAutoBackupEnabled = false;
  int _animationSpeed = 0; // 0: kapalı, 1: yavaş, 2: normal, 3: hızlı
  
  // Bildirim zamanlama
  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);
  List<bool> _selectedDays = [true, true, true, true, true, true, true]; // Pzt-Pzr
  
  // Reklam durumu
  bool _isRewardedAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppVersion();
    _loadRewardedAd();
  }

  Future<void> _loadSettings() async {
    try {
      final themeId = await _settingsService.getTheme();
      final languageCode = await _settingsService.getLanguage();
      final vibration = await _settingsService.getVibration();
      final sound = await _settingsService.getSound();
      final confetti = await _settingsService.getConfetti();
      final reminderEnabled = await _settingsService.getReminderEnabled();
      final ttsEnabled = await _settingsService.getTtsEnabled();
      
      // Yeni özellikleri SharedPreferences'ten yükle
      final prefs = await SharedPreferences.getInstance();
      // final autoBackup = prefs.getBool('auto_backup_enabled') ?? false;
      final animationSpeed = prefs.getInt('animation_speed') ?? 0;
      final leaderboardEnabled = prefs.getBool('leaderboard_enabled') ?? true;
      
      // Bildirim zamanını yükle
      final reminderHour = prefs.getInt('reminder_hour') ?? 21;
      final reminderMinute = prefs.getInt('reminder_minute') ?? 0;
      final selectedDays = prefs.getStringList('selected_days') ?? 
          ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Pzr'];
      
      // Tek bir setState ile tüm verileri güncelle
      if (mounted) {
        setState(() {
          _currentTheme = AppThemes.getTheme(themeId);
          _currentLanguage = languageCode;
          _isVibrationOn = vibration;
          _isSoundOn = sound;
          _isConfettiOn = confetti;
          _isReminderEnabled = reminderEnabled;
          _isTtsOn = ttsEnabled;
          _isLeaderboardEnabled = leaderboardEnabled;
          // _isAutoBackupEnabled = autoBackup;
          _animationSpeed = animationSpeed;
          _reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
          _selectedDays = selectedDays.map((day) => true).toList();
        });
      }
    } catch (e) {
      print('Settings load error: $e');
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _appVersion = '1.0.0';
        });
      }
    }
  }

  Future<void> _loadRewardedAd() async {
    try {
      await _adService.loadRewardedAd(
        onAdLoaded: () {
          if (mounted) {
            setState(() {
              _isRewardedAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (error) {
          print('Rewarded ad failed to load: $error');
          if (mounted) {
            setState(() {
              _isRewardedAdLoaded = false;
            });
          }
        },
      );
    } catch (e) {
      print('Error loading rewarded ad: $e');
    }
  }

  Future<void> _showRewardedAd() async {
    if (!_isRewardedAdLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reklam henüz yüklenmedi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _adService.showRewardedAd(
      onUserEarnedReward: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödül kazandınız! Bize destek olduğunuz için teşekkürler!'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onAdDismissed: () {
        // Reklam kapandığında yeni reklam yükle
        _loadRewardedAd();
      },
    );
  }

  Future<void> _syncProfileToLeaderboard() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil senkronize ediliyor...'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );

      // Kullanıcı profil bilgilerini al
      final prefs = await SharedPreferences.getInstance();
      final totalZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      final username = prefs.getString('username_${widget.currentUserId}') ?? 'user';
      final displayName = prefs.getString('display_name_${widget.currentUserId}') ?? username;
      final avatarUrl = prefs.getString('avatar_url_${widget.currentUserId}');

      // Supabase'e profil oluştur/güncelle
      final userProfile = UserProfile(
        userId: widget.currentUserId,
        username: username,
        displayName: displayName,
        avatarUrl: avatarUrl,
        totalZikrs: totalZikrs,
        lastZikrDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _supabaseService.updateUserProfile(userProfile);

      // Leaderboard'a ekle
      await _supabaseService.updateDailyLeaderboard(widget.currentUserId, totalZikrs);
      await _supabaseService.updateWeeklyLeaderboard(widget.currentUserId, totalZikrs);
      await _supabaseService.updateMonthlyLeaderboard(widget.currentUserId, totalZikrs);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil başarıyla senkronize edildi!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      print('✅ Profile synced to leaderboard: $username ($totalZikrs zikrs)');
    } catch (e) {
      print('❌ Error syncing profile to leaderboard: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Senkronizasyon başarısız. Lütfen tekrar deneyin.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
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
        ],
      ),
    );
  }

  Widget _buildModernContent() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 1,
      itemBuilder: (context, index) {
        return Column(
          children: [
            // Tema & Dil
            _buildModernSection(
              title: 'Tema & Dil',
              icon: Icons.palette,
              children: [
                _buildModernNavigationSetting(
                  title: 'Tema',
                  subtitle: 'Uygulama temasını değiştir',
                  icon: Icons.palette,
                  onTap: _showThemeSelector,
                ),
                _buildModernNavigationSetting(
                  title: 'Dil',
                  subtitle: 'Uygulama dilini değiştir',
                  icon: Icons.language,
                  onTap: _showLanguageSelector,
                ),
              ],
            ),
            
            // Sosyal & Leaderboard
            _buildModernSection(
              title: 'Sosyal & Leaderboard',
              icon: Icons.leaderboard,
              children: [
                _buildModernToggleSetting(
                  title: 'Leaderboard',
                  subtitle: 'Liderlik tablosuna katıl',
                  icon: Icons.leaderboard,
                  value: _isLeaderboardEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _isLeaderboardEnabled = value;
                    });
                    
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('leaderboard_enabled', value);
                    
                    if (value) {
                      await _syncProfileToLeaderboard();
                    }
                    
                    if (widget.onSettingsChanged != null) {
                      widget.onSettingsChanged!();
                    }
                  },
                ),
                _buildModernNavigationSetting(
                  title: 'Profili Senkronize Et',
                  subtitle: 'Liderlik tablosunu güncelle',
                  icon: Icons.sync,
                  onTap: _syncProfileToLeaderboard,
                ),
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
            
            // Diğer
            _buildModernSection(
              title: 'Diğer',
              icon: Icons.more_horiz,
              children: [
                // _buildModernToggleSetting(
                //   title: 'Otomatik Yedekleme',
                //   subtitle: 'Verilerinizi otomatik yedekleyin',
                //   icon: Icons.backup,
                //   value: _isAutoBackupEnabled,
                //   onTap: _toggleAutoBackup,
                // ),
                _buildModernNavigationSetting(
                  title: 'İmport/Export',
                  subtitle: 'Verilerinizi dışa aktarın veya içe aktarın',
                  icon: Icons.import_export,
                  onTap: _navigateToImportExport,
                ),
                _buildModernNavigationSetting(
                  title: 'Bize Destek Ol',
                  subtitle: 'Reklam izleyerek destek olun',
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
      },
    );
  }

  Widget _buildAnimationSpeedSetting() {
    final speedOptions = [
      {'value': 0, 'label': 'Kapalı', 'icon': Icons.stop},
      {'value': 1, 'label': 'Yavaş', 'icon': Icons.slow_motion_video},
      {'value': 2, 'label': 'Normal', 'icon': Icons.play_arrow},
      {'value': 3, 'label': 'Hızlı', 'icon': Icons.fast_forward},
    ];

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.themeConfig.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.speed,
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
                        'Animasyon Hızı',
                        style: GoogleFonts.notoSans(
                          color: widget.themeConfig.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Arayüz animasyonlarının hızı',
                        style: GoogleFonts.notoSans(
                          color: widget.themeConfig.textColor.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: speedOptions.map((option) {
                final isSelected = _animationSpeed == option['value'];
                return GestureDetector(
                  onTap: () => _changeAnimationSpeed(option['value'] as int),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? widget.themeConfig.accentColor.withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                            ? widget.themeConfig.accentColor
                            : Colors.white.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          option['icon'] as IconData,
                          size: 16,
                          color: isSelected 
                              ? widget.themeConfig.accentColor
                              : widget.themeConfig.textColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          option['label'] as String,
                          style: GoogleFonts.notoSans(
                            color: isSelected 
                                ? widget.themeConfig.accentColor
                                : widget.themeConfig.textColor.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Test Bildirim Butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await _notificationService.showTestNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Test bildirimi gönderildi!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Test Bildirimi Gönder',
                style: GoogleFonts.notoSans(
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
  void _showThemeSelector() {
    if (!DialogManager.canShowDialog()) return;
    
    DialogManager.onDialogOpened();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Tema Seç', style: GoogleFonts.notoSans()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppThemes.themes.map((theme) {
              final isSelected = _currentTheme.id == theme.id;
              return ListTile(
                title: Text(
                  _getThemeName(theme),
                  style: GoogleFonts.notoSans(),
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              DialogManager.onDialogClosed();
            },
            child: Text('İptal'),
          ),
        ],
      ),
    ).then((_) => DialogManager.onDialogClosed());
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

  void _showLanguageSelector() {
    if (!DialogManager.canShowDialog()) return;
    
    DialogManager.onDialogOpened();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Dil Seç', style: GoogleFonts.notoSans()),
        content: SizedBox(
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
              return ListTile(
                title: Text(
                  lang['name']!,
                  style: GoogleFonts.notoSans(),
                ),
                trailing: _currentLanguage == lang['code']
                    ? Icon(Icons.check, color: widget.themeConfig.accentColor)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  DialogManager.onDialogClosed();
                  _changeLanguage(lang['code']!);
                },
              );
            }).toList(),
          ),
        ),
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
    
    // Ana sayfaya hemen yansıtması için bildirim gönder
    if (widget.onSettingsChanged != null) {
      widget.onSettingsChanged!();
    }
  }

  void _toggleSound() {
    setState(() => _isSoundOn = !_isSoundOn);
    _settingsService.saveSound(_isSoundOn);
    
    // Ana sayfaya hemen yansıtması için bildirim gönder
    if (widget.onSettingsChanged != null) {
      widget.onSettingsChanged!();
    }
  }

  void _toggleConfetti() {
    setState(() => _isConfettiOn = !_isConfettiOn);
    _settingsService.saveConfetti(_isConfettiOn);
    
    // Ana sayfaya hemen yansıtması için bildirim gönder
    if (widget.onSettingsChanged != null) {
      widget.onSettingsChanged!();
    }
  }

  void _toggleTts() async {
    setState(() => _isTtsOn = !_isTtsOn);
    await _settingsService.saveTtsEnabled(_isTtsOn);
    
    // Ana sayfaya hemen yansıtması için bildirim gönder
    if (widget.onSettingsChanged != null) {
      widget.onSettingsChanged!();
    }
  }

  void _toggleReminder() {
    setState(() => _isReminderEnabled = !_isReminderEnabled);
    _settingsService.saveReminderEnabled(_isReminderEnabled);
    
    if (_isReminderEnabled) {
      _scheduleReminder();
    } else {
      _cancelReminder();
    }
    
    // Ana sayfaya hemen yansıtması için bildirim gönder
    if (widget.onSettingsChanged != null) {
      widget.onSettingsChanged!();
    }
  }

  // void _toggleAutoBackup() async {
  //   setState(() => _isAutoBackupEnabled = !_isAutoBackupEnabled);
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('auto_backup_enabled', _isAutoBackupEnabled);
  // }

  void _changeAnimationSpeed(int speed) async {
    setState(() => _animationSpeed = speed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('animation_speed', speed);
    
    // Ana sayfadaki animasyon hızını güncelle
    try {
      // Ana sayfaya bildirim göndermek için farklı bir yaklaşım kullanabiliriz
      // Şimdilik sadece kaydediyoruz, ana sayfa açıldığında yeni değeri okuyacak
      print('Animation speed changed to: $speed');
    } catch (e) {
      print('Animation speed update error: $e');
    }
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
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Pzr'];
    final selectedDays = days.where((day) {
      final index = days.indexOf(day);
      return _selectedDays[index];
    }).toList();
    
    await _notificationService.scheduleDailyReminder(
      hour: _reminderTime.hour,
      minute: _reminderTime.minute,
      title: 'Zikir Vakti',
      body: 'Günlük zikirlerinizi yapmayı unutmayın!',
      selectedDays: selectedDays.isEmpty ? null : selectedDays,
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
