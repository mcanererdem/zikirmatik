import 'dart:math';

class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static final Map<String, Map<String, String>> _localizedValues = {
    // TÜRKÇE
    'tr': {
      // Ana Menü ve Navigasyon
      'app_name': 'Zikirmatik',
      'counter': 'Sayaç',
      'target': 'Hedef',
      'reset': 'Sıfırla',
      'continue': 'Devam Et',
      'cancel': 'İptal',
      'ok': 'Tamam',
      'settings': 'Ayarlar',
      'theme': 'Tema',
      'language': 'Dil',
      'vibration': 'Titreşim',
      'sound': 'Ses',
      'select_zikr': 'Zikir Seç',
      'add_zikr': 'Zikir Ekle',
      'custom_zikrs': 'Özel Zikirler',
      
      // Zikir İsimleri
      'zikr_name_ar': 'Arapça İsim',
      'zikr_name_tr': 'Türkçe İsim',
      'zikr_name_en': 'İngilizce İsim',
      'zikr_name_id': 'İndonezce İsim',
      'zikr_name_ur': 'Urduca İsim',
      'zikr_name_bn': 'Bengalce İsim',
      'zikr_name_ms': 'Malayca İsim',
      'zikr_name_fa': 'Farsça İsim',
      'zikr_name_fr': 'Fransızca İsim',
      'zikr_name_zh': 'Çince İsim',
      'zikr_name_ja': 'Japonca İsim',
      'zikr_name_ru': 'Rusça İsim',
      'zikr_name_de': 'Almanca İsim',
      'zikr_name_sw': 'Svahili İsim',
      'zikr_name_ha': 'Hausa İsim',
      
      // Ana Sayfa Butonları
      'leaderboard': 'Liderlik Tablosu',
      'profile': 'Profil',
      'trophies': 'Kupalar',
      'statistics': 'İstatistikler',
      'export': 'Dışa Aktar',
      'import': 'İçe Aktar',
      'backup': 'Yedekle',
      'restore': 'Geri Yükle',
      
      // İstatistikler
      'daily': 'Günlük',
      'weekly': 'Haftalık',
      'monthly': 'Aylık',
      'yearly': 'Yıllık',
      'total': 'Toplam',
      'streak': 'Seri',
      'average': 'Ortalama',
      'best_day': 'En İyi Gün',
      'best_hour': 'En İyi Saat',
      'consecutive_days': 'Arka Arkaya Günler',
      'last_7_days': 'Son 7 Gün',
      'days': 'Gün',
      
      // Kupalar
      'achievements': 'Başarılar',
      'bronze': 'Bronz',
      'silver': 'Gümüş',
      'gold': 'Altın',
      'diamond': 'Elmas',
      'platinum': 'Platin',
      'next_cup': 'Sonraki Kupa',
      'remaining': 'Kalan',
      'cup_unlocked': 'Kupa Kazanıldı!',
      'bronze_kupa': 'Bronz Kupa',
      'silver_kupa': 'Gümüş Kupa',
      'gold_kupa': 'Altın Kupa',
      'diamond_kupa': 'Elmas Kupa',
      'platinum_kupa': 'Platin Kupa',
      
      // Profil
      'sync': 'Senkronize Et',
      'refresh': 'Yenile',
      'save': 'Kaydet',
      'delete': 'Sil',
      'edit': 'Düzenle',
      'username': 'Kullanıcı Adı',
      'display_name': 'Görünen Ad',
      'avatar': 'Profil Fotoğrafı',
      'upload_avatar': 'Profil Fotoğrafı Yükle',
      'sign_out': 'Çıkış Yap',
      'delete_account': 'Hesabı Sil',
      'sync_profile': 'Profili Senkronize Et',
      
      // Dialog ve Bildirimler
      'confirm': 'Onayla',
      'warning': 'Uyarı',
      'success': 'Başarılı',
      'error': 'Hata',
      'loading': 'Yükleniyor',
      'no_internet': 'İnternet Bağlantısı Yok',
      'check_connection': 'Bağlantıyı Kontrol Et',
      'try_again': 'Tekrar Dene',
      'dismiss': 'Kapat',
      
      // Liderlik Tablosu
      'leaderboard_enabled': 'Liderlik Tablosu Aktif',
      'sync_to_leaderboard': 'Liderlik Tablosuna Senkronize Et',
      'auto_sync': 'Otomatik Senkronizasyon',
      'rank': 'Sıra',
      'user': 'Kullanıcı',
      'zikrs': 'Zikirler',
      
      // Bildirimler
      'notifications': 'Bildirimler',
      'daily_reminder': 'Günlük Hatırlatıcı',
      'reminder_time': 'Hatırlatıcı Saati',
      'reminder_days': 'Hatırlatıcı Günleri',
      'enable_reminder': 'Hatırlatıcıyı Etkinleştir',
      'reminder_enabled': 'Hatırlatıcı Aktif',
      'reminder_disabled': 'Hatırlatıcı Pasif',
      'reminder_set_success': 'Hatırlatıcı başarıyla ayarlandı!',
      'reminder_set_fail': 'Hatırlatıcı ayarlanamadı. İzinleri kontrol edin.',
      'reminder_cancelled': 'Hatırlatıcı başarıyla iptal edildi.',
      'test_notification_sent': 'Test bildirimi gönderildi!',
      
      // Günler
      'monday': 'Pazartesi',
      'tuesday': 'Salı',
      'wednesday': 'Çarşamba',
      'thursday': 'Perşembe',
      'friday': 'Cuma',
      'saturday': 'Cumartesi',
      'sunday': 'Pazar',
      'everyday': 'Her Gün',
      'weekdays': 'Hafta İçi',
      'weekends': 'Hafta Sonu',
      'mon': 'Pzt',
      'tue': 'Sal',
      'wed': 'Çar',
      'thu': 'Per',
      'fri': 'Cum',
      'sat': 'Cmt',
      'sun': 'Paz',
      
      // Ayarlar
      'animation_speed': 'Animasyon Hızı',
      'off': 'Kapalı',
      'slow': 'Yavaş',
      'normal': 'Normal',
      'fast': 'Hızlı',
      'confetti': 'Konfeti',
      'tts': 'Metin Okuma',
      
      // Hakkında
      'about': 'Hakkında',
      'support': 'Destek',
      'privacy': 'Gizlilik',
      'terms': 'Kullanım Koşulları',
      'version': 'Sürüm',
      'developer': 'Geliştirici',
      'contact': 'İletişim',
      'source_code': 'Kaynak Kodu',
      'feedback': 'Geri Bildirim',
      'rate_app': 'Uygulamayı Değerlendir',
      'share_app': 'Uygulamayı Paylaş',
      'report_bug': 'Hata Bildir',
      'request_feature': 'Özellik İste',
      
      // Yardım
      'help': 'Yardım',
      'tutorial': 'Eğitim',
      'faq': 'SSS',
      'tips': 'İpuçları',
      'guide': 'Rehber',
      'how_to_use': 'Nasıl Kullanılır',
      'getting_started': 'Başlangıç',
      
      // Özellikler
      'features': 'Özellikler',
      'updates': 'Güncellemeler',
      'news': 'Haberler',
      'changelog': 'Değişiklik Günlüğü',
      'whats_new': 'Yenilikler',
      'coming_soon': 'Çok Yakında',
      'under_development': 'Geliştirme Aşamasında',
      'maintenance': 'Bakım',
      
      // Modlar
      'offline_mode': 'Çevrimdışı Mod',
      'online_mode': 'Çevrimiçi Mod',
      'cloud_sync': 'Bulut Senkronizasyonu',
      
      // Veri İşlemleri
      'data_backup': 'Veri Yedekleme',
      'data_restore': 'Veri Geri Yükleme',
      'export_data': 'Verileri Dışa Aktar',
      'import_data': 'Verileri İçe Aktar',
      'backup_success': 'Yedekleme Başarılı',
      'restore_success': 'Geri Yükleme Başarılı',
      'export_success': 'Dışa Aktarım Başarılı',
      'import_success': 'İçe Aktarım Başarılı',
      'backup_failed': 'Yedekleme Başarısız',
      'restore_failed': 'Geri Yükleme Başarısız',
      'export_failed': 'Dışa Aktarım Başarısız',
      'import_failed': 'İçe Aktarım Başarısız',
      
      // Hata Mesajları
      'no_data_found': 'Veri Bulunamadı',
      'data_corrupted': 'Veri Bozuk',
      'invalid_file': 'Geçersiz Dosya',
      'file_not_found': 'Dosya Bulunamadı',
      'permission_denied': 'İzin Reddedildi',
      'storage_full': 'Depolama Alanı Dolu',
      'network_error': 'Ağ Hatası',
      'server_error': 'Sunucu Hatası',
      'timeout': 'Zaman Aşımı',
      'unknown_error': 'Bilinmeyen Hata',
      
      // Durum Mesajları
      'please_wait': 'Lütfen Bekleyin',
      'processing': 'İşleniyor',
      'completed': 'Tamamlandı',
      'failed': 'Başarısız',
      'cancelled': 'İptal Edildi',
      
      // Navigasyon
      'retry': 'Tekrar Dene',
      'skip': 'Atla',
      'next': 'Sonraki',
      'previous': 'Önceki',
      'finish': 'Bitir',
      'close': 'Kapat',
      'open': 'Aç',
      'browse': 'Gözat',
      'select': 'Seç',
      'choose': 'Seç',
      'search': 'Ara',
      'filter': 'Filtre',
      'sort': 'Sırala',
      
      // Sıralama
      'ascending': 'Artan',
      'descending': 'Azalan',
      'name': 'Ad',
      'date': 'Tarih',
      'size': 'Boyut',
      'type': 'Tür',
      'all': 'Tümü',
      'none': 'Hiçbiri',
      'other': 'Diğer',
      
      // Seçenekler
      'custom': 'Özel',
      'default': 'Varsayılan',
      'auto': 'Otomatik',
      'manual': 'Manuel',
      'enabled': 'Etkin',
      'disabled': 'Devre Dışı',
      'on': 'Açık',
      'off': 'Kapalı',
      'yes': 'Evet',
      'no': 'Hayır',
      'maybe': 'Belki',
      'later': 'Sonra',
      'now': 'Şimdi',
      
      // Zaman
      'today': 'Bugün',
      'yesterday': 'Dün',
      'tomorrow': 'Yarın',
      'this_week': 'Bu Hafta',
      'last_week': 'Geçen Hafta',
      'next_week': 'Gelecek Hafta',
      'this_month': 'Bu Ay',
      'last_month': 'Geçen Ay',
      'next_month': 'Gelecek Ay',
      'this_year': 'Bu Yıl',
      'last_year': 'Geçen Yıl',
      'next_year': 'Gelecek Yıl',
      
      // Zikir Sayacı
      'zikr_count': 'Zikir',
      'increment_counter': 'Sayacı Artır',
      'reset_counter': 'Sayacı Sıfırla',
      'change_target': 'Hedefi Değiştir',
      'vibration_on': 'Titreşim Açık',
      'vibration_off': 'Titreşim Kapalı',
      'sound_on': 'Ses Açık',
      'sound_off': 'Ses Kapalı',
      'confetti_on': 'Konfeti Açık',
      'confetti_off': 'Konfeti Kapalı',
      
      // Hedefler
      'goals': 'Hedefler',
      'daily_goal': 'Günlük Hedef',
      'weekly_goal': 'Haftalık Hedef',
      'monthly_goal': 'Aylık Hedef',
      'set_goal': 'Hedef Belirle',
      'goal_completed': 'Hedef Tamamlandı! 🎯',
      'progress': 'İlerleme',
      'set_target': 'Hedef Belirle',
      'quick_select': 'Hızlı Seçim',
      'custom_target': 'Özel Hedef',
      'enter_target': 'Hedef sayısını girin',
      
      // Başarı Mesajları
      'success_title': 'MashaAllah! 🎉',
      'success_message': 'Hedefe ulaşıldı!',
      
      // Test
      'test': 'Test',
      'set_reminder': 'Hatırlatıcı Ayarla',
      'cancel_reminder': 'İptal Et',
      
      // Dil Adları
      'arabic': 'العربية',
      'turkish': 'Türkçe',
      'english': 'English',
      'indonesian': 'Bahasa Indonesia',
      'urdu': 'اردو',
      'bengali': 'বাংলা',
      'malay': 'Bahasa Melayu',
      'persian': 'فارسی',
      'french': 'Français',
      'chinese': '中文',
      'japanese': '日本語',
      'russian': 'Русский',
      'german': 'Deutsch',
      'swahili': 'Kiswahili',
      'hausa': 'Hausa',
      
      // Ek Mesajlar
      'optional': 'Opsiyonel',
      'required': 'gerekli',
      'count_cannot_be_zero': 'Sayı 0 olamaz',
      'transliteration': 'Okunuş',
    },

