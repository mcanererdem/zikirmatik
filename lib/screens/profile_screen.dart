import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:math';
import '../models/theme_model.dart';
import '../models/user_profile_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';
import '../services/settings_service.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import '../services/secure_storage_service.dart';

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
  static const int _usernameMinLen = 3;
  static const int _usernameMaxLen = 20;
  static const int _displayNameMinLen = 2;
  static const int _displayNameMaxLen = 30;
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_.]+$');

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
  final NotificationService _notificationService = NotificationService();
  final ImagePicker _imagePicker = ImagePicker();
  final SecureStorageService _secureStorageService = SecureStorageService.instance;
  final SettingsService _settingsService = SettingsService();

  String _getZikrDefaultDisplayName() {
    return DynamicLocalizationHelper.getText({
      'tr': 'Zikir',
      'en': 'Dhikr',
      'ar': 'الذكر',
      'id': 'Dzikir',
      'ur': 'ذکر',
      'bn': 'যিকির',
      'ms': 'Zikir',
      'fa': 'ذکر',
      'fr': 'Dhikr',
      'zh': 'ذكر',
      'ja': 'ズィクル',
      'ru': 'Зикр',
      'de': 'Dhikr',
      'sw': 'Dhikri',
      'ha': 'Zikir',
    });
  }

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

      // Kupalar: yerel toplam zikir + Supabase achievement birleşik kaynak (bilgi uyumlu olsun)
      final localTotalZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      try {
        await _supabaseService.syncAchievementsFromTotal(widget.currentUserId, localTotalZikrs);
      } catch (_) {}
      bool bronzeUnlocked = localTotalZikrs >= 100;
      bool silverUnlocked = localTotalZikrs >= 500;
      bool goldUnlocked = localTotalZikrs >= 1000;
      bool diamondUnlocked = localTotalZikrs >= 5000;
      bool platinumUnlocked = localTotalZikrs >= 10000;
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

      String? avatarUrl = userProfile?.avatarUrl ??
          await _secureStorageService.readWithMigration(
            secureKey: 'avatar_url_${widget.currentUserId}',
            legacyPrefsKey: 'avatar_url_${widget.currentUserId}',
          );
      final localUsername = await _secureStorageService.readWithMigration(
        secureKey: 'username_${widget.currentUserId}',
        legacyPrefsKey: 'username_${widget.currentUserId}',
      );
      final localDisplayName = await _secureStorageService.readWithMigration(
        secureKey: 'display_name_${widget.currentUserId}',
        legacyPrefsKey: 'display_name_${widget.currentUserId}',
      );
      final totalZikrs = prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0;
      final localAvatarPath = prefs.getString('avatar_path_${widget.currentUserId}');

      if (userProfile == null) {
        final initialUsername = localUsername ?? _generateRandomUsername();
        if (localUsername == null) {
          await _secureStorageService.write('username_${widget.currentUserId}', initialUsername);
        }
        userProfile = UserProfile(
          userId: widget.currentUserId,
          username: initialUsername,
        displayName: localDisplayName != null && localDisplayName.trim().isNotEmpty
            ? localDisplayName
            : _getZikrDefaultDisplayName(),
          avatarUrl: avatarUrl,
          totalZikrs: totalZikrs,
          lastZikrDate: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        // Yerel toplam zikir öncelikli (kazanılan kupalar ile uyum)
        userProfile = userProfile.copyWith(totalZikrs: totalZikrs);
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
        final pathLower = image.path.toLowerCase();
        final validExt = pathLower.endsWith('.jpg') ||
            pathLower.endsWith('.jpeg') ||
            pathLower.endsWith('.png') ||
            pathLower.endsWith('.webp');
        if (!validExt) {
          _showErrorSnackBar(DynamicLocalizationHelper.getText({
            'tr': 'Desteklenmeyen dosya türü. Lütfen JPG, PNG veya WEBP seçin.',
            'en': 'Unsupported file type. Please select JPG, PNG, or WEBP.',
            'ar': 'نوع ملف غير مدعوم. يرجى اختيار JPG أو PNG أو WEBP.',
            'id': 'Jenis file tidak didukung. Pilih JPG, PNG, atau WEBP.',
            'ur': 'فائل کی قسم معاونت یافتہ نہیں۔ براہ کرم JPG، PNG یا WEBP منتخب کریں۔',
            'bn': 'অসমর্থিত ফাইল টাইপ। JPG, PNG, বা WEBP নির্বাচন করুন।',
            'ms': 'Jenis fail tidak disokong. Sila pilih JPG, PNG, atau WEBP.',
            'fa': 'نوع فایل پشتیبانی نمی‌شود. لطفا JPG، PNG یا WEBP انتخاب کنید.',
            'fr': 'Type de fichier non pris en charge. Choisissez JPG, PNG ou WEBP.',
            'zh': '不支持的文件类型，请选择 JPG、PNG 或 WEBP。',
            'ja': '未対応のファイル形式です。JPG、PNG、または WEBP を選択してください。',
            'ru': 'Неподдерживаемый тип файла. Выберите JPG, PNG или WEBP.',
            'de': 'Nicht unterstützter Dateityp. Bitte JPG, PNG oder WEBP wählen.',
            'sw': 'Aina ya faili haitumiki. Tafadhali chagua JPG, PNG, au WEBP.',
            'ha': 'Nau’in fayil ba a goyon baya. Da fatan a zabi JPG, PNG, ko WEBP.',
          }));
          return;
        }
        final fileSize = await File(image.path).length();
        if (fileSize > 10 * 1024 * 1024) {
          _showErrorSnackBar(DynamicLocalizationHelper.getText({
            'tr': 'Dosya çok büyük. En fazla 10MB olmalı.',
            'en': 'File is too large. Maximum size is 10MB.',
            'ar': 'الملف كبير جدا. الحد الأقصى 10MB.',
            'id': 'File terlalu besar. Ukuran maksimum 10MB.',
            'ur': 'فائل بہت بڑی ہے۔ زیادہ سے زیادہ 10MB ہو سکتی ہے۔',
            'bn': 'ফাইল অনেক বড়। সর্বোচ্চ 10MB হতে হবে।',
            'ms': 'Fail terlalu besar. Saiz maksimum ialah 10MB.',
            'fa': 'فایل خیلی بزرگ است. حداکثر اندازه 10MB است.',
            'fr': 'Le fichier est trop volumineux. Taille maximale : 10MB.',
            'zh': '文件过大，最大为 10MB。',
            'ja': 'ファイルサイズが大きすぎます。最大 10MB です。',
            'ru': 'Файл слишком большой. Максимум 10MB.',
            'de': 'Datei ist zu groß. Maximale Größe ist 10MB.',
            'sw': 'Faili ni kubwa sana. Ukubwa wa juu ni 10MB.',
            'ha': 'Fayil ya yi girma sosai. Matsakaicin girma 10MB ne.',
          }));
          return;
        }
        final canUploadCloud = await _settingsService.getShowInLeaderboard();
        if (!canUploadCloud) {
          await _saveAvatarLocally(image);
          if (mounted) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.removeCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                content: Text(DynamicLocalizationHelper.getText({
                  'tr': 'Paylaşım kapalı: fotoğraf yalnızca yerel kaydedildi.',
                  'en': 'Sharing is off: photo was saved locally only.',
                  'ar': 'المشاركة مغلقة: تم حفظ الصورة محليًا فقط.',
                  'id': 'Berbagi nonaktif: foto hanya disimpan lokal.',
                  'ur': 'شیئرنگ بند ہے: تصویر صرف مقامی طور پر محفوظ ہوئی۔',
                  'bn': 'শেয়ারিং বন্ধ: ছবি শুধু লোকাল সেভ হয়েছে।',
                  'ms': 'Perkongsian dimatikan: foto disimpan secara tempatan sahaja.',
                  'fa': 'اشتراک غیرفعال است: عکس فقط به‌صورت محلی ذخیره شد.',
                  'fr': 'Partage désactivé : la photo a été enregistrée localement uniquement.',
                  'zh': '分享已关闭：照片仅保存在本地。',
                  'ja': '共有オフ：写真はローカル保存のみです。',
                  'ru': 'Публикация выключена: фото сохранено только локально.',
                  'de': 'Freigabe ist aus: Foto wurde nur lokal gespeichert.',
                  'sw': 'Ushiriki umezimwa: picha imehifadhiwa ndani pekee.',
                  'ha': 'An kashe rabawa: an adana hoton a gida kawai.',
                })),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
        
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
                    Text(
                      DynamicLocalizationHelper.getText({
                        'tr': 'Profil fotoğrafı başarıyla güncellendi!',
                        'en': 'Profile photo updated successfully!',
                        'ar': 'تم تحديث صورة الملف الشخصي بنجاح!',
                        'id': 'Foto profil berhasil diperbarui!',
                        'ur': 'پروفائل فوٹو کامیابی سے اپڈیٹ ہوئی!',
                        'bn': 'প্রোফাইল ছবি সফলভাবে আপডেট হয়েছে!',
                        'ms': 'Foto profil berjaya dikemas kini!',
                        'fa': 'عکس پروفایل با موفقیت به‌روزرسانی شد!',
                        'fr': 'Photo de profil mise à jour avec succès !',
                        'zh': '头像更新成功！',
                        'ja': 'プロフィール画像を更新しました！',
                        'ru': 'Профильное фото обновлено успешно!',
                        'de': 'Profilfoto erfolgreich aktualisiert!',
                        'sw': 'Picha ya wasifu imesasishwa kwa mafanikio!',
                        'ha': 'An sabunta hoton martaba cikin nasara!',
                      }),
                    ),
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
      _showErrorSnackBar(
        DynamicLocalizationHelper.getText({
              'tr': 'Profil fotoğrafı seçilemedi:',
              'en': 'Profile photo could not be selected:',
              'ar': 'تعذر اختيار صورة الملف الشخصي:',
              'id': 'Foto profil tidak dapat dipilih:',
              'ur': 'پروفائل فوٹو منتخب نہیں ہوسکی:',
              'bn': 'প্রোফাইল ছবি নির্বাচন করা যায়নি:',
              'ms': 'Foto profil tidak dapat dipilih:',
              'fa': 'امکان انتخاب عکس پروفایل وجود نداشت:',
              'fr': 'Impossible de sélectionner la photo de profil :',
              'zh': '无法选择头像：',
              'ja': 'プロフィール画像を選択できませんでした：',
              'ru': 'Не удалось выбрать профильное фото:',
              'de': 'Profilfoto konnte nicht ausgewählt werden:',
              'sw': 'Picha ya wasifu haikuweza kuchaguliwa:',
              'ha': 'Ba a iya zaɓar hoton martaba:',
            }) +
            ' $e',
      );
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
          DynamicLocalizationHelper.getText({
            'tr': 'Galeri İzni Gerekli',
            'en': 'Gallery Permission Required',
            'ar': 'يلزم إذن المعرض',
            'id': 'Izin Galeri Diperlukan',
            'ur': 'گیلری اجازت درکار ہے',
            'bn': 'গ্যালারির অনুমতি প্রয়োজন',
            'ms': 'Kebenaran Galeri Diperlukan',
            'fa': 'اجازه دسترسی به گالری لازم است',
            'fr': 'Autorisation de la galerie requise',
            'zh': '需要相册权限',
            'ja': 'ギャラリーの権限が必要です',
            'ru': 'Требуется разрешение на галерею',
            'de': 'Galerieberechtigung erforderlich',
            'sw': 'Ruhusa ya Matunzio inahitajika',
            'ha': 'Ana bukatar izinin Gallery',
          }),
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          DynamicLocalizationHelper.getText({
            'tr': 'Profil fotoğrafı seçmek için galeri erişim izni gereklidir. Lütfen izni verin.',
            'en': 'Gallery access permission is required to select a profile photo. Please allow it.',
            'ar': 'يلزم إذن الوصول للمعرض لاختيار صورة الملف الشخصي. يُرجى السماح بذلك.',
            'id': 'Izin akses galeri diperlukan untuk memilih foto profil. Silakan izinkan.',
            'ur': 'پروفائل فوٹو منتخب کرنے کے لیے گیلری رسائی کی اجازت ضروری ہے۔ براہ کرم اجازت دیں۔',
            'bn': 'প্রোফাইল ছবি নির্বাচন করতে গ্যালারির অ্যাক্সেস অনুমতি প্রয়োজন। অনুগ্রহ করে অনুমতি দিন।',
            'ms': 'Kebenaran akses galeri diperlukan untuk memilih foto profil. Sila benarkan.',
            'fa': 'برای انتخاب عکس پروفایل، اجازه دسترسی به گالری لازم است. لطفا اجازه دهید.',
            'fr': "L'autorisation d'accès à la galerie est requise pour sélectionner une photo de profil. Veuillez l'autoriser.",
            'zh': '选择头像需要允许访问相册。请允许。',
            'ja': 'プロフィール画像を選択するには、ギャラリーへのアクセス権限が必要です。許可してください。',
            'ru': 'Чтобы выбрать фото профиля, требуется разрешение на доступ к галерее. Пожалуйста, разрешите.',
            'de': 'Zum Auswählen eines Profilfotos ist die Berechtigung für den Galeriezugriff erforderlich. Bitte erlauben.',
            'sw': 'Ruhusa ya kufikia matunzio inahitajika kuchagua picha ya wasifu. Tafadhali ruhusu.',
            'ha': 'Ana bukatar izinin shiga Gallery don zabar hoton martaba. Don Allah ka ba da izini.',
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
              DynamicLocalizationHelper.allow,
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
      if (mounted) {
        _showErrorSnackBar(
          DynamicLocalizationHelper.getText({
            'tr': 'Profil fotoğrafı yüklenemedi!',
            'en': 'Could not load profile photo!',
            'ar': 'تعذر تحميل صورة الملف الشخصي!',
            'id': 'Tidak dapat memuat foto profil!',
            'ur': 'پروفائل فوٹو لوڈ نہیں ہو سکی!',
            'bn': 'প্রোফাইল ছবি লোড করা যায়নি!',
            'ms': 'Tidak dapat memuatkan foto profil!',
            'fa': 'بارگذاری عکس پروفایل ممکن نبود!',
            'fr': 'Impossible de charger la photo de profil !',
            'zh': '无法加载头像！',
            'ja': 'プロフィール画像を読み込めませんでした！',
            'ru': 'Не удалось загрузить профильное фото!',
            'de': 'Profilfoto konnte nicht geladen werden!',
            'sw': 'Haikuweza kupakia picha ya wasifu!',
            'ha': 'Ba a iya loda hoton martaba ba!',
          }),
        );
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String? _validateUsername(String value) {
    final v = value.trim();
    if (v.length < _usernameMinLen || v.length > _usernameMaxLen) {
      return DynamicLocalizationHelper.getText({
        'tr': 'Kullanıcı adı $_usernameMinLen-$_usernameMaxLen karakter olmalı.',
        'en': 'Username must be $_usernameMinLen-$_usernameMaxLen characters.',
        'ar': 'يجب أن يكون اسم المستخدم بين $_usernameMinLen و$_usernameMaxLen حرفًا.',
        'id': 'Nama pengguna harus $_usernameMinLen-$_usernameMaxLen karakter.',
        'ur': 'صارف نام $_usernameMinLen سے $_usernameMaxLen حروف کے درمیان ہونا چاہیے۔',
        'bn': 'ইউজারনেম $_usernameMinLen-$_usernameMaxLen অক্ষরের হতে হবে।',
        'ms': 'Nama pengguna mesti $_usernameMinLen-$_usernameMaxLen aksara.',
        'fa': 'نام کاربری باید بین $_usernameMinLen تا $_usernameMaxLen کاراکتر باشد.',
        'fr': 'Le nom d’utilisateur doit contenir $_usernameMinLen à $_usernameMaxLen caractères.',
        'zh': '用户名长度需为 $_usernameMinLen-$_usernameMaxLen 个字符。',
        'ja': 'ユーザー名は $_usernameMinLen〜$_usernameMaxLen 文字で入力してください。',
        'ru': 'Имя пользователя должно быть от $_usernameMinLen до $_usernameMaxLen символов.',
        'de': 'Der Benutzername muss $_usernameMinLen-$_usernameMaxLen Zeichen lang sein.',
        'sw': 'Jina la mtumiaji lazima liwe herufi $_usernameMinLen-$_usernameMaxLen.',
        'ha': 'Sunan mai amfani ya zama haruffa $_usernameMinLen-$_usernameMaxLen.',
      });
    }
    if (!_usernameRegex.hasMatch(v)) {
      return DynamicLocalizationHelper.getText({
        'tr': 'Sadece harf, rakam, nokta ve alt çizgi kullanın.',
        'en': 'Use only letters, numbers, dot, and underscore.',
        'ar': 'استخدم الحروف والأرقام والنقطة والشرطة السفلية فقط.',
        'id': 'Gunakan hanya huruf, angka, titik, dan garis bawah.',
        'ur': 'صرف حروف، اعداد، ڈاٹ اور انڈر اسکور استعمال کریں۔',
        'bn': 'শুধু অক্ষর, সংখ্যা, ডট ও আন্ডারস্কোর ব্যবহার করুন।',
        'ms': 'Guna huruf, nombor, titik, dan garis bawah sahaja.',
        'fa': 'فقط از حروف، اعداد، نقطه و زیرخط استفاده کنید.',
        'fr': 'Utilisez uniquement des lettres, chiffres, point et tiret bas.',
        'zh': '仅可使用字母、数字、点号和下划线。',
        'ja': '英字・数字・ドット・アンダースコアのみ使用できます。',
        'ru': 'Используйте только буквы, цифры, точку и подчёркивание.',
        'de': 'Nur Buchstaben, Zahlen, Punkt und Unterstrich verwenden.',
        'sw': 'Tumia herufi, namba, nukta na mstari chini pekee.',
        'ha': 'Yi amfani da haruffa, lambobi, aya da alamar underscore kawai.',
      });
    }
    return null;
  }

  String? _validateDisplayName(String value) {
    final v = value.trim();
    if (v.length < _displayNameMinLen || v.length > _displayNameMaxLen) {
      return DynamicLocalizationHelper.getText({
        'tr': 'Görünen ad $_displayNameMinLen-$_displayNameMaxLen karakter olmalı.',
        'en': 'Display name must be $_displayNameMinLen-$_displayNameMaxLen characters.',
        'ar': 'يجب أن يكون الاسم المعروض بين $_displayNameMinLen و$_displayNameMaxLen حرفًا.',
        'id': 'Nama tampilan harus $_displayNameMinLen-$_displayNameMaxLen karakter.',
        'ur': 'ڈسپلے نام $_displayNameMinLen سے $_displayNameMaxLen حروف کے درمیان ہونا چاہیے۔',
        'bn': 'ডিসপ্লে নাম $_displayNameMinLen-$_displayNameMaxLen অক্ষরের হতে হবে।',
        'ms': 'Nama paparan mesti $_displayNameMinLen-$_displayNameMaxLen aksara.',
        'fa': 'نام نمایشی باید بین $_displayNameMinLen تا $_displayNameMaxLen کاراکتر باشد.',
        'fr': 'Le nom affiché doit contenir $_displayNameMinLen à $_displayNameMaxLen caractères.',
        'zh': '显示名长度需为 $_displayNameMinLen-$_displayNameMaxLen 个字符。',
        'ja': '表示名は $_displayNameMinLen〜$_displayNameMaxLen 文字で入力してください。',
        'ru': 'Отображаемое имя должно быть от $_displayNameMinLen до $_displayNameMaxLen символов.',
        'de': 'Der Anzeigename muss $_displayNameMinLen-$_displayNameMaxLen Zeichen lang sein.',
        'sw': 'Jina la kuonyesha lazima liwe herufi $_displayNameMinLen-$_displayNameMaxLen.',
        'ha': 'Sunan da ake nunawa ya zama haruffa $_displayNameMinLen-$_displayNameMaxLen.',
      });
    }
    return null;
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
        await _secureStorageService.write('avatar_url_${widget.currentUserId}', avatarUrl);
        
        // Local state'i güncelle
        setState(() {
          _userProfile = updatedProfile;
        });
        
        print('✅ Avatar URL kaydedildi: $avatarUrl');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Profil fotoğrafı başarıyla güncellendi!',
                'en': 'Profile photo updated successfully!',
                'ar': 'تم تحديث صورة الملف الشخصي بنجاح!',
                'id': 'Foto profil berhasil diperbarui!',
                'ur': 'پروفائل فوٹو کامیابی سے اپڈیٹ ہوئی!',
                'bn': 'প্রোফাইল ছবি সফলভাবে আপডেট হয়েছে!',
                'ms': 'Foto profil berjaya dikemas kini!',
                'fa': 'عکس پروفایل با موفقیت به‌روزرسانی شد!',
                'fr': 'Photo de profil mise à jour avec succès !',
                'zh': '头像更新成功！',
                'ja': 'プロフィール画像を更新しました！',
                'ru': 'Профильное фото обновлено успешно!',
                'de': 'Profilfoto erfolgreich aktualisiert!',
                'sw': 'Picha ya wasifu imesasishwa kwa mafanikio!',
                'ha': 'An sabunta hoton martaba cikin nasara!',
              }),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Avatar güncelleme hatası: $e');
      
      // Supabase hatası olursa local storage'a kaydet
      try {
        final prefs = await SharedPreferences.getInstance();
        await _secureStorageService.write('avatar_url_${widget.currentUserId}', avatarUrl);
        
        // Local state'i güncelle
        setState(() {
          if (_userProfile != null) {
            _userProfile = _userProfile!.copyWith(avatarUrl: avatarUrl);
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Profil fotoğrafı yerel olarak kaydedildi!',
                'en': 'Profile photo saved locally!',
                'ar': 'تم حفظ صورة الملف الشخصي محليًا!',
                'id': 'Foto profil disimpan secara lokal!',
                'ur': 'پروفائل فوٹو مقامی طور پر محفوظ ہوگئی!',
                'bn': 'প্রোফাইল ছবি লোকালি সংরক্ষণ করা হয়েছে!',
                'ms': 'Foto profil disimpan secara tempatan!',
                'fa': 'عکس پروفایل به صورت محلی ذخیره شد!',
                'fr': 'Photo de profil enregistrée localement !',
                'zh': '头像已本地保存！',
                'ja': 'プロフィール画像をローカルに保存しました！',
                'ru': 'Профильное фото сохранено локально!',
                'de': 'Profilfoto lokal gespeichert!',
                'sw': 'Picha ya wasifu imehifadhiwa hapa kwenye kifaa!',
                'ha': 'An adana hoton martaba a gida!',
              }),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (localError) {
        print('❌ Local storage hatası: $localError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Profil fotoğrafı kaydedilemedi!',
                'en': 'Could not save profile photo!',
                'ar': 'تعذر حفظ صورة الملف الشخصي!',
                'id': 'Tidak dapat menyimpan foto profil!',
                'ur': 'پروفائل فوٹو محفوظ نہیں ہو سکی!',
                'bn': 'প্রোফাইল ছবি সংরক্ষণ করা যায়নি!',
                'ms': 'Tidak dapat menyimpan foto profil!',
                'fa': 'ذخیره عکس پروفایل ممکن نبود!',
                'fr': 'Impossible d’enregistrer la photo de profil !',
                'zh': '无法保存头像！',
                'ja': 'プロフィール画像を保存できませんでした！',
                'ru': 'Не удалось сохранить профильное фото!',
                'de': 'Profilfoto konnte nicht gespeichert werden!',
                'sw': 'Haikuweza kuhifadhi picha ya wasifu!',
                'ha': 'Ba a iya ajiye hoton martaba!',
              }),
            ),
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
    // Kazanılan kupalar: yerel toplam zikir ile uyumlu (profil = kullanıcının kazandıkları)
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
            'tr': 'Profil Resmini Değiştir',
            'en': 'Change Profile Photo',
            'ar': 'تغيير صورة الملف الشخصي',
            'id': 'Ganti Foto Profil',
            'ur': 'پروفائل تصویر تبدیل کریں',
            'bn': 'প্রোফাইল ছবি পরিবর্তন করুন',
            'ms': 'Tukar Foto Profil',
            'fa': 'تغییر عکس پروفایل',
            'fr': 'Changer la Photo de Profil',
            'zh': '更改头像',
            'ja': 'プロフィール写真を変更',
            'ru': 'Изменить Фото Профиля',
            'de': 'Profilfoto ändern',
            'sw': 'Badilisha Picha ya Wasifu',
            'ha': 'Canja Hoton Martaba',
          }),
          Icons.photo_camera,
          Colors.purple,
          () => _pickAndUploadAvatar(),
        ),
        const SizedBox(height: 8),
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
          maxLength: _usernameMaxLen,
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
              final validation = _validateUsername(controller.text);
              if (validation != null) {
                _showErrorSnackBar(validation);
                return;
              }
              final ok = await _updateUsername(controller.text.trim());
              if (ok && mounted) Navigator.pop(context);
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
              'tr': 'Takma ad (liste ve liderlikte görünür)',
              'en': 'Display name (shown on leaderboard)',
              'ar': 'الاسم المعروض',
              'id': 'Nama Tampilan',
            }),
            hintText: DynamicLocalizationHelper.getText({
              'tr': 'Örn. ZikirSever',
              'en': 'e.g. DhikrFan',
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
          maxLength: _displayNameMaxLen,
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
              final validation = _validateDisplayName(controller.text);
              if (validation != null) {
                _showErrorSnackBar(validation);
                return;
              }
              final ok = await _updateDisplayName(controller.text.trim());
              if (ok && mounted) Navigator.pop(context);
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

  Future<bool> _updateUsername(String username) async {
    if (_userProfile == null) return false;
    final updatedProfile = _userProfile!.copyWith(username: username);
    final canUploadCloud = await _settingsService.getShowInLeaderboard();
    if (!canUploadCloud) {
      _saveProfileToLocal(updatedProfile);
      setState(() => _userProfile = updatedProfile);
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.removeCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Paylaşım kapalı: kullanıcı adı yalnızca yerel kaydedildi.',
                'en': 'Sharing is off: username was saved locally only.',
                'ar': 'المشاركة مغلقة: تم حفظ اسم المستخدم محليًا فقط.',
                'id': 'Berbagi nonaktif: nama pengguna hanya disimpan lokal.',
                'ur': 'شیئرنگ بند ہے: صارف نام صرف مقامی طور پر محفوظ ہوا۔',
                'bn': 'শেয়ারিং বন্ধ: ইউজারনেম শুধু লোকালি সেভ হয়েছে।',
                'ms': 'Perkongsian dimatikan: nama pengguna disimpan secara tempatan sahaja.',
                'fa': 'اشتراک غیرفعال است: نام کاربری فقط به‌صورت محلی ذخیره شد.',
                'fr': 'Partage désactivé : le nom d’utilisateur a été enregistré localement uniquement.',
                'zh': '分享已关闭：用户名仅保存在本地。',
                'ja': '共有オフ：ユーザー名はローカル保存のみです。',
                'ru': 'Публикация выключена: имя пользователя сохранено только локально.',
                'de': 'Freigabe ist aus: Benutzername wurde nur lokal gespeichert.',
                'sw': 'Ushiriki umezimwa: jina la mtumiaji limehifadhiwa ndani pekee.',
                'ha': 'An kashe rabawa: an adana sunan mai amfani a gida kawai.',
              }),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return true;
    }
    try {
      await _supabaseService.updateUserProfile(updatedProfile);
      setState(() => _userProfile = updatedProfile);
      _saveProfileToLocal(updatedProfile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Kullanıcı adı güncellendi!',
                'en': 'Username updated!',
                'ar': 'تم تحديث اسم المستخدم!',
                'id': 'Nama pengguna diperbarui!',
                'ur': 'صارف نام اپڈیٹ ہو گیا!',
                'bn': 'ইউজারনেম আপডেট হয়েছে!',
                'ms': 'Nama pengguna dikemas kini!',
                'fa': 'نام کاربری به‌روزرسانی شد!',
                'fr': 'Nom d’utilisateur mis à jour !',
                'zh': '用户名已更新！',
                'ja': 'ユーザー名を更新しました！',
                'ru': 'Имя пользователя обновлено!',
                'de': 'Benutzername aktualisiert!',
                'sw': 'Jina la mtumiaji limesasishwa!',
                'ha': 'An sabunta sunan mai amfani!',
              }),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    } catch (e) {
      print('Error updating username: $e');
      if (e is PostgrestException && e.code == '23505') {
        if (mounted) {
          _showErrorSnackBar(DynamicLocalizationHelper.getText({
            'tr': 'Bu kullanıcı adı zaten kullanılıyor. Lütfen başka bir ad seçin.',
            'en': 'This username is already taken. Please choose another one.',
            'ar': 'اسم المستخدم هذا مستخدم بالفعل. الرجاء اختيار اسم آخر.',
            'id': 'Nama pengguna ini sudah dipakai. Silakan pilih nama lain.',
            'ur': 'یہ صارف نام پہلے سے استعمال ہو رہا ہے۔ براہ کرم دوسرا نام منتخب کریں۔',
            'bn': 'এই ইউজারনেমটি আগে থেকেই ব্যবহৃত হচ্ছে। অন্য একটি নাম দিন।',
            'ms': 'Nama pengguna ini sudah digunakan. Sila pilih nama lain.',
            'fa': 'این نام کاربری قبلاً استفاده شده است. لطفاً نام دیگری انتخاب کنید.',
            'fr': 'Ce nom d’utilisateur est déjà utilisé. Veuillez en choisir un autre.',
            'zh': '该用户名已被占用，请选择其他名称。',
            'ja': 'このユーザー名は既に使用されています。別の名前を選んでください。',
            'ru': 'Это имя пользователя уже занято. Выберите другое.',
            'de': 'Dieser Benutzername ist bereits vergeben. Bitte wählen Sie einen anderen.',
            'sw': 'Jina hili la mtumiaji tayari limetumika. Tafadhali chagua jingine.',
            'ha': 'An riga an yi amfani da wannan sunan mai amfani. Ka zaɓi wani daban.',
          }));
        }
        return false;
      }
      _saveProfileToLocal(updatedProfile);
      setState(() => _userProfile = updatedProfile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Kullanıcı adı yerel olarak kaydedildi.',
                'en': 'Username saved locally.',
                'ar': 'تم حفظ اسم المستخدم محليًا.',
                'id': 'Nama pengguna disimpan secara lokal.',
                'ur': 'صارف نام مقامی طور پر محفوظ ہوگیا.',
                'bn': 'ইউজারনেম লোকালি সংরক্ষণ করা হয়েছে.',
                'ms': 'Nama pengguna disimpan secara tempatan.',
                'fa': 'نام کاربری به صورت محلی ذخیره شد.',
                'fr': 'Nom d’utilisateur enregistré localement.',
                'zh': '用户名已本地保存。',
                'ja': 'ユーザー名をローカルに保存しました。',
                'ru': 'Имя пользователя сохранено локально.',
                'de': 'Benutzername lokal gespeichert.',
                'sw': 'Jina la mtumiaji limehifadhiwa hapa kwenye kifaa.',
                'ha': 'An adana sunan mai amfani a gida.',
              }),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return true;
    }
  }

  Future<bool> _updateDisplayName(String displayName) async {
    if (_userProfile == null) return false;
    final updatedProfile = _userProfile!.copyWith(displayName: displayName);
    final canUploadCloud = await _settingsService.getShowInLeaderboard();
    if (!canUploadCloud) {
      _saveProfileToLocal(updatedProfile);
      setState(() => _userProfile = updatedProfile);
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.removeCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Paylaşım kapalı: görünen ad yalnızca yerel kaydedildi.',
                'en': 'Sharing is off: display name was saved locally only.',
                'ar': 'المشاركة مغلقة: تم حفظ الاسم المعروض محليًا فقط.',
                'id': 'Berbagi nonaktif: nama tampilan hanya disimpan lokal.',
                'ur': 'شیئرنگ بند ہے: ڈسپلے نام صرف مقامی طور پر محفوظ ہوا۔',
                'bn': 'শেয়ারিং বন্ধ: ডিসপ্লে নাম শুধু লোকালি সেভ হয়েছে।',
                'ms': 'Perkongsian dimatikan: nama paparan disimpan secara tempatan sahaja.',
                'fa': 'اشتراک غیرفعال است: نام نمایشی فقط به‌صورت محلی ذخیره شد.',
                'fr': 'Partage désactivé : le nom d’affichage a été enregistré localement uniquement.',
                'zh': '分享已关闭：显示名称仅保存在本地。',
                'ja': '共有オフ：表示名はローカル保存のみです。',
                'ru': 'Публикация выключена: отображаемое имя сохранено только локально.',
                'de': 'Freigabe ist aus: Anzeigename wurde nur lokal gespeichert.',
                'sw': 'Ushiriki umezimwa: jina la kuonyesha limehifadhiwa ndani pekee.',
                'ha': 'An kashe rabawa: an adana sunan da ake nunawa a gida kawai.',
              }),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return true;
    }
    try {
      await _supabaseService.updateUserProfile(updatedProfile);
      setState(() => _userProfile = updatedProfile);
      _saveProfileToLocal(updatedProfile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Görünen adı güncellendi!',
                'en': 'Display name updated!',
                'ar': 'تم تحديث الاسم المعروض!',
                'id': 'Nama tampilan diperbarui!',
                'ur': 'ڈسپلے نام اپڈیٹ ہو گیا!',
                'bn': 'ডিসপ্লে নাম আপডেট হয়েছে!',
                'ms': 'Nama paparan dikemas kini!',
                'fa': 'نام نمایشی به‌روزرسانی شد!',
                'fr': 'Nom d’affichage mis à jour !',
                'zh': '显示名称已更新！',
                'ja': '表示名を更新しました！',
                'ru': 'Отображаемое имя обновлено!',
                'de': 'Anzeigename aktualisiert!',
                'sw': 'Jina la kuonyesha limesasishwa!',
                'ha': 'An sabunta sunan da ake nunawa!',
              }),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    } catch (e) {
      print('Error updating display name: $e');
      _saveProfileToLocal(updatedProfile);
      setState(() => _userProfile = updatedProfile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              DynamicLocalizationHelper.getText({
                'tr': 'Görünen ad yerel olarak kaydedildi.',
                'en': 'Display name saved locally.',
                'ar': 'تم حفظ الاسم المعروض محليًا.',
                'id': 'Nama tampilan disimpan secara lokal.',
                'ur': 'ڈسپلے نام مقامی طور پر محفوظ ہوگیا.',
                'bn': 'ডিসপ্লে নাম লোকালি সংরক্ষণ করা হয়েছে.',
                'ms': 'Nama paparan disimpan secara tempatan.',
                'fa': 'نام نمایشی به صورت محلی ذخیره شد.',
                'fr': 'Nom d’affichage enregistré localement.',
                'zh': '显示名称已本地保存。',
                'ja': '表示名をローカルに保存しました。',
                'ru': 'Отображаемое имя сохранено локально.',
                'de': 'Anzeigename lokal gespeichert.',
                'sw': 'Jina la kuonyesha limehifadhiwa hapa kwenye kifaa.',
                'ha': 'An adana sunan da ake nunawa a gida.',
              }),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return true;
    }
  }

  Future<void> _saveProfileToLocal(UserProfile profile) async {
    await _secureStorageService.write('username_${widget.currentUserId}', profile.username);
    await _secureStorageService.write('display_name_${widget.currentUserId}', profile.displayName ?? '');
    if (profile.avatarUrl != null) {
      await _secureStorageService.write('avatar_url_${widget.currentUserId}', profile.avatarUrl!);
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
          content: Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Profil bilgileri güncellendi!',
              'en': 'Profile information updated!',
              'ar': 'تم تحديث معلومات الملف الشخصي!',
              'id': 'Informasi profil diperbarui!',
              'ur': 'پروفائل کی معلومات اپڈیٹ ہو گئیں!',
              'bn': 'প্রোফাইল তথ্য আপডেট হয়েছে!',
              'ms': 'Maklumat profil dikemas kini!',
              'fa': 'اطلاعات پروفایل به‌روزرسانی شد!',
              'fr': 'Informations du profil mises à jour !',
              'zh': '个人资料信息已更新！',
              'ja': 'プロフィール情報を更新しました！',
              'ru': 'Информация профиля обновлена!',
              'de': 'Profilinformationen aktualisiert!',
              'sw': 'Taarifa za wasifu zimesasishwa!',
              'ha': 'An sabunta bayanan martaba!',
            }),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error refreshing profile: $e');
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Profil bilgileri güncellenemedi.',
              'en': 'Could not update profile information.',
              'ar': 'تعذر تحديث معلومات الملف الشخصي.',
              'id': 'Tidak dapat memperbarui informasi profil.',
              'ur': 'پروفائل کی معلومات اپڈیٹ نہیں ہو سکیں.',
              'bn': 'প্রোফাইল তথ্য আপডেট করা যায়নি.',
              'ms': 'Tidak dapat mengemas kini maklumat profil.',
              'fa': 'عدم امکان به‌روزرسانی اطلاعات پروفایل.',
              'fr': 'Impossible de mettre à jour les informations du profil.',
              'zh': '无法更新个人资料信息。',
              'ja': 'プロフィール情報を更新できませんでした。',
              'ru': 'Не удалось обновить информацию профиля.',
              'de': 'Profilinformationen konnten nicht aktualisiert werden.',
              'sw': 'Haikuweza kusasisha taarifa za wasifu.',
              'ha': 'Ba a iya sabunta bayanan martaba.',
            }),
          ),
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

      bool deletedInCloud = false;
      try {
        await _supabaseService.deleteUserAccount(widget.currentUserId);
        deletedInCloud = true;
      } catch (e) {
        // İnternet yoksa ya da RLS hatası varsa burası çalışır.
        // Bu durumda en azından yerel verileri temizliyoruz.
        print('Cloud delete failed: $e');
      }

      // Hesap silme sonrası bildirim planlarını temizle.
      try {
        await _notificationService.cancelReminderNotifications();
      } catch (e) {
        print('Reminder cancel failed: $e');
      }

      // Local verileri temizle (cihaz bazlı hesap akışı için yeterli).
      final prefs = await SharedPreferences.getInstance();
      // Uygulama dilini (kullanıcı verisi değil) koru.
      final savedLanguageCode = prefs.getString('language_code');
      final legacyLanguage = prefs.getString('language');
      final savedLanguage = savedLanguageCode ?? legacyLanguage;
      final localAvatarPath = prefs.getString('avatar_path_${widget.currentUserId}');
      if (localAvatarPath != null && localAvatarPath.isNotEmpty) {
        try {
          final f = File(localAvatarPath);
          if (f.existsSync()) {
            await f.delete();
          }
        } catch (e) {
          print('Local avatar delete failed: $e');
        }
      }
      await prefs.clear();

      // Dil ayarlarını geri yükle (hesap silme sadece kullanıcı verisini etkilesin).
      if (savedLanguage != null && savedLanguage.trim().isNotEmpty) {
        await prefs.setString('language_code', savedLanguage.trim());
      }
      if (savedLanguage != null && savedLanguage.trim().isNotEmpty) {
        await prefs.setString('language', savedLanguage.trim());
      }
      await prefs.setInt('current_count', 0);
      await prefs.setBool('show_in_leaderboard', false);
      await _secureStorageService.delete('user_id_secure');
      await _secureStorageService.delete('username_${widget.currentUserId}');
      await _secureStorageService.delete('display_name_${widget.currentUserId}');
      await _secureStorageService.delete('avatar_url_${widget.currentUserId}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            deletedInCloud
                ? DynamicLocalizationHelper.getText({
                    'tr': 'Hesabınız silindi.',
                    'en': 'Your account was deleted.',
                    'ar': 'تم حذف حسابك.',
                    'id': 'Akun Anda telah dihapus.',
                    'ur': 'آپ کا کھاتہ حذف کر دیا گیا ہے۔',
                    'bn': 'আপনার অ্যাকাউন্ট মুছে ফেলা হয়েছে।',
                    'ms': 'Akaun anda telah dipadamkan.',
                    'fa': 'حساب شما حذف شد.',
                    'fr': 'Votre compte a été supprimé.',
                    'zh': '你的账户已删除。',
                    'ja': 'アカウントを削除しました。',
                    'ru': 'Ваш аккаунт удален.',
                    'de': 'Ihr Konto wurde gelöscht.',
                    'sw': 'Akaunti yako imefutwa.',
                    'ha': 'An goge asusunka.',
                  })
                : DynamicLocalizationHelper.getText({
                    'tr': 'Yerel veriler silindi. İnternet yoksa buluttaki silme işlemi gerçekleşmemiş olabilir.',
                    'en': 'Local data deleted. If there is no internet, the cloud delete may not have completed.',
                    'ar': 'تم حذف البيانات محليًا. إذا لم يكن هناك اتصال بالإنترنت، فقد لا تكتمل عملية الحذف في السحابة.',
                    'id': 'Data lokal dihapus. Jika tidak ada internet, penghapusan di cloud mungkin belum selesai.',
                    'ur': 'مقامی ڈیٹا حذف ہو گیا۔ اگر انٹرنیٹ نہیں تو کلاؤڈ والی ڈیلیٹ مکمل نہیں ہوئی ہو سکتی ہے۔',
                    'bn': 'লোকাল ডেটা মুছে ফেলা হয়েছে। ইন্টারনেট না থাকলে ক্লাউড ডিলিট সম্পন্ন নাও হতে পারে।',
                    'ms': 'Data tempatan dipadamkan. Jika tiada internet, pemadaman di cloud mungkin belum selesai.',
                    'fa': 'داده‌های محلی حذف شد. اگر اینترنت نباشد، ممکن است حذف در ابر کامل نشده باشد.',
                    'fr': 'Données locales supprimées. S’il n’y a pas d’internet, la suppression dans le cloud n’a peut-être pas abouti.',
                    'zh': '已删除本地数据。如果没有网络，云端删除可能未完成。',
                    'ja': 'ローカルデータを削除しました。インターネットがない場合、クラウド側の削除は完了していない可能性があります。',
                    'ru': 'Локальные данные удалены. Если нет интернета, удаление в облаке могло не завершиться.',
                    'de': 'Lokale Daten gelöscht. Ohne Internet kann das Löschen in der Cloud möglicherweise nicht abgeschlossen worden sein.',
                    'sw': 'Data za ndani zimefutwa. Kama hakuna intaneti, kufuta kwenye wingu kunaweza kuwa hakujakamilika.',
                    'ha': 'An goge bayanan cikin gida. Idan babu internet, goge a gajimare yana iya kasa cika.',
                  }),
          ),
          backgroundColor: deletedInCloud ? Colors.green : Colors.orange,
        ),
      );

      // Ana sayfaya dön
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      print('Error deleting account: $e');
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Hesap silinemedi.',
              'en': 'Account could not be deleted.',
              'ar': 'تعذر حذف الحساب.',
              'id': 'Akun tidak dapat dihapus.',
              'ur': 'کھاتہ حذف نہیں ہو سکا۔',
              'bn': 'অ্যাকাউন্ট মুছতে ব্যর্থ হয়েছে।',
              'ms': 'Akaun tidak dapat dipadamkan.',
              'fa': 'حساب قابل حذف نیست.',
              'fr': "Impossible de supprimer le compte.",
              'zh': '无法删除账户。',
              'ja': 'アカウントを削除できませんでした。',
              'ru': 'Не удалось удалить аккаунт.',
              'de': 'Konto konnte nicht gelöscht werden.',
              'sw': 'Akaunti haikuweza kufutwa.',
              'ha': 'Ba a iya goge asusu ba.',
            }),
          ),
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
                                (_userProfile?.displayName != null && _userProfile!.displayName!.isNotEmpty)
                                    ? _userProfile!.displayName!
                                    : (_userProfile?.username ?? 'user'),
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
                  
                  const SizedBox(height: 8),
                  
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
                            'tr': 'Hesap İşlemleri',
                            'en': 'Account Actions',
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
                        Row(
                          children: [
                            Text(
                              DynamicLocalizationHelper.getText({
                                'tr': 'Kupa İlerlemesi',
                                'en': 'Trophy Progress',
                                'ar': 'تقدم الكؤوس',
                                'id': 'Progres Piala',
                                'ur': 'ٹرافی پیش رفت',
                                'bn': 'ট্রফি অগ্রগতি',
                                'ms': 'Kemajuan Trofi',
                                'fa': 'پیشرفت جام‌ها',
                                'fr': 'Progression des trophées',
                                'zh': '奖杯进度',
                                'ja': 'トロフィー進捗',
                                'ru': 'Прогресс трофеев',
                                'de': 'Trophäenfortschritt',
                                'sw': 'Maendeleo ya Nyara',
                                'ha': 'Ci gaban Kofuna',
                              }),
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: widget.themeConfig.textColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${(_unlockedCups.values.where((v) => v).length)}/5)',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: widget.themeConfig.textColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (_unlockedCups.values.any((v) => v))
                              ? '${_unlockedCups.values.where((v) => v).length}/5 ${DynamicLocalizationHelper.getText({
                                  'tr': 'kupa ilerlemesi tamamlandı',
                                  'en': 'trophy progress completed',
                                  'ar': 'اكتمل تقدم الكؤوس',
                                  'id': 'progres piala selesai',
                                  'ur': 'ٹرافی پیش رفت مکمل',
                                  'bn': 'ট্রফি অগ্রগতি সম্পন্ন',
                                  'ms': 'kemajuan trofi selesai',
                                  'fa': 'پیشرفت جام‌ها تکمیل شد',
                                  'fr': 'progression des trophées terminée',
                                  'zh': '奖杯进度已完成',
                                  'ja': 'トロフィー進捗が完了',
                                  'ru': 'прогресс трофеев завершен',
                                  'de': 'Trophäenfortschritt abgeschlossen',
                                  'sw': 'maendeleo ya nyara yamekamilika',
                                  'ha': 'an kammala ci gaban kofuna',
                                })}'
                              : DynamicLocalizationHelper.getText({
                                  'tr': 'Kupa ilerlemesi henüz başlamadı (0/5)',
                                  'en': 'Trophy progress has not started yet (0/5)',
                                  'ar': 'لم يبدأ تقدم الكؤوس بعد (0/5)',
                                  'id': 'Progres piala belum dimulai (0/5)',
                                  'ur': 'ٹرافی پیش رفت ابھی شروع نہیں ہوئی (0/5)',
                                  'bn': 'ট্রফি অগ্রগতি এখনো শুরু হয়নি (0/5)',
                                  'ms': 'Kemajuan trofi belum bermula (0/5)',
                                  'fa': 'پیشرفت جام‌ها هنوز شروع نشده است (0/5)',
                                  'fr': 'La progression des trophées n’a pas encore commencé (0/5)',
                                  'zh': '奖杯进度尚未开始 (0/5)',
                                  'ja': 'トロフィー進捗はまだ開始されていません (0/5)',
                                  'ru': 'Прогресс трофеев еще не начался (0/5)',
                                  'de': 'Der Trophäenfortschritt hat noch nicht begonnen (0/5)',
                                  'sw': 'Maendeleo ya nyara bado hayajaanza (0/5)',
                                  'ha': 'Ci gaban kofuna bai fara ba tukuna (0/5)',
                                }),
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            color: widget.themeConfig.textColor.withValues(alpha: 0.7),
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
