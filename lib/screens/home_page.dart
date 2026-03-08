import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/theme_model.dart';
import '../models/user_profile_model.dart';
import '../utils/localizations.dart';
import '../services/settings_service.dart';
import '../services/supabase_service.dart';
import '../services/audio_manager.dart';
import '../services/feedback_manager.dart';
import '../services/notification_service.dart';
import '../services/tts_service.dart';
import '../services/widget_service.dart';
import '../models/zikr_model.dart';
import '../models/goal_model.dart';
import '../services/counter_logic.dart';
import '../services/ad_service.dart';
import '../utils/dialog_manager.dart';
import '../utils/random_name_generator.dart';
import 'dart:async';
import 'dart:math';
import '../widgets/settings_dialog_new.dart';
import '../widgets/zikr_selection_dialog.dart';
import '../widgets/target_dialog.dart';
import '../widgets/success_dialog.dart';
import '../widgets/goal_dialog.dart';
import '../widgets/add_zikr_dialog.dart';
import '../widgets/notification_settings_dialog.dart';
import '../widgets/confetti_animation.dart';
import 'kupa_screen_new.dart';
import 'statistics_screen_new.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';
import 'settings_screen.dart';
import 'splash_screen.dart';

class HomePage extends StatefulWidget {
  final Function(ThemeMode)? onThemeModeChanged;
  