    // İNGİLİZCE
    'en': {
      // Ana Menü ve Navigasyon
      'app_name': 'Tasbih Counter',
      'counter': 'Counter',
      'target': 'Target',
      'reset': 'Reset',
      'continue': 'Continue',
      'cancel': 'Cancel',
      'ok': 'OK',
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'vibration': 'Vibration',
      'sound': 'Sound',
      'select_zikr': 'Select Dhikr',
      'add_zikr': 'Add Dhikr',
      'custom_zikrs': 'Custom Dhikrs',
      
      // Zikir İsimleri
      'zikr_name_ar': 'Arabic Name',
      'zikr_name_tr': 'Turkish Name',
      'zikr_name_en': 'English Name',
      'zikr_name_id': 'Indonesian Name',
      'zikr_name_ur': 'Urdu Name',
      'zikr_name_bn': 'Bengali Name',
      'zikr_name_ms': 'Malay Name',
      'zikr_name_fa': 'Persian Name',
      'zikr_name_fr': 'French Name',
      'zikr_name_zh': 'Chinese Name',
      'zikr_name_ja': 'Japanese Name',
      'zikr_name_ru': 'Russian Name',
      'zikr_name_de': 'German Name',
      'zikr_name_sw': 'Swahili Name',
      'zikr_name_ha': 'Hausa Name',
      
      // Ana Sayfa Butonları
      'leaderboard': 'Leaderboard',
      'profile': 'Profile',
      'trophies': 'Trophies',
      'statistics': 'Statistics',
      'export': 'Export',
      'import': 'Import',
      'backup': 'Backup',
      'restore': 'Restore',
      
      // İstatistikler
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'yearly': 'Yearly',
      'total': 'Total',
      'streak': 'Streak',
      'average': 'Average',
      'best_day': 'Best Day',
      'best_hour': 'Best Hour',
      'consecutive_days': 'Consecutive days',
      'last_7_days': 'Last 7 Days',
      'days': 'days',
      
      // Kupalar
      'achievements': 'Achievements',
      'bronze': 'Bronze',
      'silver': 'Silver',
      'gold': 'Gold',
      'diamond': 'Diamond',
      'platinum': 'Platinum',
      'next_cup': 'Next Cup',
      'remaining': 'Remaining',
      'cup_unlocked': 'Cup Unlocked!',
      'bronze_kupa': 'Bronze Cup',
      'silver_kupa': 'Silver Cup',
      'gold_kupa': 'Gold Cup',
      'diamond_kupa': 'Diamond Cup',
      'platinum_kupa': 'Platinum Cup',
      
      // Profil
      'sync': 'Sync',
      'refresh': 'Refresh',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'username': 'Username',
      'display_name': 'Display Name',
      'avatar': 'Profile Photo',
      'upload_avatar': 'Upload Profile Photo',
      'sign_out': 'Sign Out',
      'delete_account': 'Delete Account',
      'sync_profile': 'Sync Profile',
      
      // Dialog ve Bildirimler
      'confirm': 'Confirm',
      'warning': 'Warning',
      'success': 'Success',
      'error': 'Error',
      'loading': 'Loading',
      'no_internet': 'No Internet Connection',
      'check_connection': 'Check Connection',
      'try_again': 'Try Again',
      'dismiss': 'Dismiss',
      
      // Liderlik Tablosu
      'leaderboard_enabled': 'Leaderboard Enabled',
      'sync_to_leaderboard': 'Sync to Leaderboard',
      'auto_sync': 'Auto Sync',
      'rank': 'Rank',
      'user': 'User',
      'zikrs': 'Dhikrs',
      
      // Bildirimler
      'notifications': 'Notifications',
      'daily_reminder': 'Daily Reminder',
      'reminder_time': 'Reminder Time',
      'reminder_days': 'Reminder Days',
      'enable_reminder': 'Enable Reminder',
      'reminder_enabled': 'Reminder Active',
      'reminder_disabled': 'Reminder Inactive',
      'reminder_set_success': 'Reminder set successfully!',
      'reminder_set_fail': 'Could not set reminder. Please check permissions.',
      'reminder_cancelled': 'Reminder cancelled successfully.',
      'test_notification_sent': 'Test notification sent!',
      
      // Günler
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
      'everyday': 'Everyday',
      'weekdays': 'Weekdays',
      'weekends': 'Weekends',
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'sat': 'Sat',
      'sun': 'Sun',
      
      // Ayarlar
      'animation_speed': 'Animation Speed',
      'off': 'Off',
      'slow': 'Slow',
      'normal': 'Normal',
      'fast': 'Fast',
      'confetti': 'Confetti',
      'tts': 'Text to Speech',
      
      // Hakkında
      'about': 'About',
      'support': 'Support',
      'privacy': 'Privacy',
      'terms': 'Terms of Service',
      'version': 'Version',
      'developer': 'Developer',
      'contact': 'Contact',
      'source_code': 'Source Code',
      'feedback': 'Feedback',
      'rate_app': 'Rate App',
      'share_app': 'Share App',
      'report_bug': 'Report Bug',
      'request_feature': 'Request Feature',
      
      // Yardım
      'help': 'Help',
      'tutorial': 'Tutorial',
      'faq': 'FAQ',
      'tips': 'Tips',
      'guide': 'Guide',
      'how_to_use': 'How to Use',
      'getting_started': 'Getting Started',
      
      // Özellikler
      'features': 'Features',
      'updates': 'Updates',
      'news': 'News',
      'changelog': 'Changelog',
      'whats_new': 'What\'s New',
      'coming_soon': 'Coming Soon',
      'under_development': 'Under Development',
      'maintenance': 'Maintenance',
      
      // Modlar
      'offline_mode': 'Offline Mode',
      'online_mode': 'Online Mode',
      'cloud_sync': 'Cloud Sync',
      
      // Veri İşlemleri
      'data_backup': 'Data Backup',
      'data_restore': 'Data Restore',
      'export_data': 'Export Data',
      'import_data': 'Import Data',
      'backup_success': 'Backup Successful',
      'restore_success': 'Restore Successful',
      'export_success': 'Export Successful',
      'import_success': 'Import Successful',
      'backup_failed': 'Backup Failed',
      'restore_failed': 'Restore Failed',
      'export_failed': 'Export Failed',
      'import_failed': 'Import Failed',
      
      // Hata Mesajları
      'no_data_found': 'No Data Found',
      'data_corrupted': 'Data Corrupted',
      'invalid_file': 'Invalid File',
      'file_not_found': 'File Not Found',
      'permission_denied': 'Permission Denied',
      'storage_full': 'Storage Full',
      'network_error': 'Network Error',
      'server_error': 'Server Error',
      'timeout': 'Timeout',
      'unknown_error': 'Unknown Error',
      
      // Durum Mesajları
      'please_wait': 'Please Wait',
      'processing': 'Processing',
      'completed': 'Completed',
      'failed': 'Failed',
      'cancelled': 'Cancelled',
      
      // Navigasyon
      'retry': 'Retry',
      'skip': 'Skip',
      'next': 'Next',
      'previous': 'Previous',
      'finish': 'Finish',
      'close': 'Close',
      'open': 'Open',
      'browse': 'Browse',
      'select': 'Select',
      'choose': 'Choose',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      
      // Sıralama
      'ascending': 'Ascending',
      'descending': 'Descending',
      'name': 'Name',
      'date': 'Date',
      'size': 'Size',
      'type': 'Type',
      'all': 'All',
      'none': 'None',
      'other': 'Other',
      
      // Seçenekler
      'custom': 'Custom',
      'default': 'Default',
      'auto': 'Auto',
      'manual': 'Manual',
      'enabled': 'Enabled',
      'disabled': 'Disabled',
      'on': 'On',
      'off': 'Off',
      'yes': 'Yes',
      'no': 'No',
      'maybe': 'Maybe',
      'later': 'Later',
      'now': 'Now',
      
      // Zaman
      'today': 'Today',
      'yesterday': 'Yesterday',
      'tomorrow': 'Tomorrow',
      'this_week': 'This Week',
      'last_week': 'Last Week',
      'next_week': 'Next Week',
      'this_month': 'This Month',
      'last_month': 'Last Month',
      'next_month': 'Next Month',
      'this_year': 'This Year',
      'last_year': 'Last Year',
      'next_year': 'Next Year',
      
      // Zikir Sayacı
      'zikr_count': 'Dhikr',
      'increment_counter': 'Increment counter',
      'reset_counter': 'Reset counter',
      'change_target': 'Change target',
      'vibration_on': 'Vibration on',
      'vibration_off': 'Vibration off',
      'sound_on': 'Sound on',
      'sound_off': 'Sound off',
      'confetti_on': 'Confetti on',
      'confetti_off': 'Confetti off',
      
      // Hedefler
      'goals': 'Goals',
      'daily_goal': 'Daily Goal',
      'weekly_goal': 'Weekly Goal',
      'monthly_goal': 'Monthly Goal',
      'set_goal': 'Set Goal',
      'goal_completed': 'Goal Completed! 🎯',
      'progress': 'Progress',
      'set_target': 'Set Target',
      'quick_select': 'Quick Select',
      'custom_target': 'Custom Target',
      'enter_target': 'Enter target number',
      
      // Başarı Mesajları
      'success_title': 'MashaAllah! 🎉',
      'success_message': 'Target reached!',
      
      // Test
      'test': 'Test',
      'set_reminder': 'Set Reminder',
      'cancel_reminder': 'Cancel',
      
      // Dil Adları
      'arabic': 'العربية',
      'turkish': 'Türkçe',
      'english': 'English',
      'indonesian': 'Bahasa Indonesia',
      'urdu': 'اردو',
      'bengali': 'বাংলা',
      'malay': 'Bahasa Melayu',
      'persian': 'فارسی',
      'french': 'Français',
      'chinese': '中文',
      'japanese': '日本語',
      'russian': 'Русский',
      'german': 'Deutsch',
      'swahili': 'Kiswahili',
      'hausa': 'Hausa',
      
      // Ek Mesajlar
      'optional': 'Optional',
      'required': 'Required',
      'count_cannot_be_zero': 'Count cannot be zero',
      'transliteration': 'Transliteration',
    },
  };

  String translate(String key) {
    if (_localizedValues.containsKey(languageCode)) {
      final languageMap = _localizedValues[languageCode]!;
      if (languageMap.containsKey(key)) {
        return languageMap[key]!;
      }
    }
    
    // Fallback to Turkish if key not found
    if (_localizedValues.containsKey('tr') && _localizedValues['tr']!.containsKey(key)) {
      return _localizedValues['tr']![key]!;
    }
    
    // Final fallback to key itself
    return key;
  }

  // Getters for commonly used strings
  String get appName => translate('app_name');
  String get counter => translate('counter');
  String get target => translate('target');
  String get reset => translate('reset');
  String get continue_ => translate('continue');
  String get cancel => translate('cancel');
  String get ok => translate('ok');
  String get settings => translate('settings');
  String get theme => translate('theme');
  String get language => translate('language');
  String get vibration => translate('vibration');
  String get sound => translate('sound');
  String get selectZikr => translate('select_zikr');
  String get addZikr => translate('add_zikr');
  String get customZikrs => translate('custom_zikrs');
  String get leaderboard => translate('leaderboard');
  String get profile => translate('profile');
  String get trophies => translate('trophies');
  String get statistics => translate('statistics');
  String get export => translate('export');
  String get import => translate('import');
  String get backup => translate('backup');
  String get restore => translate('restore');
  String get daily => translate('daily');
  String get weekly => translate('weekly');
  String get monthly => translate('monthly');
  String get yearly => translate('yearly');
  String get total => translate('total');
  String get streak => translate('streak');
  String get average => translate('average');
  String get bestDay => translate('best_day');
  String get bestHour => translate('best_hour');
  String get achievements => translate('achievements');
  String get bronze => translate('bronze');
  String get silver => translate('silver');
  String get gold => translate('gold');
  String get diamond => translate('diamond');
  String get platinum => translate('platinum');
  String get nextCup => translate('next_cup');
  String get remaining => translate('remaining');
  String get sync => translate('sync');
  String get refresh => translate('refresh');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get username => translate('username');
  String get displayName => translate('display_name');
  String get avatar => translate('avatar');
  String get uploadAvatar => translate('upload_avatar');
  String get signOut => translate('sign_out');
  String get deleteAccount => translate('delete_account');
  String get confirm => translate('confirm');
  String get warning => translate('warning');
  String get success => translate('success');
  String get error => translate('error');
  String get loading => translate('loading');
  String get noInternet => translate('no_internet');
  String get checkConnection => translate('check_connection');
  String get tryAgain => translate('try_again');
  String get dismiss => translate('dismiss');
  String get leaderboardEnabled => translate('leaderboard_enabled');
  String get syncToLeaderboard => translate('sync_to_leaderboard');
  String get autoSync => translate('auto_sync');
  String get notifications => translate('notifications');
  String get dailyReminder => translate('daily_reminder');
  String get reminderTime => translate('reminder_time');
  String get reminderDays => translate('reminder_days');
  String get monday => translate('monday');
  String get tuesday => translate('tuesday');
  String get wednesday => translate('wednesday');
  String get thursday => translate('thursday');
  String get friday => translate('friday');
  String get saturday => translate('saturday');
  String get sunday => translate('sunday');
  String get everyday => translate('everyday');
  String get weekdays => translate('weekdays');
  String get weekends => translate('weekends');
  String get animationSpeed => translate('animation_speed');
  String get off => translate('off');
  String get slow => translate('slow');
  String get normal => translate('normal');
  String get fast => translate('fast');
  String get confetti => translate('confetti');
  String get tts => translate('tts');
  String get about => translate('about');
  String get support => translate('support');
  String get privacy => translate('privacy');
  String get terms => translate('terms');
  String get version => translate('version');
  String get developer => translate('developer');
  String get contact => translate('contact');
  String get feedback => translate('feedback');
  String get rateApp => translate('rate_app');
  String get shareApp => translate('share_app');
  String get reportBug => translate('report_bug');
  String get requestFeature => translate('request_feature');
  String get help => translate('help');
  String get tutorial => translate('tutorial');
  String get faq => translate('faq');
  String get tips => translate('tips');
  String get guide => translate('guide');
  String get howToUse => translate('how_to_use');
  String get gettingStarted => translate('getting_started');
  String get features => translate('features');
  String get updates => translate('updates');
  String get news => translate('news');
  String get changelog => translate('changelog');
  String get whatsNew => translate('whats_new');
  String get comingSoon => translate('coming_soon');
  String get underDevelopment => translate('under_development');
  String get maintenance => translate('maintenance');
  String get offlineMode => translate('offline_mode');
  String get onlineMode => translate('online_mode');
  String get cloudSync => translate('cloud_sync');
  String get dataBackup => translate('data_backup');
  String get dataRestore => translate('data_restore');
  String get exportData => translate('export_data');
  String get importData => translate('import_data');
  String get backupSuccess => translate('backup_success');
  String get restoreSuccess => translate('restore_success');
  String get exportSuccess => translate('export_success');
  String get importSuccess => translate('import_success');
  String get backupFailed => translate('backup_failed');
  String get restoreFailed => translate('restore_failed');
  String get exportFailed => translate('export_failed');
  String get importFailed => translate('import_failed');
  String get noDataFound => translate('no_data_found');
  String get dataCorrupted => translate('data_corrupted');
  String get invalidFile => translate('invalid_file');
  String get fileNotFound => translate('file_not_found');
  String get permissionDenied => translate('permission_denied');
  String get storageFull => translate('storage_full');
  String get networkError => translate('network_error');
  String get serverError => translate('server_error');
  String get timeout => translate('timeout');
  String get unknownError => translate('unknown_error');
  String get pleaseWait => translate('please_wait');
  String get processing => translate('processing');
  String get completed => translate('completed');
  String get failed => translate('failed');
  String get cancelled => translate('cancelled');
  String get retry => translate('retry');
  String get skip => translate('skip');
  String get next => translate('next');
  String get previous => translate('previous');
  String get finish => translate('finish');
  String get close => translate('close');
  String get open => translate('open');
  String get browse => translate('browse');
  String get select => translate('select');
  String get choose => translate('choose');
  String get search => translate('search');
  String get filter => translate('filter');
  String get sort => translate('sort');
  String get ascending => translate('ascending');
  String get descending => translate('descending');
  String get name => translate('name');
  String get date => translate('date');
  String get size => translate('size');
  String get type => translate('type');
  String get all => translate('all');
  String get none => translate('none');
  String get other => translate('other');
  String get custom => translate('custom');
  String get default_ => translate('default');
  String get auto => translate('auto');
  String get manual => translate('manual');
  String get enabled => translate('enabled');
  String get disabled => translate('disabled');
  String get on_ => translate('on');
  String get off_ => translate('off');
  String get yes => translate('yes');
  String get no => translate('no');
  String get maybe => translate('maybe');
  String get later => translate('later');
  String get now => translate('now');
  String get today => translate('today');
  String get yesterday => translate('yesterday');
  String get tomorrow => translate('tomorrow');
  String get thisWeek => translate('this_week');
  String get lastWeek => translate('last_week');
  String get nextWeek => translate('next_week');
  String get thisMonth => translate('this_month');
  String get lastMonth => translate('last_month');
  String get nextMonth => translate('next_month');
  String get thisYear => translate('this_year');
  String get lastYear => translate('last_year');
  String get nextYear => translate('next_year');
  String get zikrCount => translate('zikr_count');
  String get edit => translate('edit');
  String get delete => translate('delete');
  String get save => translate('save');
  String get arabic => translate('arabic');
  String get turkish => translate('turkish');
  String get english => translate('english');
  String get indonesian => translate('indonesian');
  String get incrementCounter => translate('increment_counter');
  String get resetCounter => translate('reset_counter');
  String get changeTarget => translate('change_target');
  String get vibrationOn => translate('vibration_on');
  String get vibrationOff => translate('vibration_off');
  String get soundOn => translate('sound_on');
  String get soundOff => translate('sound_off');
  String get about => translate('about');
  String get confettiOn => translate('confetti_on');
  String get confettiOff => translate('confetti_off');
  String get setReminder => translate('set_reminder');
  String get cancelReminder => translate('cancel_reminder');
  String get goals => translate('goals');
  String get dailyGoal => translate('daily_goal');
  String get weeklyGoal => translate('weekly_goal');
  String get monthlyGoal => translate('monthly_goal');
  String get setGoal => translate('set_goal');
  String get goalCompleted => translate('goal_completed');
  String get progress => translate('progress');
  String get statistics => translate('statistics');
  String get today => translate('today');
  String get total => translate('total');
  String get streak => translate('streak');
  String get consecutiveDays => translate('consecutive_days');
  String get last7Days => translate('last_7_days');
  String get days => translate('days');
  String get mon => translate('mon');
  String get tue => translate('tue');
  String get wed => translate('wed');
  String get thu => translate('thu');
  String get fri => translate('fri');
  String get sat => translate('sat');
  String get sun => translate('sun');
  String get test => translate('test');
  String get enableReminder => translate('enable_reminder');
  String get reminderEnabled => translate('reminder_enabled');
  String get reminderDisabled => translate('reminder_disabled');
  String get reminderSetSuccess => translate('reminder_set_success');
  String get reminderSetFail => translate('reminder_set_fail');
  String get reminderCancelled => translate('reminder_cancelled');
  String get testNotificationSent => translate('test_notification_sent');
  String get close => translate('close');
  String get target => translate('target');
  String get reset => translate('reset');
  String get continue_ => translate('continue');
  String get cancel => translate('cancel');
  String get ok => translate('ok');
  String get settings => translate('settings');
  String get theme => translate('theme');
  String get language => translate('language');
  String get vibration => translate('vibration');
  String get sound => translate('sound');
  String get selectZikr => translate('select_zikr');
  String get addZikr => translate('add_zikr');
  String get customZikrs => translate('custom_zikrs');
  String get zikrNameAr => translate('zikr_name_ar');
  String get zikrNameTr => translate('zikr_name_tr');
  String get zikrNameEn => translate('zikr_name_en');
  String get zikrNameId => translate('zikr_name_id');
  String get zikrNameUr => translate('zikr_name_ur');
  String get zikrNameBn => translate('zikr_name_bn');
  String get zikrNameMs => translate('zikr_name_ms');
  String get zikrNameFa => translate('zikr_name_fa');
  String get leaderboard => translate('leaderboard');
  String get profile => translate('profile');
  String get trophies => translate('trophies');
  String get statistics => translate('statistics');
  String get export => translate('export');
  String get import => translate('import');
  String get backup => translate('backup');
  String get restore => translate('restore');
  String get daily => translate('daily');
  String get weekly => translate('weekly');
  String get monthly => translate('monthly');
  String get yearly => translate('yearly');
  String get total => translate('total');
  String get streak => translate('streak');
  String get average => translate('average');
  String get bestDay => translate('best_day');
  String get bestHour => translate('best_hour');
  String get achievements => translate('achievements');
  String get bronze => translate('bronze');
  String get silver => translate('silver');
  String get gold => translate('gold');
  String get diamond => translate('diamond');
  String get platinum => translate('platinum');
  String get nextCup => translate('next_cup');
  String get remaining => translate('remaining');
  String get sync => translate('sync');
  String get refresh => translate('refresh');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get username => translate('username');
  String get displayName => translate('display_name');
  String get avatar => translate('avatar');
  String get uploadAvatar => translate('upload_avatar');
  String get signOut => translate('sign_out');
  String get deleteAccount => translate('delete_account');
  String get confirm => translate('confirm');
  String get warning => translate('warning');
  String get success => translate('success');
  String get error => translate('error');
  String get loading => translate('loading');
  String get noInternet => translate('no_internet');
  String get checkConnection => translate('check_connection');
  String get tryAgain => translate('try_again');
  String get dismiss => translate('dismiss');
  String get leaderboardEnabled => translate('leaderboard_enabled');
  String get syncToLeaderboard => translate('sync_to_leaderboard');
  String get autoSync => translate('auto_sync');
  String get notifications => translate('notifications');
  String get dailyReminder => translate('daily_reminder');
  String get reminderTime => translate('reminder_time');
  String get reminderDays => translate('reminder_days');
  String get monday => translate('monday');
  String get tuesday => translate('tuesday');
  String get wednesday => translate('wednesday');
  String get thursday => translate('thursday');
  String get friday => translate('friday');
  String get saturday => translate('saturday');
  String get sunday => translate('sunday');
  String get everyday => translate('everyday');
  String get weekdays => translate('weekdays');
  String get weekends => translate('weekends');
  String get animationSpeed => translate('animation_speed');
  String get off => translate('off');
  String get slow => translate('slow');
  String get normal => translate('normal');
  String get fast => translate('fast');
  String get confetti => translate('confetti');
  String get tts => translate('tts');
  String get about => translate('about');
  String get support => translate('support');
  String get privacy => translate('privacy');
  String get terms => translate('terms');
  String get version => translate('version');
  String get developer => translate('developer');
  String get contact => translate('contact');
  String get sourceCode => translate('source_code');
  String get defaultCount => translate('default_count');
  String get setTarget => translate('set_target');
  String get quickSelect => translate('quick_select');
  String get customTarget => translate('custom_target');
  String get enterTarget => translate('enter_target');
  String get successTitle => translate('success_title');
  String get successMessage => translate('success_message');
  String get zikrCount => translate('zikr_count');
  String get edit => translate('edit');
  String get delete => translate('delete');
  String get save => translate('save');
  String get arabic => translate('arabic');
  String get turkish => translate('turkish');
  String get english => translate('english');
  String get indonesian => translate('indonesian');
  String get incrementCounter => translate('increment_counter');
  String get resetCounter => translate('reset_counter');
  String get changeTarget => translate('change_target');
  String get vibrationOn => translate('vibration_on');
  String get vibrationOff => translate('vibration_off');
  String get soundOn => translate('sound_on');
  String get soundOff => translate('sound_off');
  String get about => translate('about');
  String get confettiOn => translate('confetti_on');
  String get confettiOff => translate('confetti_off');
  String get setReminder => translate('set_reminder');
  String get cancelReminder => translate('cancel_reminder');
  String get close => translate('close');
  String get optional => translate('optional');
  String get required => translate('required');
  String get countCannotBeZero => translate('count_cannot_be_zero');
  String get transliteration => translate('transliteration');
}
