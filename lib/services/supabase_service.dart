import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final Uuid _uuid = const Uuid();
  late final SupabaseClient _supabase;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(
        url: 'https://tkhdemvsbzjiofgpnbcn.supabase.co',
        anonKey: 'sb_publishable_JTYcd8QOx7ZW5SEFyClFcA_uM7qB6Ax',
      );
      _supabase = Supabase.instance.client;
      _isInitialized = true;
      print('Supabase initialized successfully');
    } catch (e) {
      print('Error initializing Supabase: $e');
      rethrow;
    }
  }

  SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _supabase;
  }

  // UUID oluşturma metodu
  String generateUserId() {
    return _uuid.v4();
  }

  // String'i UUID'ye çevirme metodu (public)
  String toUuid(String input) {
    // Eğer input zaten UUID formatındaysa, doğrudan döndür
    if (RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false).hasMatch(input)) {
      return input;
    }
    
    // String'i UUID'ye çevir
    final hash = input.hashCode.abs();
    final uuid = _uuid.v5(Uuid.NAMESPACE_URL, 'zikirmatik://$hash');
    return uuid;
  }

  // Kullanıcı profili işlemleri
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final uuid = toUuid(userId);
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', uuid)
          .maybeSingle();
      
      if (response != null) {
        return UserProfile.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    try {
      final uuid = toUuid(profile.userId);
      final response = await _supabase
          .from('users')
          .upsert({
            'id': uuid,
            'username': profile.username,
            'display_name': profile.displayName,
            'avatar_url': profile.avatarUrl,
            'total_zikrs': profile.totalZikrs,
            'last_zikr_date': profile.lastZikrDate?.toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      
      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<void> updateUserZikrCount(String userId, int zikrCount) async {
    try {
      final uuid = toUuid(userId);
      await _supabase
          .from('users')
          .update({
            'total_zikrs': zikrCount,
            'last_zikr_date': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', uuid);
      
      // Update daily leaderboard
      await _updateDailyLeaderboard(uuid, zikrCount);
    } catch (e) {
      print('Error updating zikr count: $e');
    }
  }

  // Kupa (Achievement) işlemleri
  Future<List<Map<String, dynamic>>> getUserAchievements(String userId) async {
    try {
      final uuid = toUuid(userId);
      final response = await _supabase
          .from('user_achievements')
          .select('*, achievements(*)')
          .eq('user_id', uuid)
          .order('unlocked_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting user achievements: $e');
      return [];
    }
  }

  Future<void> unlockAchievement(String userId, String achievementId) async {
    try {
      final uuid = toUuid(userId);
      await _supabase
          .from('user_achievements')
          .insert({
            'user_id': uuid,
            'achievement_id': achievementId,
            'unlocked_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Error unlocking achievement: $e');
      rethrow;
    }
  }

  // Leaderboard işlemleri
  Future<void> updateDailyLeaderboard(String userId, int zikrCount) async {
    try {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      await _supabase
          .from('leaderboard_daily')
          .upsert({
            'user_id': userId,
            'date': todayStr,
            'daily_count': zikrCount,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Error updating daily leaderboard: $e');
    }
  }

  Future<void> updateWeeklyLeaderboard(String userId, int zikrCount) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStr = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
      
      await _supabase
          .from('leaderboard_weekly')
          .upsert({
            'user_id': userId,
            'week_start': weekStr,
            'weekly_count': zikrCount,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Error updating weekly leaderboard: $e');
    }
  }

  Future<void> updateMonthlyLeaderboard(String userId, int zikrCount) async {
    try {
      final now = DateTime.now();
      final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      
      await _supabase
          .from('leaderboard_monthly')
          .upsert({
            'user_id': userId,
            'month': monthStr,
            'monthly_count': zikrCount,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Error updating monthly leaderboard: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDailyLeaderboard({int limit = 50}) async {
    try {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final response = await _supabase
          .from('leaderboard_daily')
          .select('daily_count, users!inner(username, display_name, avatar_url)')
          .eq('date', todayStr)
          .order('daily_count', ascending: false)
          .limit(limit);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting daily leaderboard: $e');
      // Fallback: users tablosundan genel leaderboard
      try {
        final response = await _supabase
            .from('users')
            .select('username, display_name, avatar_url, total_zikrs')
            .order('total_zikrs', ascending: false)
            .limit(limit);
        
        final users = List<Map<String, dynamic>>.from(response);
        // Formatı leaderboard formatına çevir
        return users.map((user) => {
          'daily_count': user['total_zikrs'],
          'username': user['username'],
          'display_name': user['display_name'],
          'avatar_url': user['avatar_url'],
        }).toList();
      } catch (fallbackError) {
        print('Fallback leaderboard also failed: $fallbackError');
        return [];
      }
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklyLeaderboard({int limit = 50}) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartStr = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
      
      final response = await _supabase
          .from('leaderboard_weekly')
          .select('weekly_count, users!inner(username, display_name, avatar_url)')
          .eq('week_start', weekStartStr)
          .order('weekly_count', ascending: false)
          .limit(limit);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting weekly leaderboard: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMonthlyLeaderboard({int limit = 50}) async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthStartStr = '${monthStart.year}-${monthStart.month.toString().padLeft(2, '0')}-${monthStart.day.toString().padLeft(2, '0')}';
      
      final response = await _supabase
          .from('leaderboard_monthly')
          .select('monthly_count, users!inner(username, display_name, avatar_url)')
          .eq('month_start', monthStartStr)
          .order('monthly_count', ascending: false)
          .limit(limit);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting monthly leaderboard: $e');
      return [];
    }
  }

  Future<int> getUserRank(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('total_zikrs')
          .order('total_zikrs', ascending: false);
      
      final users = List<Map<String, dynamic>>.from(response);
      final userIndex = users.indexWhere((user) => user['id'] == userId);
      
      return userIndex >= 0 ? userIndex + 1 : 0;
    } catch (e) {
      print('Error getting user rank: $e');
      return 0;
    }
  }

  // General leaderboard method for backward compatibility
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 50}) async {
    try {
      return await getDailyLeaderboard(limit: limit);
    } catch (e) {
      print('Error getting leaderboard: $e');
      // Fallback: users tablosundan genel leaderboard
      try {
        final response = await _supabase
            .from('users')
            .select('username, display_name, avatar_url, total_zikrs')
            .order('total_zikrs', ascending: false)
            .limit(limit);
        
        final users = List<Map<String, dynamic>>.from(response);
        // Formatı leaderboard formatına çevir
        return users.map((user) => {
          'user_id': user['id'],
          'username': user['username'],
          'display_name': user['display_name'],
          'avatar_url': user['avatar_url'],
          'total_zikrs': user['total_zikrs'],
        }).toList();
      } catch (fallbackError) {
        print('Fallback leaderboard also failed: $fallbackError');
        return [];
      }
    }
  }

  // Avatar upload işlemi
  Future<String?> uploadAvatar(XFile imageFile) async {
    try {
      print('📸 Starting avatar upload...');
      
      // Resim dosyasını kontrol et
      if (imageFile.path.isEmpty) {
        print('❌ Empty file path');
        throw Exception('Resim dosyası seçilemedi. Lütfen tekrar deneyin.');
      }
      
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fileBytes = await imageFile.readAsBytes();
      
      print('📤 Uploading file: $fileName, size: ${fileBytes.length} bytes');
      
      // Dosya boyutunu kontrol et (max 5MB)
      if (fileBytes.length > 5 * 1024 * 1024) {
        print('❌ File too large: ${fileBytes.length} bytes');
        throw Exception('Resim dosyası çok büyük. Lütfen 5MB\'dan küçük bir resim seçin.');
      }
      
      // Supabase Storage'a yükle
      final uploadResponse = await _supabase.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            fileBytes,
            fileOptions: FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      
      print('✅ Upload successful: ${uploadResponse}');
      
      // Public URL oluştur
      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);
      
      print('✅ Public URL: $publicUrl');
      return publicUrl;
      
    } catch (e) {
      print('❌ Avatar upload error: $e');
      
      // Hata mesajını daha kullanıcı dostu yap
      String errorMessage = 'Profil fotoğrafı yüklenemedi. ';
      
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage += 'İnternet bağlantınızı kontrol edin.';
      } else if (e.toString().contains('timeout')) {
        errorMessage += 'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';
      } else if (e.toString().contains('permission') || e.toString().contains('unauthorized')) {
        errorMessage += 'Yetki hatası. Lütfen tekrar giriş yapın.';
      } else if (e.toString().contains('storage') || e.toString().contains('bucket')) {
        errorMessage += 'Depolama hatası. Lütfen daha sonra tekrar deneyin.';
      } else {
        errorMessage += 'Bilinmeyen bir hata oluştu: $e';
      }
      
      throw Exception(errorMessage);
    }
  }

  // Kullanıcı profilini güncelleaderboard
  Future<void> _updateDailyLeaderboard(String userId, int zikrCount) async {
    try {
      final uuid = toUuid(userId);
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      // Check if today's entry exists
      final existingEntry = await _supabase
          .from('leaderboard_daily')
          .select()
          .eq('user_id', uuid)
          .eq('date', todayStart.toIso8601String())
          .maybeSingle();
      
      if (existingEntry != null) {
        // Update existing entry
        await _supabase
            .from('leaderboard_daily')
            .update({
              'zikr_count': zikrCount,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', uuid)
            .eq('date', todayStart.toIso8601String());
      } else {
        // Create new entry
        await _supabase
            .from('leaderboard_daily')
            .insert({
              'user_id': uuid,
              'date': todayStart.toIso8601String(),
              'zikr_count': zikrCount,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
      }
    } catch (e) {
      print('Error updating daily leaderboard: $e');
    }
  }
}
