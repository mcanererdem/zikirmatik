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

  Future<UserProfile> createOrUpdateUserProfile(UserProfile profile) async {
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
      print('Error creating/updating user profile: $e');
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
  Future<void> _updateDailyLeaderboard(String userId, int zikrCount) async {
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
      return [];
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
    return getDailyLeaderboard(limit: limit);
  }

  // Avatar upload işlemi
  Future<String?> uploadAvatar(XFile imageFile) async {
    try {
      print('Starting avatar upload...');
      
      // Check if avatars bucket exists, if not create it
      try {
        await _supabase.storage.getBucket('avatars');
        print('Avatars bucket exists');
      } catch (e) {
        print('Creating avatars bucket...');
        await _supabase.storage.createBucket('avatars');
      }
      
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fileBytes = await imageFile.readAsBytes();
      
      print('Uploading file: $fileName, size: ${fileBytes.length} bytes');
      
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
      return null;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }
}
