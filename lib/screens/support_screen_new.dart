import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';

class SupportScreenNew extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;

  const SupportScreenNew({
    super.key,
    required this.themeConfig,
    required this.localizations,
  });

  @override
  State<SupportScreenNew> createState() => _SupportScreenNewState();
}

class _SupportScreenNewState extends State<SupportScreenNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.themeConfig.primaryColor,
      appBar: AppBar(
        backgroundColor: widget.themeConfig.primaryColor,
        elevation: 0,
        title: Text(
          'Bize Destek Ol',
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
            // Header
            Container(
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
                    Icons.support_agent,
                    color: widget.themeConfig.accentColor,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Yardıma mı ihtiyacınız var?',
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sorunlarınızı yanıtlamak ve geri bildirimlerinizi değerlendirmek için buradayız.',
                    style: GoogleFonts.notoSans(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // İletişim Yöntemleri
            _buildContactMethods(),
            
            const SizedBox(height: 30),
            
            // Sıkça Sorulan Sorular
            _buildFAQ(),
            
            const SizedBox(height: 30),
            
            // Geri Bildirim
            _buildFeedback(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethods() {
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
            'İletişim Yöntemleri',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildContactItem(
            'E-posta',
            'support@mcanererdem.com',
            Icons.email,
            () => _launchEmail('support@mcanererdem.com'),
          ),
          
          const SizedBox(height: 16),
          
          _buildContactItem(
            'Web Sitesi',
            'www.mcanererdem.com',
            Icons.language,
            () => _launchUrl('https://www.mcanererdem.com'),
          ),
          
          const SizedBox(height: 16),
          
          _buildContactItem(
            'GitHub',
            'github.com/mcanererdem',
            Icons.code,
            () => _launchUrl('https://github.com/mcanererdem'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.themeConfig.accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: widget.themeConfig.accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSans(
                      color: Colors.white70,
                      fontSize: 14,
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

  Widget _buildFAQ() {
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
            'Sıkça Sorulan Sorular',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildFAQItem(
            'Zikirlerim kaybolursa ne yapmalıyım?',
            'Verileriniz cihazınızda saklanır. Uygulamayı silmeden önce İçe/Dışa Aktar özelliğini kullanarak yedek almanızı öneririz.',
          ),
          
          const SizedBox(height: 16),
          
          _buildFAQItem(
            'Reklamları nasıl kaldırabilirim?',
            'Reklamlar uygulamanın geliştirilmesi için gereklidir. Ayarlar menüsünden reklam izleme seçeneğini inceleyebilirsiniz.',
          ),
          
          const SizedBox(height: 16),
          
          _buildFAQItem(
            'Çoklu dil desteği olacak mı?',
            'Evet, gelecek güncellemelerde daha fazla dil desteği planlanmaktadır.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.accentColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: GoogleFonts.notoSans(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
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
            Icons.feedback,
            color: widget.themeConfig.accentColor,
            size: 32,
          ),
          const SizedBox(height: 16),
          Text(
            'Geri Bildirim',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Uygulamayı geliştirmemiz için geri bildirimlerinizi önemsiyoruz. Öneri ve şikayetlerinizi bizimle paylaşın.',
            style: GoogleFonts.notoSans(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _launchFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeConfig.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Geri Bildirim Gönder',
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Zikirmatik Destek',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchFeedback() async {
    final Uri feedbackUri = Uri(
      scheme: 'mailto',
      path: 'feedback@mcanererdem.com',
      query: 'subject=Zikirmatik Geri Bildirim',
    );
    
    if (await canLaunchUrl(feedbackUri)) {
      await launchUrl(feedbackUri);
    }
  }
}
