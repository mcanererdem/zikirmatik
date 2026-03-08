import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import 'dart:math';

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
  bool _isLoading = true;
  Map<String, bool> _unlockedCups = {};
  
  // Yeni özellikler
  List<Map<String, dynamic>> _allCups = [];
  int _userLevel = 0;
  double _progressToNextCup = 0.0;
  String _nextCupName = '';
  int _nextCupRequirement = 0;
  DateTime? _lastCupUnlocked;

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında hemen güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
    _loadZikrCount();
  }

  Future<void> _refreshData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final totalZikrs = widget.currentZikrCount > 0 
          ? widget.currentZikrCount 
          : prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      
      setState(() {
        _totalZikrs = totalZikrs;
      });
      
      // Kupaları yeniden hesapla
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
      
      print('🔄 Kupa screen refreshed with zikr count: $totalZikrs');
    } catch (e) {
      print('Error refreshing kupa screen: $e');
    }
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

  int _calculateUserLevel(int totalZikrs) {
    if (totalZikrs >= 50000) return 6;
    if (totalZikrs >= 10000) return 5;
    if (totalZikrs >= 5000) return 4;
    if (totalZikrs >= 1000) return 3;
    if (totalZikrs >= 500) return 2;
    if (totalZikrs >= 100) return 1;
    return 0;
  }

  String _getUserLevelTitle(int level) {
    switch (level) {
      case 0: return 'Yeni Başlayan';
      case 1: return 'Bronz Zikir Çeken';
      case 2: return 'Gümüş Zikir Çeken';
      case 3: return 'Altın Zikir Çeken';
      case 4: return 'Platin Zikir Çeken';
      case 5: return 'Elmas Zikir Çeken';
      case 6: return 'Zikir Ustası';
      default: return 'Bilinmeyen Seviye';
    }
  }

  Color _getUserLevelColor(int level) {
    switch (level) {
      case 0: return Colors.grey;
      case 1: return Colors.brown;
      case 2: return Colors.grey;
      case 3: return Colors.yellow;
      case 4: return Colors.blueGrey;
      case 5: return Colors.cyan;
      case 6: return Colors.purple;
      default: return Colors.grey;
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
                          'Kupalar',
                          style: GoogleFonts.notoSans(
                            color: widget.themeConfig.textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _refreshData,
                          icon: Icon(
                            Icons.refresh,
                            color: widget.themeConfig.textColor,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Kullanıcı Seviyesi Kartı
                    _buildUserLevelCard(),
                    
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

  Widget _buildUserLevelCard() {
    final level = _calculateUserLevel(_totalZikrs);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getUserLevelColor(level).withOpacity(0.2),
            _getUserLevelColor(level).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getUserLevelColor(level).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seviye $level',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getUserLevelTitle(level),
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
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
            'Kalan: $_nextCupirRequirement zikir',
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
