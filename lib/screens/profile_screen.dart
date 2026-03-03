import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../services/supabase_service.dart';
import '../models/user_profile_model.dart';
import 'dart:math';

class ProfileScreen extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String currentUserId;

  const ProfileScreen({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.currentUserId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = true;
  UserProfile? _userProfile;
  
  // Yeni özellikler
  Map<String, bool> _unlockedCups = {};
  int _currentStreak = 0;
  int _weeklyZikrs = 0;
  int _monthlyZikrs = 0;
  List<String> _achievements = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      print('Loading profile for userId: ${widget.currentUserId}');
      
      // Önce SharedPreferences'ten verileri yükle
      final prefs = await SharedPreferences.getInstance();
      final totalZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      final lastZikrDate = prefs.getString('last_zikr_date_${widget.currentUserId}');
      
      // Streak hesapla
      _currentStreak = _calculateStreak(prefs);
      
      // Haftalık ve aylık zikirler
      _weeklyZikrs = _calculateWeeklyZikrs(prefs);
      _monthlyZikrs = _calculateMonthlyZikrs(prefs);
      
      // Başarıları hesapla
      _achievements = _calculateAchievements(totalZikrs, _currentStreak);
      
      // Varsayılan profil oluştur
      final defaultProfile = UserProfile(
        userId: widget.currentUserId,
        username: 'User_${widget.currentUserId.substring(0, 8)}',
        displayName: 'Zikir Çalışanı',
        totalZikrs: totalZikrs,
        lastZikrDate: lastZikrDate != null ? DateTime.parse(lastZikrDate) : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Supabase'den profil verisini al
      try {
        final profile = await _supabaseService.getUserProfile(widget.currentUserId);
        if (profile != null) {
          _userProfile = profile;
        } else {
          _userProfile = defaultProfile;
        }
      } catch (e) {
        print('Error loading profile from Supabase: $e');
        _userProfile = defaultProfile;
      }

      // Kupaları kontrol et
      _checkUnlockedCups();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkUnlockedCups() {
    final totalZikrs = _userProfile?.totalZikrs ?? 0;
    
    setState(() {
      _unlockedCups = {
        'bronze': totalZikrs >= 100,
        'silver': totalZikrs >= 500,
        'gold': totalZikrs >= 1000,
        'diamond': totalZikrs >= 5000,
        'platinum': totalZikrs >= 10000,
      };
    });
  }

  int _calculateStreak(SharedPreferences prefs) {
    // Basit streak hesaplaması
    final lastZikrDate = prefs.getString('last_zikr_date_${widget.currentUserId}');
    if (lastZikrDate == null) return 0;
    
    final lastDate = DateTime.parse(lastZikrDate);
    final now = DateTime.now();
    final difference = now.difference(lastDate).inDays;
    
    if (difference <= 1) {
      return (prefs.getInt('current_streak_${widget.currentUserId}') ?? 0) + 1;
    } else {
      return 1;
    }
  }

  int _calculateWeeklyZikrs(SharedPreferences prefs) {
    // Basit haftalık hesaplama
    return prefs.getInt('weekly_zikrs_${widget.currentUserId}') ?? 0;
  }

  int _calculateMonthlyZikrs(SharedPreferences prefs) {
    // Basit aylık hesaplama
    return prefs.getInt('monthly_zikrs_${widget.currentUserId}') ?? 0;
  }

  List<String> _calculateAchievements(int totalZikrs, int streak) {
    final achievements = <String>[];
    
    if (totalZikrs >= 1) achievements.add('İlk Zikir');
    if (totalZikrs >= 100) achievements.add('100 Zikir');
    if (totalZikrs >= 500) achievements.add('500 Zikir');
    if (totalZikrs >= 1000) achievements.add('1000 Zikir');
    if (totalZikrs >= 5000) achievements.add('5000 Zikir');
    if (totalZikrs >= 10000) achievements.add('10000 Zikir');
    
    if (streak >= 7) achievements.add('Haftalık Devam');
    if (streak >= 30) achievements.add('Aylık Devam');
    
    return achievements;
  }

  String _calculateDaysSince(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    return difference.inDays.toString();
  }

  String _calculateDailyAverage() {
    if (_userProfile == null) return '0';
    final days = int.parse(_calculateDaysSince(_userProfile!.createdAt));
    if (days == 0) return '0';
    return (_userProfile!.totalZikrs! / days).floor().toString();
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.themeConfig.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: widget.themeConfig.textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCupGrid() {
    final cups = [
      {'name': 'Bronze', 'icon': Icons.emoji_events, 'color': Colors.brown, 'unlocked': _unlockedCups['bronze'] ?? false},
      {'name': 'Silver', 'icon': Icons.emoji_events, 'color': Colors.grey, 'unlocked': _unlockedCups['silver'] ?? false},
      {'name': 'Gold', 'icon': Icons.emoji_events, 'color': Colors.amber, 'unlocked': _unlockedCups['gold'] ?? false},
      {'name': 'Diamond', 'icon': Icons.emoji_events, 'color': Colors.blue, 'unlocked': _unlockedCups['diamond'] ?? false},
      {'name': 'Platinum', 'icon': Icons.emoji_events, 'color': Colors.purple, 'unlocked': _unlockedCups['platinum'] ?? false},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: cups.length,
      itemBuilder: (context, index) {
        final cup = cups[index];
        final isUnlocked = cup['unlocked'] as bool;
        
        return Container(
          decoration: BoxDecoration(
            color: isUnlocked 
                ? (cup['color'] as Color).withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnlocked 
                  ? (cup['color'] as Color).withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                cup['icon'] as IconData,
                color: isUnlocked 
                    ? cup['color'] as Color
                    : Colors.grey,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                cup['name'] as String,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked 
                      ? widget.themeConfig.textColor
                      : Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.themeConfig.primaryColor,
      appBar: AppBar(
        backgroundColor: widget.themeConfig.primaryColor,
        elevation: 0,
        title: Text(
          'Profil',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: widget.themeConfig.backgroundGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: widget.themeConfig.accentColor,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userProfile?.displayName ?? 'Zikir Çalışanı',
                                style: GoogleFonts.notoSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _userProfile?.username ?? 'user',
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Stats Cards
                  Row(
                    children: [
                      _buildStatCard(
                        'Toplam Zikir',
                        '${_userProfile?.totalZikrs ?? 0}',
                        Icons.trending_up,
                        Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Streak',
                        '$_currentStreak',
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      _buildStatCard(
                        'Haftalık',
                        '$_weeklyZikrs',
                        Icons.calendar_view_week,
                        Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Günlük Ort.',
                        _calculateDailyAverage(),
                        Icons.trending_up,
                        Colors.blue,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Kupalar Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.themeConfig.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.themeConfig.accentColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kazanılan Kupalar',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.themeConfig.textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCupGrid(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
