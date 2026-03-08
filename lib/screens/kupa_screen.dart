import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../services/supabase_service.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String requirement;
  final int points;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String category;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requirement,
    required this.points,
    this.isUnlocked = false,
    this.unlockedAt,
    this.category = 'regular',
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      requirement: json['requirement'] ?? '',
      points: json['points'] ?? 0,
      isUnlocked: json['is_unlocked'] ?? false,
      unlockedAt: json['unlocked_at'] != null 
          ? DateTime.parse(json['unlocked_at'])
          : null,
      category: json['category'] ?? 'regular',
    );
  }

  Achievement copyWith({
    bool? isUnlocked,
  }) {
    return Achievement(
      id: this.id,
      title: this.title,
      description: this.description,
      icon: this.icon,
      requirement: this.requirement,
      points: this.points,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: this.unlockedAt,
      category: this.category,
    );
  }
}

class KupaScreen extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String currentUserId;
  final int currentZikrCount; // Mevcut zikir sayısı

  const KupaScreen({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.currentUserId,
    required this.currentZikrCount,
  });

  @override
  State<KupaScreen> createState() => _KupaScreenState();
}

class _KupaScreenState extends State<KupaScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _userAchievements = [];
  List<Achievement> _allAchievements = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedCategory = 'all'; // all, beginner, regular, advanced, master
  
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _loadAchievements();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    try {
      // Kullanıcının başarımlarını yükle
      final userAchievements = await _supabaseService.getUserAchievements(widget.currentUserId);
      
      // Tüm başarımları tanımla
      final allAchievements = _defineAllAchievements();
      
      // Kullanıcının başarımlarını işaretle
      final unlockedIds = userAchievements.map((ua) => ua['achievement_id'] as String).toSet();
      
      setState(() {
        _userAchievements = userAchievements;
        _allAchievements = allAchievements.map((achievement) {
          final isUnlocked = unlockedIds.contains(achievement.id);
          return achievement.copyWith(isUnlocked: isUnlocked);
        }).toList();
        _isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      print('Error loading achievements: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Achievement> _defineAllAchievements() {
    return [
      // Bronz Kupa Başarımları
      Achievement(
        id: 'bronze_kupa',
        title: 'Bronz Kupa',
        description: '100 zikir tamamla',
        icon: '🥉',
        requirement: '100 zikir',
        points: 100,
        category: 'bronze',
      ),
      
      // Gümüş Kupa Başarımları
      Achievement(
        id: 'silver_kupa',
        title: 'Gümüş Kupa',
        description: '500 zikir tamamla',
        icon: '🥈',
        requirement: '500 zikir',
        points: 250,
        category: 'silver',
      ),
      
      // Altın Kupa Başarımları
      Achievement(
        id: 'gold_kupa',
        title: 'Altın Kupa',
        description: '1000 zikir tamamla',
        icon: '🥇',
        requirement: '1000 zikir',
        points: 500,
        category: 'gold',
      ),
      
      // Elmas Kupa Başarımları
      Achievement(
        id: 'diamond_kupa',
        title: 'Elmas Kupa',
        description: '5000 zikir tamamla',
        icon: '💎',
        requirement: '5000 zikir',
        points: 1000,
        category: 'diamond',
      ),
      
      // Platin Kupa Başarımları
      Achievement(
        id: 'platinum_kupa',
        title: 'Platin Kupa',
        description: '10000 zikir tamamla',
        icon: '🏆',
        requirement: '10000 zikir',
        points: 2000,
        category: 'platinum',
      ),
      
      // Özel Başarımlar
      Achievement(
        id: 'first_zikr',
        title: 'İlk Adım',
        description: 'İlk zikrini tamamla',
        icon: '🌱',
        requirement: '1 zikir',
        points: 10,
        category: 'special',
      ),
      Achievement(
        id: 'daily_warrior',
        title: 'Günlük Savaşçı',
        description: 'Günde 1000 zikir yap',
        icon: '⚔️',
        requirement: '1000 zikir/gün',
        points: 100,
        category: 'special',
      ),
      Achievement(
        id: 'week_streak',
        title: 'Haftalık Seri',
        description: '7 gün üst üste zikir yap',
        icon: '🔥',
        requirement: '7 gün seri',
        points: 150,
        category: 'special',
      ),
      Achievement(
        id: 'monthly_master',
        title: 'Aylık Usta',
        description: 'Bir ayda 10,000 zikir yap',
        icon: '👑',
        requirement: '10,000 zikir/ay',
        points: 300,
        category: 'special',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.themeConfig.primaryColor,
      appBar: AppBar(
        backgroundColor: widget.themeConfig.primaryColor,
        elevation: 0,
        title: Text(
          'Kupalar',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_userAchievements.length}/${_allAchievements.length}',
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(widget.themeConfig.accentColor),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategorySelector(),
                    const SizedBox(height: 20),
                    _buildStatsCard(),
                    const SizedBox(height: 20),
                    _buildAchievementsGrid(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip('Tümü', 'all'),
          _buildCategoryChip('Başlangıç', 'beginner'),
          _buildCategoryChip('Standart', 'regular'),
          _buildCategoryChip('İleri', 'advanced'),
          _buildCategoryChip('Usta', 'master'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(
                  colors: [
                    widget.themeConfig.accentColor,
                    widget.themeConfig.accentColor.withOpacity(0.8),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected 
                ? widget.themeConfig.accentColor
                : Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final unlockedCount = _userAchievements.length;
    final totalPoints = _userAchievements.fold<int>(
      0, 
      (sum, achievement) => sum + ((achievement['achievements']?['points'] as int?) ?? 0)
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.themeConfig.primaryColor,
            widget.themeConfig.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.themeConfig.accentColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toplam Kupa',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$unlockedCount',
                  style: GoogleFonts.notoSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Toplam Puan',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalPoints',
                  style: GoogleFonts.notoSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsGrid() {
    final filteredAchievements = _selectedCategory == 'all'
        ? _allAchievements
        : _allAchievements.where((a) => a.category == _selectedCategory).toList();
    
    if (filteredAchievements.isEmpty) {
      return Center(
        child: Text(
          'Bu kategoride henüz başarı bulunmuyor.',
          style: GoogleFonts.notoSans(
            fontSize: 16,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      );
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: filteredAchievements.length,
      itemBuilder: (context, index) {
        final achievement = filteredAchievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    
    // Sonraki kupa bilgisi
    String nextCupName = '';
    int remainingForNext = 0;
    
    if (isUnlocked) {
      // Bu kupa açıksa, sonraki kupayı bul
      final allAchievements = _defineAllAchievements();
      final currentIndex = allAchievements.indexWhere((a) => a.id == achievement.id);
      
      if (currentIndex >= 0 && currentIndex < allAchievements.length - 1) {
        final nextAchievement = allAchievements[currentIndex + 1];
        if (!nextAchievement.isUnlocked) {
          nextCupName = nextAchievement.title;
          // Gerçek zikir sayısını hesapla - SharedPreferences'ten al
          final nextRequired = int.tryParse(nextAchievement.requirement.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          remainingForNext = (nextRequired - _getCurrentZikrCount()).clamp(0, nextRequired);
        }
      }
    } else {
      // Bu kupa kapalıysa, kalanı hesapla
      final required = int.tryParse(achievement.requirement.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      remainingForNext = (required - _getCurrentZikrCount()).clamp(0, required);
    }
    
    return Container(
      decoration: BoxDecoration(
        gradient: isUnlocked 
            ? LinearGradient(
              colors: [
                widget.themeConfig.primaryColor,
                widget.themeConfig.primaryColor.withOpacity(0.8),
              ],
            )
            : LinearGradient(
                colors: [
                  Colors.grey.shade700,
                  Colors.grey.shade800,
                ],
              ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: (isUnlocked ? widget.themeConfig.accentColor : Colors.grey)
                .withOpacity(isUnlocked ? 0.3 : 0.2),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const Spacer(),
                if (isUnlocked)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              achievement.title,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              achievement.description,
              style: GoogleFonts.notoSans(
                fontSize: 10,
                color: isUnlocked ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.5),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (!isUnlocked)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kalan: $remainingForNext',
                    style: GoogleFonts.notoSans(
                      fontSize: 9,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            else if (nextCupName.isNotEmpty && remainingForNext > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sonraki: $nextCupName',
                    style: GoogleFonts.notoSans(
                      fontSize: 9,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    'Kalan: $remainingForNext',
                    style: GoogleFonts.notoSans(
                      fontSize: 9,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 12,
                    color: isUnlocked ? Colors.amber : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${achievement.points} puan',
                    style: GoogleFonts.notoSans(
                      fontSize: 10,
                      color: isUnlocked ? Colors.amber : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Mevcut zikir sayısını al
  int _getCurrentZikrCount() {
    return widget.currentZikrCount;
  }
}
