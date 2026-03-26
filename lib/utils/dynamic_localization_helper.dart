import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dinamik localization helper - tüm sabit metinleri dil bazlı yapar
class DynamicLocalizationHelper {
  static String _currentLanguage = 'tr';
  
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code') ?? prefs.getString('language');
    _currentLanguage = code ?? 'tr';
  }
  
  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    // Keep both keys in sync since parts of the app read different legacy keys.
    await prefs.setString('language_code', language);
    await prefs.setString('language', language);
    _currentLanguage = language;
    print('🌐 DynamicLocalizationHelper: Language set to $language');
  }
  
  static String getText(Map<String, String> texts) {
    return texts[_currentLanguage] ?? texts['tr'] ?? texts.values.first ?? '';
  }
  
  static String _getText(Map<String, String> texts) {
    return texts[_currentLanguage] ?? texts['tr'] ?? texts.values.first ?? '';
  }
  
  // Genel metinler
  static String get statistics => _getText({
    'tr': 'İstatistikler',
    'en': 'Statistics', 
    'ar': 'الإحصائيات',
    'id': 'Statistik',
    'ur': 'اعدادیات',
    'bn': 'পরিসংখ্যান',
    'ms': 'Statistik',
    'fa': 'آمار',
    'fr': 'Statistiques',
    'zh': '统计',
    'ja': '統計',
    'ru': 'Статистика',
    'de': 'Statistik',
    'sw': 'Takwimu',
    'ha': 'Kididdigar',
  });
  
  static String get trophies => _getText({
    'tr': 'Kupalar',
    'en': 'Trophies',
    'ar': 'الكؤوس', 
    'id': 'Piala',
    'ur': 'ٹرافیاں',
    'bn': 'ট্রফি',
    'ms': 'Piala',
    'fa': 'جام ها',
    'fr': 'Trophées',
    'zh': '奖杯',
    'ja': 'トロフィー',
    'ru': 'Трофеи',
    'de': 'Trophäen',
    'sw': 'Tuzo',
    'ha': 'Kofuna',
  });
  
  static String get settings => _getText({
    'tr': 'Ayarlar',
    'en': 'Settings',
    'ar': 'الإعدادات',
    'id': 'Pengaturan',
    'ur': 'ترتیبات',
    'bn': 'সেটিংস',
    'ms': 'Tetapan',
    'fa': 'تنظیمات',
    'fr': 'Paramètres',
    'zh': '设置',
    'ja': '設定',
    'ru': 'Настройки',
    'de': 'Einstellungen',
    'sw': 'Mipangilio',
    'ha': 'Saituna',
  });
  
  static String get profile => _getText({
    'tr': 'Profil',
    'en': 'Profile',
    'ar': 'الملف الشخصي',
    'id': 'Profil',
    'ur': 'پروفائل',
    'bn': 'প্রোফাইল',
    'ms': 'Profil',
    'fa': 'پروفایل',
    'fr': 'Profil',
    'zh': '个人资料',
    'ja': 'プロフィール',
    'ru': 'Профиль',
    'de': 'Profil',
    'sw': 'Wasifu',
    'ha': 'Bayanan',
  });
  
  static String get leaderboard => _getText({
    'tr': 'Liderlik Tablosu',
    'en': 'Leaderboard',
    'ar': 'لوحة الصدارة',
    'id': 'Papan Peringkat',
    'ur': 'لیڈربورڈ',
    'bn': 'লিডারবোর্ড',
    'ms': 'Papan Kedudukan',
    'fa': 'جدول امتیازات',
    'fr': 'Classement',
    'zh': '排行榜',
    'ja': 'リーダーボード',
    'ru': 'Таблица лидеров',
    'de': 'Bestenliste',
    'sw': 'Ubao wa Waongozaji',
    'ha': 'Tebur Shugaba',
  });
  
  static String get export => _getText({
    'tr': 'Dışa Aktar',
    'en': 'Export',
    'ar': 'تصدير',
    'id': 'Ekspor',
  });
  
  static String get import => _getText({
    'tr': 'İçe Aktar',
    'en': 'Import',
    'ar': 'استيراد',
    'id': 'Impor',
  });
  
  static String get support => _getText({
    'tr': 'Destek',
    'en': 'Support',
    'ar': 'الدعم',
    'id': 'Dukungan',
  });
  
  static String get about => _getText({
    'tr': 'Hakkında',
    'en': 'About',
    'ar': 'حول',
    'id': 'Tentang',
  });
  
  static String get ok => _getText({
    'tr': 'Tamam',
    'en': 'OK',
    'ar': 'موافق',
    'id': 'OK',
  });
  
  static String get cancel => _getText({
    'tr': 'İptal',
    'en': 'Cancel',
    'ar': 'إلغاء',
    'id': 'Batal',
  });
  
  static String get save => _getText({
    'tr': 'Kaydet',
    'en': 'Save',
    'ar': 'حفظ',
    'id': 'Simpan',
  });
  
  static String get delete => _getText({
    'tr': 'Sil',
    'en': 'Delete',
    'ar': 'حذف',
    'id': 'Hapus',
  });
  
  static String get edit => _getText({
    'tr': 'Düzenle',
    'en': 'Edit',
    'ar': 'تعديل',
    'id': 'Edit',
  });
  
  static String get back => _getText({
    'tr': 'Geri',
    'en': 'Back',
    'ar': 'رجوع',
    'id': 'Kembali',
  });
  
  static String get next => _getText({
    'tr': 'Sonraki',
    'en': 'Next',
    'ar': 'التالي',
    'id': 'Berikutnya',
  });
  
  static String get previous => _getText({
    'tr': 'Önceki',
    'en': 'Previous',
    'ar': 'السابق',
    'id': 'Sebelumnya',
  });
  
  static String get total => _getText({
    'tr': 'Toplam',
    'en': 'Total',
    'ar': 'المجموع',
    'id': 'Total',
  });
  
  static String get daily => _getText({
    'tr': 'Günlük',
    'en': 'Daily',
    'ar': 'يومي',
    'id': 'Harian',
  });
  
  static String get weekly => _getText({
    'tr': 'Haftalık',
    'en': 'Weekly',
    'ar': 'أسبوعي',
    'id': 'Mingguan',
  });
  
  static String get monthly => _getText({
    'tr': 'Aylık',
    'en': 'Monthly',
    'ar': 'شهري',
    'id': 'Bulanan',
  });
  
  static String get year => _getText({
    'tr': 'Yıl',
    'en': 'Year',
    'ar': 'سنة',
    'id': 'Tahun',
  });
  
  static String get theme => _getText({
    'tr': 'Tema',
    'en': 'Theme',
    'ar': 'السمة',
    'id': 'Tema',
  });
  
  static String get language => _getText({
    'tr': 'Dil',
    'en': 'Language',
    'ar': 'اللغة',
    'id': 'Bahasa',
  });
  
  static String get vibration => _getText({
    'tr': 'Titreşim',
    'en': 'Vibration',
    'ar': 'اهتزاز',
    'id': 'Getaran',
  });
  
  static String get sound => _getText({
    'tr': 'Ses',
    'en': 'Sound',
    'ar': 'صوت',
    'id': 'Suara',
  });
  
  static String get darkMode => _getText({
    'tr': 'Karanlık Modu',
    'en': 'Dark Mode',
    'ar': 'الوضع الليلي',
    'id': 'Mode Gelap',
  });
  
  static String get lightMode => _getText({
    'tr': 'Açık Mod',
    'en': 'Light Mode',
    'ar': 'الوضع النهاري',
    'id': 'Mode Terang',
  });
  
  static String get reset => _getText({
    'tr': 'Sıfırla',
    'en': 'Reset',
    'ar': 'إعادة تعيين',
    'id': 'Reset',
  });
  
  static String get target => _getText({
    'tr': 'Hedef',
    'en': 'Target',
    'ar': 'الهدف',
    'id': 'Target',
  });
  
  static String get counter => _getText({
    'tr': 'Sayaç',
    'en': 'Counter',
    'ar': 'عداد',
    'id': 'Penghitung',
  });
  
  static String get continue_ => _getText({
    'tr': 'Devam',
    'en': 'Continue',
    'ar': 'متابعة',
    'id': 'Lanjutkan',
  });
  
  static String get select => _getText({
    'tr': 'Seç',
    'en': 'Select',
    'ar': 'اختر',
    'id': 'Pilih',
  });
  
  static String get add => _getText({
    'tr': 'Ekle',
    'en': 'Add',
    'ar': 'أضف',
    'id': 'Tambah',
  });
  
  static String get remove => _getText({
    'tr': 'Kaldır',
    'en': 'Remove',
    'ar': 'إزالة',
    'id': 'Hapus',
  });
  
  static String get search => _getText({
    'tr': 'Ara',
    'en': 'Search',
    'ar': 'بحث',
    'id': 'Cari',
  });
  
  static String get filter => _getText({
    'tr': 'Filtrele',
    'en': 'Filter',
    'ar': 'تصفية',
    'id': 'Filter',
  });
  
  static String get sort => _getText({
    'tr': 'Sırala',
    'en': 'Sort',
    'ar': 'فرز',
    'id': 'Urutkan',
  });
  
  static String get refresh => _getText({
    'tr': 'Yenile',
    'en': 'Refresh',
    'ar': 'تحديث',
    'id': 'Segarkan',
  });
  
  static String get loading => _getText({
    'tr': 'Yükleniyor...',
    'en': 'Loading...',
    'ar': 'جاري التحميل...',
    'id': 'Memuat...',
  });
  
  static String get error => _getText({
    'tr': 'Hata',
    'en': 'Error',
    'ar': 'خطأ',
    'id': 'Kesalahan',
  });
  
  static String get success => _getText({
    'tr': 'Başarılı',
    'en': 'Success',
    'ar': 'نجاح',
    'id': 'Berhasil',
  });
  
  static String get warning => _getText({
    'tr': 'Uyarı',
    'en': 'Warning',
    'ar': 'تحذير',
    'id': 'Peringatan',
  });
  
  static String get info => _getText({
    'tr': 'Bilgi',
    'en': 'Info',
    'ar': 'معلومات',
    'id': 'Info',
  });
  
  static String get yes => _getText({
    'tr': 'Evet',
    'en': 'Yes',
    'ar': 'نعم',
    'id': 'Ya',
  });
  
  static String get no => _getText({
    'tr': 'Hayır',
    'en': 'No',
    'ar': 'لا',
    'id': 'Tidak',
  });
  
  static String get share => _getText({
    'tr': 'Paylaş',
    'en': 'Share',
    'ar': 'مشاركة',
    'id': 'Bagikan',
  });
  
  static String get copy => _getText({
    'tr': 'Kopyala',
    'en': 'Copy',
    'ar': 'نسخ',
    'id': 'Salin',
  });
  
  static String get paste => _getText({
    'tr': 'Yapıştır',
    'en': 'Paste',
    'ar': 'لصق',
    'id': 'Tempel',
  });
  
  static String get cut => _getText({
    'tr': 'Kes',
    'en': 'Cut',
    'ar': 'قص',
    'id': 'Potong',
  });
  
  static String get undo => _getText({
    'tr': 'Geri Al',
    'en': 'Undo',
    'ar': 'تراجع',
    'id': 'Batalkan',
  });
  
  static String get redo => _getText({
    'tr': 'Yinele',
    'en': 'Redo',
    'ar': 'إعادة',
    'id': 'Ulangi',
  });
  
  static String get help => _getText({
    'tr': 'Yardım',
    'en': 'Help',
    'ar': 'مساعدة',
    'id': 'Bantuan',
  });
  
  static String get feedback => _getText({
    'tr': 'Geri Bildirim',
    'en': 'Feedback',
    'ar': 'ملاحظات',
    'id': 'Masukan',
  });
  
  static String get contact => _getText({
    'tr': 'İletişim',
    'en': 'Contact',
    'ar': 'اتصل',
    'id': 'Kontak',
  });
  
  static String get website => _getText({
    'tr': 'Web Sitesi',
    'en': 'Website',
    'ar': 'الموقع الإلكتروني',
    'id': 'Situs Web',
  });
  
  static String get github => _getText({
    'tr': 'GitHub',
    'en': 'GitHub',
    'ar': 'GitHub',
    'id': 'GitHub',
  });
  
  static String get email => _getText({
    'tr': 'E-posta',
    'en': 'Email',
    'ar': 'البريد الإلكتروني',
    'id': 'Email',
  });
  
  static String get phone => _getText({
    'tr': 'Telefon',
    'en': 'Phone',
    'ar': 'هاتف',
    'id': 'Telepon',
  });
  
  static String get address => _getText({
    'tr': 'Adres',
    'en': 'Address',
    'ar': 'عنوان',
    'id': 'Alamat',
  });
  
  static String get name => _getText({
    'tr': 'Ad',
    'en': 'Name',
    'ar': 'الاسم',
    'id': 'Nama',
  });
  
  static String get description => _getText({
    'tr': 'Açıklama',
    'en': 'Description',
    'ar': 'الوصف',
    'id': 'Deskripsi',
  });
  
  static String get date => _getText({
    'tr': 'Tarih',
    'en': 'Date',
    'ar': 'التاريخ',
    'id': 'Tanggal',
  });
  
  static String get time => _getText({
    'tr': 'Saat',
    'en': 'Time',
    'ar': 'الوقت',
    'id': 'Waktu',
  });
  
  static String get hour => _getText({
    'tr': 'Saat',
    'en': 'Hour',
    'ar': 'ساعة',
    'id': 'Jam',
  });
  
  static String get minute => _getText({
    'tr': 'Dakika',
    'en': 'Minute',
    'ar': 'دقيقة',
    'id': 'Menit',
  });
  
  static String get second => _getText({
    'tr': 'Saniye',
    'en': 'Second',
    'ar': 'ثانية',
    'id': 'Detik',
  });
  
  static String get day => _getText({
    'tr': 'Gün',
    'en': 'Day',
    'ar': 'يوم',
    'id': 'Hari',
  });
  
  static String get week => _getText({
    'tr': 'Hafta',
    'en': 'Week',
    'ar': 'أسبوع',
    'id': 'Minggu',
  });
  
  static String get month => _getText({
    'tr': 'Ay',
    'en': 'Month',
    'ar': 'شهر',
    'id': 'Bulan',
  });
  
  static String get level => _getText({
    'tr': 'Seviye',
    'en': 'Level',
    'ar': 'مستوى',
    'id': 'Level',
  });
  
  static String get score => _getText({
    'tr': 'Skor',
    'en': 'Score',
    'ar': 'درجة',
    'id': 'Skor',
  });
  
  static String get rank => _getText({
    'tr': 'Sıralama',
    'en': 'Rank',
    'ar': 'ترتيب',
    'id': 'Peringkat',
  });
  
  static String get achievement => _getText({
    'tr': 'Başarı',
    'en': 'Achievement',
    'ar': 'إنجاز',
    'id': 'Pencapaian',
  });
  
  static String get bronze => _getText({
    'tr': 'Bronz',
    'en': 'Bronze',
    'ar': 'برونزي',
    'id': 'Perunggu',
  });
  
  static String get silver => _getText({
    'tr': 'Gümüş',
    'en': 'Silver',
    'ar': 'فضي',
    'id': 'Perak',
  });
  
  static String get gold => _getText({
    'tr': 'Altın',
    'en': 'Gold',
    'ar': 'ذهبي',
    'id': 'Emas',
  });
  
  static String get diamond => _getText({
    'tr': 'Elmas',
    'en': 'Diamond',
    'ar': 'ماسي',
    'id': 'Berlian',
  });
  
  static String get platinum => _getText({
    'tr': 'Platin',
    'en': 'Platinum',
    'ar': 'بلاتين',
    'id': 'Platinum',
  });
  
  static String get unlocked => _getText({
    'tr': 'Kilidi Açıldı',
    'en': 'Unlocked',
    'ar': 'تم فتح القفل',
    'id': 'Dibuka',
  });
  
  static String get locked => _getText({
    'tr': 'Kilitli',
    'en': 'Locked',
    'ar': 'مقفل',
    'id': 'Terkunci',
  });
  
  static String get progress => _getText({
    'tr': 'İlerleme',
    'en': 'Progress',
    'ar': 'التقدم',
    'id': 'Kemajuan',
  });
  
  static String get completed => _getText({
    'tr': 'Tamamlandı',
    'en': 'Completed',
    'ar': 'مكتمل',
    'id': 'Selesai',
  });
  
  static String get pending => _getText({
    'tr': 'Bekliyor',
    'en': 'Pending',
    'ar': 'في انتظار',
    'id': 'Menunggu',
  });
  
  static String get active => _getText({
    'tr': 'Aktif',
    'en': 'Active',
    'ar': 'نشط',
    'id': 'Aktif',
  });
  
  static String get inactive => _getText({
    'tr': 'Pasif',
    'en': 'Inactive',
    'ar': 'غير نشط',
    'id': 'Tidak Aktif',
  });
  
  static String get online => _getText({
    'tr': 'Çevrimiçi',
    'en': 'Online',
    'ar': 'متصل',
    'id': 'Daring',
  });
  
  static String get offline => _getText({
    'tr': 'Çevrimdışı',
    'en': 'Offline',
    'ar': 'غير متصل',
    'id': 'Luring',
  });
  
  static String get connected => _getText({
    'tr': 'Bağlandı',
    'en': 'Connected',
    'ar': 'متصل',
    'id': 'Terhubung',
  });
  
  static String get disconnected => _getText({
    'tr': 'Bağlantı Kesildi',
    'en': 'Disconnected',
    'ar': 'انقطع الاتصال',
    'id': 'Terputus',
  });
  
  static String get sync => _getText({
    'tr': 'Senkronize Et',
    'en': 'Sync',
    'ar': 'مزامنة',
    'id': 'Sinkronisasi',
  });
  
  static String get backup => _getText({
    'tr': 'Yedekle',
    'en': 'Backup',
    'ar': 'نسخ احتياطي',
    'id': 'Cadangkan',
  });
  
  static String get restore => _getText({
    'tr': 'Geri Yükle',
    'en': 'Restore',
    'ar': 'استعادة',
    'id': 'Pulihkan',
  });
  
  static String get download => _getText({
    'tr': 'İndir',
    'en': 'Download',
    'ar': 'تنزيل',
    'id': 'Unduh',
  });
  
  static String get upload => _getText({
    'tr': 'Yükle',
    'en': 'Upload',
    'ar': 'رفع',
    'id': 'Unggah',
  });
  
  static String get file => _getText({
    'tr': 'Dosya',
    'en': 'File',
    'ar': 'ملف',
    'id': 'File',
  });
  
  static String get folder => _getText({
    'tr': 'Klasör',
    'en': 'Folder',
    'ar': 'مجلد',
    'id': 'Folder',
  });
  
  static String get image => _getText({
    'tr': 'Resim',
    'en': 'Image',
    'ar': 'صورة',
    'id': 'Gambar',
  });
  
  static String get video => _getText({
    'tr': 'Video',
    'en': 'Video',
    'ar': 'فيديو',
    'id': 'Video',
  });
  
  static String get audio => _getText({
    'tr': 'Ses',
    'en': 'Audio',
    'ar': 'صوت',
    'id': 'Audio',
  });
  
  static String get document => _getText({
    'tr': 'Belge',
    'en': 'Document',
    'ar': 'وثيقة',
    'id': 'Dokumen',
  });
  
  static String get camera => _getText({
    'tr': 'Kamera',
    'en': 'Camera',
    'ar': 'كاميرا',
    'id': 'Kamera',
  });
  
  static String get gallery => _getText({
    'tr': 'Galeri',
    'en': 'Gallery',
    'ar': 'معرض الصور',
    'id': 'Galeri',
  });
  
  static String get permission => _getText({
    'tr': 'İzin',
    'en': 'Permission',
    'ar': 'إذن',
    'id': 'Izin',
  });
  
  static String get allow => _getText({
    'tr': 'İzin Ver',
    'en': 'Allow',
    'ar': 'سماح',
    'id': 'Izinkan',
  });
  
  static String get deny => _getText({
    'tr': 'Reddet',
    'en': 'Deny',
    'ar': 'رفض',
    'id': 'Tolak',
  });
  
  static String get enable => _getText({
    'tr': 'Etkinleştir',
    'en': 'Enable',
    'ar': 'تفعيل',
    'id': 'Aktifkan',
  });
  
  static String get disable => _getText({
    'tr': 'Devre Dışı Bırak',
    'en': 'Disable',
    'ar': 'تعطيل',
    'id': 'Nonaktifkan',
  });
  
  static String get on => _getText({
    'tr': 'Açık',
    'en': 'On',
    'ar': 'مفعل',
    'id': 'Aktif',
  });
  
  static String get off => _getText({
    'tr': 'Kapalı',
    'en': 'Off',
    'ar': 'معطل',
    'id': 'Nonaktif',
  });
  
  static String get open => _getText({
    'tr': 'Aç',
    'en': 'Open',
    'ar': 'فتح',
    'id': 'Buka',
  });
  
  static String get close => _getText({
    'tr': 'Kapat',
    'en': 'Close',
    'ar': 'إغلاق',
    'id': 'Tutup',
  });
  
  static String get exit => _getText({
    'tr': 'Çık',
    'en': 'Exit',
    'ar': 'خروج',
    'id': 'Keluar',
  });
  
  static String get quit => _getText({
    'tr': 'Çık',
    'en': 'Quit',
    'ar': 'استقال',
    'id': 'Keluar',
  });
  
  static String get start => _getText({
    'tr': 'Başla',
    'en': 'Start',
    'ar': 'ابدأ',
    'id': 'Mulai',
  });
  
  static String get stop => _getText({
    'tr': 'Dur',
    'en': 'Stop',
    'ar': 'توقف',
    'id': 'Berhenti',
  });
  
  static String get pause => _getText({
    'tr': 'Duraklat',
    'en': 'Pause',
    'ar': 'إيقاف',
    'id': 'Jeda',
  });
  
  static String get play => _getText({
    'tr': 'Oynat',
    'en': 'Play',
    'ar': 'تشغيل',
    'id': 'Mainkan',
  });
  
  static String get retry => _getText({
    'tr': 'Tekrar Dene',
    'en': 'Retry',
    'ar': 'إعادة المحاولة',
    'id': 'Coba Lagi',
  });
  
  static String get skip => _getText({
    'tr': 'Atla',
    'en': 'Skip',
    'ar': 'تخطي',
    'id': 'Lewati',
  });
  
  static String get next_ => _getText({
    'tr': 'Sonraki',
    'en': 'Next',
    'ar': 'التالي',
    'id': 'Berikutnya',
  });
  
  static String get previous_ => _getText({
    'tr': 'Önceki',
    'en': 'Previous',
    'ar': 'السابق',
    'id': 'Sebelumnya',
  });
  
  static String get first => _getText({
    'tr': 'İlk',
    'en': 'First',
    'ar': 'الأول',
    'id': 'Pertama',
  });
  
  static String get last => _getText({
    'tr': 'Son',
    'en': 'Last',
    'ar': 'الأخير',
    'id': 'Terakhir',
  });
  
  static String get all => _getText({
    'tr': 'Tümü',
    'en': 'All',
    'ar': 'الكل',
    'id': 'Semua',
  });
  
  static String get none => _getText({
    'tr': 'Hiçbiri',
    'en': 'None',
    'ar': 'لا شيء',
    'id': 'Tidak Ada',
  });
  
  static String get any => _getText({
    'tr': 'Herhangi',
    'en': 'Any',
    'ar': 'أي',
    'id': 'Apapun',
  });
  
  static String get other => _getText({
    'tr': 'Diğer',
    'en': 'Other',
    'ar': 'أخرى',
    'id': 'Lainnya',
  });
  
  static String get more => _getText({
    'tr': 'Daha Fazla',
    'en': 'More',
    'ar': 'المزيد',
    'id': 'Lebih Banyak',
  });
  
  static String get less => _getText({
    'tr': 'Daha Az',
    'en': 'Less',
    'ar': 'أقل',
    'id': 'Kurang',
  });
  
  static String get new_ => _getText({
    'tr': 'Yeni',
    'en': 'New',
    'ar': 'جديد',
    'id': 'Baru',
  });
  
  static String get old => _getText({
    'tr': 'Eski',
    'en': 'Old',
    'ar': 'قديم',
    'id': 'Lama',
  });
  
  static String get recent => _getText({
    'tr': 'Son',
    'en': 'Recent',
    'ar': 'الحديث',
    'id': 'Baru-baru Ini',
  });
  
  static String get favorite => _getText({
    'tr': 'Favori',
    'en': 'Favorite',
    'ar': 'المفضلة',
    'id': 'Favorit',
  });
  
  static String get bookmark => _getText({
    'tr': 'Yer İmi',
    'en': 'Bookmark',
    'ar': 'علامة مرجعية',
    'id': 'Penanda',
  });
  
  static String get history => _getText({
    'tr': 'Geçmiş',
    'en': 'History',
    'ar': 'التاريخ',
    'id': 'Riwayat',
  });
  
  static String get log => _getText({
    'tr': 'Günlük',
    'en': 'Log',
    'ar': 'سجل',
    'id': 'Log',
  });
  
  static String get report => _getText({
    'tr': 'Rapor',
    'en': 'Report',
    'ar': 'تقرير',
    'id': 'Laporan',
  });
  
  static String get statistics_ => _getText({
    'tr': 'İstatistikler',
    'en': 'Statistics',
    'ar': 'الإحصائيات',
    'id': 'Statistik',
  });
  
  static String get analytics => _getText({
    'tr': 'Analitik',
    'en': 'Analytics',
    'ar': 'التحليلات',
    'id': 'Analitik',
  });
  
  static String get performance => _getText({
    'tr': 'Performans',
    'en': 'Performance',
    'ar': 'الأداء',
    'id': 'Kinerja',
  });
  
  static String get quality => _getText({
    'tr': 'Kalite',
    'en': 'Quality',
    'ar': 'الجودة',
    'id': 'Kualitas',
  });
  
  static String get speed => _getText({
    'tr': 'Hız',
    'en': 'Speed',
    'ar': 'السرعة',
    'id': 'Kecepatan',
  });
  
  static String get size => _getText({
    'tr': 'Boyut',
    'en': 'Size',
    'ar': 'الحجم',
    'id': 'Ukuran',
  });
  
  static String get color => _getText({
    'tr': 'Renk',
    'en': 'Color',
    'ar': 'اللون',
    'id': 'Warna',
  });
  
  static String get style => _getText({
    'tr': 'Stil',
    'en': 'Style',
    'ar': 'النمط',
    'id': 'Gaya',
  });
  
  static String get design => _getText({
    'tr': 'Tasarım',
    'en': 'Design',
    'ar': 'تصميم',
    'id': 'Desain',
  });
  
  static String get layout => _getText({
    'tr': 'Yerleşim',
    'en': 'Layout',
    'ar': 'تخطيط',
    'id': 'Tata Letak',
  });
  
  static String get format => _getText({
    'tr': 'Format',
    'en': 'Format',
    'ar': 'تنسيق',
    'id': 'Format',
  });
  
  static String get option => _getText({
    'tr': 'Seçenek',
    'en': 'Option',
    'ar': 'خيار',
    'id': 'Opsi',
  });
  
  static String get setting => _getText({
    'tr': 'Ayar',
    'en': 'Setting',
    'ar': 'إعداد',
    'id': 'Pengaturan',
  });
  
  static String get configuration => _getText({
    'tr': 'Yapılandırma',
    'en': 'Configuration',
    'ar': 'تكوين',
    'id': 'Konfigurasi',
  });
  
  static String get preference => _getText({
    'tr': 'Tercih',
    'en': 'Preference',
    'ar': 'تفضيل',
    'id': 'Preferensi',
  });
  
  static String get custom => _getText({
    'tr': 'Özel',
    'en': 'Custom',
    'ar': 'مخصص',
    'id': 'Kustom',
  });
  
  static String get default_ => _getText({
    'tr': 'Varsayılan',
    'en': 'Default',
    'ar': 'افتراضي',
    'id': 'Bawaan',
  });
  
  static String get automatic => _getText({
    'tr': 'Otomatik',
    'en': 'Automatic',
    'ar': 'تلقائي',
    'id': 'Otomatis',
  });
  
  static String get manual => _getText({
    'tr': 'Manuel',
    'en': 'Manual',
    'ar': 'يدوي',
    'id': 'Manual',
  });
  
  static String get secure => _getText({
    'tr': 'Güvenli',
    'en': 'Secure',
    'ar': 'آمن',
    'id': 'Aman',
  });
  
  static String get private => _getText({
    'tr': 'Özel',
    'en': 'Private',
    'ar': 'خاص',
    'id': 'Pribadi',
  });
  
  static String get public => _getText({
    'tr': 'Herkese Açık',
    'en': 'Public',
    'ar': 'عام',
    'id': 'Publik',
  });
  
  static String get hidden => _getText({
    'tr': 'Gizli',
    'en': 'Hidden',
    'ar': 'مخفي',
    'id': 'Tersembunyi',
  });
  
  static String get visible => _getText({
    'tr': 'Görünür',
    'en': 'Visible',
    'ar': 'مرئي',
    'id': 'Terlihat',
  });
  
  static String get available => _getText({
    'tr': 'Mevcut',
    'en': 'Available',
    'ar': 'متاح',
    'id': 'Tersedia',
  });
  
  static String get unavailable => _getText({
    'tr': 'Mevcut Değil',
    'en': 'Unavailable',
    'ar': 'غير متاح',
    'id': 'Tidak Tersedia',
  });
  
  static String get required => _getText({
    'tr': 'Gerekli',
    'en': 'Required',
    'ar': 'مطلوب',
    'id': 'Diperlukan',
  });
  
  static String get optional => _getText({
    'tr': 'İsteğe Bağlı',
    'en': 'Optional',
    'ar': 'اختياري',
    'id': 'Opsional',
  });
  
  static String get recommended => _getText({
    'tr': 'Önerilen',
    'en': 'Recommended',
    'ar': 'موصى به',
    'id': 'Direkomendasikan',
  });
  
  static String get suggested => _getText({
    'tr': 'Önerilen',
    'en': 'Suggested',
    'ar': 'مقترح',
    'id': 'Disarankan',
  });
  
  static String get popular => _getText({
    'tr': 'Popüler',
    'en': 'Popular',
    'ar': 'شائع',
    'id': 'Populer',
  });
  
  static String get trending => _getText({
    'tr': 'Trend',
    'en': 'Trending',
    'ar': 'الرائج',
    'id': 'Tren',
  });
  
  static String get featured => _getText({
    'tr': 'Öne Çıkan',
    'en': 'Featured',
    'ar': 'مميز',
    'id': 'Unggulan',
  });
  
  static String get latest => _getText({
    'tr': 'En Son',
    'en': 'Latest',
    'ar': 'الأحدث',
    'id': 'Terbaru',
  });
  
  static String get updated => _getText({
    'tr': 'Güncellendi',
    'en': 'Updated',
    'ar': 'محدث',
    'id': 'Diperbarui',
  });
  
  static String get created => _getText({
    'tr': 'Oluşturuldu',
    'en': 'Created',
    'ar': 'تم إنشاؤه',
    'id': 'Dibuat',
  });
  
  static String get modified => _getText({
    'tr': 'Değiştirildi',
    'en': 'Modified',
    'ar': 'تم تعديله',
    'id': 'Dimodifikasi',
  });
  
  static String get deleted => _getText({
    'tr': 'Silindi',
    'en': 'Deleted',
    'ar': 'تم حذفه',
    'id': 'Dihapus',
  });
  
  static String get archived => _getText({
    'tr': 'Arşivlendi',
    'en': 'Archived',
    'ar': 'مؤرشف',
    'id': 'Diarsipkan',
  });
  
  static String get expired => _getText({
    'tr': 'Süresi Doldu',
    'en': 'Expired',
    'ar': 'منتهي الصلاحية',
    'id': 'Kedaluwarsa',
  });
  
  static String get valid => _getText({
    'tr': 'Geçerli',
    'en': 'Valid',
    'ar': 'صالح',
    'id': 'Valid',
  });
  
  static String get invalid => _getText({
    'tr': 'Geçersiz',
    'en': 'Invalid',
    'ar': 'غير صالح',
    'id': 'Tidak Valid',
  });
  
  static String get correct => _getText({
    'tr': 'Doğru',
    'en': 'Correct',
    'ar': 'صحيح',
    'id': 'Benar',
  });
  
  static String get incorrect => _getText({
    'tr': 'Yanlış',
    'en': 'Incorrect',
    'ar': 'غير صحيح',
    'id': 'Salah',
  });
  
  static String get true_ => _getText({
    'tr': 'Doğru',
    'en': 'True',
    'ar': 'صحيح',
    'id': 'Benar',
  });
  
  static String get false_ => _getText({
    'tr': 'Yanlış',
    'en': 'False',
    'ar': 'خطأ',
    'id': 'Salah',
  });
  
  static String get unknown => _getText({
    'tr': 'Bilinmeyen',
    'en': 'Unknown',
    'ar': 'غير معروف',
    'id': 'Tidak Dikenal',
  });
  
  static String get empty => _getText({
    'tr': 'Boş',
    'en': 'Empty',
    'ar': 'فارغ',
    'id': 'Kosong',
  });
  
  static String get full => _getText({
    'tr': 'Dolu',
    'en': 'Full',
    'ar': 'ممتلئ',
    'id': 'Penuh',
  });
  
  static String get partial => _getText({
    'tr': 'Kısmi',
    'en': 'Partial',
    'ar': 'جزئي',
    'id': 'Sebagian',
  });
  
  static String get complete => _getText({
    'tr': 'Tamamlandı',
    'en': 'Complete',
    'ar': 'مكتمل',
    'id': 'Lengkap',
  });
  
  static String get incomplete => _getText({
    'tr': 'Tamamlanmadı',
    'en': 'Incomplete',
    'ar': 'غير مكتمل',
    'id': 'Tidak Lengkap',
  });
  
  static String get ready => _getText({
    'tr': 'Hazır',
    'en': 'Ready',
    'ar': 'جاهز',
    'id': 'Siap',
  });
  
  static String get busy => _getText({
    'tr': 'Meşgul',
    'en': 'Busy',
    'ar': 'مشغول',
    'id': 'Sibuk',
  });
  
  static String get idle => _getText({
    'tr': 'Boşta',
    'en': 'Idle',
    'ar': 'خامل',
    'id': 'Menganggur',
  });
  
  static String get running => _getText({
    'tr': 'Çalışıyor',
    'en': 'Running',
    'ar': 'يعمل',
    'id': 'Berjalan',
  });
  
  static String get stopped => _getText({
    'tr': 'Durdu',
    'en': 'Stopped',
    'ar': 'توقف',
    'id': 'Berhenti',
  });
  
  static String get failed => _getText({
    'tr': 'Başarısız',
    'en': 'Failed',
    'ar': 'فشل',
    'id': 'Gagal',
  });
  
  static String get successful => _getText({
    'tr': 'Başarılı',
    'en': 'Successful',
    'ar': 'نجح',
    'id': 'Berhasil',
  });
  
  static String get pending_ => _getText({
    'tr': 'Beklemede',
    'en': 'Pending',
    'ar': 'في انتظار',
    'id': 'Menunggu',
  });
  
  static String get processing => _getText({
    'tr': 'İşleniyor',
    'en': 'Processing',
    'ar': 'قيد المعالجة',
    'id': 'Memproses',
  });
  
  static String get finished => _getText({
    'tr': 'Bitti',
    'en': 'Finished',
    'ar': 'انتهى',
    'id': 'Selesai',
  });
  
  static String get cancelled => _getText({
    'tr': 'İptal Edildi',
    'en': 'Cancelled',
    'ar': 'تم إلغاؤه',
    'id': 'Dibatalkan',
  });
  
  static String get aborted => _getText({
    'tr': 'İptal Edildi',
    'en': 'Aborted',
    'ar': 'تم إجهاضه',
    'id': 'Dibatalkan',
  });
  
  static String get timeout => _getText({
    'tr': 'Zaman Aşımı',
    'en': 'Timeout',
    'ar': 'انتهت المهلة',
    'id': 'Waktu Habis',
  });
  
  static String get limit => _getText({
    'tr': 'Limit',
    'en': 'Limit',
    'ar': 'الحد',
    'id': 'Batas',
  });
  
  static String get exceeded => _getText({
    'tr': 'Aşıldı',
    'en': 'Exceeded',
    'ar': 'تجاوز',
    'id': 'Melebihi',
  });
  
  static String get insufficient => _getText({
    'tr': 'Yetersiz',
    'en': 'Insufficient',
    'ar': 'غير كافي',
    'id': 'Tidak Cukup',
  });
  
  static String get enough => _getText({
    'tr': 'Yeterli',
    'en': 'Enough',
    'ar': 'كافي',
    'id': 'Cukup',
  });
  
  static String get too => _getText({
    'tr': 'Çok',
    'en': 'Too',
    'ar': 'كثير جدا',
    'id': 'Terlalu',
  });
  
  static String get little => _getText({
    'tr': 'Az',
    'en': 'Little',
    'ar': 'قليل',
    'id': 'Sedikit',
  });
  
  static String get much => _getText({
    'tr': 'Çok',
    'en': 'Much',
    'ar': 'كثير',
    'id': 'Banyak',
  });
  
  static String get few => _getText({
    'tr': 'Az',
    'en': 'Few',
    'ar': 'قليل',
    'id': 'Sedikit',
  });
  
  static String get many => _getText({
    'tr': 'Çok',
    'en': 'Many',
    'ar': 'كثير',
    'id': 'Banyak',
  });
  
  static String get several => _getText({
    'tr': 'Birkaç',
    'en': 'Several',
    'ar': 'عدة',
    'id': 'Beberapa',
  });
  
  static String get multiple => _getText({
    'tr': 'Çoklu',
    'en': 'Multiple',
    'ar': 'متعدد',
    'id': 'Beberapa',
  });
  
  static String get single => _getText({
    'tr': 'Tek',
    'en': 'Single',
    'ar': 'واحد',
    'id': 'Tunggal',
  });
  
  static String get double => _getText({
    'tr': 'Çift',
    'en': 'Double',
    'ar': 'مزدوج',
    'id': 'Ganda',
  });
  
  static String get triple => _getText({
    'tr': 'Üçlü',
    'en': 'Triple',
    'ar': 'ثلاثي',
    'id': 'Tiga',
  });
  
  static String get once => _getText({
    'tr': 'Bir Kez',
    'en': 'Once',
    'ar': 'مرة واحدة',
    'id': 'Sekali',
  });
  
  static String get twice => _getText({
    'tr': 'İki Kez',
    'en': 'Twice',
    'ar': 'مرتين',
    'id': 'Dua Kali',
  });
  
  static String get thrice => _getText({
    'tr': 'Üç Kez',
    'en': 'Thrice',
    'ar': 'ثلاث مرات',
    'id': 'Tiga Kali',
  });
  
  static String get always => _getText({
    'tr': 'Her Zaman',
    'en': 'Always',
    'ar': 'دائما',
    'id': 'Selalu',
  });
  
  static String get never => _getText({
    'tr': 'Asla',
    'en': 'Never',
    'ar': 'أبدا',
    'id': 'Tidak Pernah',
  });
  
  static String get sometimes => _getText({
    'tr': 'Bazen',
    'en': 'Sometimes',
    'ar': 'أحيانا',
    'id': 'Kadang-kadang',
  });
  
  static String get often => _getText({
    'tr': 'Sık Sık',
    'en': 'Often',
    'ar': 'غالبا',
    'id': 'Sering',
  });
  
  static String get rarely => _getText({
    'tr': 'Nadiren',
    'en': 'Rarely',
    'ar': 'نادرا',
    'id': 'Jarang',
  });
  
  static String get usually => _getText({
    'tr': 'Genellikle',
    'en': 'Usually',
    'ar': 'عادة',
    'id': 'Biasanya',
  });
  
  static String get normally => _getText({
    'tr': 'Normalde',
    'en': 'Normally',
    'ar': 'عادة',
    'id': 'Normalnya',
  });
  
  static String get occasionally => _getText({
    'tr': 'Ara Sıra',
    'en': 'Occasionally',
    'ar': 'أحيانا',
    'id': 'Kadang-kadang',
  });
  
  static String get frequently => _getText({
    'tr': 'Sıkça',
    'en': 'Frequently',
    'ar': 'بشكل متكرر',
    'id': 'Sering',
  });
  
  static String get occasionally_ => _getText({
    'tr': 'Bazen',
    'en': 'Occasionally',
    'ar': 'أحيانا',
    'id': 'Kadang-kadang',
  });
  
  static String get seldom => _getText({
    'tr': 'Nadiren',
    'en': 'Seldom',
    'ar': 'نادرا',
    'id': 'Jarang',
  });
  
  static String get hardly => _getText({
    'tr': 'Neredeyse',
    'en': 'Hardly',
    'ar': 'نادرا جدا',
    'id': 'Jarang',
  });
  
  static String get barely => _getText({
    'tr': 'Zorla',
    'en': 'Barely',
    'ar': 'بالكاد',
    'id': 'Sulit',
  });
  
  static String get almost => _getText({
    'tr': 'Neredeyse',
    'en': 'Almost',
    'ar': 'تقريبا',
    'id': 'Hampir',
  });
  
  static String get nearly => _getText({
    'tr': 'Neredeyse',
    'en': 'Nearly',
    'ar': 'تقريبا',
    'id': 'Hampir',
  });
  
  static String get approximately => _getText({
    'tr': 'Yaklaşık',
    'en': 'Approximately',
    'ar': 'تقريبا',
    'id': 'Kira-kira',
  });
  
  static String get exactly => _getText({
    'tr': 'Tam Olarak',
    'en': 'Exactly',
    'ar': 'تماما',
    'id': 'Tepat',
  });
  
  static String get precisely => _getText({
    'tr': 'Tam Olarak',
    'en': 'Precisely',
    'ar': 'بشكل دقيق',
    'id': 'Tepat',
  });
  
  static String get roughly => _getText({
    'tr': 'Yaklaşık',
    'en': 'Roughly',
    'ar': 'تقريبا',
    'id': 'Kira-kira',
  });
  
  static String get about_ => _getText({
    'tr': 'Hakkında',
    'en': 'About',
    'ar': 'حول',
    'id': 'Tentang',
  });
  
  static String get around => _getText({
    'tr': 'Yaklaşık',
    'en': 'Around',
    'ar': 'حول',
    'id': 'Sekitar',
  });
  
  static String get between => _getText({
    'tr': 'Arasında',
    'en': 'Between',
    'ar': 'بين',
    'id': 'Antara',
  });
  
  static String get among => _getText({
    'tr': 'Arasında',
    'en': 'Among',
    'ar': 'بين',
    'id': 'Di Antara',
  });
  
  static String get within => _getText({
    'tr': 'İçinde',
    'en': 'Within',
    'ar': 'داخل',
    'id': 'Dalam',
  });
  
  static String get outside => _getText({
    'tr': 'Dışında',
    'en': 'Outside',
    'ar': 'خارج',
    'id': 'Di Luar',
  });
  
  static String get inside => _getText({
    'tr': 'İçinde',
    'en': 'Inside',
    'ar': 'داخل',
    'id': 'Di Dalam',
  });
  
  static String get above => _getText({
    'tr': 'Üstünde',
    'en': 'Above',
    'ar': 'فوق',
    'id': 'Di Atas',
  });
  
  static String get below => _getText({
    'tr': 'Altında',
    'en': 'Below',
    'ar': 'تحت',
    'id': 'Di Bawah',
  });
  
  static String get before => _getText({
    'tr': 'Önce',
    'en': 'Before',
    'ar': 'قبل',
    'id': 'Sebelum',
  });
  
  static String get after => _getText({
    'tr': 'Sonra',
    'en': 'After',
    'ar': 'بعد',
    'id': 'Setelah',
  });
  
  static String get during => _getText({
    'tr': 'Sırasında',
    'en': 'During',
    'ar': 'أثناء',
    'id': 'Selama',
  });
  
  static String get since => _getText({
    'tr': 'Şu Kadar',
    'en': 'Since',
    'ar': 'منذ',
    'id': 'Sejak',
  });
  
  static String get until => _getText({
    'tr': 'Kadar',
    'en': 'Until',
    'ar': 'حتى',
    'id': 'Hingga',
  });
  
  static String get while_ => _getText({
    'tr': 'Sırasında',
    'en': 'While',
    'ar': 'أثناء',
    'id': 'Selama',
  });
  
  static String get when_ => _getText({
    'tr': 'Zaman',
    'en': 'When',
    'ar': 'متى',
    'id': 'Ketika',
  });
  
  static String get where => _getText({
    'tr': 'Nerede',
    'en': 'Where',
    'ar': 'أين',
    'id': 'Di Mana',
  });
  
  static String get why => _getText({
    'tr': 'Neden',
    'en': 'Why',
    'ar': 'لماذا',
    'id': 'Mengapa',
  });
  
  static String get how => _getText({
    'tr': 'Nasıl',
    'en': 'How',
    'ar': 'كيف',
    'id': 'Bagaimana',
  });
  
  static String get what => _getText({
    'tr': 'Ne',
    'en': 'What',
    'ar': 'ماذا',
    'id': 'Apa',
  });
  
  static String get which => _getText({
    'tr': 'Hangisi',
    'en': 'Which',
    'ar': 'أي',
    'id': 'Mana',
  });
  
  static String get who => _getText({
    'tr': 'Kim',
    'en': 'Who',
    'ar': 'من',
    'id': 'Siapa',
  });
  
  static String get whose => _getText({
    'tr': 'Kimin',
    'en': 'Whose',
    'ar': 'لمن',
    'id': 'Siapa',
  });
  
  static String get whom => _getText({
    'tr': 'Kimi',
    'en': 'Whom',
    'ar': 'من',
    'id': 'Siapa',
  });
  
  static String get whose_ => _getText({
    'tr': 'Kimin',
    'en': 'Whose',
    'ar': 'لمن',
    'id': 'Siapa',
  });
  
  static String get whom_ => _getText({
    'tr': 'Kimi',
    'en': 'Whom',
    'ar': 'من',
    'id': 'Siapa',
  });
}