  const HomePage({super.key, this.onThemeModeChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin, WidgetsBindingObserver {
  int _counter = 0;
  int _target = 100;
  bool _isVibrationOn = true;
  bool _isSoundOn = true;
  bool _isConfettiOn = true;
  bool _isReminderEnabled = false;
  bool _showConfetti = false;

  late AnimationController _buttonAnimationController;
  late AnimationController _counterAnimationController;
  late AnimationController _neonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _counterScaleAnimation;
  late Animation<double> _neonPulseAnimation;

  final SettingsService _settingsService = SettingsService();
  final AdService _adService = AdService();
  final CounterLogic _counterLogic = CounterLogic();
  final AudioManager _audioManager = AudioManager();
  final FeedbackManager _feedbackManager = FeedbackManager();
  final SupabaseService _supabaseService = SupabaseService();
  
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  
  final List<ZikrModel> _defaultZikrs = DefaultZikrs.zikrs;
  List<ZikrModel> _customZikrs = [];
  ZikrModel? _selectedZikr;
  
  ThemeConfig _currentTheme = AppThemes.getTheme('dark_blue');
  String _currentLanguage = 'en';
  String _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
  late AppLocalizations _localizations;
  List<Goal> _goals = [];
  Map<String, dynamic>? _lastStreakInfo;
  bool _isTtsOn = false;
  final TtsService _ttsService = TtsService();

  BoxDecoration _buildBackgroundDecoration() {
    final isLightTheme = _currentTheme.textColor.computeLuminance() < 0.5;
    final asset = isLightTheme ? _currentTheme.lightBackgroundAsset : _currentTheme.darkBackgroundAsset;
    return BoxDecoration(
      gradient: _currentTheme.backgroundGradient,
      image: asset != null
          ? DecorationImage(
              image: AssetImage(asset),
              fit: BoxFit.cover,
              opacity: 0.18,
            )
          : null,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _localizations = AppLocalizations('en');
    
    // Dialog durumlarını sıfırla (uygulama başladığında)
    DialogManager.resetAllStates();
    
    // Rastgele kullanıcı ismi oluştur
    _generateUserId();
    
    // Supabase'i başlat
    _supabaseService.initialize();
    
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
    final savedUserId = prefs.getString('user_id');
    
    if (savedUserId != null && savedUserId!.isNotEmpty) {
      _currentUserId = savedUserId;
      print('👤 Existing user ID loaded: $_currentUserId');
    } else {
      // Rastgele isim oluştur
      final randomUsername = await RandomNameGenerator.generateRandomUsername();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentUserId = '${randomUsername}_$timestamp';
      
      // Kaydet
      await prefs.setString('user_id', _currentUserId);
      print('🎲 New random user ID generated: $_currentUserId');
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
    await WidgetService.syncWidgetCounter();
    final themeId = await _settingsService.getTheme();
    final languageCode = await _settingsService.getLanguage();
    final vibration = await _settingsService.getVibration();
    final sound = await _settingsService.getSound();
    final confetti = await _settingsService.getConfetti();
    final ttsEnabled = await _settingsService.getTtsEnabled();
    final customZikrs = await _settingsService.getCustomZikrs();
    final selectedZikrId = await _settingsService.getSelectedZikr();
    final savedCount = await _settingsService.getCurrentCount();
    final goals = await _settingsService.getGoals();
    final reminderEnabled = await _settingsService.getReminderEnabled();
    await _settingsService.cleanExpiredGoals();
    
    // Animasyon hızını yükle
    final prefs = await SharedPreferences.getInstance();
    final animationSpeed = prefs.getInt('animation_speed') ?? 0;

    setState(() {
      _currentTheme = AppThemes.getTheme(themeId);
      _currentLanguage = languageCode;
      _localizations = AppLocalizations(languageCode);
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
      
      if (selectedZikrId != null) {
        _selectedZikr = _defaultZikrs.firstWhere(
          (z) => z.id == selectedZikrId,
          orElse: () => _customZikrs.firstWhere(
            (z) => z.id == selectedZikrId,
            orElse: () => _defaultZikrs[0],
          ),
        );
      } else {
        _selectedZikr = _defaultZikrs[0];
      }
      
      _target = _selectedZikr!.defaultCount;
    });
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
    
    // Dialog durumlarını temizle
    DialogManager.resetAllStates();
    
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await WidgetService.syncWidgetCounter();
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
    await _counterLogic.incrementCounter(_counter, _selectedZikr?.id);
    
    // Local storage'a kaydet
    final prefs = await SharedPreferences.getInstance();
    final totalZikrs = prefs.getInt('total_zikrs_$_currentUserId') ?? 0;
    await prefs.setInt('total_zikrs_$_currentUserId', totalZikrs + 1);
    await prefs.setString('last_zikr_date_$_currentUserId', DateTime.now().toIso8601String());
    
    print('Zikir count saved locally: ${totalZikrs + 1}');
    
    // Supabase'e senkronize et
    try {
      await _supabaseService.updateUserZikrCount(_currentUserId, totalZikrs + 1);
      print('Zikir count synced to Supabase: ${totalZikrs + 1}');
    } catch (e) {
      print('Error syncing to Supabase: $e');
    }
    
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

    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });
    
    _counterAnimationController.forward().then((_) => _counterAnimationController.reverse());

    if (_isSoundOn) _audioManager.playClick();
    if (_isVibrationOn) _feedbackManager.vibrateLight();

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
          duration: const Duration(seconds: 4),
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
      final username = prefs.getString('username_$_currentUserId') ?? 'user';
      final displayName = prefs.getString('display_name_$_currentUserId') ?? username;
      final avatarUrl = prefs.getString('avatar_url_$_currentUserId');

      // Supabase'e profil oluştur/güncelle
      final userProfile = UserProfile(
        userId: _currentUserId,
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
      await _supabaseService.updateDailyLeaderboard(_currentUserId, totalZikrs);
      await _supabaseService.updateWeeklyLeaderboard(_currentUserId, totalZikrs);
      await _supabaseService.updateMonthlyLeaderboard(_currentUserId, totalZikrs);

      print('✅ Auto-sync to leaderboard: $username ($totalZikrs zikrs)');
    } catch (e) {
      print('❌ Error auto-syncing to leaderboard: $e');
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
        print('📅 Daily achievements reset for $todayKey');
      }
      
      final totalZikrs = prefs.getInt('total_zikrs_$_currentUserId') ?? 0;
      
      print('Checking achievements for $totalZikrs zikrs');
      
      // Leaderboard senkronizasyonu kontrolü
      final leaderboardEnabled = prefs.getBool('leaderboard_enabled') ?? true;
      if (leaderboardEnabled) {
        // Her 50 zikirde bir leaderboard güncelle
        if (totalZikrs % 50 == 0) {
          await _syncToLeaderboard();
        }
        
        // Aktif sayaç değiştiğinde kupa güncelle
        final previousZikrs = prefs.getInt('previous_zikrs_${widget.currentUserId}') ?? 0;
        if (totalZikrs > previousZikrs) {
          await _syncToLeaderboard();
        }
        await prefs.setInt('previous_zikrs_${widget.currentUserId}', totalZikrs);
      }
      
      // Bronz Kupa - 100 zikir (kalıcı)
      if (totalZikrs >= 100) {
        final bronzeUnlocked = prefs.getBool('bronze_kupa_unlocked_$_currentUserId') ?? false;
        if (!bronzeUnlocked) {
          print('🥉 Bronze Kupa unlocked!');
          _showAchievementNotification('🥉 Bronz Kupa Kazandınız!', '100 zikir hedefine ulaştınız!');
          await prefs.setBool('bronze_kupa_unlocked_$_currentUserId', true);
          // Supabase'e kaydet
          try {
            await _supabaseService.unlockAchievement(_currentUserId, 'bronze_kupa');
          } catch (e) {
            print('Error saving bronze achievement to Supabase: $e');
          }
        }
      }
      
      // Gümüş Kupa - 500 zikir (kalıcı)
      if (totalZikrs >= 500) {
        final silverUnlocked = prefs.getBool('silver_kupa_unlocked_$_currentUserId') ?? false;
        if (!silverUnlocked) {
          print('🥈 Silver Kupa unlocked!');
          _showAchievementNotification('🥈 Gümüş Kupa Kazandınız!', '500 zikir hedefine ulaştınız!');
          await prefs.setBool('silver_kupa_unlocked_$_currentUserId', true);
          // Supabase'e kaydet
          try {
            await _supabaseService.unlockAchievement(_currentUserId, 'silver_kupa');
          } catch (e) {
            print('Error saving silver achievement to Supabase: $e');
          }
        }
      }
      
      // Altın Kupa - 1000 zikir (kalıcı)
      if (totalZikrs >= 1000) {
        final goldUnlocked = prefs.getBool('gold_kupa_unlocked_$_currentUserId') ?? false;
        if (!goldUnlocked) {
          print('🥇 Gold Kupa unlocked!');
          _showAchievementNotification('🥇 Altın Kupa Kazandınız!', '1000 zikir hedefine ulaştınız!');
          await prefs.setBool('gold_kupa_unlocked_$_currentUserId', true);
          // Supabase'e kaydet
          try {
            await _supabaseService.unlockAchievement(_currentUserId, 'gold_kupa');
          } catch (e) {
            print('Error saving gold achievement to Supabase: $e');
          }
        }
      }
      
      // Elmas Kupa - 5000 zikir (kalıcı)
      if (totalZikrs >= 5000) {
        final diamondUnlocked = prefs.getBool('diamond_kupa_unlocked_$_currentUserId') ?? false;
        if (!diamondUnlocked) {
          print('💎 Diamond Kupa unlocked!');
          _showAchievementNotification('💎 Elmas Kupa Kazandınız!', '5000 zikir hedefine ulaştınız!');
          await prefs.setBool('diamond_kupa_unlocked_$_currentUserId', true);
          // Supabase'e kaydet
          try {
            await _supabaseService.unlockAchievement(_currentUserId, 'diamond_kupa');
          } catch (e) {
            print('Error saving diamond achievement to Supabase: $e');
          }
        }
      }
      
      // Platin Kupa - 10000 zikir (kalıcı)
      if (totalZikrs >= 10000) {
        final platinumUnlocked = prefs.getBool('platinum_kupa_unlocked_$_currentUserId') ?? false;
        if (!platinumUnlocked) {
          print('🏆 Platinum Kupa unlocked!');
          _showAchievementNotification('🏆 Platin Kupa Kazandınız!', '10000 zikir hedefine ulaştınız!');
          await prefs.setBool('platinum_kupa_unlocked_$_currentUserId', true);
          // Supabase'e kaydet
          try {
            await _supabaseService.unlockAchievement(_currentUserId, 'platinum_kupa');
          } catch (e) {
            print('Error saving platinum achievement to Supabase: $e');
          }
        }
      }
      
      // Günlük Savaşçı - 1000 zikir/gün (günlük)
      final todayZikrs = prefs.getInt('daily_count_${today.year}_${today.month}_${today.day}_$_currentUserId') ?? 0;
      if (todayZikrs >= 1000) {
        final dailyWarriorUnlocked = prefs.getBool('daily_warrior_unlocked_$_currentUserId') ?? false;
        if (!dailyWarriorUnlocked) {
          print('⚔️ Daily Warrior unlocked!');
          _showAchievementNotification('⚔️ Günlük Savaşçı!', 'Bugün 1000 zikir yaptınız!');
          await prefs.setBool('daily_warrior_unlocked_$_currentUserId', true);
          // Supabase'e kaydet
          try {
            await _supabaseService.unlockAchievement(_currentUserId, 'daily_warrior');
          } catch (e) {
            print('Error saving daily warrior achievement to Supabase: $e');
          }
        }
      }
      
    } catch (e) {
      print('Error checking achievements: $e');
    }
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
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ).closed.then((_) => DialogManager.onSnackbarHidden());
    }
  }

