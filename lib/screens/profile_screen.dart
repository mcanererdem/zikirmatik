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
  int _currentLevel = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      print('Loading profile for userId: ${widget.currentUserId}');
      
      // Local storage'dan verileri oku
      final prefs = await SharedPreferences.getInstance();
      final totalZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      final lastZikrDateStr = prefs.getString('last_zikr_date_${widget.currentUserId}');
      final lastZikrDate = lastZikrDateStr != null ? DateTime.parse(lastZikrDateStr) : null;
      
      // Kupaları yükle
      _unlockedCups = {
        'bronze_kupa': prefs.getBool('bronze_kupa_${widget.currentUserId}') ?? false,
        'silver_kupa': prefs.getBool('silver_kupa_${widget.currentUserId}') ?? false,
        'gold_kupa': prefs.getBool('gold_kupa_${widget.currentUserId}') ?? false,
        'platinum_kupa': prefs.getBool('platinum_kupa_${widget.currentUserId}') ?? false,
        'diamond_kupa': prefs.getBool('diamond_kupa_${widget.currentUserId}') ?? false,
      };
      
      // Streak hesapla
      _currentStreak = _calculateStreak(prefs);
      
      // Haftalık ve aylık zikirler
      _weeklyZikrs = _calculateWeeklyZikrs(prefs);
      _monthlyZikrs = _calculateMonthlyZikrs(prefs);
      
      // Başarıları hesapla
      _achievements = _calculateAchievements(totalZikrs, _currentStreak);
      
      // Seviyeyi hesapla
      _currentLevel = _calculateUserLevel();
      
      // Varsayılan profil oluştur
      final defaultProfile = UserProfile(
        userId: widget.currentUserId,
        username: 'User_${widget.currentUserId.substring(0, 8)}',
        displayName: 'Zikir Çalışanı',
        totalZikrs: totalZikrs,
        lastZikrDate: lastZikrDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      setState(() {
        _userProfile = defaultProfile;
        _isLoading = false;
      });
      
      print('Profile loaded with zikrs: $totalZikrs, streak: $_currentStreak');
      
      // Arka planda Supabase'i dene (opsiyonel)
      try {
        final profile = await _supabaseService.getUserProfile(widget.currentUserId);
        if (profile != null) {
          setState(() {
            _userProfile = profile;
          });
        }
      } catch (e) {
        print('Supabase profile fetch failed: $e');
        // Local verilerle devam et
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _calculateStreak(SharedPreferences prefs) {
    final lastZikrDateStr = prefs.getString('last_zikr_date_${widget.currentUserId}');
    if (lastZikrDateStr == null) return 0;
    
    final lastZikrDate = DateTime.parse(lastZikrDateStr);
    final now = DateTime.now();
    final difference = now.difference(lastZikrDate).inDays;
    
    if (difference == 0) {
      // Bugün zikir yapılmış
      return (prefs.getInt('current_streak_${widget.currentUserId}') ?? 0) + 1;
    } else if (difference == 1) {
      // Dün yapılmış, streak devam ediyor
      return prefs.getInt('current_streak_${widget.currentUserId}') ?? 0;
    } else {
      // Streak kırılmış
      return 0;
    }
  }

  int _calculateWeeklyZikrs(SharedPreferences prefs) {
    // Basit hesaplama - gerçek uygulamada daha detaylı olabilir
    return (prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0) ~/ 7;
  }

  int _calculateMonthlyZikrs(SharedPreferences prefs) {
    // Basit hesaplama - gerçek uygulamada daha detaylı olabilir
    return (prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0) ~/ 30;
  }

  List<String> _calculateAchievements(int totalZikrs, int streak) {
    List<String> achievements = [];
    
    if (totalZikrs >= 100) achievements.add('🥉 Bronz Kupa');
    if (totalZikrs >= 500) achievements.add('🥈 Gümüş Kupa');
    if (totalZikrs >= 1000) achievements.add('🥇 Altın Kupa');
    if (totalZikrs >= 5000) achievements.add('💎 Elmas Kupa');
    if (totalZikrs >= 10000) achievements.add('🏆 Platin Kupa');
    
    if (streak >= 7) achievements.add('🔥 Haftalık Streak');
    if (streak >= 30) achievements.add('🌟 Aylık Streak');
    
    return achievements;
  }

  Future<void> _updateAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 200,
        maxHeight: 200,
        imageQuality: 80,
      );
      
      if (image != null) {
        // Supabase'a yükle (opsiyonel)
        // Local'a kaydet (geçici)
        print('Avatar selected: ${image.path}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Avatar güncellendi (geçici)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error updating avatar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Avatar güncellenemedi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: widget.themeConfig.textColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.themeConfig.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: widget.themeConfig.textColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDaysSince(DateTime? date) {
    if (date == null) return '0';
    final difference = DateTime.now().difference(date).inDays;
    return difference.toString();
  }

  String _calculateDailyAverage() {
    if (_userProfile == null) return '0';
    final days = int.parse(_calculateDaysSince(_userProfile!.createdAt));
    if (days == 0) return '0';
    return (_userProfile!.totalZikrs! / days).floor().toString();
  }

  int _calculateUserLevel() {
    final totalZikrs = _userProfile?.totalZikrs ?? 0;
    
    if (totalZikrs >= 10000) return 5;
    if (totalZikrs >= 5000) return 4;
    if (totalZikrs >= 1000) return 3;
    if (totalZikrs >= 500) return 2;
    if (totalZikrs >= 100) return 1;
    return 0;
  }

  double _calculateLevelProgress() {
    final totalZikrs = _userProfile?.totalZikrs ?? 0;
    final currentLevel = _calculateUserLevel();
    final nextLevelRequirement = _getNextLevelRequirement();
    final currentLevelRequirement = _getCurrentLevelRequirement();
    
    if (currentLevel == 5) return 1.0; // Max level
    
    final progress = (totalZikrs - currentLevelRequirement) / 
                    (nextLevelRequirement - currentLevelRequirement);
    return progress.clamp(0.0, 1.0);
  }

  int _getNextLevelRequirement() {
    final currentLevel = _calculateUserLevel();
    switch (currentLevel) {
      case 0: return 100;
      case 1: return 500;
      case 2: return 1000;
      case 3: return 5000;
      case 4: return 10000;
      case 5: return 10000; // Max level
      default: return 100;
    }
  }

  int _getCurrentLevelRequirement() {
    final currentLevel = _calculateUserLevel();
    switch (currentLevel) {
      case 0: return 0;
      case 1: return 100;
      case 2: return 500;
      case 3: return 1000;
      case 4: return 5000;
      case 5: return 10000;
      default: return 0;
    }
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
            color: widget.themeConfig.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: widget.themeConfig.textColor),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(widget.themeConfig.accentColor),
              ),
            )
          : _userProfile == null
              ? Center(
                  child: Text(
                    'Profil yüklenemedi',
                    style: TextStyle(color: widget.themeConfig.textColor),
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
                          gradient: LinearGradient(
                            colors: [
                              widget.themeConfig.accentColor.withOpacity(0.8),
                              widget.themeConfig.accentColor.withOpacity(0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _updateAvatar,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.themeConfig.textColor.withOpacity(0.2),
                                  border: Border.all(
                                    color: widget.themeConfig.textColor.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _userProfile?.avatarUrl != null
                                      ? Image.network(
                                          _userProfile!.avatarUrl!,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person,
                                              size: 40,
                                              color: widget.themeConfig.textColor.withOpacity(0.7),
                                            );
                                          },
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: 40,
                                          color: widget.themeConfig.textColor.withOpacity(0.7),
                                        ),
                                ),
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
                                      color: widget.themeConfig.textColor,
                                    ),
                                  ),
                                  Text(
                                    '@${_userProfile?.username ?? 'user'}',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 14,
                                      color: widget.themeConfig.textColor.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Stats Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                        children: [
                          _buildStatCard(
                            'Toplam Zikir',
                            '${_userProfile?.totalZikrs ?? 0}',
                            Icons.toll,
                            widget.themeConfig.accentColor,
                          ),
                          _buildStatCard(
                            'Katılım Günü',
                            _calculateDaysSince(_userProfile?.createdAt),
                            Icons.calendar_today,
                            Colors.green,
                          ),
                          _buildStatCard(
                            'Günlük Ort',
                            _calculateDailyAverage(),
                            Icons.trending_up,
                            Colors.blue,
                          ),
                          _buildStatCard(
                            'Seviye',
                            '${_calculateUserLevel()}',
                            Icons.star,
                            Colors.amber,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Progress Section
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
                              'Level $_currentLevel',
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: widget.themeConfig.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: _calculateLevelProgress(),
                              backgroundColor: widget.themeConfig.textColor.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation(widget.themeConfig.accentColor),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(_userProfile?.totalZikrs ?? 0)} / ${_getNextLevelRequirement()} zikir',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: widget.themeConfig.textColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
