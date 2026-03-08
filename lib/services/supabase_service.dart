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
      print('Starting avatar upload...');
      
      // Basit ve güvenilir internet kontrolü
      bool hasConnection = false;
      
      try {
        // Basit bir sorgu ile bağlantı testi
        final response = await _supabase
            .from('users')
            .select('id')
            .limit(1)
            .timeout(const Duration(seconds: 5));
        
        hasConnection = true;
        print('✅ Internet connection confirmed');
      } catch (e) {
        print('❌ Internet connection test failed: $e');
        
        // Hata mesajını daha spesifik yap
        if (e.toString().contains('timeout')) {
          throw Exception('İnternet bağlantısı çok yavaş. Lütfen bağlantınızı kontrol edin ve tekrar deneyin.');
        } else if (e.toString().contains('network')) {
          throw Exception('İnternet bağlantısı bulunamadı. Lütfen Wi-Fi veya mobil veri bağlantınızı kontrol edin.');
        } else {
          throw Exception('Bağlantı hatası oluştu. Lütfen internet bağlantınızı kontrol edin.');
        }
      }
      
      if (!hasConnection) {
        print('❌ No internet connection');
        throw Exception('İnternet bağlantısı bulunamadı. Lütfen Wi-Fi veya mobil veri bağlantınızı kontrol edin.');
      }
      
      print('✅ Internet connection confirmed, proceeding with upload...');
      
      // Resim dosyasını kontrol et
      if (imageFile.path.isEmpty) {
        print('❌ Empty file path');
        throw Exception('Resim dosyası seçilemedi. Lütfen tekrar deneyin.');
      }
      
      // Check if avatars bucket exists, if not create it
      try {
        await _supabase.storage.getBucket('avatars');
        print('Avatars bucket exists');
      } catch (e) {
        print('Creating avatars bucket...');
        try {
          await _supabase.storage.createBucket('avatars', 
            BucketOptions(
              public: true,
              allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
              fileSizeLimit: '5242880', // 5MB string olarak
            )
          );
          print('Avatars bucket created successfully');
        } catch (bucketError) {
          print('Failed to create bucket: $bucketError');
          // Bucket oluşturulamazsa devam etmeyi dene
        }
      }
      
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}.jpg';
      final fileBytes = await imageFile.readAsBytes();
      
      print('Uploading file: $fileName, size: ${fileBytes.length} bytes');
      
      // Dosya boyutunu kontrol et (max 5MB)
      if (fileBytes.length > 5 * 1024 * 1024) {
        print('File too large: ${fileBytes.length} bytes');
        return null;
      }
      
      // Dosya tipini kontrol et
      final fileType = imageFile.mimeType ?? '';
      if (!['image/jpeg', 'image/png', 'image/webp'].contains(fileType)) {
        print('Invalid file type: $fileType');
        return null;
      }
      
      try {
        final response = await _supabase.storage
            .from('avatars')
            .uploadBinary(fileName, fileBytes);
        
        print('Upload response: $response');
        
        if (response != null) {
          final publicUrl = _supabase.storage
              .from('avatars')
              .getPublicUrl(fileName);
          
          print('Public URL: $publicUrl');
          return publicUrl;
        }
      } catch (uploadError) {
        print('Upload failed: $uploadError');
        // Eğer dosya zaten varsa, farklı bir isimle dene
        final newFileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}.jpg';
        try {
          final response = await _supabase.storage
              .from('avatars')
              .uploadBinary(newFileName, fileBytes);
          
          if (response != null) {
            final publicUrl = _supabase.storage
                .from('avatars')
                .getPublicUrl(newFileName);
            
            print('Public URL (retry): $publicUrl');
            return publicUrl;
          }
        } catch (retryError) {
          print('Retry upload also failed: $retryError');
        }
      }
      
      return null;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }
}
