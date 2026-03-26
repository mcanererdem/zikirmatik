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
            
            const SizedBox(height: 30),
            
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
            DynamicLocalizationHelper.getText({
              'tr': 'Modern bir zikir sayacı uygulaması. Zikir takibi, kupa ilerlemesi, istatistikler, yedekleme ve çoklu dil desteği sunar.',
              'en': 'A modern dhikr counter app with dhikr tracking, trophy progress, statistics, backup, and multi-language support.',
            }),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Geliştirici',
              'en': 'Developer',
            }),
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoItem(
            DynamicLocalizationHelper.getText({'tr': 'Ad', 'en': 'Name'}),
            'Caner Erdem',
            Icons.person,
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoItem(
            'Website',
            'github.com/mcanererdem/zikirmatik',
            Icons.language,
            () => _launchUrl('https://github.com/mcanererdem/zikirmatik'),
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoItem(
            'GitHub',
            'github.com/mcanererdem',
            Icons.code,
            () => _launchUrl('https://github.com/mcanererdem'),
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoItem(
            DynamicLocalizationHelper.getText({'tr': 'E-posta', 'en': 'Email'}),
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
            }),
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildFeatureItem(
            DynamicLocalizationHelper.getText({'tr': '🎯 Zikir Sayacı', 'en': '🎯 Dhikr Counter'}),
            DynamicLocalizationHelper.getText({'tr': 'Hızlı ve sade sayaç deneyimi', 'en': 'Fast and simple counting experience'}),
          ),
          _buildFeatureItem(
            DynamicLocalizationHelper.getText({'tr': '🏆 Kupa İlerlemesi', 'en': '🏆 Trophy Progress'}),
            DynamicLocalizationHelper.getText({'tr': 'Kademeli kupa hedefleri ve ilerleme görünümü', 'en': 'Tiered trophy goals with progress visibility'}),
          ),
          _buildFeatureItem(
            DynamicLocalizationHelper.getText({'tr': '📊 İstatistikler', 'en': '📊 Statistics'}),
            DynamicLocalizationHelper.getText({'tr': 'Günlük/haftalık/aylık analiz ekranları', 'en': 'Daily/weekly/monthly analytics views'}),
          ),
          _buildFeatureItem(
            DynamicLocalizationHelper.getText({'tr': '☁️ Leaderboard Senkronu', 'en': '☁️ Leaderboard Sync'}),
            DynamicLocalizationHelper.getText({'tr': 'Paylaşım açıkken bulut eşleme ve sıralama', 'en': 'Cloud sync and ranking when sharing is enabled'}),
          ),
          _buildFeatureItem(
            DynamicLocalizationHelper.getText({'tr': '💾 İçe/Dışa Aktar', 'en': '💾 Import/Export'}),
            DynamicLocalizationHelper.getText({'tr': 'Yedekleme, geri yükleme ve veri taşınabilirliği', 'en': 'Backup, restore, and data portability'}),
          ),
          _buildFeatureItem(
            DynamicLocalizationHelper.getText({'tr': '🌍 Çoklu Dil + Tema', 'en': '🌍 Multi-language + Themes'}),
            DynamicLocalizationHelper.getText({'tr': 'Kişiselleştirilebilir arayüz deneyimi', 'en': 'Customizable interface experience'}),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.notoSans(
                color: Colors.white70,
                fontSize: 12,
                height: 1.3,
              ),
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
            DynamicLocalizationHelper.getText({'tr': 'Teşekkürler', 'en': 'Thank You'}),
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Uygulamayı kullandığınız için teşekkür ederiz. Geri bildirimlerinizle uygulamayı sürekli geliştiriyoruz.',
              'en': 'Thank you for using the app. We continuously improve it with your feedback.',
            }),
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
            DynamicLocalizationHelper.getText({
              'tr': 'Yasal Bilgiler',
              'en': 'Legal',
            }),
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildLegalItem(
            DynamicLocalizationHelper.getText({'tr': 'Gizlilik Politikası', 'en': 'Privacy Policy'}),
            DynamicLocalizationHelper.getText({'tr': 'Verilerinizin nasıl işlendiğini öğrenin', 'en': 'Learn how your data is handled'}),
            () => _launchUrl('https://mcanererdem.github.io/zikirmatik/privacy'),
          ),
          
          const SizedBox(height: 12),
          
          _buildLegalItem(
            DynamicLocalizationHelper.getText({'tr': 'Kullanım Koşulları', 'en': 'Terms of Use'}),
            DynamicLocalizationHelper.getText({'tr': 'Uygulama kullanım koşulları', 'en': 'Application usage terms'}),
            () => _launchEmail('tasbih.counter.zikirmatik@gmail.com'),
          ),
          
          const SizedBox(height: 12),
          
          _buildLegalItem(
            DynamicLocalizationHelper.getText({'tr': 'Lisans', 'en': 'License'}),
            DynamicLocalizationHelper.getText({'tr': 'Açık kaynak lisans bilgisi', 'en': 'Open source license details'}),
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
      query: 'subject=${Uri.encodeComponent(DynamicLocalizationHelper.getText({'tr': 'Zikirmatik Hakkında', 'en': 'About Zikirmatik'}))}',
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
