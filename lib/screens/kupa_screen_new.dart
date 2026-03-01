import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../services/supabase_service.dart';
import 'dart:math';

class KupaScreenNew extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String currentUserId;

  const KupaScreenNew({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.currentUserId,
  });

  @override
  State<KupaScreenNew> createState() => _KupaScreenNewState();
}

class _KupaScreenNewState extends State<KupaScreenNew> {
  final SupabaseService _supabaseService = SupabaseService();
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
    _loadZikrCount();
  }

  Future<void> _loadZikrCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final totalZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      
      // Tüm kupaları tanımla
      _allCups = [
        {
          'id': 'bronze_kupa',
          'name': 'Bronz Kupa',
          'icon': '🥉',
          'requirement': 100,
          'description': 'İlk 100 zikir için',
          'color': Colors.brown,
          'unlocked': false,
        },
        {
          'id': 'silver_kupa',
          'name': 'Gümüş Kupa',
          'icon': '🥈',
          'requirement': 500,
          'description': '500 zikir için',
          'color': Colors.grey,
          'unlocked': false,
        },
        {
          'id': 'gold_kupa',
          'name': 'Altın Kupa',
          'icon': '🥇',
          'requirement': 1000,
          'description': '1000 zikir için',
          'color': Colors.yellow,
          'unlocked': false,
        },
        {
          'id': 'platinum_kupa',
          'name': 'Platin Kupa',
          'icon': '🏆',
          'requirement': 5000,
          'description': '5000 zikir için',
          'color': Colors.blueGrey,
          'unlocked': false,
        },
        {
          'id': 'diamond_kupa',
          'name': 'Elmas Kupa',
          'icon': '💎',
          'requirement': 10000,
          'description': '10000 zikir için',
          'color': Colors.cyan,
          'unlocked': false,
        },
        {
          'id': 'master_kupa',
          'name': 'Usta Kupa',
          'icon': '👑',
          'requirement': 50000,
          'description': '50000 zikir için',
          'color': Colors.purple,
          'unlocked': false,
        },
      ];
      
      // Kazanılmış kupaları kontrol et
      final unlockedCups = <String, bool>{};
      for (final cup in _allCups) {
        final isUnlocked = prefs.getBool('${cup['id']}_${widget.currentUserId}') ?? false;
        unlockedCups[cup['id'] as String] = isUnlocked;
        cup['unlocked'] = isUnlocked;
      }
      
      // Kullanıcı seviyesini hesapla
      final userLevel = _calculateUserLevel(totalZikrs);
      
      // Sonraki kupa bilgilerini hesapla
      final nextCupInfo = _getNextCupInfo(totalZikrs);
      
      setState(() {
        _totalZikrs = totalZikrs;
        _unlockedCups = unlockedCups;
        _userLevel = userLevel;
        _progressToNextCup = nextCupInfo['progress'] as double;
        _nextCupName = nextCupInfo['name'] as String;
        _nextCupRequirement = nextCupInfo['requirement'] as int;
        _isLoading = false;
      });
      
      print('Kupa screen loaded: total=$totalZikrs, level=$userLevel, next cup=$_nextCupName');
      
    } catch (e) {
      print('Error loading kupa screen: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Yeni yardımcı metodlar
  int _calculateUserLevel(int totalZikrs) {
    if (totalZikrs >= 50000) return 6;
    if (totalZikrs >= 10000) return 5;
    if (totalZikrs >= 5000) return 4;
    if (totalZikrs >= 1000) return 3;
    if (totalZikrs >= 500) return 2;
    if (totalZikrs >= 100) return 1;
    return 0;
  }

  Map<String, dynamic> _getNextCupInfo(int totalZikrs) {
    for (final cup in _allCups) {
      if (!(cup['unlocked'] as bool)) {
        final requirement = cup['requirement'] as int;
        final prevRequirement = cup == _allCups.first ? 0 : 
            (_allCups[_allCups.indexOf(cup) - 1]['requirement'] as int);
        final progress = (totalZikrs - prevRequirement) / (requirement - prevRequirement);
        
        return {
          'name': cup['name'] as String,
          'requirement': requirement,
          'progress': progress.clamp(0.0, 1.0),
        };
      }
    }
    
    return {
      'name': 'Tüm kupalar kazanıldı',
      'requirement': 0,
      'progress': 1.0,
    };
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getUserLevelColor(_userLevel).withOpacity(0.3),
            _getUserLevelColor(_userLevel).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getUserLevelColor(_userLevel).withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Seviye $_userLevel',
                style: GoogleFonts.notoSans(
                  color: widget.themeConfig.textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getUserLevelColor(_userLevel),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getUserLevelTitle(_userLevel),
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Toplam $_totalZikrs zikir',
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextCupProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sonraki Kupa: $_nextCupName',
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progressToNextCup,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.themeConfig.accentColor,
                      widget.themeConfig.accentColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$_nextCupRequirement zikir gerekli',
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor.withOpacity(0.7),
              fontSize: 14,
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
        childAspectRatio: 1.2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: _allCups.length,
      itemBuilder: (context, index) {
        final cup = _allCups[index];
        final isUnlocked = cup['unlocked'] as bool;
        
        return Container(
          decoration: BoxDecoration(
            gradient: isUnlocked
                ? LinearGradient(
                    colors: [
                      (cup['color'] as Color).withOpacity(0.3),
                      (cup['color'] as Color).withOpacity(0.1),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      Colors.grey.withOpacity(0.2),
                      Colors.grey.withOpacity(0.1),
                    ],
                  ),
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
                style: TextStyle(
                  fontSize: 40,
                  color: isUnlocked ? null : Colors.grey.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cup['name'] as String,
                style: GoogleFonts.notoSans(
                  color: isUnlocked
                      ? widget.themeConfig.textColor
                      : Colors.grey.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                cup['description'] as String,
                style: GoogleFonts.notoSans(
                  color: isUnlocked
                      ? widget.themeConfig.textColor.withOpacity(0.7)
                      : Colors.grey.withOpacity(0.4),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${cup['requirement']} zikir',
                style: GoogleFonts.notoSans(
                  color: isUnlocked
                      ? widget.themeConfig.accentColor
                      : Colors.grey.withOpacity(0.4),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