  // Kazanılmış kupaları getir
  Future<Map<String, bool>> _getUnlockedCups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'bronze_kupa': prefs.getBool('bronze_kupa_unlocked_$_currentUserId') ?? false,
        'silver_kupa': prefs.getBool('silver_kupa_unlocked_$_currentUserId') ?? false,
        'gold_kupa': prefs.getBool('gold_kupa_unlocked_$_currentUserId') ?? false,
        'diamond_kupa': prefs.getBool('diamond_kupa_unlocked_$_currentUserId') ?? false,
        'platinum_kupa': prefs.getBool('platinum_kupa_unlocked_$_currentUserId') ?? false,
      };
    } catch (e) {
      print('Error getting unlocked cups: $e');
      return {};
    }
  }

  // Kazanılmış en yüksek kupayı hesapla
  Future<String> _getHighestCup() async {
    final prefs = await SharedPreferences.getInstance();
    final totalZikrs = prefs.getInt('total_zikrs_$_currentUserId') ?? 0;
    
    if (totalZikrs >= 10000) return 'Platinum';
    if (totalZikrs >= 5000) return 'Diamond';
    if (totalZikrs >= 1000) return 'Gold';
    if (totalZikrs >= 500) return 'Silver';
    if (totalZikrs >= 100) return 'Bronze';
    return 'Yeni';
  }

  void _changeTarget() {
    showDialog(
      context: context,
      builder: (context) => TargetDialog(
        currentTarget: _target,
        onTargetChanged: (newTarget) {
          setState(() {
            _target = newTarget;
            
            // Seçili zikrin hedefini güncelle
            if (_selectedZikr != null) {
              // Default zikirse güncelleme
              final defaultIndex = _defaultZikrs.indexWhere((z) => z.id == _selectedZikr!.id);
              if (defaultIndex != -1) {
                _defaultZikrs[defaultIndex] = ZikrModel(
                  id: _selectedZikr!.id,
                  nameAr: _selectedZikr!.nameAr,
                  nameTr: _selectedZikr!.nameTr,
                  nameEn: _selectedZikr!.nameEn,
                  defaultCount: newTarget,
                );
                _selectedZikr = _defaultZikrs[defaultIndex];
              }
              
              // Custom zikirse güncelle
              final customIndex = _customZikrs.indexWhere((z) => z.id == _selectedZikr!.id);
              if (customIndex != -1) {
                _customZikrs[customIndex] = ZikrModel(
                  id: _selectedZikr!.id,
                  nameAr: _selectedZikr!.nameAr,
                  nameTr: _selectedZikr!.nameTr,
                  nameEn: _selectedZikr!.nameEn,
                  defaultCount: newTarget,
                );
                _selectedZikr = _customZikrs[customIndex];
                _settingsService.saveCustomZikrs(_customZikrs);
              }
            }
          });
        },
        themeConfig: _currentTheme,
        localizations: _localizations,
      ),
    );
  }

  void _selectZikr() {
    showDialog(
      context: context,
      builder: (context) => ZikrSelectionDialog(
        defaultZikrs: _defaultZikrs,
        customZikrs: _customZikrs,
        selectedZikr: _selectedZikr,
        currentLanguage: _currentLanguage,
        onZikrSelected: (zikr) {
          setState(() {
            _selectedZikr = zikr;
            _target = zikr.defaultCount;
            _counter = 0;
          });
          _settingsService.saveSelectedZikr(zikr.id);
          Navigator.pop(context);
        },
        onAddCustomZikr: _addCustomZikr,
        onDeleteZikr: _deleteCustomZikr,
        themeConfig: _currentTheme,
        localizations: _localizations,
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
            onPressed: () {
              setState(() {
                _customZikrs.removeWhere((z) => z.id == zikr.id);
                if (_selectedZikr?.id == zikr.id) {
                  _selectedZikr = _defaultZikrs[0];
                  _target = _selectedZikr!.defaultCount;
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

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          themeConfig: _currentTheme,
          localizations: _localizations,
          currentUserId: _currentUserId,
          onSettingsChanged: () {
            // Ayarlar değiştiğinde ana sayfayı güncelle
            _loadSettings();
          },
        ),
      ),
    );
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
    switch (_currentLanguage) {
      case 'ar':
        return zikr.nameAr;
      case 'en':
        return zikr.nameEn;
      default:
        return zikr.nameTr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final progress = _counter / _target;
    String zikrText = _selectedZikr?.nameAr ?? 'سُبْحَانَ اللّٰهِ';

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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      themeConfig: _currentTheme,
                      localizations: _localizations,
                      currentUserId: _currentUserId,
                    ),
                  ),
                );
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
                          'Zikir Çalışanı',
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
                            // Kazanılmış kupaları göster
                            FutureBuilder<Map<String, bool>>(
                              future: _getUnlockedCups(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final unlockedCups = snapshot.data!;
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (unlockedCups['bronze_kupa'] == true)
                                        Text('🥉', style: TextStyle(fontSize: 14)),
                                      if (unlockedCups['silver_kupa'] == true)
                                        Text('🥈', style: TextStyle(fontSize: 14)),
                                      if (unlockedCups['gold_kupa'] == true)
                                        Text('🥇', style: TextStyle(fontSize: 14)),
                                      if (unlockedCups['diamond_kupa'] == true)
                                        Text('💎', style: TextStyle(fontSize: 14)),
                                      if (unlockedCups['platinum_kupa'] == true)
                                        Text('🏆', style: TextStyle(fontSize: 14)),
                                    ],
                                  );
                                }
                                return Text('🎯', style: TextStyle(fontSize: 14));
                              },
                            ),
                            const SizedBox(width: 4),
                            FutureBuilder<String>(
                              future: _getHighestCup(),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? 'Yeni',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _currentTheme.textColor.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(
                        themeConfig: _currentTheme,
                        localizations: _localizations,
                        currentUserId: _currentUserId,
                        onSettingsChanged: () {
                          // Ayarlar değiştiğinde ana sayfayı güncelle
                          _loadSettings();
                        },
                      ),
                    ),
                  );
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
        child: Text(
          '$_counter',
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: _currentTheme.accentColor,
            letterSpacing: 2,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _currentTheme.textColor,
                  ),
                  textDirection: _currentLanguage == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                ),
                Text(
                  '${_localizations.target}: $_target',
                  style: TextStyle(
                    fontSize: 12,
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
                  style: (_currentLanguage == 'ar'
                      ? GoogleFonts.notoNaskhArabic(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: _currentTheme.accentColor.withOpacity(0.8),
                              blurRadius: 10,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        )
                      : GoogleFonts.notoSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: _currentTheme.accentColor.withOpacity(0.8),
                              blurRadius: 10,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        )),
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
            icon: Icons.bar_chart_rounded,
            isActive: true,
            onTap: () {
              Navigator.push(
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
              Navigator.push(
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
              Navigator.push(
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
}
