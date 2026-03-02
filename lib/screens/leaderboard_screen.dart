import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
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

  Future<void> _loadLeaderboard() async {
    try {
      print('Loading leaderboard from Supabase...');
      
      // SupabaseService üzerinden leaderboard verilerini çek
      List<Map<String, dynamic>> leaderboardData = await _supabaseService.getLeaderboard(limit: 50);
      
      // Local storage'dan mevcut kullanıcının zikir sayısını oku
      final prefs = await SharedPreferences.getInstance();
      final currentUserZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      
      // Mevcut kullanıcıyı ekle (eğer listede yoksa)
      final existingUserIndex = leaderboardData.indexWhere(
        (user) => user['user_id'] == widget.currentUserId,
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
      
      // Mevcut kullanıcının sıralamasını bul
      final userRank = leaderboardData.indexWhere((user) => user['user_id'] == widget.currentUserId) + 1;
      currentUserProfile['rank'] = userRank;
      
      setState(() {
        _leaderboardData = leaderboardData;
        _leaderboard = leaderboardData;
        _currentUserProfile = currentUserProfile;
        _currentUserRank = userRank;
        _isLoading = false;
      });
      
      print('Leaderboard loaded from Supabase with ${leaderboardData.length} users');
      print('Current user zikrs: $currentUserZikrs, rank: $userRank');
    } catch (e) {
      print('Error loading leaderboard from Supabase: $e');
      // Supabase hata verirse local verileri kullan
      _loadLocalLeaderboard();
    }
  }

  Future<void> _loadLocalLeaderboard() async {
    try {
      print('Loading local leaderboard...');
      
      final prefs = await SharedPreferences.getInstance();
      final currentUserZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      
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
      
      print('Local leaderboard loaded with current user zikrs: $currentUserZikrs, rank: $userRank');
    } catch (e) {
      print('Error loading local leaderboard: $e');
      setState(() => _isLoading = false);
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
          'Liderlik Tablosu',
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: widget.themeConfig.textColor),
        actions: [
          IconButton(
            onPressed: _loadLeaderboard,
            icon: Icon(Icons.refresh, color: widget.themeConfig.textColor),
          ),
        ],
      ),
      body: Column(
        children: [
          // Period selector
          _buildPeriodSelector(),
          
          // Content
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
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildPeriodChip('Tüm Zamanlar', 'all'),
          _buildPeriodChip('Günlük', 'daily'),
          _buildPeriodChip('Haftalık', 'weekly'),
          _buildPeriodChip('Aylık', 'monthly'),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = value;
          });
          _loadLeaderboard();
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
                  'Sen',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.themeConfig.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_currentUserProfile!['total_zikrs'] ?? 0} zikir',
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
              'Sıran: $_currentUserRank',
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _leaderboard.length,
      itemBuilder: (context, index) {
        final user = _leaderboard[index];
        final rank = index + 1;
        final isCurrentUser = user['user_id'] == widget.currentUserId;
        
        return _buildLeaderboardItem(user, rank, isCurrentUser);
      },
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
                        '${user['total_zikrs'] ?? 0} zikir',
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
