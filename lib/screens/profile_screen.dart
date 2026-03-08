import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_settings/app_settings.dart';
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
  UserProfile? _userProfile;
  bool _isLoading = true;
  Map<String, bool> _unlockedCups = {
    'bronze': false,
    'silver': false,
    'gold': false,
    'diamond': false,
    'platinum': false,
  };
  int _currentStreak = 0;
  int _weeklyZikrs = 0;
  final SupabaseService _supabaseService = SupabaseService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await _supabaseService.getUserProfile(widget.currentUserId);
      final prefs = await SharedPreferences.getInstance();
      final weeklyZikrs = prefs.getInt('weekly_zikrs_${widget.currentUserId}') ?? 0;
      final currentStreak = prefs.getInt('current_streak_${widget.currentUserId}') ?? 0;
      
      // Kupa durumunu kontrol et
      final bronzeUnlocked = prefs.getBool('bronze_kupa_unlocked_${widget.currentUserId}') ?? false;
      final silverUnlocked = prefs.getBool('silver_kupa_unlocked_${widget.currentUserId}') ?? false;
      final goldUnlocked = prefs.getBool('gold_kupa_unlocked_${widget.currentUserId}') ?? false;
      final diamondUnlocked = prefs.getBool('diamond_kupa_unlocked_${widget.currentUserId}') ?? false;
      final platinumUnlocked = prefs.getBool('platinum_kupa_unlocked_${widget.currentUserId}') ?? false;
      
      setState(() {
        _userProfile = userProfile;
        _weeklyZikrs = weeklyZikrs;
        _currentStreak = currentStreak;
        _unlockedCups = {
          'bronze': bronzeUnlocked,
          'silver': silverUnlocked,
          'gold': goldUnlocked,
          'diamond': diamondUnlocked,
          'platinum': platinumUnlocked,
        };
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _pickAndUploadAvatar,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: widget.themeConfig.accentColor,
            backgroundImage: _userProfile?.avatarUrl != null 
                ? NetworkImage(_userProfile!.avatarUrl!)
                : null,
            child: _userProfile?.avatarUrl == null
                ? Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: widget.themeConfig.accentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.camera_alt,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      // İzin kontrolü yap
      final hasPermission = await _checkImagePermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('Resim seçme için izin gerekiyor. Ayarlardan izin verin.')),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Ayarlar',
                textColor: Colors.white,
                onPressed: () => _openAppSettings(),
              ),
              dismissDirection: DismissDirection.horizontal,
            ),
          );
        }
        return;
      }
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() => _isLoading = true);
        
        print('📸 Avatar upload başlatılıyor...');
        
        // Avatar'ı Supabase'e yükle
        final avatarUrl = await _supabaseService.uploadAvatar(image);
        
        if (avatarUrl != null) {
          print('✅ Avatar başarıyla yüklendi: $avatarUrl');
          
          // Kullanıcı profilini güncelle
          await _updateUserProfile(avatarUrl);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Profil fotoğrafı başarıyla güncellendi!'),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                dismissDirection: DismissDirection.horizontal,
              ),
            );
          }
        } else {
          print('❌ Avatar yükleme başarısız');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(child: Text('İnternet bağlantısı yok. Wi-Fi veya mobil veriyi kontrol edin.')),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 8),
                action: SnackBarAction(
                  label: 'Tekrar Dene',
                  textColor: Colors.white,
                  onPressed: () => _pickAndUploadAvatar(),
                ),
                dismissDirection: DismissDirection.horizontal,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('❌ Avatar upload hatası: $e');
      
      String errorMessage = 'Fotoğraf yüklenemedi. ';
      if (e.toString().contains('Internet bağlantısı')) {
        errorMessage = 'İnternet bağlantısı bulunamadı. ';
      } else if (e.toString().contains('Resim dosyası')) {
        errorMessage = 'Resim dosyası seçilemedi. ';
      } else {
        errorMessage = 'Beklenmedik hata oluştu. ';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text(errorMessage + 'Lütfen tekrar deneyin.')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Tekrar Dene',
              textColor: Colors.white,
              onPressed: () => _pickAndUploadAvatar(),
            ),
            dismissDirection: DismissDirection.horizontal,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _checkImagePermission() async {
    try {
      // Android 13+ için yeni izin sistemi
      if (Theme.of(context).platform == TargetPlatform.android) {
        final status = await Permission.photos.request();
        return status.isGranted;
      }
      return true;
    } catch (e) {
      print('Permission check error: $e');
      return true;
    }
  }

  void _openAppSettings() {
    // Ayarlara yönlendirme
    AppSettings.openAppSettings(type: AppSettingsType.settings);
  }

  Future<void> _updateUserProfile(String avatarUrl) async {
    try {
      if (_userProfile != null) {
        final updatedProfile = _userProfile!.copyWith(avatarUrl: avatarUrl);
        
        // Supabase'de güncelle
        await _supabaseService.updateUserProfile(updatedProfile);
        
        // Local state'i güncelle
        setState(() {
          _userProfile = updatedProfile;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil bilgileri güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error updating user profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil bilgileri güncellenemedi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    final totalZikrs = _userProfile?.totalZikrs ?? 0;
    final cups = [
      {
        'name': 'Bronze', 
        'icon': Icons.emoji_events, 
        'color': Colors.brown, 
        'unlocked': _unlockedCups['bronze'] ?? false,
        'required': 100,
        'nextRequired': 500
      },
      {
        'name': 'Silver', 
        'icon': Icons.emoji_events, 
        'color': Colors.grey, 
        'unlocked': _unlockedCups['silver'] ?? false,
        'required': 500,
        'nextRequired': 1000
      },
      {
        'name': 'Gold', 
        'icon': Icons.emoji_events, 
        'color': Colors.amber, 
        'unlocked': _unlockedCups['gold'] ?? false,
        'required': 1000,
        'nextRequired': 5000
      },
      {
        'name': 'Diamond', 
        'icon': Icons.emoji_events, 
        'color': Colors.blue, 
        'unlocked': _unlockedCups['diamond'] ?? false,
        'required': 5000,
        'nextRequired': 10000
      },
      {
        'name': 'Platinum', 
        'icon': Icons.emoji_events, 
        'color': Colors.purple, 
        'unlocked': _unlockedCups['platinum'] ?? false,
        'required': 10000,
        'nextRequired': null
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: cups.length,
      itemBuilder: (context, index) {
        final cup = cups[index];
        final isUnlocked = cup['unlocked'] as bool;
        final required = cup['required'] as int;
        final nextRequired = cup['nextRequired'] as int?;
        
        // Sonraki kupa hangisi?
        String nextCupName = '';
        int remainingForNext = 0;
        
        if (!isUnlocked) {
          remainingForNext = (required - totalZikrs).clamp(0, required);
        } else if (nextRequired != null && index < cups.length - 1) {
          final nextCup = cups[index + 1];
          final isNextUnlocked = nextCup['unlocked'] as bool;
          if (!isNextUnlocked) {
            nextCupName = nextCup['name'] as String;
            remainingForNext = ((nextCup['required'] as int) - totalZikrs).clamp(0, nextCup['required'] as int);
          }
        }
        
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
                  ? (cup['color'] as Color).withOpacity(0.6)
                  : Colors.grey.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: isUnlocked 
                    ? (cup['color'] as Color).withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Kupa İkonu ve Durum
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isUnlocked
                      ? LinearGradient(
                        colors: [
                          (cup['color'] as Color),
                          (cup['color'] as Color).withOpacity(0.8),
                        ],
                      )
                      : LinearGradient(
                        colors: [
                          Colors.grey.shade600,
                          Colors.grey.shade400,
                        ],
                      ),
                ),
                child: Icon(
                  cup['icon'] as IconData,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              
              // Kupa Adı
              Text(
                cup['name'] as String,
                style: GoogleFonts.notoSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked 
                      ? Colors.white
                      : Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Durum Bilgisi
              if (!isUnlocked)
                Text(
                  '$remainingForNext',
                  style: GoogleFonts.notoSans(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                )
              else if (nextCupName.isNotEmpty && remainingForNext > 0)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nextCupName,
                      style: GoogleFonts.notoSans(
                        fontSize: 7,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$remainingForNext',
                      style: GoogleFonts.notoSans(
                        fontSize: 7,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileActions() {
    return Column(
      children: [
        _buildActionTile(
          'Kullanıcı Adını Düzenle',
          Icons.edit,
          Colors.blue,
          () => _showEditUsernameDialog(),
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          'Görünen Adı Düzenle',
          Icons.person,
          Colors.green,
          () => _showEditDisplayNameDialog(),
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          'Hesabı Sil',
          Icons.delete_forever,
          Colors.red,
          () => _showDeleteAccountDialog(),
        ),
      ],
    );
  }

  Widget _buildActionTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: widget.themeConfig.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: widget.themeConfig.textColor.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUsernameDialog() {
    final controller = TextEditingController(text: _userProfile?.username ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.themeConfig.primaryColor,
        title: Text(
          'Kullanıcı Adını Düzenle',
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: widget.themeConfig.textColor),
          decoration: InputDecoration(
            labelText: 'Kullanıcı Adı',
            labelStyle: TextStyle(color: widget.themeConfig.textColor.withOpacity(0.7)),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: widget.themeConfig.accentColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.themeConfig.accentColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.themeConfig.accentColor, width: 2),
            ),
          ),
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(color: widget.themeConfig.accentColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _updateUsername(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(
              'Kaydet',
              style: TextStyle(color: widget.themeConfig.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDisplayNameDialog() {
    final controller = TextEditingController(text: _userProfile?.displayName ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.themeConfig.primaryColor,
        title: Text(
          'Görünen Adı Düzenle',
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: widget.themeConfig.textColor),
          decoration: InputDecoration(
            labelText: 'Görünen Adı',
            labelStyle: TextStyle(color: widget.themeConfig.textColor.withOpacity(0.7)),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: widget.themeConfig.accentColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.themeConfig.accentColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.themeConfig.accentColor, width: 2),
            ),
          ),
          maxLength: 100,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(color: widget.themeConfig.accentColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _updateDisplayName(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(
              'Kaydet',
              style: TextStyle(color: widget.themeConfig.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUsername(String username) async {
    try {
      if (_userProfile != null) {
        final updatedProfile = _userProfile!.copyWith(username: username);
        await _supabaseService.updateUserProfile(updatedProfile);
        
        setState(() {
          _userProfile = updatedProfile;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kullanıcı adı güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error updating username: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kullanıcı adı güncellenemedi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateDisplayName(String displayName) async {
    try {
      if (_userProfile != null) {
        final updatedProfile = _userProfile!.copyWith(displayName: displayName);
        await _supabaseService.updateUserProfile(updatedProfile);
        
        setState(() {
          _userProfile = updatedProfile;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görünen adı güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error updating display name: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görünen adı güncellenemedi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshProfile() async {
    try {
      setState(() => _isLoading = true);
      
      final userProfile = await _supabaseService.getUserProfile(widget.currentUserId);
      
      setState(() {
        _userProfile = userProfile;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil bilgileri güncellendi!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error refreshing profile: $e');
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil bilgileri güncellenemedi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.themeConfig.primaryColor,
        title: Text(
          'Hesabı Sil',
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(color: widget.themeConfig.accentColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount();
            },
            child: Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      setState(() => _isLoading = true);
      
      // TODO: SupabaseService'e deleteUser metodu eklenecek
      // await _supabaseService.deleteUser(widget.currentUserId);
      
      // Local verileri temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hesap silme özelliği yakında eklenecek.'),
          backgroundColor: Colors.orange,
        ),
      );
      
      // Ana sayfaya dön
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      print('Error deleting account: $e');
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hesap silinemedi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _calculateDailyAverage() {
    if (_currentStreak == 0) return '0';
    final totalZikrs = _userProfile?.totalZikrs ?? 0;
    return (totalZikrs / _currentStreak).toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.themeConfig.primaryColor,
      appBar: AppBar(
        backgroundColor: widget.themeConfig.primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
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
                        _buildAvatar(),
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
                  
                  // Profile Actions
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
                          'Profil Ayarları',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.themeConfig.textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildProfileActions(),
                      ],
                    ),
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
