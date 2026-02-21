import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';

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
            localizations.translate('version') ?? 'Version 1.0.0',
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
            localizations.translate('source_code') ?? 'Source Code',
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
            localizations.translate('contact') ?? 'Contact',
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
      {'icon': Icons.emoji_events_rounded, 'text': localizations.translate('feature_goals') ?? 'Daily, Weekly, Monthly Goals'},
      {'icon': Icons.bar_chart_rounded, 'text': localizations.translate('feature_statistics') ?? 'Detailed Statistics'},
      {'icon': Icons.widgets_rounded, 'text': localizations.translate('feature_widget') ?? 'Home Screen Widget'},
      {'icon': Icons.language_rounded, 'text': localizations.translate('feature_languages') ?? '15 Languages Support'},
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
            localizations.translate('features') ?? 'Features',
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
            localizations.translate('help_title') ?? 'Uygulama Özellikleri',
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
            onTap: () => _launchUrl('https://github.com/mcanererdem/zikirmatik/blob/dev/LICENSE'),
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
