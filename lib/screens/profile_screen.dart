import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';
import '../models/theme_model.dart';
import '../models/user_profile_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';
import '../services/settings_service.dart';
import '../services/supabase_service.dart';

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
  /// Yükleme başarısız olunca yerel dosya yolu (Supabase dışı fallback).
  String? _localAvatarPath;
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
      var userProfile = await _supabaseService.getUserProfile(widget.currentUserId);
      final prefs = await SharedPreferences.getInstance();
      final weeklyZikrs = prefs.getInt('weekly_zikrs_${widget.currentUserId}') ?? 0;
      final currentStreak = prefs.getInt('current_streak_${widget.currentUserId}') ?? 0;

      bool bronzeUnlocked = prefs.getBool('bronze_kupa_unlocked_${widget.currentUserId}') ?? false;
      bool silverUnlocked = prefs.getBool('silver_kupa_unlocked_${widget.currentUserId}') ?? false;
      bool goldUnlocked = prefs.getBool('gold_kupa_unlocked_${widget.currentUserId}') ?? false;
      bool diamondUnlocked = prefs.getBool('diamond_kupa_unlocked_${widget.currentUserId}') ?? false;
      bool platinumUnlocked = prefs.getBool('platinum_kupa_unlocked_${widget.currentUserId}') ?? false;
      try {
        final achievements = await _supabaseService.getUserAchievements(widget.currentUserId);
        for (final a in achievements) {
          final id = a['achievement_id'] as String?;
          if (id == 'bronze_kupa') bronzeUnlocked = true;
          if (id == 'silver_kupa') silverUnlocked = true;
          if (id == 'gold_kupa') goldUnlocked = true;
          if (id == 'diamond_kupa') diamondUnlocked = true;
          if (id == 'platinum_kupa') platinumUnlocked = true;
        }
        await prefs.setBool('bronze_kupa_unlocked_${widget.currentUserId}', bronzeUnlocked);
        await prefs.setBool('silver_kupa_unlocked_${widget.currentUserId}', silverUnlocked);
        await prefs.setBool('gold_kupa_unlocked_${widget.currentUserId}', goldUnlocked);
        await prefs.setBool('diamond_kupa_unlocked_${widget.currentUserId}', diamondUnlocked);
        await prefs.setBool('platinum_kupa_unlocked_${widget.currentUserId}', platinumUnlocked);
      } catch (_) {}

      String? avatarUrl = userProfile?.avatarUrl ?? prefs.getString('avatar_url_${widget.currentUserId}');
      final localUsername = prefs.getString('username_${widget.currentUserId}');
      final localDisplayName = prefs.getString('display_name_${widget.currentUserId}');
      final totalZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      final localAvatarPath = prefs.getString('avatar_path_${widget.currentUserId}');

      if (userProfile == null) {
        final initialUsername = localUsername ?? _generateRandomUsername();
        if (localUsername == null) {
          await prefs.setString('username_${widget.currentUserId}', initialUsername);
        }
        userProfile = UserProfile(
          userId: widget.currentUserId,
          username: initialUsername,
          displayName: localDisplayName ?? 'Zikir Kullanıcısı',
          avatarUrl: avatarUrl,
          totalZikrs: totalZikrs,
          lastZikrDate: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        if (localUsername != null || localDisplayName != null || avatarUrl != null) {
          userProfile = userProfile.copyWith(
            username: localUsername ?? userProfile.username,
            displayName: localDisplayName ?? userProfile.displayName,
            avatarUrl: avatarUrl ?? userProfile.avatarUrl,
          );
        }
      }

      setState(() {
        _userProfile = userProfile;
        _localAvatarPath = localAvatarPath;
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
      
      print('👤 User profile loaded: ${userProfile?.displayName ?? 'Unknown'}');
      print('🖼️ Avatar URL: $avatarUrl');
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() => _isLoading = false);
    }
  }

  static const String _randomUsernameChars = 'abcdefghjkmnpqrstuvwxyz23456789';
  String _generateRandomUsername() {
    final r = Random();
    final part = List.generate(8, (_) => _randomUsernameChars[r.nextInt(_randomUsernameChars.length)]).join();
    return 'user_$part';
  }

  Widget _buildAvatar() {
    ImageProvider? backgroundImage;
    if (_localAvatarPath != null) {
      final f = File(_localAvatarPath!);
      if (f.existsSync()) backgroundImage = FileImage(f);
    }
    if (backgroundImage == null && _userProfile?.avatarUrl != null && _userProfile!.avatarUrl!.isNotEmpty) {
      backgroundImage = NetworkImage(_userProfile!.avatarUrl!);
    }
    return GestureDetector(
      onTap: _pickAndUploadAvatar,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: widget.themeConfig.accentColor,
            backgroundImage: backgroundImage,
            child: backgroundImage == null
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
        _showPermissionDialog();
        return;
      }
      
      setState(() => _isLoading = true);
      
      print('📸 Avatar selection starting...');
      
      // Image picker'ı çalıştır
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        print('📸 Image selected: ${image.path}');
        
        // Avatar'ı Supabase'e yükle
        final avatarUrl = await _supabaseService.uploadAvatar(image);
        
        if (avatarUrl != null) {
          print('✅ Avatar successfully uploaded: $avatarUrl');
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
              ),
            );
          }
        } else {
          print('❌ Avatar upload failed; saving locally.');
          await _saveAvatarLocally(image!);
        }
      } else {
        print('📸 No image selected');
      }
      
    } catch (e) {
      print('❌ Avatar selection error: $e');
      _showErrorSnackBar('Profil fotoğrafı seçilemedi: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.themeConfig.primaryColor,
        title: Text(
          'Galeri İzni Gerekli',
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Profil fotoğrafı seçmek için galeri erişim izni gereklidir. Lütfen izni verin.',
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: GoogleFonts.notoSans(
                color: widget.themeConfig.textColor.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // İzin isteğini tekrar gönder
              final status = await Permission.photos.request();
              if (status.isGranted) {
                // İzin verildi, tekrar deneyin
                _pickAndUploadAvatar();
              } else if (status.isPermanentlyDenied) {
                // Kalıcı olarak reddedildi, ayarlara yönlendir
                _openAppSettings();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.themeConfig.accentColor,
            ),
            child: Text(
              'İzin Ver',
              style: GoogleFonts.notoSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Bulut yükleme başarısız olunca seçilen fotoğrafı uygulama dizinine kopyalar ve ekranda gösterir.
  Future<void> _saveAvatarLocally(XFile image) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/avatar_${widget.currentUserId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')}.jpg';
      final file = File(path);
      final bytes = await image.readAsBytes();
      await file.writeAsBytes(bytes);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_path_${widget.currentUserId}', path);
      if (mounted) {
        setState(() => _localAvatarPath = path);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(DynamicLocalizationHelper.getText({
              'tr': 'Profil fotoğrafı yerel olarak kaydedildi.',
              'en': 'Profile photo saved locally.',
            })),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Local avatar save error: $e');
      if (mounted) _showErrorSnackBar('Profil fotoğrafı yüklenemedi!');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool> _checkImagePermission() async {
    try {
      // Android 13+ için yeni izin sistemi
      if (Theme.of(context).platform == TargetPlatform.android) {
        // Önce medya izinlerini kontrol et
        var photosStatus = await Permission.photos.request();
        var storageStatus = await Permission.storage.request();
        
        print('📸 Permission check - Photos: $photosStatus, Storage: $storageStatus');
        
        if (photosStatus.isGranted || storageStatus.isGranted) {
          return true;
        } else if (photosStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
          // İzin kalıcı olarak reddedildi, ayarlara yönlendir
          return false;
        } else {
          // İzin reddedildi, tekrar iste
          photosStatus = await Permission.photos.request();
          storageStatus = await Permission.storage.request();
          return photosStatus.isGranted || storageStatus.isGranted;
        }
      }
      return true;
    } catch (e) {
      print('📸 Permission check error: $e');
      return false;
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
        
        // Local storage'a da kaydet (fallback)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('avatar_url_${widget.currentUserId}', avatarUrl);
        
        // Local state'i güncelle
        setState(() {
          _userProfile = updatedProfile;
        });
        
        print('✅ Avatar URL kaydedildi: $avatarUrl');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil fotoğrafı başarıyla güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Avatar güncelleme hatası: $e');
      
      // Supabase hatası olursa local storage'a kaydet
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('avatar_url_${widget.currentUserId}', avatarUrl);
        
        // Local state'i güncelle
        setState(() {
          if (_userProfile != null) {
            _userProfile = _userProfile!.copyWith(avatarUrl: avatarUrl);
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil fotoğrafı yerel olarak kaydedildi!'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (localError) {
        print('❌ Local storage hatası: $localError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil fotoğrafı kaydedilemedi!'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  String _getCupDisplayName(String type) {
    final names = {
      'bronze': {'tr': 'Bronz Kupa', 'en': 'Bronze Cup', 'ar': 'كأس برونزي', 'id': 'Piala Perunggu', 'ur': 'کانسی ٹرافی', 'bn': 'ব্রোঞ্জ কাপ', 'ms': 'Piala Gangsa', 'fa': 'جام برنزی', 'fr': 'Coupe de bronze', 'zh': '铜杯', 'ja': '銅杯', 'ru': 'Бронзовая чаша', 'de': 'Bronzepokal', 'sw': 'Kombe la Shaba', 'ha': 'Kofin Bronze'},
      'silver': {'tr': 'Gümüş Kupa', 'en': 'Silver Cup', 'ar': 'كأس فضي', 'id': 'Piala Perak', 'ur': 'سلور کپ', 'bn': 'রৌপ্য কাপ', 'ms': 'Piala Perak', 'fa': 'جام نقره', 'fr': 'Coupe d\'argent', 'zh': '银杯', 'ja': '銀杯', 'ru': 'Серебряная чаша', 'de': 'Silberpokal', 'sw': 'Kombe la Fedha', 'ha': 'Kofin Azurfa'},
      'gold': {'tr': 'Altın Kupa', 'en': 'Gold Cup', 'ar': 'كأس ذهبي', 'id': 'Piala Emas', 'ur': 'گولڈ کپ', 'bn': 'স্বর্ণ কাপ', 'ms': 'Piala Emas', 'fa': 'جام طلا', 'fr': 'Coupe d\'or', 'zh': '金杯', 'ja': '金杯', 'ru': 'Золотая чаша', 'de': 'Goldpokal', 'sw': 'Kombe la Dhahabu', 'ha': 'Kofin Zinariya'},
      'diamond': {'tr': 'Elmas Kupa', 'en': 'Diamond Cup', 'ar': 'كأس ماسي', 'id': 'Piala Berlian', 'ur': 'ڈائمنڈ کپ', 'bn': 'হীরা কাপ', 'ms': 'Piala Berlian', 'fa': 'جام الماس', 'fr': 'Coupe diamant', 'zh': '钻石杯', 'ja': 'ダイヤモンド杯', 'ru': 'Бриллиантовая чаша', 'de': 'Diamantpokal', 'sw': 'Kombe la Almasi', 'ha': 'Kofin Lu\'u'},
      'platinum': {'tr': 'Platin Kupa', 'en': 'Platinum Cup', 'ar': 'كأس بلاتيني', 'id': 'Piala Platinum', 'ur': 'پلاٹینم کپ', 'bn': 'প্ল্যাটিনাম কাপ', 'ms': 'Piala Platinum', 'fa': 'جام پلاتین', 'fr': 'Coupe platine', 'zh': '白金杯', 'ja': 'プラチナ杯', 'ru': 'Платиновая чаша', 'de': 'Platinpokal', 'sw': 'Kombe la Platini', 'ha': 'Kofin Platinum'},
    };
    return DynamicLocalizationHelper.getText(names[type] ?? {'tr': type});
  }

  Widget _buildCupGrid() {
    final totalZikrs = _userProfile?.totalZikrs ?? 0;
    final cups = [
      {
        'name': _getCupDisplayName('bronze'),
        'icon': Icons.emoji_events,
        'color': Colors.brown,
        'unlocked': _unlockedCups['bronze'] ?? false,
        'required': 100,
        'nextRequired': 500
      },
      {
        'name': _getCupDisplayName('silver'),
        'icon': Icons.emoji_events,
        'color': Colors.grey,
        'unlocked': _unlockedCups['silver'] ?? false,
        'required': 500,
        'nextRequired': 1000
      },
      {
        'name': _getCupDisplayName('gold'),
        'icon': Icons.emoji_events,
        'color': Colors.amber,
        'unlocked': _unlockedCups['gold'] ?? false,
        'required': 1000,
        'nextRequired': 5000
      },
      {
        'name': _getCupDisplayName('diamond'),
        'icon': Icons.emoji_events,
        'color': Colors.blue,
        'unlocked': _unlockedCups['diamond'] ?? false,
        'required': 5000,
        'nextRequired': 10000
      },
      {
        'name': _getCupDisplayName('platinum'),
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
          DynamicLocalizationHelper.getText({
            'tr': 'Kullanıcı Adını Düzenle',
            'en': 'Edit Username',
            'ar': 'تعديل اسم المستخدم',
            'id': 'Edit Username',
            'ur': 'صارف نام میں ترمیم کریں',
            'bn': 'ব্যবহারকারী নাম সম্পাদনা করুন',
            'ms': 'Edit Nama Pengguna',
            'fa': 'ویرایش نام کاربری',
            'fr': 'Modifier le Nom d\'Utilisateur',
            'zh': '编辑用户名',
            'ja': 'ユーザー名を編集',
            'ru': 'Редактировать Имя Пользователя',
            'de': 'Benutzernamen bearbeiten',
            'sw': 'Hariri Jina la Mtumiaji',
            'ha': 'Suna Mai Amfani',
          }),
          Icons.edit,
          Colors.blue,
          () => _showEditUsernameDialog(),
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          DynamicLocalizationHelper.getText({
            'tr': 'Görünen Adı Düzenle',
            'en': 'Edit Display Name',
            'ar': 'تعديل الاسم المعروض',
            'id': 'Edit Nama Tampilan',
            'ur': 'ڈسپلے نام میں ترمیم کریں',
            'bn': 'প্রদর্শন নাম সম্পাদনা করুন',
            'ms': 'Edit Nama Paparan',
            'fa': 'ویرایش نام نمایشی',
            'fr': 'Modifier le Nom d\'Affichage',
            'zh': '编辑显示名称',
            'ja': '表示名を編集',
            'ru': 'Редактировать Отображаемое Имя',
            'de': 'Anzeigenamen bearbeiten',
            'sw': 'Hariri Jina la Onyesha',
            'ha': 'Suna Bayyana',
          }),
          Icons.person,
          Colors.green,
          () => _showEditDisplayNameDialog(),
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          DynamicLocalizationHelper.getText({
            'tr': 'Hesabı Sil',
            'en': 'Delete Account',
            'ar': 'حذف الحساب',
            'id': 'Hapus Akun',
            'ur': 'کھاتہ حذف کریں',
            'bn': 'অ্যাকাউন্ট মুছে ফেলুন',
            'ms': 'Padam Akaun',
            'fa': 'حذف حساب',
            'fr': 'Supprimer le Compte',
            'zh': '删除账户',
            'ja': 'アカウントを削除',
            'ru': 'Удалить Аккаунт',
            'de': 'Konto löschen',
            'sw': 'Futa Akaunti',
            'ha': 'Share Akaunti',
          }),
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
          DynamicLocalizationHelper.getText({
            'tr': 'Kullanıcı Adını Düzenle',
            'en': 'Edit Username',
            'ar': 'تعديل اسم المستخدم',
            'id': 'Edit Username',
            'ur': 'صارف نام میں ترمیم کریں',
            'bn': 'ব্যবহারকারী নাম সম্পাদনা করুন',
            'ms': 'Edit Nama Pengguna',
            'fa': 'ویرایش نام کاربری',
            'fr': 'Modifier le Nom d\'Utilisateur',
            'zh': '编辑用户名',
            'ja': 'ユーザー名を編集',
            'ru': 'Редактировать Имя Пользователя',
            'de': 'Benutzernamen bearbeiten',
            'sw': 'Hariri Jina la Mtumiaji',
            'ha': 'Suna Mai Amfani',
          }),
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: widget.themeConfig.textColor),
          decoration: InputDecoration(
            labelText: DynamicLocalizationHelper.getText({
              'tr': 'Kullanıcı Adı',
              'en': 'Username',
              'ar': 'اسم المستخدم',
              'id': 'Username',
              'ur': 'صارف نام',
              'bn': 'ব্যবহারকারী নাম',
              'ms': 'Nama Pengguna',
              'fa': 'نام کاربری',
              'fr': 'Nom d\'Utilisateur',
              'zh': '用户名',
              'ja': 'ユーザー名',
              'ru': 'Имя Пользователя',
              'de': 'Benutzername',
              'sw': 'Jina la Mtumiaji',
              'ha': 'Suna Mai Amfani',
            }),
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
              DynamicLocalizationHelper.cancel,
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
              DynamicLocalizationHelper.save,
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
          DynamicLocalizationHelper.getText({
            'tr': 'Görünen Adı Düzenle',
            'en': 'Edit Display Name',
            'ar': 'تعديل الاسم المعروض',
            'id': 'Edit Nama Tampilan',
          }),
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: widget.themeConfig.textColor),
          decoration: InputDecoration(
            labelText: DynamicLocalizationHelper.getText({
              'tr': 'Görünen Adı',
              'en': 'Display Name',
              'ar': 'الاسم المعروض',
              'id': 'Nama Tampilan',
            }),
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
              DynamicLocalizationHelper.cancel,
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
              DynamicLocalizationHelper.save,
              style: TextStyle(color: widget.themeConfig.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUsername(String username) async {
    if (_userProfile == null) return;
    final updatedProfile = _userProfile!.copyWith(username: username);
    try {
      await _supabaseService.updateUserProfile(updatedProfile);
      setState(() => _userProfile = updatedProfile);
      _saveProfileToLocal(updatedProfile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kullanıcı adı güncellendi!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print('Error updating username: $e');
      _saveProfileToLocal(updatedProfile);
      setState(() => _userProfile = updatedProfile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kullanıcı adı yerel olarak kaydedildi.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _updateDisplayName(String displayName) async {
    if (_userProfile == null) return;
    final updatedProfile = _userProfile!.copyWith(displayName: displayName);
    try {
      await _supabaseService.updateUserProfile(updatedProfile);
      setState(() => _userProfile = updatedProfile);
      _saveProfileToLocal(updatedProfile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Görünen adı güncellendi!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print('Error updating display name: $e');
      _saveProfileToLocal(updatedProfile);
      setState(() => _userProfile = updatedProfile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görünen ad yerel olarak kaydedildi.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _saveProfileToLocal(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username_${widget.currentUserId}', profile.username);
    await prefs.setString('display_name_${widget.currentUserId}', profile.displayName ?? '');
    if (profile.avatarUrl != null) {
      await prefs.setString('avatar_url_${widget.currentUserId}', profile.avatarUrl!);
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
          DynamicLocalizationHelper.getText({
            'tr': 'Hesabı Sil',
            'en': 'Delete Account',
            'ar': 'حذف الحساب',
            'id': 'Hapus Akun',
          }),
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          DynamicLocalizationHelper.getText({
            'tr': 'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
            'en': 'Are you sure you want to delete your account? This action cannot be undone.',
            'ar': 'هل أنت متأكد من أنك تريد حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه.',
            'id': 'Apakah Anda yakin ingin menghapus akun Anda? Tindakan ini tidak dapat dibatalkan.',
          }),
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              DynamicLocalizationHelper.cancel,
              style: TextStyle(color: widget.themeConfig.accentColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount();
            },
            child: Text(
              DynamicLocalizationHelper.delete,
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
          icon: Icon(
            Icons.arrow_back,
            color: widget.themeConfig.textColor,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(widget.themeConfig.textColor),
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
                                _userProfile?.displayName ?? 'ZikirUser123',
                                style: GoogleFonts.notoSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: widget.themeConfig.textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _userProfile?.username ?? 'user',
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  color: widget.themeConfig.textColor.withValues(alpha: 0.85),
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
                        DynamicLocalizationHelper.getText({
                          'tr': 'Toplam Zikir',
                          'en': 'Total Dhikr',
                          'ar': 'مجموع الذكر',
                          'id': 'Total Zikir',
                          'ur': 'کل ذکر',
                          'bn': 'মোট জিকির',
                          'ms': 'Jumlah Zikir',
                          'fa': 'مجموع ذکر',
                          'fr': 'Total Dhikr',
                          'zh': '总赞念',
                          'ja': '総ジクル',
                          'ru': 'Всего Зикров',
                          'de': 'Gesamte Dhikr',
                          'sw': 'Jumla ya Dhikr',
                          'ha': 'Duk Cikin Gaba',
                        }),
                        '${_userProfile?.totalZikrs ?? 0}',
                        Icons.trending_up,
                        Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        DynamicLocalizationHelper.getText({
                          'tr': 'Streak',
                          'en': 'Streak',
                          'ar': 'السلسلة',
                          'id': 'Streak',
                          'ur': 'سلسلہ',
                          'bn': 'স্ট্রিক',
                          'ms': 'Streak',
                          'fa': 'سلسله',
                          'fr': 'Série',
                          'zh': '连续',
                          'ja': '連続',
                          'ru': 'Серия',
                          'de': 'Serie',
                          'sw': 'Mfululizo',
                          'ha': 'Saita',
                        }),
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
                        '$_weeklyZikrs',
                        Icons.calendar_view_week,
                        Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        DynamicLocalizationHelper.getText({
                          'tr': 'Günlük Ort.',
                          'en': 'Daily Avg.',
                          'ar': 'المتوسط اليومي',
                          'id': 'Rata-rata Harian',
                          'ur': 'روزانہ اوسط',
                          'bn': 'দৈনিক গড়',
                          'ms': 'Purata Harian',
                          'fa': 'میانگین روزانه',
                          'fr': 'Moyenne Journalière',
                          'zh': '日均',
                          'ja': '日平均',
                          'ru': 'Среднее Дневное',
                          'de': 'Tagesdurchschnitt',
                          'sw': 'Wastani wa Siku',
                          'ha': 'Matsakaicin Tsakila',
                        }),
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
                          DynamicLocalizationHelper.getText({
                            'tr': 'Profil Ayarları',
                            'en': 'Profile Settings',
                            'ar': 'إعدادات الملف الشخصي',
                            'id': 'Pengaturan Profil',
                            'ur': 'پروفائل سیٹنگز',
                            'bn': 'প্রোফাইল সেটিংস',
                            'ms': 'Tetapan Profil',
                            'fa': 'تنظیمات پروفایل',
                            'fr': 'Paramètres du Profil',
                            'zh': '个人资料设置',
                            'ja': 'プロフィール設定',
                            'ru': 'Настройки Профиля',
                            'de': 'Profil-Einstellungen',
                            'sw': 'Mipangilio ya Wasifu',
                            'ha': 'Saitunan Bayanan',
                          }),
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
                          DynamicLocalizationHelper.getText({
                            'tr': 'Kazanılan Kupalar',
                            'en': 'Earned Trophies',
                            'ar': 'الجوائز المكتسبة',
                            'id': 'Piala yang Dimenangkan',
                            'ur': 'کمائے ہوئے ٹرافیاں',
                            'bn': 'অর্জিত ট্রফি',
                            'ms': 'Piala Diperoleh',
                            'fa': 'جام های کسب شده',
                            'fr': 'Trophées Gagnées',
                            'zh': '获得的奖杯',
                            'ja': '獲得したトロフィー',
                            'ru': 'Завоёванные Трофеи',
                            'de': 'Verdiente Trophäen',
                            'sw': 'Tuzo Zilizopolewa',
                            'ha': 'Kofunan da Ka Samu',
                          }),
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
