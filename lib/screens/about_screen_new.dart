import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';

class AboutScreenNew extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String appVersion;

  const AboutScreenNew({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.appVersion,
  });

  @override
  State<AboutScreenNew> createState() => _AboutScreenNewState();
}

class _AboutScreenNewState extends State<AboutScreenNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.themeConfig.primaryColor,
      appBar: AppBar(
        backgroundColor: widget.themeConfig.primaryColor,
        elevation: 0,
        title: Text(
          DynamicLocalizationHelper.getText({
            'tr': 'Hakkımızda',
            'en': 'About',
            'ar': 'حول التطبيق',
            'id': 'Tentang',
            'ur': 'ہمارے بارے میں',
            'bn': 'অ্যাপ সম্পর্কে',
            'ms': 'Perihal',
            'fa': 'درباره برنامه',
            'fr': 'À propos',
            'zh': '关于',
            'ja': 'このアプリについて',
            'ru': 'О приложении',
            'de': 'Über die App',
            'sw': 'Kuhusu',
            'ha': 'Game da app',
          }),
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo ve Bilgileri
            _buildAppInfo(),

            const SizedBox(height: 18),
            _buildAboutHero(),
            const SizedBox(height: 22),

            // Geliştirici Bilgileri
            _buildDeveloperInfo(),
            
            const SizedBox(height: 30),
            
            // Özellikler
            _buildFeatures(),
            
            const SizedBox(height: 30),
            
            // Teşekkürler
            _buildThanks(),
            
            const SizedBox(height: 30),
            
            // Lisans ve Politikalar
            _buildLegal(),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutHero() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.themeConfig.accentColor.withOpacity(0.25),
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 0.14,
              child: Image.asset(
                'assets/generated/illustrations/about_hero.png',
                fit: BoxFit.cover,
              ),
            ),
            // Hafif bir gradient overlay; görselin yazıyla çakışmasını azaltır.
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.themeConfig.primaryColor.withOpacity(0.25),
                    widget.themeConfig.primaryColor.withOpacity(0.55),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.themeConfig.accentColor.withOpacity(0.2),
            widget.themeConfig.accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.accentColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // App Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: widget.themeConfig.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: widget.themeConfig.accentColor.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.mosque,
              color: widget.themeConfig.accentColor,
              size: 40,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Zikirmatik',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '${DynamicLocalizationHelper.getText({
              'tr': 'Sürüm',
              'en': 'Version',
              'ar': 'الإصدار',
              'id': 'Versi',
              'ur': 'ورژن',
              'bn': 'সংস্করণ',
              'ms': 'Versi',
              'fa': 'نسخه',
              'fr': 'Version',
              'zh': '版本',
              'ja': 'バージョン',
              'ru': 'Версия',
              'de': 'Version',
              'sw': 'Toleo',
              'ha': 'Sigar',
            })} ${widget.appVersion}',
            style: GoogleFonts.notoSans(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            widget.localizations.translate('about_intro'),
            style: GoogleFonts.notoSans(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.localizations.translate('about_developer_title'),
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoItem(
            widget.localizations.translate('name'),
            'Caner Erdem',
            Icons.person,
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoItem(
            DynamicLocalizationHelper.getText({
              'tr': 'LinkedIn',
              'en': 'LinkedIn',
              'ar': 'لينكدإن',
              'id': 'LinkedIn',
              'ur': 'لنکڈ اِن',
              'ms': 'LinkedIn',
              'fa': 'لینکدین',
              'fr': 'LinkedIn',
              'zh': '领英',
              'ja': 'LinkedIn',
              'ru': 'LinkedIn',
              'de': 'LinkedIn',
              'sw': 'LinkedIn',
              'ha': 'LinkedIn',
            }),
            'linkedin.com/in/mcanererdem',
            Icons.business_center,
            () => _launchUrl('https://www.linkedin.com/in/mcanererdem/'),
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoItem(
            widget.localizations.translate('github'),
            'github.com/mcanererdem',
            Icons.code,
            () => _launchUrl('https://github.com/mcanererdem'),
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoItem(
            widget.localizations.translate('email'),
            'tasbih.counter.zikirmatik@gmail.com',
            Icons.email,
            () => _launchEmail('tasbih.counter.zikirmatik@gmail.com'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, [VoidCallback? onTap]) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: widget.themeConfig.accentColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.notoSans(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Özellikler',
              'en': 'Features',
              'ar': 'الميزات',
              'id': 'Fitur',
              'ur': 'خصوصیات',
              'bn': 'ফিচারসমূহ',
              'ms': 'Ciri-ciri',
              'fa': 'ویژگی‌ها',
              'fr': 'Fonctionnalités',
              'zh': '功能',
              'ja': '機能',
              'ru': 'Функции',
              'de': 'Funktionen',
              'sw': 'Vipengele',
              'ha': 'Siffofi',
            }),
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildFeatureItem(
            DynamicLocalizationHelper.getText({
              'tr': '🎯 Zikir Sayacı',
              'en': '🎯 Dhikr Counter',
              'ar': '🎯 عداد الذكر',
              'id': '🎯 Penghitung Zikir',
              'ur': '🎯 ذکر کاؤنٹر',
              'bn': '🎯 জিকির কাউন্টার',
              'ms': '🎯 Kaunter Zikir',
              'fa': '🎯 شمارنده ذکر',
              'fr': '🎯 Compteur de Dhikr',
              'zh': '🎯 赞念计数器',
              'ja': '🎯 ジクルカウンター',
              'ru': '🎯 Счётчик зикра',
              'de': '🎯 Dhikr-Zähler',
              'sw': '🎯 Kihesabu Dhikr',
              'ha': '🎯 Mai Kirga Zikiri',
            }),
            DynamicLocalizationHelper.getText({
              'tr': 'Hızlı ve sade sayaç deneyimi',
              'en': 'Fast and simple counting experience',
              'ar': 'تجربة عدّ سريعة وبسيطة',
              'id': 'Pengalaman menghitung yang cepat dan sederhana',
              'ur': 'تیز اور سادہ گنتی کا تجربہ',
              'bn': 'দ্রুত ও সহজ কাউন্টিং অভিজ্ঞতা',
              'ms': 'Pengalaman kiraan yang pantas dan ringkas',
              'fa': 'تجربه شمارش سریع و ساده',
              'fr': 'Une expérience de comptage rapide et simple',
              'zh': '快速简洁的计数体验',
              'ja': '素早くシンプルなカウント体験',
              'ru': 'Быстрый и простой подсчёт',
              'de': 'Schnelles und einfaches Zählerlebnis',
              'sw': 'Uzoefu wa kuhesabu wa haraka na rahisi',
              'ha': 'Saurin kidaya mai sauki',
            }),
          ),
          _buildFeatureItem(
            DynamicLocalizationHelper.getText({
              'tr': '🏆 Kupa İlerlemesi',
              'en': '🏆 Trophy Progress',
              'ar': '🏆 تقدم الكؤوس',
              'id': '🏆 Progres Piala',
              'ur': '🏆 ٹرافی پیش رفت',
              'bn': '🏆 ট্রফি অগ্রগতি',
              'ms': '🏆 Kemajuan Trofi',
              'fa': '🏆 پیشرفت جام‌ها',
              'fr': '🏆 Progression des trophées',
              'zh': '🏆 奖杯进度',
              'ja': '🏆 トロフィー進捗',
              'ru': '🏆 Прогресс трофеев',
              'de': '🏆 Trophäenfortschritt',
              'sw': '🏆 Maendeleo ya Nyara',
              'ha': '🏆 Ci gaban Kofuna',
            }),
            DynamicLocalizationHelper.getText({
              'tr': 'Kademeli kupa hedefleri ve ilerleme görünümü',
              'en': 'Tiered trophy goals with progress visibility',
              'ar': 'أهداف كؤوس متدرجة مع عرض واضح للتقدم',
              'id': 'Target piala bertahap dengan tampilan progres',
              'ur': 'درجہ بندی شدہ ٹرافی اہداف اور پیش رفت کا واضح نظارہ',
              'bn': 'ধাপে ধাপে ট্রফি লক্ষ্য ও অগ্রগতির দৃশ্য',
              'ms': 'Sasaran trofi bertahap dengan paparan kemajuan',
              'fa': 'اهداف مرحله‌ای جام با نمایش پیشرفت',
              'fr': 'Objectifs de trophées par niveaux avec suivi visible',
              'zh': '分级奖杯目标与进度展示',
              'ja': '段階的なトロフィー目標と進捗表示',
              'ru': 'Многоуровневые цели трофеев с видимым прогрессом',
              'de': 'Gestufte Trophäenziele mit sichtbarem Fortschritt',
              'sw': 'Malengo ya nyara kwa viwango na mwonekano wa maendeleo',
              'ha': 'Manufofin kofi na matakai tare da nuna ci gaba',
            }),
          ),
          _buildFeatureItem(
            DynamicLocalizationHelper.getText({
              'tr': '📊 İstatistikler',
              'en': '📊 Statistics',
              'ar': '📊 الإحصائيات',
              'id': '📊 Statistik',
              'ur': '📊 شماریات',
              'bn': '📊 পরিসংখ্যান',
              'ms': '📊 Statistik',
              'fa': '📊 آمار',
              'fr': '📊 Statistiques',
              'zh': '📊 统计',
              'ja': '📊 統計',
              'ru': '📊 Статистика',
              'de': '📊 Statistiken',
              'sw': '📊 Takwimu',
              'ha': '📊 Kididdiga',
            }),
            DynamicLocalizationHelper.getText({
              'tr': 'Günlük/haftalık/aylık analiz ekranları',
              'en': 'Daily/weekly/monthly analytics views',
              'ar': 'شاشات تحليل يومي/أسبوعي/شهري',
              'id': 'Tampilan analitik harian/mingguan/bulanan',
              'ur': 'روزانہ/ہفتہ وار/ماہانہ تجزیاتی اسکرینیں',
              'bn': 'দৈনিক/সাপ্তাহিক/মাসিক বিশ্লেষণ স্ক্রিন',
              'ms': 'Paparan analitik harian/mingguan/bulanan',
              'fa': 'نمایش تحلیل روزانه/هفتگی/ماهانه',
              'fr': 'Vues analytiques quotidiennes/hebdomadaires/mensuelles',
              'zh': '日/周/月分析视图',
              'ja': '日次/週次/月次の分析画面',
              'ru': 'Ежедневная/еженедельная/ежемесячная аналитика',
              'de': 'Tägliche/wöchentliche/monatliche Analyseansichten',
              'sw': 'Mionekano ya uchambuzi wa kila siku/wiki/mwezi',
              'ha': 'Allon nazari na kullum/mako-mako/wata-wata',
            }),
          ),
          _buildFeatureItem(
            DynamicLocalizationHelper.getText({
              'tr': '☁️ Leaderboard Senkronu',
              'en': '☁️ Leaderboard Sync',
              'ar': '☁️ مزامنة لوحة المتصدرين',
              'id': '☁️ Sinkronisasi Papan Peringkat',
              'ur': '☁️ لیڈر بورڈ ہم آہنگی',
              'bn': '☁️ লিডারবোর্ড সিঙ্ক',
              'ms': '☁️ Segerak Kedudukan',
              'fa': '☁️ همگام‌سازی جدول رتبه‌بندی',
              'fr': '☁️ Sync Classement',
              'zh': '☁️ 排行榜同步',
              'ja': '☁️ ランキング同期',
              'ru': '☁️ Синхронизация таблицы лидеров',
              'de': '☁️ Ranglisten-Sync',
              'sw': '☁️ Usawazishaji wa Orodha',
              'ha': '☁️ Daidaita Jadawalin Jagoranci',
            }),
            DynamicLocalizationHelper.getText({
              'tr': 'Paylaşım açıkken bulut eşleme ve sıralama',
              'en': 'Cloud sync and ranking when sharing is enabled',
              'ar': 'مزامنة وترتيب سحابي عند تفعيل المشاركة',
              'id': 'Sinkronisasi cloud dan peringkat saat berbagi aktif',
              'ur': 'شیئرنگ آن ہونے پر کلاؤڈ سنک اور رینکنگ',
              'bn': 'শেয়ারিং চালু থাকলে ক্লাউড সিঙ্ক ও র‌্যাঙ্কিং',
              'ms': 'Segerak awan dan kedudukan apabila perkongsian diaktifkan',
              'fa': 'همگام‌سازی ابری و رتبه‌بندی هنگام فعال بودن اشتراک‌گذاری',
              'fr': 'Sync cloud et classement lorsque le partage est activé',
              'zh': '开启分享后进行云同步与排行',
              'ja': '共有有効時にクラウド同期とランキング',
              'ru': 'Облачная синхронизация и рейтинг при включенном доступе',
              'de': 'Cloud-Sync und Ranking bei aktivierter Freigabe',
              'sw': 'Usawazishaji wa wingu na nafasi ukishiriki umewashwa',
              'ha': 'Daidaita girgije da matsayi idan an kunna rabawa',
            }),
          ),
          _buildFeatureItem(
            DynamicLocalizationHelper.getText({
              'tr': '💾 İçe/Dışa Aktar',
              'en': '💾 Import/Export',
              'ar': '💾 استيراد/تصدير',
              'id': '💾 Impor/Ekspor',
              'ur': '💾 امپورٹ/ایکسپورٹ',
              'bn': '💾 ইমপোর্ট/এক্সপোর্ট',
              'ms': '💾 Import/Eksport',
              'fa': '💾 وارد/صادر',
              'fr': '💾 Import/Export',
              'zh': '💾 导入/导出',
              'ja': '💾 インポート/エクスポート',
              'ru': '💾 Импорт/Экспорт',
              'de': '💾 Import/Export',
              'sw': '💾 Ingiza/Hamisha',
              'ha': '💾 Shigo/Fitar',
            }),
            DynamicLocalizationHelper.getText({
              'tr': 'Yedekleme, geri yükleme ve veri taşınabilirliği',
              'en': 'Backup, restore, and data portability',
              'ar': 'نسخ احتياطي واستعادة ونقل البيانات',
              'id': 'Pencadangan, pemulihan, dan portabilitas data',
              'ur': 'بیک اپ، بحالی، اور ڈیٹا پورٹیبلٹی',
              'bn': 'ব্যাকআপ, রিস্টোর ও ডেটা পোর্টেবিলিটি',
              'ms': 'Sandaran, pemulihan, dan kebolehbawaan data',
              'fa': 'پشتیبان‌گیری، بازیابی و قابلیت انتقال داده',
              'fr': 'Sauvegarde, restauration et portabilité des données',
              'zh': '备份、恢复与数据可迁移',
              'ja': 'バックアップ、復元、データ移行',
              'ru': 'Резервное копирование, восстановление и переносимость данных',
              'de': 'Backup, Wiederherstellung und Datenportabilität',
              'sw': 'Hifadhi nakala, rudisha, na uhamishaji wa data',
              'ha': 'Ajiyar baya, mayarwa, da saukin daukar bayanai',
            }),
          ),
          _buildFeatureItem(
            DynamicLocalizationHelper.getText({
              'tr': '🌍 Çoklu Dil + Tema',
              'en': '🌍 Multi-language + Themes',
              'ar': '🌍 تعدد اللغات + السمات',
              'id': '🌍 Multi-bahasa + Tema',
              'ur': '🌍 کثیر زبانیں + تھیمز',
              'bn': '🌍 বহু ভাষা + থিম',
              'ms': '🌍 Pelbagai bahasa + Tema',
              'fa': '🌍 چندزبانه + تم‌ها',
              'fr': '🌍 Multilingue + Thèmes',
              'zh': '🌍 多语言 + 主题',
              'ja': '🌍 多言語 + テーマ',
              'ru': '🌍 Мультиязычность + Темы',
              'de': '🌍 Mehrsprachig + Themes',
              'sw': '🌍 Lugha nyingi + Mandhari',
              'ha': '🌍 Harsuna da yawa + Jigogi',
            }),
            DynamicLocalizationHelper.getText({
              'tr': 'Kişiselleştirilebilir arayüz deneyimi',
              'en': 'Customizable interface experience',
              'ar': 'تجربة واجهة قابلة للتخصيص',
              'id': 'Pengalaman antarmuka yang dapat disesuaikan',
              'ur': 'حسبِ ضرورت قابل تخصیص انٹرفیس تجربہ',
              'bn': 'কাস্টমাইজযোগ্য ইন্টারফেস অভিজ্ঞতা',
              'ms': 'Pengalaman antara muka yang boleh disesuaikan',
              'fa': 'تجربه رابط کاربری قابل شخصی‌سازی',
              'fr': 'Expérience d’interface personnalisable',
              'zh': '可自定义的界面体验',
              'ja': 'カスタマイズ可能なUI体験',
              'ru': 'Настраиваемый интерфейс',
              'de': 'Anpassbares Benutzeroberflächen-Erlebnis',
              'sw': 'Uzoefu wa kiolesura kinachoweza kubinafsishwa',
              'ha': 'Kwarewar fuskar app mai gyarawa',
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.notoSans(
              color: Colors.white70,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThanks() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.themeConfig.accentColor.withOpacity(0.2),
            widget.themeConfig.accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.accentColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            color: widget.themeConfig.accentColor,
            size: 32,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            widget.localizations.translate('about_thanks_title'),
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            widget.localizations.translate('about_thanks_desc'),
            style: GoogleFonts.notoSans(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLegal() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.localizations.translate('about_legal_title'),
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildLegalItem(
            widget.localizations.translate('about_privacy_title'),
            widget.localizations.translate('about_privacy_desc'),
            () => _launchUrl('https://mcanererdem.github.io/zikirmatik/privacy'),
          ),
          
          const SizedBox(height: 12),
          
          _buildLegalItem(
            widget.localizations.translate('about_terms_title'),
            widget.localizations.translate('about_terms_desc'),
            () => _launchUrl('https://github.com/mcanererdem/zikirmatik/blob/HEAD/TERMS_OF_USE.md'),
          ),
          
          const SizedBox(height: 12),
          
          _buildLegalItem(
            widget.localizations.translate('about_license_title'),
            widget.localizations.translate('about_license_desc'),
            () => _launchUrl('https://github.com/mcanererdem/zikirmatik/blob/main/LICENSE'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem(String title, String description, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.description,
              color: widget.themeConfig.accentColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.notoSans(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(DynamicLocalizationHelper.getText({
        'tr': 'Zikirmatik Hakkında',
        'en': 'About Zikirmatik',
        'ur': 'Zikirmatik کے بارے میں',
        'ms': 'Perihal Zikirmatik',
      }))}',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
