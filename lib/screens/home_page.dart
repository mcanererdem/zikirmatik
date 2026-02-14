import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/zikr_model.dart';
import '../models/theme_model.dart';
import '../services/settings_service.dart';
import '../services/ad_service.dart';
import '../services/widget_service.dart';
import '../utils/localizations.dart';
import '../widgets/confetti_animation.dart';
import '../widgets/success_dialog.dart';
import '../widgets/target_dialog.dart';
import '../widgets/zikr_selection_dialog.dart';
import '../widgets/add_zikr_dialog.dart';
import '../widgets/settings_dialog.dart';
import 'statistics_screen.dart';
import '../widgets/reminder_dialog.dart';

class HomePage extends StatefulWidget {
  final Function(ThemeMode)? onThemeModeChanged;
  
  const HomePage({super.key, this.onThemeModeChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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
  final AdService _adService = AdService(); // YENİ
  BannerAd? _bannerAd; // YENİ
  bool _isBannerAdLoaded = false; // YENİ
  
  final List<AudioPlayer> _audioPlayers = [];
  int _currentPlayerIndex = 0;
  final int _maxPlayers = 5;
  
  final List<ZikrModel> _defaultZikrs = DefaultZikrs.zikrs;
  List<ZikrModel> _customZikrs = [];
  ZikrModel? _selectedZikr;
  
  ThemeConfig _currentTheme = AppThemes.themes[0];
  String _currentLanguage = 'en';
  late AppLocalizations _localizations;

  @override
  void initState() {
    super.initState();
    _localizations = AppLocalizations('en');
    _loadSettings();
    _initAudio();
    // Ensure MobileAds initialized before loading banners to improve reliability.
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
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _counterScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _counterAnimationController,
        curve: Curves.easeOut,
      ),
    );
  }

  // YENİ: Banner reklam yükle
  Future<void> _loadBannerAd() async {
    await _adService.loadBannerAd(
      onAdLoaded: (ad) {
        setState(() {
          _bannerAd = ad;
          _isBannerAdLoaded = true;
        });
      },
      onAdFailedToLoad: (error) {
        print('Banner ad failed to load: $error');
        setState(() {
          _isBannerAdLoaded = false;
        });
      },
    );
  }

  Future<void> _initAudio() async {
    for (int i = 0; i < _maxPlayers; i++) {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(1.0);
      _audioPlayers.add(player);
    }
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

    setState(() {
      _currentTheme = AppThemes.getTheme(themeId);
      _currentLanguage = languageCode;
      _localizations = AppLocalizations(languageCode);
      _isVibrationOn = vibration;
      _isSoundOn = sound;
      _isConfettiOn = confetti;
      _customZikrs = customZikrs;
      _counter = savedCount;
      
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
    _buttonAnimationController.dispose();
    _counterAnimationController.dispose();
    
    for (var player in _audioPlayers) {
      player.dispose();
    }
    
    _bannerAd?.dispose(); // YENİ: Reklam dispose
    
    super.dispose();
  }

  Future<void> _playSound() async {
    if (_isSoundOn) {
      try {
        final player = _audioPlayers[_currentPlayerIndex];
        await player.stop();
        await player.play(AssetSource('sounds/click.mp3'));
        _currentPlayerIndex = (_currentPlayerIndex + 1) % _maxPlayers;
      } catch (e) {
        try {
          await SystemSound.play(SystemSoundType.click);
        } catch (e2) {
          // Sessizce devam et
        }
      }
    }
  }

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });

    // Sayacı kaydet
    await _settingsService.saveCurrentCount(_counter);
    await _settingsService.updateStreak();
    await WidgetService.updateWidget(_counter);

    final today = DateTime.now();
    await _settingsService.saveDailyCount(today, _counter);
    await _settingsService.incrementTotalCount(1);

    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });
    
    _counterAnimationController.forward().then((_) {
      _counterAnimationController.reverse();
    });

    // Her tıklamada ses ve titreşim (ayarlar açıksa)
    if (_isSoundOn) {
      _playSound();
    }

    if (_isVibrationOn) {
      try {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          Vibration.vibrate(duration: 50);
        } else {
          HapticFeedback.lightImpact();
        }
      } catch (e) {
        HapticFeedback.lightImpact();
      }
    }

    if (_counter == _target) {
      _showSuccessAnimation();
    }
  }

  void _showSuccessAnimation() {
    // Titreşim açıksa hedef titreşimi
    if (_isVibrationOn) {
      _vibrateSuccess();
    }

    // Ses açıksa hedef sesi
    if (_isSoundOn) {
      _playSuccessSound();
    }

    // Konfeti açıksa konfeti + dialog
    if (_isConfettiOn) {
      setState(() {
        _showConfetti = true;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
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
          );
        }
      });
    }
  }

  Future<void> _vibrateSuccess() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 100);
        await Future.delayed(const Duration(milliseconds: 150));
        Vibration.vibrate(duration: 100);
      } else {
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _playSuccessSound() async {
    try {
      final player = _audioPlayers[0];
      await player.play(AssetSource('sounds/click.mp3'));
      await Future.delayed(const Duration(milliseconds: 200));
      await player.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (e2) {}
    }
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
      _showConfetti = false;
    });
    _settingsService.saveCurrentCount(0);
    WidgetService.updateWidget(0);
    
    if (_isVibrationOn) {
      HapticFeedback.mediumImpact();
    }
  }

  // GÜNCELLENMİŞ: Hedef değiştiğinde zikr listesinde de güncelle
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
    setState(() {
      _isVibrationOn = !_isVibrationOn;
    });
    _settingsService.saveVibration(_isVibrationOn);
    
    if (_isVibrationOn) {
      HapticFeedback.mediumImpact();
    }
  }

  void _toggleSound() {
    setState(() {
      _isSoundOn = !_isSoundOn;
    });
    _settingsService.saveSound(_isSoundOn);
    
    if (_isSoundOn) {
      _playSound();
    }
  }

  void _toggleConfetti() {
    setState(() {
      _isConfettiOn = !_isConfettiOn;
    });
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
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
                                  const SizedBox(height: 40),
                                  _buildBottomControls(),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Banner area - always reserve space so we can see placeholder when
                  // ad isn't loaded yet (helps debugging on devices where ads fail).
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: _currentTheme.goldGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _currentTheme.accentColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    _localizations.appName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Semantics(
            label: _localizations.changeTarget,
            child: _buildControlButton(
              icon: Icons.flag_rounded,
              isActive: true,
              onTap: _changeTarget,
            ),
          ),
          Semantics(
            label: 'Reminder',
            child: _buildControlButton(
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
            ),
          ),
          Semantics(
            label: _isVibrationOn ? _localizations.vibrationOn : _localizations.vibrationOff,
            child: _buildControlButton(
              icon: _isVibrationOn ? Icons.vibration : Icons.phone_android,
              isActive: _isVibrationOn,
              onTap: _toggleVibration,
            ),
          ),
          Semantics(
            label: _isSoundOn ? _localizations.soundOn : _localizations.soundOff,
            child: _buildControlButton(
              icon: _isSoundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              isActive: _isSoundOn,
              onTap: _toggleSound,
            ),
          ),
          Semantics(
            label: _isConfettiOn ? _localizations.confettiOn : _localizations.confettiOff,
            child: _buildControlButton(
              icon: Icons.celebration_rounded,
              isActive: _isConfettiOn,
              onTap: _toggleConfetti,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
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
          size: 28,
        ),
      ),
    );
  }
}