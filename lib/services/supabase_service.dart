import 'dart:math';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import '../models/user_profile_model.dart';

/// Supabase bağlantı ve kullanım:
/// - Bağlantı: [initialize()] uygulama açılışında (main.dart) bir kez çağrılır.
/// - Kullanıcı oluşturma: Ayrı bir "kayıt" ekranı yok; cihazda oluşturulan [userId]
///   ile ilk [updateUserProfile] veya [updateUserZikrCount] çağrısında users tablosuna
///   upsert ile satır eklenir/güncellenir (yani ilk senkronizasyonda kullanıcı oluşur).
/// - Sıklık: Her zikir artışında [updateUserZikrCount], profil değişince [updateUserProfile],
///   kupa açılınca [unlockAchievement]; leaderboard güncellemesi isteğe bağlı (ayarlardan kapatılabilir).
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final Uuid _uuid = const Uuid();
  late final SupabaseClient _supabase;
  bool _isInitialized = false;

  static const String _supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String _supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  Future<void> initialize() async {
    if (_isInitialized) return;
    if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
      throw Exception(
        'Supabase credentials not set. Build with:\n'
        '--dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY'
      );
    }
    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
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
      if (!_isInitialized) {
        print('Supabase not initialized, returning null user profile.');
        return null;
      }
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
      if (!_isInitialized) {
        print('Supabase not initialized, skipping remote updateUserProfile.');
        return profile;
      }
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

  /// [updateLeaderboard] false ise kullanıcı sıralamada görünmez (ayarlardan kapatılmış).
  Future<void> updateUserZikrCount(String userId, int zikrCount, {bool updateLeaderboard = true}) async {
    try {
      if (!_isInitialized) {
        print('Supabase not initialized, skipping updateUserZikrCount.');
        return;
      }
      final uuid = toUuid(userId);
      await _supabase
          .from('users')
          .update({
            'total_zikrs': zikrCount,
            'last_zikr_date': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', uuid);

      if (updateLeaderboard) {
        await _updateDailyLeaderboard(uuid, zikrCount);
      }
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
      if (!_isInitialized) {
        print('Supabase not initialized, skipping unlockAchievement.');
        return;
      }
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
          .select('user_id, daily_count, users!inner(username, display_name, avatar_url)')
          .eq('date', todayStr)
          .order('daily_count', ascending: false)
          .limit(limit);
      
      final rows = List<Map<String, dynamic>>.from(response);
      return rows.map((row) {
        final users = row['users'];
        final userMap = users is Map ? Map<String, dynamic>.from(users) : <String, dynamic>{};
        return {
          'user_id': row['user_id'],
          'total_zikrs': row['daily_count'] ?? 0,
          'username': userMap['username'] ?? '',
          'display_name': userMap['display_name'],
          'avatar_url': userMap['avatar_url'],
        };
      }).toList();
    } catch (e) {
      print('Error getting daily leaderboard: $e');
      try {
        final response = await _supabase
            .from('users')
            .select('id, username, display_name, avatar_url, total_zikrs')
            .order('total_zikrs', ascending: false)
            .limit(limit);
        final users = List<Map<String, dynamic>>.from(response);
        return users.map((user) => {
          'user_id': user['id'],
          'username': user['username'],
          'display_name': user['display_name'],
          'avatar_url': user['avatar_url'],
          'total_zikrs': user['total_zikrs'] ?? 0,
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
      return [];
    }
  }

  /// Tüm zamanlar sıralaması: users tablosuna göre total_zikrs
  Future<List<Map<String, dynamic>>> getAllTimeLeaderboard({int limit = 50}) async {
    try {
      if (!_isInitialized) return [];
      final response = await _supabase
          .from('users')
          .select('id, username, display_name, avatar_url, total_zikrs')
          .order('total_zikrs', ascending: false)
          .limit(limit);
      final users = List<Map<String, dynamic>>.from(response);
      return users.map((user) => {
        'user_id': user['id'],
        'username': user['username'] ?? '',
        'display_name': user['display_name'],
        'avatar_url': user['avatar_url'],
        'total_zikrs': user['total_zikrs'] ?? 0,
      }).toList();
    } catch (e) {
      print('Error getting all-time leaderboard: $e');
      return [];
    }
  }

  /// Profil fotoğrafı için boyut küçültme: max 512px, JPEG kalite 82, ~200KB altı hedeflenir.
  Uint8List? _resizeAvatarBytes(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      const int maxSize = 512;
      img.Image resized = decoded;
      if (decoded.width > maxSize || decoded.height > maxSize) {
        resized = img.copyResize(decoded, width: maxSize, height: maxSize, interpolation: img.Interpolation.linear);
      }
      return Uint8List.fromList(img.encodeJpg(resized, quality: 82));
    } catch (_) {
      return null;
    }
  }

  // Avatar upload işlemi (yüklemeden önce küçültme uygulanır)
  Future<String?> uploadAvatar(XFile imageFile) async {
    try {
      if (!_isInitialized) {
        throw Exception('Supabase yapılandırılmamış. Profil fotoğrafı sadece yerel kaydedilebilir.');
      }
      print('📸 Starting avatar upload...');

      if (imageFile.path.isEmpty) {
        print('❌ Empty file path');
        throw Exception('Resim dosyası seçilemedi. Lütfen tekrar deneyin.');
      }

      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Uint8List rawBytes = await imageFile.readAsBytes();

      if (rawBytes.length > 10 * 1024 * 1024) {
        print('❌ File too large: ${rawBytes.length} bytes');
        throw Exception('Resim dosyası çok büyük. Lütfen 10MB\'dan küçük bir resim seçin.');
      }

      Uint8List fileBytes = _resizeAvatarBytes(rawBytes) ?? rawBytes;
      if (fileBytes.length > 2 * 1024 * 1024) {
        throw Exception('Resim çok büyük. Lütfen daha küçük bir resim seçin.');
      }

      print('📤 Uploading file: $fileName, size: ${fileBytes.length} bytes');

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
      
    } catch (e, stack) {
      print('❌ Avatar upload error: $e');
      print('Stack: $stack');
      final isLateError = e.toString().contains('LateInitializationError');
      final isNotConfigured = e.toString().contains('yapılandırılmamış') || e.toString().contains('not set');
      String errorMessage = 'Profil fotoğrafı yüklenemedi. ';
      if (isLateError || isNotConfigured) {
        errorMessage += 'Bulut depolama kullanılamıyor; sadece yerel kayıt yapılacak.';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage += 'İnternet bağlantınızı kontrol edin.';
      } else if (e.toString().contains('timeout')) {
        errorMessage += 'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';
      } else if (e.toString().contains('permission') || e.toString().contains('unauthorized')) {
        errorMessage += 'Yetki hatası. Lütfen tekrar deneyin.';
      } else if (e.toString().contains('storage') || e.toString().contains('bucket')) {
        errorMessage += 'Depolama hatası. Lütfen daha sonra tekrar deneyin.';
      } else if (e.toString().toLowerCase().contains('row') ||
          e.toString().toLowerCase().contains('rls') ||
          e.toString().toLowerCase().contains('policy') ||
          e.toString().toLowerCase().contains('violates')) {
        errorMessage += 'Depolama izin ayarları (RLS) Supabase Storage için kontrol edilmeli.';
      } else {
        errorMessage += 'Hata: ${e.toString().length > 80 ? e.toString().substring(0, 80) + '...' : e}';
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
