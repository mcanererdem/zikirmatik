import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';

class AboutScreen extends StatelessWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;

  const AboutScreen({
    super.key,
    required this.themeConfig,
    required this.localizations,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeConfig.primaryColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: themeConfig.backgroundGradient,
          image: (() {
            final isLightTheme = themeConfig.textColor.computeLuminance() < 0.5;
            final asset = isLightTheme ? themeConfig.lightBackgroundAsset : themeConfig.darkBackgroundAsset;
            return asset != null
                ? DecorationImage(
                    image: AssetImage(asset),
                    fit: BoxFit.cover,
                    opacity: 0.12,
                  )
                : null;
          })(),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildAppInfo(),
                      const SizedBox(height: 24),
                      _buildContactSection(),
                      const SizedBox(height: 24),
                      _buildFeaturesSection(),
                      const SizedBox(height: 24),
                      _buildHelpSection(),
                      const SizedBox(height: 24),
                      _buildLegalSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: themeConfig.textColor),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Text(
            localizations.about,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeConfig.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeConfig.accentColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: themeConfig.goldGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset('assets/icons/white_misbah.png', width: 64, height: 64),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.appName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeConfig.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Sürüm 1.0.0',
              'en': 'Version 1.0.0',
              'ar': 'الإصدار 1.0.0',
              'id': 'Versi 1.0.0',
              'ur': 'ورژن 1.0.0',
              'bn': 'সংস্করণ 1.0.0',
              'ms': 'Versi 1.0.0',
              'fa': 'نسخه 1.0.0',
              'fr': 'Version 1.0.0',
              'zh': '版本 1.0.0',
              'ja': 'バージョン 1.0.0',
              'ru': 'Версия 1.0.0',
              'de': 'Version 1.0.0',
              'sw': 'Toleo 1.0.0',
              'ha': 'Sigila 1.0.0',
            }),
            style: TextStyle(
              fontSize: 14,
              color: themeConfig.textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeConfig.accentColor.withOpacity(0.2),
            themeConfig.primaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeConfig.accentColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.code_rounded,
            color: themeConfig.accentColor,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Kaynak Kodu',
              'en': 'Source Code',
              'ar': 'الكود المصدري',
              'id': 'Kode Sumber',
              'ur': 'سورس کوڈ',
              'bn': 'সোর্স কোড',
              'ms': 'Kod Sumber',
              'fa': 'کد منبع',
              'fr': 'Code Source',
              'zh': '源代码',
              'ja': 'ソースコード',
              'ru': 'Исходный Код',
              'de': 'Quellcode',
              'sw': 'Msingi wa Nambari',
              'ha': 'Tushen Lambar',
            }),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeConfig.accentColor,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _launchUrl('https://github.com/mcanererdem/zikirmatik'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: themeConfig.goldGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.open_in_new, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'GitHub',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'İletişim',
              'en': 'Contact',
              'ar': 'التواصل',
              'id': 'Kontak',
              'ur': 'رابطہ کریں',
              'bn': 'যোগাযোগ',
              'ms': 'Hubungi',
              'fa': 'تماس',
              'fr': 'Contact',
              'zh': '联系',
              'ja': '連絡',
              'ru': 'Контакт',
              'de': 'Kontakt',
              'sw': 'Mawasiliano',
              'ha': 'Tuntuba',
            }),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _launchUrl('mailto:mcanererdem@gmail.com'),
            child: Text(
              'mcanererdem@gmail.com',
              style: TextStyle(
                fontSize: 14,
                color: themeConfig.accentColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.emoji_events_rounded, 
        'text': DynamicLocalizationHelper.getText({
          'tr': 'Günlük, Haftalık, Aylık Hedefler',
          'en': 'Daily, Weekly, Monthly Goals',
          'ar': 'أهداف يومية، أسبوعية، شهرية',
          'id': 'Tujuan Harian, Mingguan, Bulanan',
          'ur': 'روزانہ، ہفتہ وار، ماہانہ ہدف',
          'bn': 'দৈনিক, সাপ্তাহিক, মাসিক লক্ষ্য',
          'ms': 'Matlamat Harian, Mingguan, Bulanan',
          'fa': 'اهداف روزانه، هفتگی، ماهانه',
          'fr': 'Objectifs Quotidiens, Hebdomadaires, Mensuels',
          'zh': '每日、每周、每月目标',
          'ja': '日次、週次、月次目標',
          'ru': 'Ежедневные, Еженедельные, Ежемесячные Цели',
          'de': 'Tägliche, Wöchentliche, Monatliche Ziele',
          'sw': 'Lengo la Kila Siku, Wiki, Mwezi',
          'ha': 'Manufa Na Rana, Mako, Wata',
        })
      },
      {
        'icon': Icons.bar_chart_rounded, 
        'text': DynamicLocalizationHelper.getText({
          'tr': 'Detaylı İstatistikler',
          'en': 'Detailed Statistics',
          'ar': 'إحصائيات مفصلة',
          'id': 'Statistik Detail',
          'ur': 'تفصیلی احصائیات',
          'bn': 'বিস্তারিত পরিসংখ্যান',
          'ms': 'Statistik Terperinci',
          'fa': 'آمار دقیق',
          'fr': 'Statistiques Détaillées',
          'zh': '详细统计',
          'ja': '詳細な統計',
          'ru': 'Подробная Статистика',
          'de': 'Detaillierte Statistik',
          'sw': 'Takwimu Zaidi',
          'ha': 'Statistics Cikak',
        })
      },
      {
        'icon': Icons.widgets_rounded, 
        'text': DynamicLocalizationHelper.getText({
          'tr': 'Ana Ekran Widget',
          'en': 'Home Screen Widget',
          'ar': 'ودجت الشاشة الرئيسية',
          'id': 'Widget Layar Utama',
          'ur': 'ہوم اسکرن ویجیٹ',
          'bn': 'হোম স্ক্রীন উইজেট',
          'ms': 'Widget Skrin Utama',
          'fa': 'ویجت صفحه اصلی',
          'fr': 'Widget Écran d\'accueil',
          'zh': '主屏幕小组件',
          'ja': 'ホーム画面ウィジェット',
          'ru': 'Виджет Главного Экрана',
          'de': 'Startbildschirm-Widget',
          'sw': 'Widget ya Skrini ya Nyumbani',
          'ha': 'Widget na Gidan Gida',
        })
      },
      {
        'icon': Icons.language_rounded,
        'text': DynamicLocalizationHelper.getText({
          'tr': '16 Dil Desteği',
          'en': '16 Languages Support',
          'ar': 'دعم 16 لغة',
          'id': 'Dukungan 16 Bahasa',
          'ur': '16 زبانوں کی سپورٹ',
          'bn': '১৬টি ভাষা সমর্থন',
          'ms': 'Sokongan 16 Bahasa',
          'fa': 'پشتیبانی از 16 زبان',
          'fr': 'Support de 16 Langues',
          'zh': '支持16种语言',
          'ja': '16言語サポート',
          'ru': 'Поддержка 16 Языков',
          'de': 'Unterstützung für 16 Sprachen',
          'sw': 'Msaada wa Lugha 16',
          'ha': 'Tallafi Harshe 16',
        })
      },
      {
        'icon': Icons.emoji_events_rounded,
        'text': DynamicLocalizationHelper.getText({
          'tr': 'Kupa Sistemi (Bronz, Gümüş, Altın, Elmas, Platin)',
          'en': 'Trophy System (Bronze, Silver, Gold, Diamond, Platinum)',
          'ar': 'نظام الكؤوس (برونزي، فضي، ذهبي، ماسي، بلاتيني)',
          'id': 'Sistem Piala (Perunggu, Perak, Emas, Berlian, Platinum)',
          'ur': 'ٹرافی سسٹم (کانسی، چاندی، سونا، ہیرا، پلاٹینم)',
          'bn': 'ট্রফি সিস্টেম (ব্রোঞ্জ, রৌপ্য, স্বর্ণ, হীরা, প্ল্যাটিনাম)',
          'ms': 'Sistem Piala (Gangsa, Perak, Emas, Berlian, Platinum)',
          'fa': 'سیستم جام (برنزی، نقره، طلا، الماس، پلاتین)',
          'fr': 'Système de Trophées (Bronze, Argent, Or, Diamant, Platine)',
          'zh': '奖杯系统（铜、银、金、钻石、白金）',
          'ja': 'トロフィーシステム（銅、銀、金、ダイヤ、プラチナ）',
          'ru': 'Система трофеев (бронза, серебро, золото, алмаз, платина)',
          'de': 'Trophäen-System (Bronze, Silber, Gold, Diamant, Platin)',
          'sw': 'Mfumo wa Tuzo (Shaba, Fedha, Dhahabu, Almasi, Platini)',
          'ha': 'Tsarin Kofuna (Bronze, Azurfa, Zinariya, Lu\'u, Platinum)',
        })
      },
      {
        'icon': Icons.notifications_active_rounded,
        'text': DynamicLocalizationHelper.getText({
          'tr': 'Günlük Hatırlatıcı ve Bildirimler',
          'en': 'Daily Reminders and Notifications',
          'ar': 'تذكيرات يومية وإشعارات',
          'id': 'Pengingat Harian dan Notifikasi',
          'ur': 'روزانہ یاد دہانیاں اور نوٹیفکیشنز',
          'bn': 'দৈনিক অনুস্মারক ও বিজ্ঞপ্তি',
          'ms': 'Peringatan Harian dan Notifikasi',
          'fa': 'یادآور روزانه و اعلان‌ها',
          'fr': 'Rappels Quotidiens et Notifications',
          'zh': '每日提醒与通知',
          'ja': '日次リマインダーと通知',
          'ru': 'Ежедневные напоминания и уведомления',
          'de': 'Tägliche Erinnerungen und Benachrichtigungen',
          'sw': 'Vikumbusho vya Kila Siku na Arifa',
          'ha': 'Tunatarwa na Sanarwa na Yau da Kullum',
        })
      },
      {
        'icon': Icons.volume_up_rounded,
        'text': DynamicLocalizationHelper.getText({
          'tr': 'Sesli Okuma (TTS) ve Titreşim',
          'en': 'Text-to-Speech (TTS) and Vibration',
          'ar': 'القراءة الصوتية والاهتزاز',
          'id': 'Teks ke Suara (TTS) dan Getaran',
          'ur': 'ٹیکسٹ ٹو اسپیچ اور لرزش',
          'bn': 'টেক্সট টু স্পিচ ও কম্পন',
          'ms': 'Teks ke Suara (TTS) dan Getaran',
          'fa': 'متن به گفتار (TTS) و لرزش',
          'fr': 'Synthèse Vocale (TTS) et Vibration',
          'zh': '语音朗读（TTS）与振动',
          'ja': '音声読み上げ（TTS）と振動',
          'ru': 'Озвучивание (TTS) и вибрация',
          'de': 'Sprachausgabe (TTS) und Vibration',
          'sw': 'Kusoma kwa Sauti na Mtetemo',
          'ha': 'Karatu da Murya da Girgiza',
        })
      },
      {
        'icon': Icons.upload_rounded,
        'text': DynamicLocalizationHelper.getText({
          'tr': 'İçe ve Dışa Aktarma (Yedekleme)',
          'en': 'Import and Export (Backup)',
          'ar': 'استيراد وتصدير (نسخ احتياطي)',
          'id': 'Impor dan Ekspor (Cadangan)',
          'ur': 'درآمد اور برآمد (بیک اپ)',
          'bn': 'আমদানি ও রপ্তানি (ব্যাকআপ)',
          'ms': 'Import dan Eksport (Sandaran)',
          'fa': 'وارد و صادر (پشتیبان‌گیری)',
          'fr': 'Import et Export (Sauvegarde)',
          'zh': '导入与导出（备份）',
          'ja': 'インポート・エクスポート（バックアップ）',
          'ru': 'Импорт и экспорт (резервная копия)',
          'de': 'Import und Export (Sicherung)',
          'sw': 'Ingiza na Hamisha (Hifadhi)',
          'ha': 'Shigar da Fitar da Bayanai (Ajiye)',
        })
      },
      {
        'icon': Icons.palette_rounded,
        'text': DynamicLocalizationHelper.getText({
          'tr': '8 Tema ve Karanlık Mod',
          'en': '8 Themes and Dark Mode',
          'ar': '8 ثيمات والوضع الداكن',
          'id': '8 Tema dan Mode Gelap',
          'ur': '8 تھیم اور ڈارک موڈ',
          'bn': '৮টি থিম ও ডার্ক মোড',
          'ms': '8 Tema dan Mod Gelap',
          'fa': '8 تم و حالت تاریک',
          'fr': '8 Thèmes et Mode Sombre',
          'zh': '8种主题与深色模式',
          'ja': '8テーマとダークモード',
          'ru': '8 тем и тёмный режим',
          'de': '8 Themen und Dunkelmodus',
          'sw': 'Mada 8 na Hali ya Giza',
          'ha': 'Jigo 8 da Yanayin Duhu',
        })
      },
      {
        'icon': Icons.leaderboard_rounded,
        'text': DynamicLocalizationHelper.getText({
          'tr': 'Liderlik Tablosu (Günlük/Haftalık/Aylık)',
          'en': 'Leaderboard (Daily/Weekly/Monthly)',
          'ar': 'لوحة المتصدرين (يومي/أسبوعي/شهري)',
          'id': 'Papan Peringkat (Harian/Mingguan/Bulanan)',
          'ur': 'لیڈر بورڈ (روزانہ/ہفتہ وار/ماہانہ)',
          'bn': 'লিডারবোর্ড (দৈনিক/সাপ্তাহিক/মাসিক)',
          'ms': 'Papan Pendahulu (Harian/Mingguan/Bulanan)',
          'fa': 'جدول امتیازات (روزانه/هفتگی/ماهانه)',
          'fr': 'Classement (Quotidien/Hebdo/Mensuel)',
          'zh': '排行榜（日/周/月）',
          'ja': 'リーダーボード（日/週/月）',
          'ru': 'Таблица лидеров (день/неделя/месяц)',
          'de': 'Bestenliste (Täglich/Wöchentlich/Monatlich)',
          'sw': 'Ubao wa Uongozi (Kila Siku/Wiki/Mwezi)',
          'ha': 'Allon Farko (Yau da Kullum/Mako/Wata)',
        })
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeConfig.accentColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Özellikler',
              'en': 'Features',
              'ar': 'المميزات',
              'id': 'Fitur',
              'ur': 'خصوصیات',
              'bn': 'বৈশিষ্ট্য',
              'ms': 'Ciri-ciri',
              'fa': 'ویژگی‌ها',
              'fr': 'Fonctionnalités',
              'zh': '功能',
              'ja': '機能',
              'ru': 'Функции',
              'de': 'Funktionen',
              'sw': 'Vipengele',
              'ha': 'Siffoki',
            }),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeConfig.accentColor,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  feature['icon'] as IconData,
                  color: themeConfig.accentColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature['text'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeConfig.textColor,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    final helpItems = [
      {
        'icon': Icons.local_fire_department_rounded,
        'title': localizations.translate('help_streak_title') ?? 'Seri (Streak) Nedir?',
        'text': localizations.translate('help_streak_text') ?? 'Hedeflerinizi düzenli olarak tamamladığınızda bir "seri" kazanırsınız. Serinizi ne kadar uzun süre devam ettirirseniz, motivasyonunuz o kadar artar. Her gün en az bir hedefi tamamlayarak seriyi canlı tutun!'
      },
      {
        'icon': Icons.flag_rounded,
        'title': localizations.translate('help_goal_title') ?? 'Hedef (Goal) Nasıl Çalışır?',
        'text': localizations.translate('help_goal_text') ?? 'Günlük, haftalık veya aylık hedefler belirleyebilirsiniz. Örneğin, "günde 1000 zikir" gibi. Hedeflerinize ulaştığınızda özel bildirimler ve animasyonlarla ödüllendirilirsiniz. Hedefler, zikirlerinizi daha planlı bir şekilde çekmenize yardımcı olur.'
      },
      {
        'icon': Icons.add_circle_outline_rounded,
        'title': localizations.translate('help_addzikr_title') ?? 'Nasıl Zikir Eklenir?',
        'text': localizations.translate('help_addzikr_text') ?? 'Ana ekrandaki zikir adına dokunarak zikir seçme ekranını açabilirsiniz. Bu ekranda, mevcut zikirler arasından seçim yapabilir veya "Yeni Zikir Ekle" butonuyla kendi özel zikirlerinizi oluşturabilirsiniz.'
      },
      {
        'icon': Icons.toggle_on_rounded,
        'title': localizations.translate('help_toggles_title') ?? 'Açma/Kapama Butonları',
        'text': localizations.translate('help_toggles_text') ?? 'Ana ekranın altındaki kontrol butonları ile Titreşim, Ses ve Konfeti animasyonu gibi özellikleri anında açıp kapatabilirsiniz. Deneyiminizi kişiselleştirmek için bu ayarları kullanın.'
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeConfig.accentColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Uygulama Özellikleri',
              'en': 'App Features',
              'ar': 'مميزات التطبيق',
              'id': 'Fitur Aplikasi',
              'ur': 'ایپ کی خصوصیات',
              'bn': 'অ্যাপ বৈশিষ্ট্য',
              'ms': 'Ciri-ciri Aplikasi',
              'fa': 'ویژگی‌های برنامه',
              'fr': 'Fonctionnalités de l\'App',
              'zh': '应用功能',
              'ja': 'アプリの機能',
              'ru': 'Функции Приложения',
              'de': 'App-Funktionen',
              'sw': 'Vipengele vya Programu',
              'ha': 'Siffofin App',
            }),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeConfig.accentColor,
            ),
          ),
          const SizedBox(height: 16),
          ...helpItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: themeConfig.accentColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeConfig.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item['text'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: themeConfig.textColor.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLegalSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeConfig.accentColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.policy_rounded, color: themeConfig.accentColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Legal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeConfig.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _launchUrl('https://mcanererdem.github.io/zikirmatik/privacy_policy.html'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: themeConfig.textColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.privacy_tip_rounded, color: themeConfig.textColor.withOpacity(0.7), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(color: themeConfig.textColor, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _launchUrl('https://github.com/mcanererdem/zikirmatik/blob/main/LICENSE'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: themeConfig.textColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.description_rounded, color: themeConfig.textColor.withOpacity(0.7), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'License',
                      style: TextStyle(color: themeConfig.textColor, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '© ${DateTime.now().year} Tasbih Counter. All rights reserved.',
            style: TextStyle(color: themeConfig.textColor.withOpacity(0.54), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
