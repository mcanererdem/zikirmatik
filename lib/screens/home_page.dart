import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/zikr_model.dart';
import '../models/theme_model.dart';
import '../models/goal_model.dart';
import '../services/settings_service.dart';
import '../services/ad_service.dart';
import '../services/counter_logic.dart';
import '../services/audio_manager.dart';
import '../services/feedback_manager.dart';
import '../services/widget_service.dart';
import '../utils/localizations.dart';
import '../widgets/confetti_animation.dart';
import '../widgets/success_dialog.dart';
import '../widgets/target_dialog.dart';
import '../widgets/zikr_selection_dialog.dart';
import '../widgets/add_zikr_dialog.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/goal_dialog.dart';
import '../widgets/reminder_dialog.dart';
import 'statistics_screen.dart';

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
  bool _showConfetti = false;

  late AnimationController _buttonAnimationController;
  late AnimationController _counterAnimationController;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _counterScaleAnimation;

  final SettingsService _settingsService = SettingsService();
  final AdService _adService = AdService();
  final CounterLogic _counterLogic = CounterLogic();
  final AudioManager _audioManager = AudioManager();
  final FeedbackManager _feedbackManager = FeedbackManager();
  
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  
  final List<ZikrModel> _defaultZikrs = DefaultZikrs.zikrs;
  List<ZikrModel> _customZikrs = [];
  ZikrModel? _selectedZikr;
  
  ThemeConfig _currentTheme = AppThemes.themes[0];
  String _currentLanguage = 'en';
  late AppLocalizations _localizations;
  List<Goal> _goals = [];
  Map<String, dynamic>? _lastStreakInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _localizations = AppLocalizations('en');
    _loadSettings();
    _audioManager.initialize();
    _syncWidgetCounter();
    MobileAds.instance.initialize().then((_) {
      _loadBannerAd();
    });
    
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _counterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _counterScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _counterAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _syncWidgetCounter() async {
    final widgetCounter = await WidgetService.getWidgetCounter();
    final appCounter = await _settingsService.getCurrentCount();
    
    print('Initial sync - Widget: $widgetCounter, App: $appCounter');
    
    if (widgetCounter != appCounter) {
      setState(() => _counter = widgetCounter);
      await _settingsService.saveCurrentCount(widgetCounter);
      print('Synced to: $widgetCounter');
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
    final themeId = await _settingsService.getTheme();
    final languageCode = await _settingsService.getLanguage();
    final vibration = await _settingsService.getVibration();
    final sound = await _settingsService.getSound();
    final confetti = await _settingsService.getConfetti();
    final customZikrs = await _settingsService.getCustomZikrs();
    final selectedZikrId = await _settingsService.getSelectedZikr();
    final savedCount = await _settingsService.getCurrentCount();
    final goals = await _settingsService.getGoals();
    await _settingsService.cleanExpiredGoals();

    setState(() {
      _currentTheme = AppThemes.getTheme(themeId);
      _currentLanguage = languageCode;
      _localizations = AppLocalizations(languageCode);
      _isVibrationOn = vibration;
      _isSoundOn = sound;
      _isConfettiOn = confetti;
      _customZikrs = customZikrs;
      _counter = savedCount;
      _goals = goals;
      
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _buttonAnimationController.dispose();
    _counterAnimationController.dispose();
    _audioManager.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await Future.delayed(const Duration(milliseconds: 300));
      final widgetCounter = await WidgetService.getWidgetCounter();
      
      print('=== WIDGET SYNC ===');
      print('Widget counter: $widgetCounter');
      print('App counter before sync: $_counter');
      
      if (widgetCounter != _counter) {
        print('Syncing: updating app counter from $_counter to $widgetCounter');
        setState(() => _counter = widgetCounter);
        await _settingsService.saveCurrentCount(widgetCounter);
        print('Sync complete: $_counter');
      } else {
        print('No sync needed, counters match');
      }
    }
  }

  void _incrementCounter() async {
    setState(() => _counter++);

    await _counterLogic.incrementCounter(_counter, _selectedZikr?.id);
    await WidgetService.updateWidget(_counter);
    final result = await _counterLogic.updateGoalProgress(_goals, _selectedZikr?.id);
    
    final updatedGoals = result['goals'] as List<Goal>;
    final streakInfo = result['streakInfo'] as Map<String, dynamic>?;
    final goalType = result['goalType'] as String?;
    
    for (var goal in updatedGoals) {
      final oldGoal = _goals.firstWhere((g) => g.id == goal.id, orElse: () => goal);
      if (!oldGoal.isCompleted && goal.isCompleted) {
        _showGoalCompletedNotification(goal, streakInfo, goalType);
      }
    }
    setState(() {
      _goals = updatedGoals;
      if (streakInfo != null) {
        _lastStreakInfo = streakInfo;
      }
    });

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
    String message = '${_localizations.goalCompleted} ${goal.targetCount}';
    
    if (streakInfo != null && streakInfo['streak'] > 1) {
      final streak = streakInfo['streak'];
      final typeLabel = goalType == 'daily' ? _localizations.dailyGoal :
                       goalType == 'weekly' ? _localizations.weeklyGoal :
                       _localizations.monthlyGoal;
      message += '\n🔥 $streak ${typeLabel} ${_localizations.translate('streak_continues') ?? 'streak!'}';
      
      if (streakInfo['isNewBest'] == true) {
        message += '\n🏆 ${_localizations.translate('new_record') ?? 'New record!'}';
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _currentTheme.accentColor,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessAnimation() {
    if (_isVibrationOn) _feedbackManager.vibrateSuccess();
    if (_isSoundOn) _audioManager.playSuccess();

    if (_isConfettiOn) {
      setState(() => _showConfetti = true);

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
          streakInfo: _lastStreakInfo,
        ),
      );
    }
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
      _showConfetti = false;
    });
    _counterLogic.resetCounter();
    WidgetService.updateWidget(0);
    if (_isVibrationOn) _feedbackManager.vibrateMedium();
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
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        currentTheme: _currentTheme,
        currentLanguage: _currentLanguage,
        onThemeChanged: (theme) {
          setState(() {
            _currentTheme = theme;
          });
          _settingsService.saveTheme(theme.id);
          Navigator.pop(context);
        },
        onLanguageChanged: (languageCode) {
          setState(() {
            _currentLanguage = languageCode;
            _localizations = AppLocalizations(languageCode);
          });
          _settingsService.saveLanguage(languageCode);
          Navigator.pop(context);
        },
        onThemeModeChanged: (mode) {
          widget.onThemeModeChanged?.call(mode);
          _settingsService.saveThemeMode(mode == ThemeMode.light ? 'light' : mode == ThemeMode.dark ? 'dark' : 'system');
        },
        localizations: _localizations,
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: _currentTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Ana içerik
                  Expanded(
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
                  
                  Container(
                    width: double.infinity,
                    height: (_bannerAd?.size.height ?? AdSize.banner.height).toDouble(),
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
                        ? Center(
                            child: AdWidget(ad: _bannerAd!),
                          )
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
            ),
            
            if (_showConfetti)
              ConfettiAnimation(
                onComplete: () {
                  setState(() {
                    _showConfetti = false;
                  });
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
          Expanded(
            child: Text(
              _localizations.appName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StatisticsScreen(
                        themeConfig: _currentTheme,
                        localizations: _localizations,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _openSettings,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
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
          color: Colors.white.withOpacity(0.1),
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
            color: Colors.white.withOpacity(0.2),
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
          color: Colors.white.withOpacity(0.1),
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textDirection: _currentLanguage == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                ),
                Text(
                  '${_localizations.target}: $_target',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
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
        ScaleTransition(
          scale: _buttonScaleAnimation,
          child: Semantics(
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
                    BoxShadow(
                      color: _currentTheme.primaryColor.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: _currentTheme.accentColor.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    zikrText,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
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
            icon: Icons.flag_rounded,
            isActive: true,
            onTap: _changeTarget,
            size: 48,
          ),
          const SizedBox(width: 6),
          _buildControlButton(
            icon: Icons.emoji_events_rounded,
            isActive: _goals.any((g) => !g.isCompleted && !g.isExpired()),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => GoalDialog(
                  themeConfig: _currentTheme,
                  localizations: _localizations,
                  currentGoals: _goals,
                  availableZikrs: [..._defaultZikrs, ..._customZikrs],
                  currentLanguage: _currentLanguage,
                  onGoalSet: (goal) async {
                    final updatedGoals = [..._goals, goal];
                    await _settingsService.saveGoals(updatedGoals);
                    setState(() => _goals = updatedGoals);
                  },
                ),
              );
            },
            size: 48,
          ),
          const SizedBox(width: 6),
          _buildControlButton(
            icon: Icons.notifications_rounded,
            isActive: true,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => ReminderDialog(
                  themeConfig: _currentTheme,
                  localizations: _localizations,
                ),
              );
            },
            size: 48,
          ),
          const SizedBox(width: 6),
          _buildControlButton(
            icon: _isVibrationOn ? Icons.vibration : Icons.phone_android,
            isActive: _isVibrationOn,
            onTap: _toggleVibration,
            size: 48,
          ),
          const SizedBox(width: 6),
          _buildControlButton(
            icon: _isSoundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            isActive: _isSoundOn,
            onTap: _toggleSound,
            size: 48,
          ),
          const SizedBox(width: 6),
          _buildControlButton(
            icon: Icons.celebration_rounded,
            isActive: _isConfettiOn,
            onTap: _toggleConfetti,
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