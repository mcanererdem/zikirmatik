import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';
import '../services/settings_service.dart';
import '../services/supabase_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String currentUserId;

  const LeaderboardScreen({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.currentUserId,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _leaderboardData = [];
  List<Map<String, dynamic>> _leaderboard = [];
  Map<String, dynamic>? _currentUserProfile;
  int _currentUserRank = 0;
  bool _isLoading = true;
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  String _selectedPeriod = 'all'; // all, daily, weekly, monthly
  
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));
    
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _refreshLeaderboard() async {
    setState(() => _isLoading = true);
    _slideAnimationController.reset();
    _fadeAnimationController.reset();
    await _loadLeaderboard();
  }

  Future<void> _loadLeaderboard({String? period}) async {
    final effectivePeriod = period ?? _selectedPeriod;
    try {
      final currentUuid = _supabaseService.toUuid(widget.currentUserId);
      print('=== LEADERBOARD DEBUG ===');
      print('Loading leaderboard from Supabase (period: $effectivePeriod)...');
      print('Current User ID: ${widget.currentUserId}');
      
      List<Map<String, dynamic>> leaderboardData;
      switch (effectivePeriod) {
        case 'all':
          leaderboardData = await _supabaseService.getAllTimeLeaderboard(limit: 50);
          break;
        case 'daily':
          leaderboardData = await _supabaseService.getDailyLeaderboard(limit: 50);
          break;
        case 'weekly':
          leaderboardData = await _supabaseService.getWeeklyLeaderboard(limit: 50);
          break;
        case 'monthly':
          leaderboardData = await _supabaseService.getMonthlyLeaderboard(limit: 50);
          break;
        default:
          leaderboardData = await _supabaseService.getDailyLeaderboard(limit: 50);
      }
      // Not: "Tüm Zamanlar"da tek kişi görünüyorsa Supabase'de users tablosu için
      // "Public can read users for leaderboard" RLS politikasının tanımlı olduğundan emin olun (supabase_schema.sql).
      print('Supabase returned ${leaderboardData.length} users');
      
      final prefs = await SharedPreferences.getInstance();
      final currentUserZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      
      print('Current user local zikrs: $currentUserZikrs');
      
      final existingUserIndex = leaderboardData.indexWhere(
        (user) => user['user_id'] == widget.currentUserId || user['user_id'] == currentUuid,
      );
      
      Map<String, dynamic> currentUserProfile;
      
      if (existingUserIndex != -1) {
        currentUserProfile = leaderboardData[existingUserIndex];
        currentUserProfile['total_zikrs'] = currentUserZikrs;
      } else {
        currentUserProfile = {
          'user_id': widget.currentUserId,
          'username': 'User_${widget.currentUserId.substring(0, 8)}',
          'display_name': 'Zikir Çalışanı',
          'total_zikrs': currentUserZikrs,
          'rank': 999,
        };
        leaderboardData.add(currentUserProfile);
      }
      
      // Sıralamayı yeniden hesapla
      leaderboardData.sort((a, b) => (b['total_zikrs'] as int).compareTo(a['total_zikrs'] as int));
      
      final userRank = leaderboardData.indexWhere((user) => user['user_id'] == widget.currentUserId || user['user_id'] == currentUuid) + 1;
      currentUserProfile['rank'] = userRank;
      
      final listForDisplay = List<Map<String, dynamic>>.from(leaderboardData);
      setState(() {
        _leaderboardData = listForDisplay;
        _leaderboard = listForDisplay;
        _currentUserProfile = currentUserProfile;
        _currentUserRank = userRank;
        _isLoading = false;
      });

      _slideAnimationController.forward();
      _fadeAnimationController.forward();

      print('=== LEADERBOARD DEBUG RESULTS ===');
      print('Total users in leaderboard: ${listForDisplay.length}');
      print('Current user zikrs: $currentUserZikrs');
      print('Current user rank: $userRank');
      print('Current user in list: ${existingUserIndex != -1 ? "YES" : "NO"}');
      print('==============================');
    } catch (e) {
      print('=== LEADERBOARD ERROR ===');
      print('Error loading leaderboard from Supabase: $e');
      print('Falling back to local data...');
      print('========================');
      // Supabase hata verirse local verileri kullan
      _loadLocalLeaderboard();
    }
  }

  Future<void> _loadLocalLeaderboard() async {
    try {
      print('=== LOCAL LEADERBOARD DEBUG ===');
      print('Loading local leaderboard...');
      
      final prefs = await SharedPreferences.getInstance();
      final currentUserZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      
      print('Current user local zikrs: $currentUserZikrs');
      
      final sampleData = [
        {'user_id': 'sample1', 'username': 'Ahmet', 'display_name': 'Ahmet Yılmaz', 'total_zikrs': 1500, 'rank': 1},
        {'user_id': 'sample2', 'username': 'Mehmet', 'display_name': 'Mehmet Kaya', 'total_zikrs': 1200, 'rank': 2},
        {'user_id': 'sample3', 'username': 'Ayşe', 'display_name': 'Ayşe Demir', 'total_zikrs': 800, 'rank': 3},
        {'user_id': 'sample4', 'username': 'Fatma', 'display_name': 'Fatma Öz', 'total_zikrs': 600, 'rank': 4},
        {'user_id': 'sample5', 'username': 'Mustafa', 'display_name': 'Mustafa Çelik', 'total_zikrs': 400, 'rank': 5},
      ];
      
      final currentUserProfile = {
        'user_id': widget.currentUserId,
        'username': 'User_${widget.currentUserId.substring(0, 8)}',
        'display_name': 'Zikir Çalışanı',
        'total_zikrs': currentUserZikrs,
        'rank': 999,
      };
      
      final allUsers = [...sampleData, currentUserProfile];
      allUsers.sort((a, b) => (b['total_zikrs'] as int).compareTo(a['total_zikrs'] as int));
      
      final userRank = allUsers.indexWhere((user) => user['user_id'] == widget.currentUserId) + 1;
      currentUserProfile['rank'] = userRank;
      
      setState(() {
        _leaderboardData = allUsers;
        _leaderboard = allUsers;
        _currentUserProfile = currentUserProfile;
        _currentUserRank = userRank;
        _isLoading = false;
      });
      
      print('=== LOCAL LEADERBOARD RESULTS ===');
      print('Sample users: ${sampleData.length}');
      print('Total users (with current): ${allUsers.length}');
      print('Current user zikrs: $currentUserZikrs');
      print('Current user rank: $userRank');
      print('==============================');
    } catch (e) {
      print('=== LOCAL LEADERBOARD ERROR ===');
      print('Error loading local leaderboard: $e');
      print('==============================');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.themeConfig.primaryColor,
      appBar: AppBar(
        title: Text(
          DynamicLocalizationHelper.leaderboard,
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: widget.themeConfig.primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: widget.themeConfig.textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: widget.themeConfig.textColor),
            onPressed: _isLoading ? null : () => _refreshLeaderboard(),
            tooltip: DynamicLocalizationHelper.getText({
              'tr': 'Yenile',
              'en': 'Refresh',
              'ar': 'تحديث',
              'id': 'Segarkan',
              'zh': '刷新',
              'ja': '更新',
              'ru': 'Обновить',
              'de': 'Aktualisieren',
            }),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: widget.themeConfig.backgroundGradient,
        ),
        child: Column(
          children: [
            _buildPeriodSelector(),
            _buildPeriodLabel(),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(widget.themeConfig.accentColor),
                      ),
                    )
                  : Column(
                      children: [
                        if (_currentUserProfile != null) _buildCurrentUserCard(),
                        Expanded(
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(_slideAnimationController),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildLeaderboardList(),
                            ),
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

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildPeriodChip(
            DynamicLocalizationHelper.getText({
              'tr': 'Tüm Zamanlar',
              'en': 'All Time',
              'ar': 'كل الأوقات',
              'id': 'Semua Waktu',
              'ur': 'تمام اوقات',
              'bn': 'সব সময়',
              'ms': 'Semua Masa',
              'fa': 'همه زمان ها',
              'fr': 'Tous les Temps',
              'zh': '所有时间',
              'ja': '全期間',
              'ru': 'Все Время',
              'de': 'Alle Zeiten',
              'sw': 'Nyakati Zote',
              'ha': 'Duk Duka Saka',
            }), 
            'all'
          ),
          _buildPeriodChip(
            DynamicLocalizationHelper.getText({
              'tr': 'Günlük',
              'en': 'Daily',
              'ar': 'يومي',
              'id': 'Harian',
              'ur': 'روزانہ',
              'bn': 'দৈনিক',
              'ms': 'Harian',
              'fa': 'روزانه',
              'fr': 'Quotidien',
              'zh': '每日',
              'ja': '日次',
              'ru': 'Ежедневно',
              'de': 'Täglich',
              'sw': 'Kila Siku',
              'ha': 'Tsakila',
            }), 
            'daily'
          ),
          _buildPeriodChip(
            DynamicLocalizationHelper.getText({
              'tr': 'Haftalık',
              'en': 'Weekly',
              'ar': 'أسبوعي',
              'id': 'Mingguan',
              'ur': 'ہفتہ وار',
              'bn': 'সাপ্তাহিক',
              'ms': 'Mingguan',
              'fa': 'هفتگی',
              'fr': 'Hebdomadaire',
              'zh': '每周',
              'ja': '週間',
              'ru': 'Еженедельно',
              'de': 'Wöchentlich',
              'sw': 'Kila Wiki',
              'ha': 'Makon Sati',
            }), 
            'weekly'
          ),
          _buildPeriodChip(
            DynamicLocalizationHelper.getText({
              'tr': 'Aylık',
              'en': 'Monthly',
              'ar': 'شهري',
              'id': 'Bulanan',
              'ur': 'ماہانہ',
              'bn': 'মাসিক',
              'ms': 'Bulanan',
              'fa': 'ماهانه',
              'fr': 'Mensuel',
              'zh': '每月',
              'ja': '月次',
              'ru': 'Ежемесячно',
              'de': 'Monatlich',
              'sw': 'Kila Mwezi',
              'ha': 'Wata',
            }), 
            'monthly'
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodLabel() {
    final now = DateTime.now();
    String rangeText;
    switch (_selectedPeriod) {
      case 'all':
        rangeText = DynamicLocalizationHelper.getText({'tr': 'Tüm zamanlar', 'en': 'All time'});
        break;
      case 'daily':
        rangeText = '${DynamicLocalizationHelper.getText({'tr': 'Bugün', 'en': 'Today'})}: ${now.day}.${now.month}.${now.year}';
        break;
      case 'weekly':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        rangeText = '${DynamicLocalizationHelper.getText({'tr': 'Bu hafta', 'en': 'This week'})}: ${weekStart.day}.${weekStart.month}-${weekEnd.day}.${weekEnd.month}';
        break;
      case 'monthly':
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 0);
        rangeText = '${DynamicLocalizationHelper.getText({'tr': 'Bu ay', 'en': 'This month'})}: ${monthStart.day}.${monthStart.month}-${monthEnd.day}.${monthEnd.month}.${now.year}';
        break;
      default:
        rangeText = '';
    }
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
      child: Text(
        rangeText,
        style: GoogleFonts.notoSans(
          fontSize: 12,
          color: widget.themeConfig.textColor.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedPeriod == value) return;
          setState(() {
            _selectedPeriod = value;
            _isLoading = true;
          });
          _loadLeaderboard(period: value);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected 
                ? LinearGradient(
                    colors: [
                      widget.themeConfig.accentColor,
                      widget.themeConfig.accentColor.withOpacity(0.8),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : widget.themeConfig.textColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentUserCard() {
    if (_currentUserProfile == null || _currentUserProfile!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: widget.themeConfig.buttonGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.themeConfig.accentColor.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '#$_currentUserRank',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.themeConfig.textColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DynamicLocalizationHelper.getText({
                    'tr': 'Sen',
                    'en': 'You',
                    'ar': 'أنت',
                    'id': 'Anda',
                    'ur': 'آپ',
                    'bn': 'আপনি',
                    'ms': 'Anda',
                    'fa': 'شما',
                    'fr': 'Vous',
                    'zh': '你',
                    'ja': 'あなた',
                    'ru': 'Вы',
                    'de': 'Sie',
                    'sw': 'Wewe',
                    'ha': 'Kai',
                  }),
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.themeConfig.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_currentUserProfile!['total_zikrs'] ?? 0} ${DynamicLocalizationHelper.getText({
                    'tr': 'zikir',
                    'en': 'dhikr',
                    'ar': 'ذكر',
                    'id': 'zikir',
                    'ur': 'ذکر',
                    'bn': 'জিকির',
                    'ms': 'zikir',
                    'fa': 'ذکر',
                    'fr': 'dhikr',
                    'zh': '赞念',
                    'ja': 'ジクル',
                    'ru': 'зикр',
                    'de': 'Dhikr',
                    'sw': 'dhikr',
                    'ha': 'zikiri',
                  })}',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: widget.themeConfig.textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.themeConfig.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Sıra',
                'en': 'Rank',
                'ar': 'الترتيب',
                'id': 'Peringkat',
              }) + ': $_currentUserRank',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: widget.themeConfig.textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    if (_leaderboard.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard,
              size: 64,
              color: widget.themeConfig.textColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz liderlik tablosu yok',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                color: widget.themeConfig.textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    print('_buildLeaderboardList: building ${_leaderboard.length} items');
    final children = <Widget>[];
    for (int index = 0; index < _leaderboard.length; index++) {
      final user = _leaderboard[index];
      final rank = index + 1;
      final userId = user['user_id'] is String ? user['user_id'] as String : user['user_id']?.toString() ?? '';
      final isCurrentUser = userId == widget.currentUserId ||
          userId == _supabaseService.toUuid(widget.currentUserId);
      children.add(_buildLeaderboardItem(user, rank, isCurrentUser));
    }

    return ListView(
      key: ValueKey<int>(_leaderboard.length),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: children,
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> user, int rank, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isCurrentUser 
            ? LinearGradient(
                colors: [
                  widget.themeConfig.accentColor.withOpacity(0.3),
                  widget.themeConfig.accentColor.withOpacity(0.1),
                ],
              )
            : LinearGradient(
                colors: [
                  widget.themeConfig.primaryColor,
                  widget.themeConfig.primaryColor.withOpacity(0.8),
                ],
              ),
        borderRadius: BorderRadius.circular(15),
        border: isCurrentUser 
            ? Border.all(
                color: widget.themeConfig.accentColor,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: (isCurrentUser ? widget.themeConfig.accentColor : widget.themeConfig.primaryColor)
                .withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildRankBadge(rank),
            const SizedBox(width: 15),
            _buildUserAvatar(user),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['username'] ?? 'Anonymous',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.themeConfig.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 14,
                        color: widget.themeConfig.textColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user['total_zikrs'] ?? 0} ${DynamicLocalizationHelper.getText({
                          'tr': 'zikir',
                          'en': 'dhikr',
                          'ar': 'ذكر',
                          'id': 'zikir',
                        })}',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: widget.themeConfig.textColor.withOpacity(0.8),
                        ),
                      ),
                      if (user['current_streak'] != null && user['current_streak'] > 0) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.local_fire_department,
                          size: 14,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${user['current_streak']} 🔥',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (rank <= 3) _buildTrophyIcon(rank),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    String rankText;
    
    if (rank == 1) {
      badgeColor = Colors.amber;
      rankText = '🥇';
    } else if (rank == 2) {
      badgeColor = Colors.grey.shade300;
      rankText = '🥈';
    } else if (rank == 3) {
      badgeColor = Colors.brown.shade300;
      rankText = '🥉';
    } else {
      badgeColor = widget.themeConfig.accentColor;
      rankText = '$rank';
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            badgeColor,
            badgeColor.withOpacity(0.7),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: rank <= 3 
            ? Text(
                rankText,
                style: const TextStyle(fontSize: 20),
              )
            : Text(
                rankText,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: widget.themeConfig.textColor,
                ),
              ),
      ),
    );
  }

  Widget _buildUserAvatar(Map<String, dynamic> user) {
    final avatarUrl = user['avatar_url'];
    final username = user['username'] ?? 'Anonymous';
    
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        gradient: widget.themeConfig.buttonGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.themeConfig.accentColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: avatarUrl != null && avatarUrl.isNotEmpty
          ? ClipOval(
              child: Image.network(
                avatarUrl,
                width: 45,
                height: 45,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildAvatarInitial(username);
                },
              ),
            )
          : _buildAvatarInitial(username),
    );
  }

  Widget _buildAvatarInitial(String username) {
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
    
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTrophyIcon(int rank) {
    IconData icon;
    Color color;
    
    if (rank == 1) {
      icon = Icons.emoji_events;
      color = Colors.amber;
    } else if (rank == 2) {
      icon = Icons.emoji_events;
      color = Colors.grey.shade300;
    } else {
      icon = Icons.emoji_events;
      color = Colors.brown.shade300;
    }

    return Icon(
      icon,
      color: color,
      size: 24,
    );
  }
}
