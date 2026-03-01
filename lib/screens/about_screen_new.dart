import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';

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
          'Hakkımızda',
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
            'Versiyon ${widget.appVersion}',
            style: GoogleFonts.notoSans(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Modern bir zikir sayacı uygulaması. Kullanıcı dostu arayüzü, zikir takibi, kupa sistemi ve daha birçok özellik sunar.',
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
            'Geliştirici',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoItem(
            'Ad',
            'M. Caner Erdem',
            Icons.person,
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoItem(
            'Web Sitesi',
            'www.mcanererdem.com',
            Icons.language,
            () => _launchUrl('https://www.mcanererdem.com'),
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
            'E-posta',
            'info@mcanererdem.com',
            Icons.email,
            () => _launchEmail('info@mcanererdem.com'),
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
            'Özellikler',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildFeatureItem('🎯 Zikir Sayma', 'Basit ve etkili zikir sayma arayüzü'),
          _buildFeatureItem('🏆 Kupa Sistemi', 'Başarımları ödüllendirin'),
          _buildFeatureItem('📊 İstatistikler', 'Detaylı zikir takibi ve analizler'),
          _buildFeatureItem('🎨 Temalar', 'Çoklu tema seçeneği'),
          _buildFeatureItem('🌍 Çoklu Dil', 'Farklı dil desteği'),
          _buildFeatureItem('🔔 Bildirimler', 'Hatırlatıcı bildirimler'),
          _buildFeatureItem('💾 Veri Yedekleme', 'İçe/Dışa aktar özelliği'),
          _buildFeatureItem('📱 Widget Desteği', 'Ana ekran widget'),
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
            'Teşekkürler',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Zikirmatik\'ı kullandığınız için teşekkür ederiz. Umarız uygulama ibadetlerinizi kolaylaştırır ve manevi hayatınıza değer katar.',
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
            'Yasal Bilgiler',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildLegalItem(
            'Gizlilik Politikası',
            'Verilerinizin nasıl korunduğunu öğrenin',
            () => _launchUrl('https://www.mcanererdem.com/privacy'),
          ),
          
          const SizedBox(height: 12),
          
          _buildLegalItem(
            'Kullanım Koşulları',
            'Uygulama kullanım kuralları',
            () => _launchUrl('https://www.mcanererdem.com/terms'),
          ),
          
          const SizedBox(height: 12),
          
          _buildLegalItem(
            'Lisans',
            'Açık kaynak lisansı',
            () => _launchUrl('https://www.mcanererdem.com/license'),
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
      query: 'subject=Zikirmatik Hakkında',
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
