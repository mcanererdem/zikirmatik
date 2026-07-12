import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:confetti/confetti.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';

import '../models/theme_model.dart';
import '../models/zikr_model.dart';
import '../models/user_profile_model.dart';
import '../models/goal_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';
import '../utils/trophy_assets.dart';
import '../services/settings_service.dart';
import '../services/audio_manager.dart';
import '../services/counter_logic.dart';
import '../services/feedback_manager.dart';
import '../services/tts_service.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';
import '../services/widget_service.dart';
import '../services/ad_service.dart';
import '../services/secure_storage_service.dart';
import '../widgets/zikr_selection_dialog.dart';
import '../widgets/add_zikr_dialog.dart';
import '../widgets/edit_zikr_dialog.dart';
import '../widgets/success_dialog.dart';
import '../widgets/target_dialog.dart';
import '../widgets/goal_dialog.dart';
import '../widgets/notification_settings_dialog.dart';
import '../widgets/confetti_animation.dart';
import '../utils/dialog_manager.dart';
import '../screens/statistics_screen_new.dart';
import '../screens/kupa_screen_new.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/import_export_screen.dart';

class HomePage extends StatefulWidget {
  final Function(ThemeMode)? onThemeModeChanged;
  final Function(String)? onLanguageChanged;
  
  const HomePage({super.key, this.onThemeModeChanged, this.onLanguageChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin, WidgetsBindingObserver {
  int _counter = 0;
  int _target = 33;
  bool _isVibrationOn = true;
  bool _isSoundOn = true;
  bool _isConfettiOn = true;
  bool _isReminderEnabled = false;
  bool _showConfetti = false;
  double _fontSize = 1.0; // Sabit font boyutu

  late AnimationController _buttonAnimationController;
  late AnimationController _counterAnimationController;
  late AnimationController _neonAnimationController;
  // Batch sync için timer
  Timer? _batchSyncTimer;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _counterScaleAnimation;
  late Animation<double> _neonPulseAnimation;

  final SettingsService _settingsService = SettingsService();
  final AdService _adService = AdService();
  final CounterLogic _counterLogic = CounterLogic();
  final AudioManager _audioManager = AudioManager();
  final FeedbackManager _feedbackManager = FeedbackManager();
  final SupabaseService _supabaseService = SupabaseService();
  final SecureStorageService _secureStorageService = SecureStorageService.instance;
  
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  
  final List<ZikrModel> _defaultZikrs = DefaultZikrs.zikrs;
  List<ZikrModel> _customZikrs = [];
  ZikrModel? _selectedZikr;
  
  ThemeConfig _currentTheme = AppThemes.getTheme('dark_blue');
  String _currentLanguage = 'en';
  String _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
  String? _profileDisplayName; // Profil/görünen ad (header'da gösterilecek)
  late AppLocalizations _localizations;
  List<Goal> _goals = [];
  Map<String, dynamic>? _lastStreakInfo;
  bool _isTtsOn = false;
  final TtsService _ttsService = TtsService();

  // Kupa/rozet önbelleği: her dokunuşta FutureBuilder ile SharedPreferences okumamak için.
  Map<String, bool> _unlockedCups = const {};
  String? _highestCup;

  // Zikir butonu metin stili önbelleği (tema/dil/font boyutu değişmedikçe yeniden hesaplanmaz).
  TextStyle? _zikrButtonTextStyle;
  String? _zikrButtonStyleKey;

  BoxDecoration? _cachedBackgroundDecoration;
  ThemeConfig? _cachedBackgroundTheme;

  BoxDecoration _buildBackgroundDecoration() {
    if (identical(_cachedBackgroundTheme, _currentTheme) && _cachedBackgroundDecoration != null) {
      return _cachedBackgroundDecoration!;
    }
    final isLightTheme = _currentTheme.textColor.computeLuminance() < 0.5;
    final generatedAsset = isLightTheme
        ? 'assets/generated/backgrounds/app_bg_light.png'
        : 'assets/generated/backgrounds/app_bg_dark.png';
    final fallbackAsset = isLightTheme
        ? 'assets/backgrounds/light_bg.png'
        : 'assets/backgrounds/dark_bg.png';

    // Theme'in opsiyonel asset override'ı varsa onu, yoksa generated default'ı kullanalım.
    final themeAsset = isLightTheme
        ? _currentTheme.lightBackgroundAsset
        : _currentTheme.darkBackgroundAsset;
    final asset = themeAsset ?? generatedAsset ?? fallbackAsset;
    final decoration = BoxDecoration(
      gradient: _currentTheme.backgroundGradient,
      image: asset != null
          ? DecorationImage(
              image: AssetImage(asset),
              fit: BoxFit.cover,
              opacity: 0.18,
            )
          : null,
    );
    _cachedBackgroundTheme = _currentTheme;
    _cachedBackgroundDecoration = decoration;
    return decoration;
  }

  @override
  void initState() {
    super.initState();
    debugPrint('🏠 HomePage initState called');
    // Dynamic localization helper'ı başlat
    DynamicLocalizationHelper.initialize();
    
    // _localizations'ı başlangıçta başlat
    _localizations = AppLocalizations('en');
    
    // Rastgele kullanıcı ismi oluştur
    _generateUserId();
    
    // Supabase'i başlat (dart-define yoksa uygulama çökmemeli).
    unawaited(
      _supabaseService.initialize().catchError((e) {
        debugPrint('Supabase initialize skipped: $e');
      }),
    );
    
    _loadSettings();
    _initializeTts();
    _audioManager.initialize();
    MobileAds.instance.initialize().then((_) {
      _loadBannerAd();
    });
    
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _counterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );
    
    _counterScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _counterAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Neon efekt animasyonu
    _neonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _neonPulseAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(
        parent: _neonAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _neonAnimationController.repeat(reverse: true);
  }

  Future<void> _generateUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = await _secureStorageService.readWithMigration(
      secureKey: 'user_id_secure',
      legacyPrefsKey: 'user_id',
    );
    
    if (savedUserId != null && savedUserId!.isNotEmpty) {
      _currentUserId = savedUserId;
      debugPrint('👤 Existing user ID loaded: $_currentUserId');
    } else {
      // Yeni kullanıcılar için tahmin edilmesi zor rastgele UUID kullan.
      _currentUserId = _supabaseService.generateUserId();
      
      // Kaydet
      await _secureStorageService.write('user_id_secure', _currentUserId);
      debugPrint('🎲 New random user ID generated: $_currentUserId');
    }
  }

  Future<void> _loadBannerAd() async {
    await _adService.loadBannerAd(
      onAdLoaded: (ad) {
        setState(() {
          _bannerAd = ad;
          _isBannerAdLoaded = true;
        });
      },
      onAdFailedToLoad: (error) {
        setState(() {
          _isBannerAdLoaded = false;
        });
      },
    );
  }

  Future<void> _loadSettings() async {
    debugPrint('🔄 Loading settings...');
    await WidgetService.syncWidgetCounter();
    final themeId = await _settingsService.getTheme();
    final languageCode = await _settingsService.getLanguage();
    final vibration = await _settingsService.getVibration();
    final sound = await _settingsService.getSound();
    final confetti = await _settingsService.getConfetti();
    final ttsEnabled = await _settingsService.getTtsEnabled();
    final customZikrs = await _settingsService.getCustomZikrs();
    final editedDefaultZikrs = await _settingsService.getEditedDefaultZikrs();
    final selectedZikrId = await _settingsService.getSelectedZikr();
    final savedCount = await _settingsService.getCurrentCount();
    final goals = await _settingsService.getGoals();
    final reminderEnabled = await _settingsService.getReminderEnabled();
    await _settingsService.cleanExpiredGoals();
    
    // Tema modu: theme_mode (system/light/dark) — Dark seçili kalır
    final themeMode = await _settingsService.getThemeMode();
    final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isSystemDark = platformBrightness == Brightness.dark;
    final isDarkMode = themeMode == 'dark' || (themeMode == 'system' && isSystemDark);

    final prefs = await SharedPreferences.getInstance();
    final animationSpeed = prefs.getInt('animation_speed') ?? 0;
    final currentLanguage = languageCode;
    // Profil/görünen ad: profil ekranında düzenlenen değer
    _profileDisplayName = await _secureStorageService.readWithMigration(
      secureKey: 'display_name_$_currentUserId',
      legacyPrefsKey: 'display_name_$_currentUserId',
    );
    
    debugPrint('🏠 HomePage _loadSettings:');
    debugPrint('🏠 languageCode from settings: $languageCode');
    debugPrint('🏠 currentLanguage from SharedPreferences: $currentLanguage');
    debugPrint('🏠 Using language: $currentLanguage');

    // Dynamic localization helper'ı güncelle
    await DynamicLocalizationHelper.setLanguage(currentLanguage);

    for (final edited in editedDefaultZikrs) {
      final idx = _defaultZikrs.indexWhere((z) => z.id == edited.id);
      if (idx != -1) {
        _defaultZikrs[idx] = edited.copyWith(isEditable: true);
      }
    }

    ZikrModel selectedZikr;
    if (selectedZikrId != null) {
      selectedZikr = _defaultZikrs.firstWhere(
        (z) => z.id == selectedZikrId,
        orElse: () => _customZikrs.firstWhere(
          (z) => z.id == selectedZikrId,
          orElse: () => _defaultZikrs[0],
        ),
      );
    } else {
      selectedZikr = _defaultZikrs[0];
    }
    final persistedTarget = await _resolveTargetForZikr(selectedZikr.id);

    setState(() {
      // Sistem / sadece koyu moda göre tema seçimi
      _currentTheme = AppThemes.getThemeForMode(themeId, isDarkMode);
      debugPrint('🎨 Theme loaded: $themeId (dark: $isDarkMode, themeMode: $themeMode)');
      _currentLanguage = currentLanguage; // SharedPreferences'ten gelen dil
      _localizations = AppLocalizations(currentLanguage);
      debugPrint('🌐 Language loaded: $currentLanguage');
      _isVibrationOn = vibration;
      _isSoundOn = sound;
      _isConfettiOn = confetti;
      _isTtsOn = ttsEnabled;
      _isReminderEnabled = reminderEnabled;
      _customZikrs = customZikrs;
      _counter = savedCount;
      _goals = goals;
      
      // Animasyon hızına göre controller ayarları
      _updateAnimationSpeed(animationSpeed);
      _selectedZikr = selectedZikr;
      _target = persistedTarget;
    });
    
    debugPrint('✅ Settings loaded successfully');

    final totalZikrs = prefs.getInt('total_zikrs_$_currentUserId') ?? 0;
    _refreshCupsCache(prefs, totalZikrs);

    // Batch sync'i başlat
    _startBatchSync();
  }

  Future<void> _initializeTts() async {
    final languageCode = await _settingsService.getLanguage();
    await _ttsService.initialize(languageCode);
    final rate = await _settingsService.getTtsRate();
    final pitch = await _settingsService.getTtsPitch();
    final voice = await _settingsService.getTtsVoice();
    await _ttsService.setRate(rate);
    await _ttsService.setPitch(pitch);
    if (voice != null && voice.isNotEmpty) {
      await _ttsService.setVoiceByName(voice);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _buttonAnimationController.dispose();
    _counterAnimationController.dispose();
    _neonAnimationController.dispose();
    _bannerAd?.dispose();
    _ttsService.dispose();
    
    // Batch sync'i durdur
    _stopBatchSync();
    
    // Dialog durumlarını temizle
    DialogManager.resetAllStates();
    
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('🏠 HomePage didChangeDependencies called');
    // Her sayfa değişiminde dil kontrolü yap
    _refreshLanguage();
  }

  Future<void> _refreshLanguage() async {
    final currentLanguage = await _settingsService.getLanguage();
    
    debugPrint('🏠 _refreshLanguage called');
    debugPrint('🏠 Current _currentLanguage: $_currentLanguage');
    debugPrint('🏠 Language from SharedPreferences: $currentLanguage');
    
    // Dynamic localization helper'ı güncelle
    await DynamicLocalizationHelper.setLanguage(currentLanguage);
    
    if (_currentLanguage != currentLanguage) {
      debugPrint('🏠 Language changed in didChangeDependencies: $_currentLanguage -> $currentLanguage');
      setState(() {
        _currentLanguage = currentLanguage;
        _localizations = AppLocalizations(currentLanguage);
      });
      
      // Ana uygulamaya dil değişimini bildir
      if (widget.onLanguageChanged != null) {
        widget.onLanguageChanged!(currentLanguage);
      }
      
      // Tüm sayfaları zorla yenile
      debugPrint('🏠 Forcing UI refresh with new language');
    } else {
      debugPrint('🏠 Language unchanged, no refresh needed');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final savedCount = await _settingsService.getCurrentCount();
      if (savedCount != _counter) {
        setState(() {
          _counter = savedCount;
        });
      }
      
      // Animasyon hızını güncelle (ayarlardan değiştirilmiş olabilir)
      final prefs = await SharedPreferences.getInstance();
      final animationSpeed = prefs.getInt('animation_speed') ?? 2;
      _updateAnimationSpeed(animationSpeed);
    } else if (state == AppLifecycleState.paused) {
      // Force widget update immediately when user backgrounds the app
      await WidgetService.updateWidgetImmediate();
    }
  }

  void _updateAnimationSpeed(int speed) {
    // Animasyon hızını güncelle
    switch (speed) {
      case 0: // Kapalı
        _buttonAnimationController.duration = const Duration(milliseconds: 0);
        _counterAnimationController.duration = const Duration(milliseconds: 0);
        _neonAnimationController.duration = const Duration(milliseconds: 0);
        _neonAnimationController.stop();
        break;
      case 1: // Yavaş
        _buttonAnimationController.duration = const Duration(milliseconds: 200);
        _counterAnimationController.duration = const Duration(milliseconds: 150);
        _neonAnimationController.duration = const Duration(milliseconds: 2500);
        _neonAnimationController.repeat(reverse: true);
        break;
      case 2: // Normal
        _buttonAnimationController.duration = const Duration(milliseconds: 100);
        _counterAnimationController.duration = const Duration(milliseconds: 80);
        _neonAnimationController.duration = const Duration(milliseconds: 1500);
        _neonAnimationController.repeat(reverse: true);
        break;
      case 3: // Hızlı
        _buttonAnimationController.duration = const Duration(milliseconds: 50);
        _counterAnimationController.duration = const Duration(milliseconds: 30);
        _neonAnimationController.duration = const Duration(milliseconds: 800);
        _neonAnimationController.repeat(reverse: true);
        break;
    }
  }

  void _incrementCounter() async {
    setState(() => _counter++);

    // Dokunuşa anında tepki: animasyon/ses/titreşim, disk I/O'nun bitmesini beklemeden hemen tetiklenir.
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });
    _counterAnimationController.forward().then((_) => _counterAnimationController.reverse());
    if (_isSoundOn) _audioManager.playClick();
    if (_isVibrationOn) _feedbackManager.vibrateLight();

    await _counterLogic.incrementCounter(_counter, _selectedZikr?.id);

    // Local storage'a kaydet
    final prefs = await SharedPreferences.getInstance();
    final totalZikrs = prefs.getInt('total_zikrs_$_currentUserId') ?? 0;
    await prefs.setInt('total_zikrs_$_currentUserId', totalZikrs + 1);
    await prefs.setString('last_zikr_date_$_currentUserId', DateTime.now().toIso8601String());

    debugPrint('Zikir count saved locally: ${totalZikrs + 1}');

    // Not: Her tıklamada cloud upload yapılmaz.
    // Cloud sync; leaderboard ekranı açılışında ve rate-limit'li refresh ile yapılır.

    if (_isTtsOn) {
      await _ttsService.speakZikr(_selectedZikr);
    }
    final result = await _counterLogic.updateGoalProgress(_goals, _selectedZikr?.id);
    
    final updatedGoals = result['goals'] as List<Goal>;
    final streakInfo = result['streakInfo'] as Map<String, dynamic>?;
    final goalType = result['goalType'] as String?;
    
    bool goalCompleted = false;
    int completedCount = 0;
    
    for (var goal in updatedGoals) {
      final oldGoal = _goals.firstWhere((g) => g.id == goal.id, orElse: () => goal);
      if (!oldGoal.isCompleted && goal.isCompleted) {
        goalCompleted = true;
        completedCount++;
        
        // Her trophy için ayrı bildirim (gecikme ile)
        final delay = Duration(milliseconds: 500 + (completedCount - 1) * 4500);
        Future.delayed(delay, () {
          if (mounted) {
            _showGoalCompletedNotification(goal, streakInfo, goal.type);
          }
        });
      }
    }
    
    setState(() {
      _goals = updatedGoals;
      if (streakInfo != null) {
        _lastStreakInfo = streakInfo;
      }
    });

    // Kupa kontrolü
    await _checkAndUnlockAchievements();

    if (_counter == _target) {
      _showSuccessAnimation();
    }
  }

  void _showGoalCompletedNotification(Goal goal, Map<String, dynamic>? streakInfo, String? goalType) {
    if (!mounted) return;
    
    // Önceki snackbar'ı kapat
    ScaffoldMessenger.of(context).clearSnackBars();
    
    if (!DialogManager.canShowSnackbar()) return;
    
    DialogManager.onSnackbarShown();
    
    final typeLabel = goalType == 'daily' ? _localizations.dailyGoal :
                     goalType == 'weekly' ? _localizations.weeklyGoal :
                     _localizations.monthlyGoal;
    
    // Kısa gecikme ile göster (önceki snackbar'ın kapanması için)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _localizations.goalCompleted,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '$typeLabel: ${goal.targetCount}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (streakInfo != null && streakInfo['streak'] > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          '${streakInfo['streak']} ${_localizations.translate('streak_continues') ?? 'streak'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (streakInfo['isNewBest'] == true) ...[
                          const SizedBox(width: 8),
                          const Text('⭐', style: TextStyle(fontSize: 18)),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ).closed.then((_) => DialogManager.onSnackbarHidden());
    });
  }

  void _showSuccessAnimation() {
    if (_isVibrationOn) _feedbackManager.vibrateSuccess();
    if (_isSoundOn) _audioManager.playSuccess();

    if (_isConfettiOn) {
      setState(() => _showConfetti = true);

      if (!DialogManager.canShowDialog()) return;
      
      DialogManager.onDialogOpened();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SuccessDialog(
          count: _counter,
          onContinue: () {
            if (mounted) {
              setState(() => _showConfetti = false);
            }
          },
          onReset: () {
            if (mounted) {
              _resetCounter();
            }
          },
          themeConfig: _currentTheme,
          localizations: _localizations,
        ),
      ).then((_) => DialogManager.onDialogClosed());
    }
  }

  Future<void> _syncToLeaderboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final totalZikrs = prefs.getInt('total_zikrs_$_currentUserId') ?? 0;
      final username = await _secureStorageService.readWithMigration(
            secureKey: 'username_$_currentUserId',
            legacyPrefsKey: 'username_$_currentUserId',
          ) ??
          'user';
      final storedDisplayName = await _secureStorageService.readWithMigration(
        secureKey: 'display_name_$_currentUserId',
        legacyPrefsKey: 'display_name_$_currentUserId',
      );
      final displayName = (storedDisplayName != null)
          ? (() {
              final t = storedDisplayName.trim();
              if (t.isNotEmpty && !_isOldDefaultDisplayName(t)) return t;
              return _getZikrDefaultDisplayName();
            })()
          : _getZikrDefaultDisplayName();
      final avatarUrl = await _secureStorageService.readWithMigration(
        secureKey: 'avatar_url_$_currentUserId',
        legacyPrefsKey: 'avatar_url_$_currentUserId',
      );

      // Supabase'e profil oluştur/güncelle
      final now = DateTime.now();
      final updatedUserProfile = UserProfile(
        userId: _currentUserId,
        username: displayName,
        displayName: displayName,
        avatarUrl: avatarUrl,
        totalZikrs: totalZikrs,
        lastZikrDate: now,
        createdAt: now,
        updatedAt: now,
      );

      // Leaderboard'a ekle (kullanıcı sıralamada görünsün istiyorsa)
      final showInLeaderboard = await _settingsService.getShowInLeaderboard();
      if (showInLeaderboard) {
        await _supabaseService.updateDailyLeaderboard(_currentUserId, totalZikrs);
        await _supabaseService.updateWeeklyLeaderboard(_currentUserId, totalZikrs);
        await _supabaseService.updateMonthlyLeaderboard(_currentUserId, totalZikrs);
      }
      debugPrint('✅ Auto-sync to leaderboard: $username ($totalZikrs zikrs)');
    } catch (e) {
      debugPrint('❌ Error auto-syncing to leaderboard: $e');
    }
  }

  void _resetCounter() async {
    setState(() {
      _counter = 0;
      _showConfetti = false;
    });
    await _counterLogic.resetCounter();
    if (_isVibrationOn) _feedbackManager.vibrateMedium();
  }

  // Kupa kontrolü
  Future<void> _checkAndUnlockAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayKey = '${today.year}_${today.month}_${today.day}';
      final lastCheckDate = prefs.getString('last_achievement_check_$_currentUserId') ?? '';
      
      // Günlük kontrolü sıfırla - sadece günlük kupaları sıfırla
      if (lastCheckDate != todayKey) {
        // Sadece günlük kupaları sıfırla
        await prefs.remove('daily_warrior_unlocked_$_currentUserId');
        await prefs.setString('last_achievement_check_$_currentUserId', todayKey);
        debugPrint('📅 Daily achievements reset for $todayKey');
      }
      
      final totalZikrs = prefs.getInt('total_zikrs_$_currentUserId') ?? 0;
      
      debugPrint('Checking achievements for $totalZikrs zikrs');
      
      // Leaderboard senkronizasyonu (varsayılan: kapalı)
      final leaderboardEnabled = await _settingsService.getShowInLeaderboard();
      if (leaderboardEnabled) {
        // Batch sync kullan - her 5 dakikada bir veya 10 zikir biriktiğinde
        // Aktif sayaç değiştiğinde batch sync tetikle
        final previousZikrs = prefs.getInt('previous_zikrs_$_currentUserId') ?? 0;
        if (totalZikrs > previousZikrs) {
          // Batch sync'i tetikle - 10 zikir biriktiğinde sync edecek
          _batchSyncToLeaderboard();
        }
        await prefs.setInt('previous_zikrs_$_currentUserId', totalZikrs);
      }
      
      // Bronz Kupa - 100 zikir (kalıcı)
      if (totalZikrs >= 100) {
        final bronzeUnlocked = prefs.getBool('bronze_kupa_unlocked_$_currentUserId') ?? false;
        if (!bronzeUnlocked) {
          debugPrint('🥉 Bronze Kupa unlocked!');
          _showAchievementNotification('🥉 Bronz Kupa Kazandınız!', '100 zikir hedefine ulaştınız!');
          await prefs.setBool('bronze_kupa_unlocked_$_currentUserId', true);
          // Supabase'e kaydet
          try {
            await _supabaseService.unlockAchievement(_currentUserId, 'bronze_kupa');
          } catch (e) {
            debugPrint('Error saving bronze achievement to Supabase: $e');
          }
        }
      }
      
      // Gümüş Kupa - 500 zikir (kalıcı)
      if (totalZikrs >= 500) {
        final silverUnlocked = prefs.getBool('silver_kupa_unlocked_$_currentUserId') ?? false;
        if (!silverUnlocked) {
          debugPrint('🥈 Silver Kupa unlocked!');
          _showAchievementNotification('🥈 Gümüş Kupa Kazandınız!', '500 zikir hedefine ulaştınız!');
          await prefs.setBool('silver_kupa_unlocked_$_currentUserId', true);
          // Supabase'e kaydet
          try {
            await _supabaseService.unlockAchievement(_currentUserId, 'silver_kupa');
          } catch (e) {
            debugPrint('Error saving silver achievement to Supabase: $e');
          }
        }
      }
      
      // Altın Kupa - 1000 zikir (kalıcı)
      if (totalZikrs >= 1000) {
        final goldUnlocked = prefs.getBool('gold_kupa_unlocked_$_currentUserId') ?? false;
        if (!goldUnlocked) {
          debugPrint('🥇 Gold Kupa unlocked!');
          _showAchievementNotification('🥇 Altın Kupa Kazandınız!', '1000 zikir hedefine ulaştınız!');
          await prefs.setBool('gold_kupa_unlocked_$_currentUserId', true);
          // Supabase'e kaydet
          try {
            await _supabaseService.unlockAchievement(_currentUserId, 'gold_kupa');
          } catch (e) {
            debugPrint('Error saving gold achievement to Supabase: $e');
          }
        }
      }
      
      // Elmas Kupa - 5000 zikir (kalıcı)
      if (totalZikrs >= 5000) {
        final diamondUnlocked = prefs.getBool('diamond_kupa_unlocked_$_currentUserId') ?? false;
        if (!diamondUnlocked) {
          debugPrint('💎 Diamond Kupa unlocked!');
          _showAchievementNotification('💎 Elmas Kupa Kazandınız!', '5000 zikir hedefine ulaştınız!');
          await prefs.setBool('diamond_kupa_unlocked_$_currentUserId', true);
          // Supabase'e kaydet
          try {
            await _supabaseService.unlockAchievement(_currentUserId, 'diamond_kupa');
          } catch (e) {
            debugPrint('Error saving diamond achievement to Supabase: $e');
          }
        }
      }
      
      // Platin Kupa - 10000 zikir (kalıcı)
      if (totalZikrs >= 10000) {
        final platinumUnlocked = prefs.getBool('platinum_kupa_unlocked_$_currentUserId') ?? false;
        if (!platinumUnlocked) {
          debugPrint('🏆 Platinum Kupa unlocked!');
          _showAchievementNotification('🏆 Platin Kupa Kazandınız!', '10000 zikir hedefine ulaştınız!');
          await prefs.setBool('platinum_kupa_unlocked_$_currentUserId', true);
          // Supabase'e kaydet
          try {
            await _supabaseService.unlockAchievement(_currentUserId, 'platinum_kupa');
          } catch (e) {
            debugPrint('Error saving platinum achievement to Supabase: $e');
          }
        }
      }
      
      // Günlük Savaşçı - 1000 zikir/gün (günlük)
      final todayZikrs = prefs.getInt('daily_count_${today.year}_${today.month}_${today.day}_$_currentUserId') ?? 0;
      if (todayZikrs >= 1000) {
        final dailyWarriorUnlocked = prefs.getBool('daily_warrior_unlocked_$_currentUserId') ?? false;
        if (!dailyWarriorUnlocked) {
          debugPrint('⚔️ Daily Warrior unlocked!');
          _showAchievementNotification('⚔️ Günlük Savaşçı!', 'Bugün 1000 zikir yaptınız!');
          await prefs.setBool('daily_warrior_unlocked_$_currentUserId', true);
          // Supabase'e kaydet
          try {
            await _supabaseService.unlockAchievement(_currentUserId, 'daily_warrior');
          } catch (e) {
            debugPrint('Error saving daily warrior achievement to Supabase: $e');
          }
        }
      }

      _refreshCupsCache(prefs, totalZikrs);
    } catch (e) {
      debugPrint('Error checking achievements: $e');
    }
  }

  // Kupa/rozet önbelleğini güncelle (header'daki FutureBuilder'ların her dokunuşta
  // SharedPreferences'a gitmesini önlemek için).
  void _refreshCupsCache(SharedPreferences prefs, int totalZikrs) {
    final unlockedCups = {
      'bronze_kupa': prefs.getBool('bronze_kupa_unlocked_$_currentUserId') ?? false,
      'silver_kupa': prefs.getBool('silver_kupa_unlocked_$_currentUserId') ?? false,
      'gold_kupa': prefs.getBool('gold_kupa_unlocked_$_currentUserId') ?? false,
      'diamond_kupa': prefs.getBool('diamond_kupa_unlocked_$_currentUserId') ?? false,
      'platinum_kupa': prefs.getBool('platinum_kupa_unlocked_$_currentUserId') ?? false,
    };
    final highestCup = totalZikrs >= 10000
        ? DynamicLocalizationHelper.platinum
        : totalZikrs >= 5000
            ? DynamicLocalizationHelper.diamond
            : totalZikrs >= 1000
                ? DynamicLocalizationHelper.gold
                : totalZikrs >= 500
                    ? DynamicLocalizationHelper.silver
                    : totalZikrs >= 100
                        ? DynamicLocalizationHelper.bronze
                        : DynamicLocalizationHelper.new_;
    if (!mounted) return;
    setState(() {
      _unlockedCups = unlockedCups;
      _highestCup = highestCup;
    });
  }

  void _showAchievementNotification(String title, String message) {
    if (mounted && DialogManager.canShowSnackbar()) {
      DialogManager.onSnackbarShown();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ).closed.then((_) => DialogManager.onSnackbarHidden());
    }
  }

  Widget _buildHeaderTrophyIcon(String assetPath, String fallbackEmoji) {
    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: Image.asset(
        assetPath,
        width: 16,
        height: 16,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Text(fallbackEmoji, style: const TextStyle(fontSize: 14));
        },
      ),
    );
  }

  Future<int> _resolveTargetForZikr(String zikrId) async {
    final savedTarget = await _settingsService.getZikrTarget(zikrId);
    if (savedTarget != null && savedTarget > 0) {
      return savedTarget;
    }
    return 33;
  }

  void _changeTarget() {
    showDialog(
      context: context,
      builder: (context) => TargetDialog(
        currentTarget: _target,
        onTargetChanged: (newTarget) {
          final selectedZikrId = _selectedZikr?.id;
          setState(() {
            _target = newTarget;
          });
          if (selectedZikrId != null) {
            unawaited(_settingsService.saveZikrTarget(selectedZikrId, newTarget));
          }
        },
        themeConfig: _currentTheme,
        localizations: _localizations,
      ),
    );
  }

  void _selectZikr() {
    final allZikrs = [..._defaultZikrs, ..._customZikrs];
    Future.wait(allZikrs.map((z) => _resolveTargetForZikr(z.id))).then((targets) {
      if (!mounted) return;
      final targetMap = <String, int>{};
      for (int i = 0; i < allZikrs.length; i++) {
        targetMap[allZikrs[i].id] = targets[i];
      }
      showDialog(
      context: context,
      builder: (context) => ZikrSelectionDialog(
        defaultZikrs: _defaultZikrs,
        customZikrs: _customZikrs,
        selectedZikr: _selectedZikr,
        currentLanguage: _currentLanguage,
        zikrTargets: targetMap,
        onZikrSelected: (zikr) async {
          final resolvedTarget = await _resolveTargetForZikr(zikr.id);
          if (!mounted) return;
          setState(() {
            _selectedZikr = zikr;
            _target = resolvedTarget;
            _counter = 0;
          });
          await _settingsService.saveSelectedZikr(zikr.id);
          Navigator.pop(context);
        },
        onEditZikr: _openEditZikrDialog,
        onAddCustomZikr: _addCustomZikr,
        onDeleteZikr: _deleteCustomZikr,
        themeConfig: _currentTheme,
        localizations: _localizations,
      ),
      );
    });
  }

  void _openEditZikrDialog(ZikrModel zikr) async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => EditZikrDialog(
        zikr: zikr,
        currentLanguage: _currentLanguage,
        themeConfig: _currentTheme,
        localizations: _localizations,
        onZikrUpdated: (updated) {
          final customIndex = _customZikrs.indexWhere((z) => z.id == updated.id);
          if (customIndex != -1) {
            _customZikrs[customIndex] = updated;
            _settingsService.saveCustomZikrs(_customZikrs);
          } else {
            final defaultIndex = _defaultZikrs.indexWhere((z) => z.id == updated.id);
            if (defaultIndex != -1) {
              _defaultZikrs[defaultIndex] = updated.copyWith(isEditable: true);
              unawaited(_settingsService.saveEditedDefaultZikrs(_defaultZikrs));
            }
          }
          unawaited(_settingsService.saveZikrTarget(updated.id, updated.defaultCount));
          setState(() {
            if (_selectedZikr?.id == updated.id) {
              _selectedZikr = updated;
              _target = updated.defaultCount;
            }
          });
        },
      ),
    );
  }

  void _addCustomZikr() {
    showDialog(
      context: context,
      builder: (context) => AddZikrDialog(
        themeConfig: _currentTheme,
        localizations: _localizations,
        currentLanguage: _currentLanguage,
        onZikrAdded: (zikr) {
          setState(() {
            _customZikrs.add(zikr);
          });
          _settingsService.saveCustomZikrs(_customZikrs);
        },
      ),
    );
  }

  void _deleteCustomZikr(ZikrModel zikr) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _currentTheme.primaryColor,
        title: Text(
          _localizations.delete,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          _currentLanguage == 'ar' 
            ? 'هل تريد حذف ${zikr.nameAr}؟'
            : _currentLanguage == 'en'
              ? 'Delete ${zikr.nameEn}?'
              : '${zikr.nameTr} silinsin mi?',
          style: const TextStyle(color: Colors.white70),
          textDirection: _currentLanguage == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _localizations.cancel,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              final nextSelected = _defaultZikrs[0];
              final nextTarget = await _resolveTargetForZikr(nextSelected.id);
              if (!mounted) return;
              setState(() {
                _customZikrs.removeWhere((z) => z.id == zikr.id);
                if (_selectedZikr?.id == zikr.id) {
                  _selectedZikr = nextSelected;
                  _target = nextTarget;
                }
              });
              _settingsService.saveCustomZikrs(_customZikrs);
              Navigator.pop(context);
            },
            child: Text(
              _localizations.delete,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  String _getProfileDisplayName() {
    // Kullanıcı profil ekranında "Görünen ad"ı ayarladıysa onu göster,
    // aksi halde yerelleştirilmiş varsayılan başlığı kullan.
    final raw = _profileDisplayName;
    if (raw != null) {
      final t = raw.trim();
      if (t.isNotEmpty && !_isOldDefaultDisplayName(t)) {
        return t;
      }
    }
    return _getZikrDefaultDisplayName();
  }

  bool _isOldDefaultDisplayName(String value) {
    // Eski sürümlerde varsayılan olarak kaydedilmiş metinleri Zikr'e dönüştür.
    const oldDefaults = <String>{
      'Kullanıcı',
      'Zikir Çalışanı',
      'Dhikr Practitioner',
      'Pengamal Zikir',
      'الذاكر',
      'user',
      'User',
    };
    return oldDefaults.contains(value);
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

  // Başka bir ekrana geçerken neon nabız animasyonunu durdurur; ekran görünür
  // değilken gereksiz repaint yapılmasını önler, geri dönünce kaldığı yerden devam eder.
  Future<dynamic> _pushWithNeonPause(BuildContext ctx, Route route) {
    final wasAnimating = _neonAnimationController.isAnimating;
    if (wasAnimating) _neonAnimationController.stop();
    return Navigator.push(ctx, route).then((result) {
      if (wasAnimating && mounted) _neonAnimationController.repeat(reverse: true);
      return result;
    });
  }

  void _openSettings() {
    _pushWithNeonPause(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          themeConfig: _currentTheme,
          localizations: _localizations,
          currentUserId: _currentUserId,
          onSettingsChanged: () {
            _loadSettings();
            setState(() {});
          },
          onLanguageChanged: widget.onLanguageChanged,
          onThemeModeChanged: (mode) {
            widget.onThemeModeChanged?.call(
              mode == 'dark' ? ThemeMode.dark : mode == 'light' ? ThemeMode.light : ThemeMode.system,
            );
          },
        ),
      ),
    ).then((_) {
      if (mounted) {
        _loadSettings();
        setState(() {});
      }
    });
  }

  void _toggleVibration() {
    setState(() => _isVibrationOn = !_isVibrationOn);
    _settingsService.saveVibration(_isVibrationOn);
    if (_isVibrationOn) _feedbackManager.vibrateMedium();
  }

  void _toggleSound() {
    setState(() => _isSoundOn = !_isSoundOn);
    _settingsService.saveSound(_isSoundOn);
    if (_isSoundOn) _audioManager.playClick();
  }

  void _toggleConfetti() {
    setState(() => _isConfettiOn = !_isConfettiOn);
    _settingsService.saveConfetti(_isConfettiOn);
  }

  void _toggleTts() async {
    final next = !_isTtsOn;
    setState(() => _isTtsOn = next);
    await _ttsService.setEnabled(next);
    final languageCode = await _settingsService.getLanguage();
    await _ttsService.setLanguage(languageCode);
  }

  String _getZikrName(ZikrModel zikr) {
    return zikr.getNameForLanguage(_currentLanguage);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final progress = _counter / _target;
    String zikrText = _selectedZikr?.getNameForLanguage('ar') ?? 'سُبْحَانَ اللّٰهِ';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _buildBackgroundDecoration(),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildCounterDisplay(),
                        const SizedBox(height: 20),
                        _buildProgressBar(progress),
                        const SizedBox(height: 15),
                        _buildTargetInfo(),
                        const Spacer(),
                        _buildZikrButton(zikrText),
                        const Spacer(),
                        _buildBottomControls(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: (_bannerAd?.size.height ?? 50.0).toDouble(),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.03),
                    border: Border(
                      top: BorderSide(
                        color: _currentTheme.accentColor.withOpacity(0.12),
                        width: 1,
                      ),
                    ),
                  ),
                  child: _isBannerAdLoaded && _bannerAd != null
                      ? Center(child: Container(
                          width: _bannerAd!.size.width.toDouble(),
                          height: _bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        ))
                      : Center(
                          child: Text(
                            _isBannerAdLoaded ? 'Preparing ad...' : 'Ad not loaded',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ),
                ),
              ],
            ),
            if (_showConfetti)
              ConfettiAnimation(
                onComplete: () {
                  setState(() => _showConfetti = false);
                },
              ),
          ],
        ),
      ),
    );
  }

  // Diğer widget metodları aynı kalıyor...
  // (_buildHeader, _buildCounterDisplay, vb.)
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sol taraf - Avatar, profil ismi ve kupalar
          Expanded(
            child: GestureDetector(
              onTap: () async {
                await _pushWithNeonPause(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      themeConfig: _currentTheme,
                      localizations: _localizations,
                      currentUserId: _currentUserId,
                    ),
                  ),
                );

                // Profil ekranından geri dönünce "Görünen ad"ı yeniden oku.
                if (!mounted) return;
                final refreshedDisplayName = await _secureStorageService.readWithMigration(
                  secureKey: 'display_name_$_currentUserId',
                  legacyPrefsKey: 'display_name_$_currentUserId',
                );
                if (!mounted) return;
                setState(() {
                  _profileDisplayName = refreshedDisplayName;
                });
              },
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _currentTheme.accentColor.withOpacity(0.3),
                          _currentTheme.accentColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _currentTheme.accentColor.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: _currentTheme.accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Profil ismi ve kupalar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getProfileDisplayName(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _currentTheme.textColor,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Kazanılmış kupaları göster (önbellekten; her dokunuşta yeniden okunmaz)
                            if (_unlockedCups['bronze_kupa'] == true)
                              _buildHeaderTrophyIcon(TrophyAssets.bronze, '🥉'),
                            if (_unlockedCups['silver_kupa'] == true)
                              _buildHeaderTrophyIcon(TrophyAssets.silver, '🥈'),
                            if (_unlockedCups['gold_kupa'] == true)
                              _buildHeaderTrophyIcon(TrophyAssets.gold, '🥇'),
                            if (_unlockedCups['diamond_kupa'] == true)
                              _buildHeaderTrophyIcon(TrophyAssets.diamond, '💎'),
                            if (_unlockedCups['platinum_kupa'] == true)
                              _buildHeaderTrophyIcon(TrophyAssets.platinum, '🏆'),
                            const SizedBox(width: 4),
                            Text(
                              _highestCup ?? DynamicLocalizationHelper.new_,
                              style: TextStyle(
                                fontSize: 12,
                                color: _currentTheme.textColor.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
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
          
          // Sağ taraf - İstatistikler, leaderboard ve ayarlar
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  _pushWithNeonPause(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(
                        themeConfig: _currentTheme,
                        localizations: _localizations,
                        currentUserId: _currentUserId,
                        onSettingsChanged: () {
                          _loadSettings();
                          setState(() {});
                        },
                        onLanguageChanged: widget.onLanguageChanged,
                        onThemeModeChanged: (mode) {
                          widget.onThemeModeChanged?.call(
                            mode == 'dark' ? ThemeMode.dark : mode == 'light' ? ThemeMode.light : ThemeMode.system,
                          );
                        },
                      ),
                    ),
                  ).then((_) {
                    if (mounted) {
                      _loadSettings();
                      setState(() {});
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _currentTheme.textColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _currentTheme.textColor.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    color: _currentTheme.textColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterDisplay() {
    return ScaleTransition(
      scale: _counterScaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          color: _currentTheme.textColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _currentTheme.accentColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _currentTheme.accentColor.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$_counter',
            style: TextStyle(
              fontSize: 72 * _fontSize,
              fontWeight: FontWeight.bold,
              color: _currentTheme.accentColor,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 12,
          decoration: BoxDecoration(
            color: _currentTheme.textColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                gradient: _currentTheme.goldGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: _currentTheme.accentColor.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTargetInfo() {
    return GestureDetector(
      onTap: _selectZikr,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: _currentTheme.textColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _currentTheme.accentColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: _currentTheme.accentColor.withOpacity(0.9),
              size: 20,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedZikr != null ? _getZikrName(_selectedZikr!) : 'Sübhanallah',
                  style: TextStyle(
                    fontSize: 14 * _fontSize,
                    fontWeight: FontWeight.w600,
                    color: _currentTheme.textColor,
                  ),
                  textDirection: _currentLanguage == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                ),
                Text(
                  '${_localizations.target}: $_target',
                  style: TextStyle(
                    fontSize: 12 * _fontSize,
                    color: _currentTheme.textColor.withOpacity(0.75),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: _currentTheme.accentColor.withOpacity(0.9),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // Tema/dil/font boyutu değişmediği sürece aynı TextStyle'ı yeniden kullanır
  // (her dokunuşta GoogleFonts çağrısı ile yeni obje oluşturmayı önler).
  TextStyle _getZikrButtonTextStyle() {
    final key = '$_currentLanguage-${_currentTheme.accentColor.value}-$_fontSize';
    final cached = _zikrButtonTextStyle;
    if (cached != null && _zikrButtonStyleKey == key) {
      return cached;
    }
    final shadow = [
      Shadow(
        color: _currentTheme.accentColor.withOpacity(0.8),
        blurRadius: 10,
        offset: const Offset(0, 0),
      ),
    ];
    final style = _currentLanguage == 'ar'
        ? GoogleFonts.notoNaskhArabic(
            fontSize: 24 * _fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: shadow,
          )
        : GoogleFonts.notoSans(
            fontSize: 24 * _fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: shadow,
          );
    _zikrButtonStyleKey = key;
    _zikrButtonTextStyle = style;
    return style;
  }

  Widget _buildZikrButton(String zikrText) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Neon efekt katmanı
        AnimatedBuilder(
          animation: _neonPulseAnimation,
          builder: (context, child) {
            return Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _currentTheme.accentColor.withOpacity(_neonPulseAnimation.value * 0.3),
                    _currentTheme.accentColor.withOpacity(_neonPulseAnimation.value * 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            );
          },
        ),
        
        // Ana buton
        Semantics(
          label: _localizations.incrementCounter,
          child: GestureDetector(
            onTap: _incrementCounter,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _currentTheme.buttonGradient,
                boxShadow: [
                  // Ana gölge
                  BoxShadow(
                    color: _currentTheme.primaryColor.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  // Neon efekt 1 - Dış halka (animasyonlu)
                  BoxShadow(
                    color: _currentTheme.accentColor.withOpacity(0.6),
                    blurRadius: 50,
                    spreadRadius: 3,
                  ),
                  // Neon efekt 2 - İç parıltı (animasyonlu)
                  BoxShadow(
                    color: _currentTheme.accentColor.withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                  // Neon efekt 3 - Merkez ışıltı (animasyonlu)
                  BoxShadow(
                    color: _currentTheme.accentColor.withOpacity(0.8),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                  // Ekstra neon halka (animasyonlu)
                  BoxShadow(
                    color: _currentTheme.accentColor.withOpacity(0.3),
                    blurRadius: 60,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  zikrText,
                  style: _getZikrButtonTextStyle(),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
          ),
        ),
        
        Positioned(
          bottom: -10,
          right: -10,
          child: Semantics(
            label: _localizations.resetCounter,
            child: GestureDetector(
              onTap: _resetCounter,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE74C3C).withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlButton(
            icon: Icons.insert_chart_rounded,
            isActive: true,
            onTap: () {
              _pushWithNeonPause(
                context,
                MaterialPageRoute(
                  builder: (context) => StatisticsScreenNew(
                    themeConfig: _currentTheme,
                    localizations: _localizations,
                    currentUserId: _currentUserId,
                  ),
                ),
              );
            },
            size: 48,
          ),
          const SizedBox(width: 6),
          _buildControlButton(
            icon: Icons.leaderboard_rounded,
            isActive: true,
            onTap: () {
              _pushWithNeonPause(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaderboardScreen(
                    themeConfig: _currentTheme,
                    localizations: _localizations,
                    currentUserId: _currentUserId,
                  ),
                ),
              );
            },
            size: 48,
          ),
          const SizedBox(width: 6),
          _buildControlButton(
            icon: Icons.emoji_events_rounded,
            isActive: true,
            onTap: () {
              _pushWithNeonPause(
                context,
                MaterialPageRoute(
                  builder: (context) => KupaScreenNew(
                    themeConfig: _currentTheme,
                    localizations: _localizations,
                    currentUserId: _currentUserId,
                    currentZikrCount: _counter, // Mevcut zikir sayısını geç
                  ),
                ),
              );
            },
            size: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? _currentTheme.accentColor.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          border: Border.all(
            color: isActive
                ? _currentTheme.accentColor.withOpacity(0.5)
                : Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? _currentTheme.accentColor : Colors.white70,
          size: size * 0.5,
        ),
      ),
    );
  }

  // Batch sync metotları
  void _startBatchSync() {
    _batchSyncTimer?.cancel();
    debugPrint('⏸️ Batch cloud sync disabled by policy');
  }

  void _stopBatchSync() {
    _batchSyncTimer?.cancel();
    debugPrint('⏹️ Batch sync stopped');
  }

  Future<void> _batchSyncToLeaderboard() async {
    // Policy gereği HomePage tarafından cloud sync tetiklenmez.
    return;
  }
}
