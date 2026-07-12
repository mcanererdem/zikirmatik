import 'package:flutter/foundation.dart';
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

  bool get isInitialized => _isInitialized;

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
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
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

  /// Supabase'den gelen id (UUID/String) her zaman string'e çevirir; liste karışmasını önler.
  String _idToString(dynamic id) {
    if (id == null) return '';
    if (id is String) return id;
    return id.toString();
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

  String _defaultUsernameForUuid(String uuid) {
    final short = uuid.replaceAll('-', '');
    final suffix = short.length >= 10 ? short.substring(0, 10) : short;
    return 'user_$suffix';
  }

  Future<bool> _ensureUserRow(String userId) async {
    if (!_isInitialized) return false;
    final uuid = toUuid(userId);
    try {
      final existing = await _supabase
          .from('users')
          .select('id')
          .eq('id', uuid)
          .maybeSingle();
      if (existing != null) return false;

      await _supabase.from('users').insert({
        'id': uuid,
        'username': _defaultUsernameForUuid(uuid),
        'display_name': null,
        'total_zikrs': 0,
        'show_in_leaderboard': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      debugPrint('Supabase: created missing users row for $uuid');
      return true;
    } catch (e) {
      // Yarış durumlarında duplicate gelebilir; yalnızca loglayıp devam et.
      debugPrint('Supabase: ensure user row skipped ($e)');
      return false;
    }
  }

  Future<bool> ensureUserExists(String userId) async {
    if (!_isInitialized) return false;
    return _ensureUserRow(userId);
  }

  // Kullanıcı profili işlemleri
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      if (!_isInitialized) {
        debugPrint('Supabase not initialized, returning null user profile.');
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
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    try {
      if (!_isInitialized) {
        debugPrint('Supabase not initialized, skipping remote updateUserProfile.');
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
          }, onConflict: 'id')
          .select()
          .single();
      
      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  /// [updateLeaderboard] false ise kullanıcı sıralamada görünmez (ayarlardan kapatılmış).
  Future<void> updateUserZikrCount(
    String userId,
    int zikrCount, {
    bool updateLeaderboard = true,
    int? dailyCount,
    int? weeklyCount,
    int? monthlyCount,
  }) async {
    try {
      if (!_isInitialized) {
        debugPrint('Supabase not initialized, skipping updateUserZikrCount.');
        return;
      }
      final uuid = toUuid(userId);
      await _ensureUserRow(userId);
      await _supabase
          .from('users')
          .update({
            'total_zikrs': zikrCount,
            'last_zikr_date': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            // Tüm zamanlı leaderboard, users tablosundaki bu bayrağa göre filtreleniyor.
            // Bu yüzden ayar kapalıyken kullanıcıyı gizlemek için false set ediyoruz.
            'show_in_leaderboard': updateLeaderboard,
          })
          .eq('id', uuid);

      if (updateLeaderboard) {
        await updateDailyLeaderboard(userId, dailyCount ?? zikrCount);
        await updateWeeklyLeaderboard(userId, weeklyCount ?? zikrCount);
        await updateMonthlyLeaderboard(userId, monthlyCount ?? zikrCount);
      }
    } catch (e) {
      debugPrint('Error updating zikr count: $e');
    }
  }

  /// Liderlik görünürlüğünü aç/kapat.
  /// show=false iken daily/weekly/monthly leaderboard kayıtları temizlenir.
  Future<void> setLeaderboardVisibility(String userId, bool show) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }

    final uuid = toUuid(userId);
    try {
      if (show) {
        await _ensureUserRow(userId);
      }
      await _supabase.rpc(
        'set_leaderboard_visibility',
        params: {
          'p_user_id': uuid,
          'p_show': show,
        },
      );
    } catch (e) {
      debugPrint('Error setting leaderboard visibility: $e');
      rethrow;
    }
  }

  // Kupa (Achievement) işlemleri
  Future<List<Map<String, dynamic>>> getUserAchievements(String userId) async {
    try {
      if (!_isInitialized) {
        debugPrint('Supabase not initialized, returning empty achievements.');
        return [];
      }
      final uuid = toUuid(userId);
      final response = await _supabase
          .from('user_achievements')
          .select('*, achievements(*)')
          .eq('user_id', uuid)
          .order('unlocked_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting user achievements: $e');
      return [];
    }
  }

  Future<void> unlockAchievement(String userId, String achievementId) async {
    try {
      if (!_isInitialized) {
        debugPrint('Supabase not initialized, skipping unlockAchievement.');
        return;
      }
      await _ensureUserRow(userId);
      final uuid = toUuid(userId);
      await _supabase
          .from('user_achievements')
          .insert({
            'user_id': uuid,
            'achievement_id': achievementId,
            'unlocked_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      debugPrint('Error unlocking achievement: $e');
      rethrow;
    }
  }

  Future<void> syncAchievementsFromTotal(String userId, int totalZikrs) async {
    if (!_isInitialized) return;
    await _ensureUserRow(userId);
    final uuid = toUuid(userId);
    final List<String> earned = [];
    if (totalZikrs >= 100) earned.add('bronze_kupa');
    if (totalZikrs >= 500) earned.add('silver_kupa');
    if (totalZikrs >= 1000) earned.add('gold_kupa');
    if (totalZikrs >= 5000) earned.add('diamond_kupa');
    if (totalZikrs >= 10000) earned.add('platinum_kupa');
    if (earned.isEmpty) return;

    try {
      final rows = earned
          .map((id) => {
                'user_id': uuid,
                'achievement_id': id,
                'unlocked_at': DateTime.now().toIso8601String(),
              })
          .toList();
      await _supabase
          .from('user_achievements')
          .upsert(rows, onConflict: 'user_id,achievement_id');
    } catch (e) {
      debugPrint('Error syncing achievements from total: $e');
    }
  }

  // Leaderboard işlemleri
  Future<void> updateDailyLeaderboard(String userId, int zikrCount) async {
    try {
      if (!_isInitialized) {
        debugPrint('Supabase not initialized, skipping daily leaderboard update.');
        return;
      }
      await _ensureUserRow(userId);
      final uuid = toUuid(userId);
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      await _supabase
          .from('leaderboard_daily')
          .upsert({
            'user_id': uuid,
            'date': todayStr,
            'daily_count': zikrCount,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id,date');
    } catch (e) {
      debugPrint('Error updating daily leaderboard: $e');
    }
  }

  Future<void> updateWeeklyLeaderboard(String userId, int zikrCount) async {
    try {
      if (!_isInitialized) {
        debugPrint('Supabase not initialized, skipping weekly leaderboard update.');
        return;
      }
      await _ensureUserRow(userId);
      final uuid = toUuid(userId);
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStr = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
      
      await _supabase
          .from('leaderboard_weekly')
          .upsert({
            'user_id': uuid,
            'week_start': weekStr,
            'weekly_count': zikrCount,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id,week_start');
    } catch (e) {
      debugPrint('Error updating weekly leaderboard: $e');
    }
  }

  Future<void> updateMonthlyLeaderboard(String userId, int zikrCount) async {
    try {
      if (!_isInitialized) {
        debugPrint('Supabase not initialized, skipping monthly leaderboard update.');
        return;
      }
      await _ensureUserRow(userId);
      final uuid = toUuid(userId);
      final now = DateTime.now();
      final monthStart = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
      await _supabase
          .from('leaderboard_monthly')
          .upsert({
            'user_id': uuid,
            'month_start': monthStart,
            'monthly_count': zikrCount,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id,month_start');
    } catch (e) {
      debugPrint('Error updating monthly leaderboard: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDailyLeaderboard({int limit = 50}) async {
    if (!_isInitialized) return [];
    try {
      await _ensureAnonForLeaderboard();
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final response = await _supabase
          .from('leaderboard_daily')
          .select('user_id, daily_count, users!inner(username, display_name, avatar_url)')
          .eq('date', todayStr)
          .eq('users.show_in_leaderboard', true)
          .order('daily_count', ascending: false)
          .limit(limit);
      
      final rows = List<Map<String, dynamic>>.from(response);
      debugPrint('Leaderboard fetch: daily ($todayStr) returned ${rows.length} users');
      return rows.map((row) {
        final users = row['users'];
        final userMap = users is Map ? Map<String, dynamic>.from(users) : <String, dynamic>{};
        return {
          'user_id': _idToString(row['user_id']),
          'total_zikrs': row['daily_count'] ?? 0,
          'username': userMap['username'] ?? '',
          'display_name': userMap['display_name'],
          'avatar_url': userMap['avatar_url'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting daily leaderboard: $e');
      try {
        final response = await _supabase
            .from('users')
            .select('id, username, display_name, avatar_url, total_zikrs')
            .eq('show_in_leaderboard', true)
            .order('total_zikrs', ascending: false)
            .limit(limit);
        final users = List<Map<String, dynamic>>.from(response);
        return users.map((user) => {
          'user_id': _idToString(user['id']),
          'username': user['username'],
          'display_name': user['display_name'],
          'avatar_url': user['avatar_url'],
          'total_zikrs': user['total_zikrs'] ?? 0,
        }).toList();
      } catch (fallbackError) {
        debugPrint('Fallback leaderboard also failed: $fallbackError');
        if (_isNetworkError(e) || _isNetworkError(fallbackError)) rethrow;
        return [];
      }
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklyLeaderboard({int limit = 50}) async {
    if (!_isInitialized) return [];
    try {
      await _ensureAnonForLeaderboard();
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartStr = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
      final response = await _supabase
          .from('leaderboard_weekly')
          .select('user_id, weekly_count, users!inner(username, display_name, avatar_url)')
          .eq('week_start', weekStartStr)
          .eq('users.show_in_leaderboard', true)
          .order('weekly_count', ascending: false)
          .limit(limit);
      final rows = List<Map<String, dynamic>>.from(response);
      debugPrint('Leaderboard fetch: weekly ($weekStartStr) returned ${rows.length} users');
      return rows.map((row) {
        final users = row['users'];
        final userMap = users is Map ? Map<String, dynamic>.from(users) : <String, dynamic>{};
        return {
          'user_id': _idToString(row['user_id']),
          'total_zikrs': row['weekly_count'] ?? 0,
          'username': userMap['username'] ?? '',
          'display_name': userMap['display_name'],
          'avatar_url': userMap['avatar_url'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting weekly leaderboard: $e');
      try {
        final response = await _supabase
            .from('users')
            .select('id, username, display_name, avatar_url, total_zikrs')
            .eq('show_in_leaderboard', true)
            .order('total_zikrs', ascending: false)
            .limit(limit);
        final users = List<Map<String, dynamic>>.from(response);
        return users.map((user) => {
          'user_id': _idToString(user['id']),
          'username': user['username'],
          'display_name': user['display_name'],
          'avatar_url': user['avatar_url'],
          'total_zikrs': user['total_zikrs'] ?? 0,
        }).toList();
      } catch (fallbackError) {
        debugPrint('Fallback weekly leaderboard also failed: $fallbackError');
        if (_isNetworkError(e) || _isNetworkError(fallbackError)) rethrow;
        return [];
      }
    }
  }

  Future<List<Map<String, dynamic>>> getMonthlyLeaderboard({int limit = 50}) async {
    if (!_isInitialized) return [];
    try {
      await _ensureAnonForLeaderboard();
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthStartStr = '${monthStart.year}-${monthStart.month.toString().padLeft(2, '0')}-${monthStart.day.toString().padLeft(2, '0')}';
      final response = await _supabase
          .from('leaderboard_monthly')
          .select('user_id, monthly_count, users!inner(username, display_name, avatar_url)')
          .eq('month_start', monthStartStr)
          .eq('users.show_in_leaderboard', true)
          .order('monthly_count', ascending: false)
          .limit(limit);
      final rows = List<Map<String, dynamic>>.from(response);
      debugPrint('Leaderboard fetch: monthly ($monthStartStr) returned ${rows.length} users');
      return rows.map((row) {
        final users = row['users'];
        final userMap = users is Map ? Map<String, dynamic>.from(users) : <String, dynamic>{};
        return {
          'user_id': _idToString(row['user_id']),
          'total_zikrs': row['monthly_count'] ?? 0,
          'username': userMap['username'] ?? '',
          'display_name': userMap['display_name'],
          'avatar_url': userMap['avatar_url'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting monthly leaderboard: $e');
      try {
        final response = await _supabase
            .from('users')
            .select('id, username, display_name, avatar_url, total_zikrs')
            .eq('show_in_leaderboard', true)
            .order('total_zikrs', ascending: false)
            .limit(limit);
        final users = List<Map<String, dynamic>>.from(response);
        return users.map((user) => {
          'user_id': _idToString(user['id']),
          'username': user['username'],
          'display_name': user['display_name'],
          'avatar_url': user['avatar_url'],
          'total_zikrs': user['total_zikrs'] ?? 0,
        }).toList();
      } catch (fallbackError) {
        debugPrint('Fallback monthly leaderboard also failed: $fallbackError');
        if (_isNetworkError(e) || _isNetworkError(fallbackError)) rethrow;
        return [];
      }
    }
  }

  Future<int> getUserRank(String userId) async {
    try {
      if (!_isInitialized) return 0;
      final response = await _supabase
          .from('users')
          .select('total_zikrs')
          .order('total_zikrs', ascending: false);
      
      final users = List<Map<String, dynamic>>.from(response);
      final userIndex = users.indexWhere((user) => user['id'] == userId);
      
      return userIndex >= 0 ? userIndex + 1 : 0;
    } catch (e) {
      debugPrint('Error getting user rank: $e');
      return 0;
    }
  }

  // General leaderboard method for backward compatibility
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 50}) async {
    try {
      return await getDailyLeaderboard(limit: limit);
    } catch (e) {
      debugPrint('Error getting leaderboard: $e');
      return [];
    }
  }

  /// Leaderboard istekleri anon ile gitsin; oturum varsa RLS sadece kendi satırını döndürebilir (tek kişi). Önce oturumu kapatıyoruz.
  Future<void> _ensureAnonForLeaderboard() async {
    if (!_isInitialized) return;
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _supabase.auth.signOut();
        await Future.delayed(const Duration(milliseconds: 150));
        debugPrint('Leaderboard: Oturum kapatıldı, istek anon ile gidecek (tüm kullanıcılar görünsün).');
      }
    } catch (_) {}
  }

  static bool _isNetworkError(dynamic e) {
    final s = e.toString().toLowerCase();
    return s.contains('socketexception') ||
        s.contains('host lookup') ||
        s.contains('no address associated') ||
        s.contains('connection') ||
        s.contains('failed host lookup') ||
        s.contains('connection refused') ||
        s.contains('timed out');
  }

  /// Tüm zamanlar sıralaması: Önce RPC (tüm kullanıcılar), yoksa/hatada tablo SELECT
  Future<List<Map<String, dynamic>>> getAllTimeLeaderboard({int limit = 50}) async {
    if (!_isInitialized) return [];

    try {
      final response = await _supabase.rpc('get_leaderboard_all_time', params: {'lim': limit});
      final users = List<Map<String, dynamic>>.from(response as List);
      if (users.isNotEmpty) {
        debugPrint('Leaderboard fetch: RPC returned ${users.length} users');
        return users.map((user) => {
            'user_id': _idToString(user['id']),
            'username': user['username'] ?? '',
            'display_name': user['display_name'],
            'avatar_url': user['avatar_url'],
            'total_zikrs': user['total_zikrs'] ?? 0,
          }).toList();
      }
    } catch (e) {
      debugPrint('Leaderboard RPC failed ($e), fallback to users table');
    }

    await _ensureAnonForLeaderboard();
    try {
      final response = await _supabase
          .from('users')
          .select('id, username, display_name, avatar_url, total_zikrs')
          .eq('show_in_leaderboard', true)
          .order('total_zikrs', ascending: false)
          .limit(limit);
      final users = List<Map<String, dynamic>>.from(response);
      debugPrint('Leaderboard fetch: table returned ${users.length} users');
      return users.map((user) => {
          'user_id': _idToString(user['id']),
          'username': user['username'] ?? '',
          'display_name': user['display_name'],
          'avatar_url': user['avatar_url'],
          'total_zikrs': user['total_zikrs'] ?? 0,
        }).toList();
    } catch (e) {
      debugPrint('Error getting all-time leaderboard: $e');
      if (_isNetworkError(e)) rethrow;
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCupLeaderboard({int limit = 50}) async {
    if (!_isInitialized) return [];
    try {
      await _ensureAnonForLeaderboard();
      final response = await _supabase.rpc(
        'get_leaderboard_by_cups',
        params: {'lim': limit},
      );
      final rows = List<Map<String, dynamic>>.from(response as List);
      debugPrint('Leaderboard fetch: cups returned ${rows.length} users');
      return rows.map((row) => {
            'user_id': _idToString(row['id']),
            'username': row['username'] ?? '',
            'display_name': row['display_name'],
            'avatar_url': row['avatar_url'],
            'total_zikrs': row['total_zikrs'] ?? 0,
            'cup_count': row['cup_count'] ?? 0,
            'bronze_count': row['bronze_count'] ?? 0,
            'silver_count': row['silver_count'] ?? 0,
            'gold_count': row['gold_count'] ?? 0,
            'diamond_count': row['diamond_count'] ?? 0,
            'platinum_count': row['platinum_count'] ?? 0,
            'top_cup': row['top_cup'],
          }).toList();
    } catch (e) {
      debugPrint('Error getting cup leaderboard: $e');
      if (_isNetworkError(e)) rethrow;
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
      debugPrint('📸 Starting avatar upload...');

      if (imageFile.path.isEmpty) {
        debugPrint('❌ Empty file path');
        throw Exception('Resim dosyası seçilemedi. Lütfen tekrar deneyin.');
      }

      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Uint8List rawBytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(rawBytes);
      if (decoded == null) {
        throw Exception('Geçersiz veya bozuk görsel dosyası. Lütfen farklı bir dosya seçin.');
      }

      if (rawBytes.length > 10 * 1024 * 1024) {
        debugPrint('❌ File too large: ${rawBytes.length} bytes');
        throw Exception('Resim dosyası çok büyük. Lütfen 10MB\'dan küçük bir resim seçin.');
      }

      Uint8List fileBytes = _resizeAvatarBytes(rawBytes) ?? rawBytes;
      if (fileBytes.length > 2 * 1024 * 1024) {
        throw Exception('Resim çok büyük. Lütfen daha küçük bir resim seçin.');
      }

      debugPrint('📤 Uploading file: $fileName, size: ${fileBytes.length} bytes');

      final uploadResponse = await _supabase.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      
      debugPrint('✅ Upload successful: $uploadResponse');
      
      // Public URL oluştur
      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);
      
      debugPrint('✅ Public URL: $publicUrl');
      return publicUrl;
      
    } catch (e, stack) {
      debugPrint('❌ Avatar upload error: $e');
      debugPrint('Stack: $stack');
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
        errorMessage += 'Hata: ${e.toString().length > 80 ? '${e.toString().substring(0, 80)}...' : e}';
      }
      throw Exception(errorMessage);
    }
  }

  /// Hesap silme: Supabase RPC (security definer) üzerinden RLS bypass.
  Future<void> deleteUserAccount(String userId) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }

    final uuid = toUuid(userId);
    try {
      await _supabase.rpc(
        'delete_user_account',
        params: {'user_id': uuid},
      );
    } catch (e) {
      debugPrint('Error deleting user account: $e');
      rethrow;
    }
  }

}
