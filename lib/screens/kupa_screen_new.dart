import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';
import '../services/settings_service.dart';

class KupaScreenNew extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String currentUserId;
  final int currentZikrCount;

  const KupaScreenNew({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.currentUserId,
    this.currentZikrCount = 0,
  });

  @override
  State<KupaScreenNew> createState() => _KupaScreenNewState();
}

class _KupaScreenNewState extends State<KupaScreenNew> {
  int _totalZikrs = 0;
  List<Map<String, dynamic>> _allCups = [];
  Map<String, bool> _unlockedCups = {};
  String _nextCupName = '';
  int _nextCupRequirement = 0;
  bool _hasShownNotification = false;
  String _currentLanguage = 'tr'; // Dil değişkeni eklendi
  int _userLevel = 0;
  double _progressToNextCup = 0.0;
  DateTime? _lastCupUnlocked;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında hemen güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
    _loadZikrCount();
  }

  @override
  void didUpdateWidget(KupaScreenNew oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget güncellendiğinde (zikir sayısı değiştiğinde) veriyi yenile
    if (oldWidget.currentZikrCount != widget.currentZikrCount) {
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final totalZikrs = widget.currentZikrCount > 0 
          ? widget.currentZikrCount 
          : prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      
      // Dil bilgisini yükle
      final currentLanguage = prefs.getString('language') ?? 'tr';
      
      print('🔄 Kupa screen refreshing with zikr count: $totalZikrs');
      print('🌐 Kupa screen language: $currentLanguage');
      
      setState(() {
        _totalZikrs = totalZikrs;
        _currentLanguage = currentLanguage; // Dil güncelle
        
        // Kupaları yeniden hesapla
        _allCups = [
          {
            'id': 'bronze_kupa',
            'name': _getKupaName('bronze'),
            'icon': '🥉',
            'requirement': 100,
            'description': _getKupaDescription('bronze'),
            'color': Colors.brown,
            'unlocked': totalZikrs >= 100,
          },
          {
            'id': 'silver_kupa',
            'name': _getKupaName('silver'),
            'icon': '🥈',
            'requirement': 500,
            'description': _getKupaDescription('silver'),
            'color': Colors.grey,
            'unlocked': totalZikrs >= 500,
          },
          {
            'id': 'gold_kupa',
            'name': _getKupaName('gold'),
            'icon': '🥇',
            'requirement': 1000,
            'description': _getKupaDescription('gold'),
            'color': Colors.yellow,
            'unlocked': totalZikrs >= 1000,
          },
          {
            'id': 'diamond_kupa',
            'name': _getKupaName('diamond'),
            'icon': '💎',
            'requirement': 5000,
            'description': _getKupaDescription('diamond'),
            'color': Colors.blue,
            'unlocked': totalZikrs >= 5000,
          },
          {
            'id': 'platinum_kupa',
            'name': _getKupaName('platinum'),
            'icon': '🏆',
            'requirement': 10000,
            'description': _getKupaDescription('platinum'),
            'color': Colors.purple,
            'unlocked': totalZikrs >= 10000,
          },
        ];
      });
      
      // Sonraki kupa bilgisini hesapla
      _calculateNextCup();
      
      print('🏆 Unlocked cups: ${_allCups.where((cup) => cup['unlocked']).length}');
      print('🎯 Next cup: $_nextCupName (need $_nextCupRequirement)');
      
      // Kupa kazanma bildirimlerini kontrol et
      _checkForNewUnlocks();
      
    } catch (e) {
      print('Error refreshing kupa screen: $e');
    }
  }

  String _getTrophiesTitle() {
    return DynamicLocalizationHelper.getText({
      'tr': 'Kupalar',
      'en': 'Trophies',
      'ar': 'الكؤوس',
      'id': 'Piala',
    });
  }

  String _getKupaName(String type) {
    return DynamicLocalizationHelper.getText({
      'tr': {
        'bronze': 'Bronz Kupa',
        'silver': 'Gümüş Kupa',
        'gold': 'Altın Kupa',
        'diamond': 'Elmas Kupa',
        'platinum': 'Platin Kupa',
      }[type] ?? 'Kupa',
      'en': {
        'bronze': 'Bronze Cup',
        'silver': 'Silver Cup',
        'gold': 'Gold Cup',
        'diamond': 'Diamond Cup',
        'platinum': 'Platinum Cup',
      }[type] ?? 'Cup',
      'ar': {
        'bronze': 'كأس برونزي',
        'silver': 'كأس فضي',
        'gold': 'كأس ذهبي',
        'diamond': 'كأس ماسي',
        'platinum': 'كأس بلاتيني',
      }[type] ?? 'كأس',
      'id': {
        'bronze': 'Piala Perunggu',
        'silver': 'Piala Perak',
        'gold': 'Piala Emas',
        'diamond': 'Piala Berlian',
        'platinum': 'Piala Platinum',
      }[type] ?? 'Piala',
    });
  }

  String _getKupaDescription(String type) {
    return DynamicLocalizationHelper.getText({
      'tr': {
        'bronze': 'İlk 100 zikir için',
        'silver': '500 zikir için',
        'gold': '1000 zikir için',
        'diamond': '5000 zikir için',
        'platinum': '10000 zikir için',
      }[type] ?? 'Zikir için',
      'en': {
        'bronze': 'For first 100 dhikr',
        'silver': 'For 500 dhikr',
        'gold': 'For 1000 dhikr',
        'diamond': 'For 5000 dhikr',
        'platinum': 'For 10000 dhikr',
      }[type] ?? 'For dhikr',
      'ar': {
        'bronze': 'لأول 100 ذكر',
        'silver': 'لـ 500 ذكر',
        'gold': 'لـ 1000 ذكر',
        'diamond': 'لـ 5000 ذكر',
        'platinum': 'لـ 10000 ذكر',
      }[type] ?? 'للذكر',
      'id': {
        'bronze': 'Untuk 100 zikir pertama',
        'silver': 'Untuk 500 zikir',
        'gold': 'Untuk 1000 zikir',
        'diamond': 'Untuk 5000 zikir',
        'platinum': 'Untuk 10000 zikir',
      }[type] ?? 'Untuk zikir',
    });
  }

  void _checkForNewUnlocks() {
    // Sadece yeni kazanılan kupaları kontrol et
    for (var cup in _allCups) {
      if (cup['unlocked'] == true) {
        final wasUnlocked = _unlockedCups[cup['id']] ?? false;
        if (!wasUnlocked) {
          // Yeni kupa kazanıldı!
          _unlockedCups[cup['id']] = true;
          // Sadece ilk defa kazanılırsa bildirim göster
          if (mounted && !_hasShownNotification) {
            _showCupUnlockedNotification(cup);
            _hasShownNotification = true;
          }
        }
      }
    }
  }

  void _showCupUnlockedNotification(Map<String, dynamic> cup) {
    if (!mounted) return;
    
    String message = DynamicLocalizationHelper.getText({
      'tr': '🎉 Tebrikler! ${cup['name']} kazandınız!',
      'en': '🎉 Congratulations! You won ${cup['name']}!',
      'ar': '🎉 مبروك! لقد فزت بـ ${cup['name']}!',
      'id': '🎉 Selamat! Anda memenangkan ${cup['name']}!',
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              cup['icon'],
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _loadZikrCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final totalZikrs = widget.currentZikrCount > 0 
          ? widget.currentZikrCount 
          : prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      
      setState(() {
        _totalZikrs = totalZikrs;
      });
      
      // Tüm kupaları tanımla
      _allCups = [
        {
          'id': 'bronze_kupa',
          'name': 'Bronz Kupa',
          'icon': '🥉',
          'requirement': 100,
          'description': 'İlk 100 zikir için',
          'color': Colors.brown,
          'unlocked': totalZikrs >= 100,
        },
        {
          'id': 'silver_kupa',
          'name': 'Gümüş Kupa',
          'icon': '🥈',
          'requirement': 500,
          'description': '500 zikir için',
          'color': Colors.grey,
          'unlocked': totalZikrs >= 500,
        },
        {
          'id': 'gold_kupa',
          'name': 'Altın Kupa',
          'icon': '🥇',
          'requirement': 1000,
          'description': '1000 zikir için',
          'color': Colors.yellow,
          'unlocked': totalZikrs >= 1000,
        },
        {
          'id': 'diamond_kupa',
          'name': 'Elmas Kupa',
          'icon': '💎',
          'requirement': 5000,
          'description': '5000 zikir için',
          'color': Colors.blue,
          'unlocked': totalZikrs >= 5000,
        },
        {
          'id': 'platinum_kupa',
          'name': 'Platin Kupa',
          'icon': '🏆',
          'requirement': 10000,
          'description': '10000 zikir için',
          'color': Colors.purple,
          'unlocked': totalZikrs >= 10000,
        },
      ];
      
      // Sonraki kupa bilgisini hesapla
      _calculateNextCup();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading zikr count: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateNextCup() {
    String nextCup = '';
    int nextRequirement = 0;
    double progress = 0.0;
    
    for (final cup in _allCups) {
      if (!cup['unlocked']) {
        nextCup = cup['name'];
        nextRequirement = cup['requirement'];
        progress = _totalZikrs / nextRequirement;
        break;
      }
    }
    
    // Kalan zikir sayısını hesapla
    final remainingForNext = nextRequirement - _totalZikrs;
    
    setState(() {
      _nextCupName = nextCup;
      _nextCupRequirement = remainingForNext;
      _progressToNextCup = progress.clamp(0.0, 1.0);
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
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.themeConfig.accentColor,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Row(
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
                          _getTrophiesTitle(),
                          style: GoogleFonts.notoSans(
                            color: widget.themeConfig.textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // Refresh butonu kaldırıldı
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Sonraki Kupa İlerlemesi
                    _buildNextCupProgress(),
                    
                    const SizedBox(height: 20),
                    
                    // Kupalar Grid
                    _buildCupsGrid(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildNextCupProgress() {
    if (_nextCupName.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tüm kupaları kazandınız!',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tebrikler! Zikir ustası oldunuz.',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sonraki Kupa: $_nextCupName',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _progressToNextCup,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Kalan: $_nextCupRequirement zikir',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCupsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0, // 1.0'dan 1.2'ye değiştirdik
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _allCups.length,
      itemBuilder: (context, index) {
        final cup = _allCups[index];
        final isUnlocked = cup['unlocked'] as bool;
        
        return Container(
          decoration: BoxDecoration(
            color: isUnlocked 
                ? (cup['color'] as Color).withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnlocked 
                  ? (cup['color'] as Color).withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                cup['icon'] as String,
                style: const TextStyle(fontSize: 40), // 48'den 40'a düşürdük
              ),
              const SizedBox(height: 6), // 8'den 6'ya düşürdük
              Text(
                cup['name'] as String,
                style: GoogleFonts.notoSans(
                  fontSize: 12, // 14'ten 12'ye düşürdük
                  fontWeight: FontWeight.w600,
                  color: isUnlocked 
                      ? Colors.white
                      : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2), // 4'ten 2'ye düşürdük
              Text(
                cup['description'] as String,
                style: GoogleFonts.notoSans(
                  fontSize: 8, // 10'den 8'e düşürdük
                  color: isUnlocked 
                      ? Colors.white.withOpacity(0.8)
                      : Colors.grey.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 1, // maxLines: 1 ekledik
                overflow: TextOverflow.ellipsis, // overflow ekle
              ),
              const SizedBox(height: 4), // 8'den 4'e düşürdük
              if (isUnlocked)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16, // 20'den 16'ya düşürdük
                )
              else
                Icon(
                  Icons.lock,
                  color: Colors.grey,
                  size: 16, // 20'den 16'ya düşürdük
                ),
            ],
          ),
        );
      },
    );
  }
}
