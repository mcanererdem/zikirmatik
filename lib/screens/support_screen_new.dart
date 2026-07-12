import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';

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
  static const String _supportEmail = 'tasbih.counter.zikirmatik@gmail.com';
  bool get _isRtl => Directionality.of(context) == TextDirection.rtl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.themeConfig.primaryColor,
      appBar: AppBar(
        backgroundColor: widget.themeConfig.primaryColor,
        elevation: 0,
        foregroundColor: widget.themeConfig.textColor,
        iconTheme: IconThemeData(color: widget.themeConfig.textColor),
        title: Text(
          widget.localizations.translate('contact'),
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: widget.themeConfig.textColor,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: widget.themeConfig.backgroundGradient,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.themeConfig.accentColor.withValues(alpha: 0.2),
                          widget.themeConfig.accentColor.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.themeConfig.accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.12,
                            child: Image.asset(
                              'assets/generated/illustrations/support_hero.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.contact_support,
                              color: widget.themeConfig.accentColor,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.localizations.translate('support_need_help_title'),
                              style: GoogleFonts.notoSans(
                                color: widget.themeConfig.textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.localizations.translate('support_need_help_desc'),
                              style: GoogleFonts.notoSans(
                                color: widget.themeConfig.textColor.withValues(alpha: 0.8),
                                fontSize: 14,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _buildContactMethods(),

                const SizedBox(height: 24),

                _buildRateAppCard(),

                const SizedBox(height: 30),

                _buildFAQ(),
                
                const SizedBox(height: 30),
                
                // Geri Bildirim
                _buildFeedback(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactMethods() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.textColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.localizations.translate('support_contact_methods_title'),
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          _buildContactItem(
            widget.localizations.translate('email'),
            _supportEmail,
            Icons.email,
            () => _launchEmail(_supportEmail),
          ),
          
          const SizedBox(height: 16),
          
          _buildContactItem(
            DynamicLocalizationHelper.getText({
              'tr': 'Gizlilik Politikası',
              'en': 'Privacy Policy',
              'ar': 'سياسة الخصوصية',
              'id': 'Kebijakan Privasi',
              'ur': 'رازداری کی پالیسی',
              'bn': 'গোপনীয়তা নীতি',
              'ms': 'Dasar Privasi',
              'fa': 'سیاست حریم خصوصی',
              'fr': 'Politique de confidentialité',
              'zh': '隐私政策',
              'ja': 'プライバシーポリシー',
              'ru': 'Политика конфиденциальности',
              'de': 'Datenschutzrichtlinie',
              'sw': 'Sera ya Faragha',
              'ha': 'Manufar Sirri',
            }),
            'mcanererdem.github.io/zikirmatik/privacy',
            Icons.language,
            () => _launchUrl('https://mcanererdem.github.io/zikirmatik/privacy'),
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
          color: widget.themeConfig.textColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.themeConfig.accentColor.withValues(alpha: 0.2),
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
                crossAxisAlignment: _isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textAlign: _isRtl ? TextAlign.right : TextAlign.left,
                    style: GoogleFonts.notoSans(
                      color: widget.themeConfig.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: _isRtl ? TextAlign.right : TextAlign.left,
                    style: GoogleFonts.notoSans(
                      color: widget.themeConfig.textColor.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _isRtl ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
              color: widget.themeConfig.textColor.withValues(alpha: 0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateAppCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.themeConfig.accentColor.withValues(alpha: 0.2),
            widget.themeConfig.accentColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.accentColor.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.star_rounded, color: widget.themeConfig.accentColor, size: 40),
          const SizedBox(height: 12),
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Uygulamayı Değerlendirin',
              'en': 'Rate the App',
              'ar': 'قيّم التطبيق',
              'id': 'Beri Rating Aplikasi',
              'ur': 'ایپ کا جائزہ لیں',
              'bn': 'অ্যাপ রেটিং দিন',
              'ms': 'Nilai Aplikasi',
              'fa': 'به برنامه امتیاز دهید',
              'fr': 'Évaluer l\'application',
              'zh': '为应用评分',
              'ja': 'アプリを評価',
              'ru': 'Оценить приложение',
              'de': 'App bewerten',
              'sw': 'Kadiria programu',
              'ha': 'Kimanta app',
            }),
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Deneyiminizi puanlamak bize çok yardımcı olur.',
              'en': 'Your rating helps us a lot.',
              'ar': 'تقييمك يساعدنا كثيراً.',
              'id': 'Rating Anda sangat membantu kami.',
              'ur': 'آپ کی درجہ بندی ہماری بہت مدد کرتی ہے۔',
              'bn': 'আপনার রেটিং আমাদের অনেক সাহায্য করে।',
              'ms': 'Penilaian anda sangat membantu kami.',
              'fa': 'امتیاز شما به ما کمک زیادی می‌کند.',
              'fr': 'Votre note nous aide beaucoup.',
              'zh': '您的评分对我们很有帮助。',
              'ja': '評価は私たちの励みになります。',
              'ru': 'Ваша оценка нам очень помогает.',
              'de': 'Ihre Bewertung hilft uns sehr.',
              'sw': 'Ukadirio wako unatusaidia sana.',
              'ha': 'Kimantawar ku tana taimaka mana sosai.',
            }),
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _launchStoreRate,
              icon: Icon(Icons.star, color: widget.themeConfig.primaryColor, size: 22),
              label: Text(
                DynamicLocalizationHelper.getText({
                  'tr': 'Store\'da Değerlendir',
                  'en': 'Rate on Store',
                  'ar': 'قيّم في المتجر',
                  'id': 'Beri Rating di Store',
                  'ur': 'اسٹور پر جائزہ لیں',
                  'bn': 'স্টোরে রেটিং দিন',
                  'ms': 'Nilai di Store',
                  'fa': 'در فروشگاه امتیاز دهید',
                  'fr': 'Noter sur le store',
                  'zh': '在商店评分',
                  'ja': 'ストアで評価',
                  'ru': 'Оценить в магазине',
                  'de': 'Im Store bewerten',
                  'sw': 'Kadiria dukani',
                  'ha': 'Kimanta a kantin sayarwa',
                }),
                style: GoogleFonts.notoSans(
                  color: widget.themeConfig.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeConfig.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const String _storeUrl = 'https://play.google.com/store/apps/details?id=com.mcanererdem.zikirmatik';

  Future<void> _launchStoreRate() async {
    final Uri uri = Uri.parse(_storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildFAQ() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.textColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Sıkça Sorulan Sorular',
              'en': 'Frequently Asked Questions',
              'ar': 'الأسئلة الشائعة',
              'id': 'Pertanyaan yang Sering Diajukan',
              'ur': 'اکثر پوچھے جانے والے سوالات',
              'bn': 'প্রায়শই জিজ্ঞাসিত প্রশ্ন',
              'ms': 'Soalan Lazim',
              'fa': 'سوالات متداول',
              'fr': 'Questions fréquentes',
              'zh': '常见问题',
              'ja': 'よくある質問',
              'ru': 'Часто задаваемые вопросы',
              'de': 'Häufig gestellte Fragen',
              'sw': 'Maswali Yanayoulizwa Mara kwa Mara',
              'ha': 'Tambayoyin da ake yawan tambaya',
            }),
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          _buildFAQItem(
            DynamicLocalizationHelper.getText({
              'tr': 'Zikirlerim kaybolursa ne yapmalıyım?',
              'en': 'What should I do if my dhikrs are lost?',
              'ar': 'ماذا أفعل إذا فقدت أذكاري؟',
              'id': 'Apa yang harus saya lakukan jika dhikr saya hilang?',
              'ur': 'اگر میرے ذکر کھو جائیں تو میں کیا کروں؟',
              'bn': 'আমার জিকর হারিয়ে গেলে কী করব?',
              'ms': 'Apa yang perlu saya lakukan jika dhikr saya hilang?',
              'fa': 'اگر ذکرهایم از دست بروند چه کنم؟',
              'fr': 'Que faire si mes dhikr sont perdus ?',
              'zh': '如果我的赞念数据丢失怎么办？',
              'ja': 'ズィクルが消えたらどうすればいいですか？',
              'ru': 'Что делать, если мои зикры потеряны?',
              'de': 'Was tun, wenn meine Dhikr verloren gehen?',
              'sw': 'Nifanye nini ikiwa dhikr zangu zimepotea?',
              'ha': 'Me zan yi idan dhikr dina suka ɓace?',
            }),
            DynamicLocalizationHelper.getText({
              'tr': 'Verileriniz cihazınızda saklanır. Uygulamayı silmeden önce İçe/Dışa Aktar özelliğini kullanarak yedek almanızı öneririz.',
              'en': 'Your data is stored on your device. We recommend backing up using Import/Export before uninstalling.',
              'ar': 'يتم تخزين بياناتك على جهازك. نوصي بالنسخ الاحتياطي باستخدام الاستيراد/التصدير قبل الحذف.',
              'id': 'Data Anda disimpan di perangkat Anda. Kami sarankan mencadangkan dengan Impor/Ekspor sebelum mencopot.',
              'ur': 'آپ کا ڈیٹا آپ کے ڈیوائس پر محفوظ ہے۔ حذف کرنے سے پہلے درآمد/برآمد استعمال کرنے کی سفارش ہے۔',
              'bn': 'আপনার ডেটা আপনার ডিভাইসে সংরক্ষিত। আনইনস্টল করার আগে আমদানি/রপ্তানি ব্যবহার করে ব্যাকআপ নেওয়ার পরামর্শ দিই।',
              'ms': 'Data anda disimpan pada peranti anda. Kami cadangkan sandaran menggunakan Import/Eksport sebelum nyahpasang.',
              'fa': 'داده‌های شما روی دستگاه ذخیره می‌شوند. قبل از حذف، پشتیبان‌گیری با وارد/صادر را توصیه می‌کنیم.',
              'fr': 'Vos données sont stockées sur votre appareil. Nous recommandons une sauvegarde via Importer/Exporter avant désinstallation.',
              'zh': '您的数据保存在设备上。建议在卸载前使用导入/导出进行备份。',
              'ja': 'データは端末に保存されます。アンインストール前にインポート/エクスポートでバックアップすることをお勧めします。',
              'ru': 'Данные хранятся на устройстве. Рекомендуем сделать резервную копию через Импорт/Экспорт перед удалением.',
              'de': 'Ihre Daten werden auf dem Gerät gespeichert. Wir empfehlen vor dem Deinstallieren ein Backup über Import/Export.',
              'sw': 'Data yako inahifadhiwa kwenye kifaa chako. Tunapendekeza uhifadhi kwa kutumia Ingiza/Hamisha kabla ya kufuta.',
              'ha': 'Bayananka yana adana a na\'urarka. Muna ba da shawarar yin backup ta Import/Export kafin in sauke.',
            }),
          ),

          const SizedBox(height: 16),

          _buildFAQItem(
            DynamicLocalizationHelper.getText({
              'tr': 'Liderlik tablosu neden görünmüyor?',
              'en': 'Why is leaderboard not visible?',
              'ar': 'لماذا لا تظهر لوحة المتصدرين؟',
              'id': 'Mengapa papan peringkat tidak terlihat?',
              'ur': 'لیڈر بورڈ کیوں نظر نہیں آتا؟',
              'bn': 'লিডারবোর্ড কেন দেখা যাচ্ছে না?',
              'ms': 'Mengapa papan pendahulu tidak kelihatan?',
              'fa': 'چرا جدول امتیازات نمایش داده نمی‌شود؟',
              'fr': 'Pourquoi le classement n’est-il pas visible ?',
              'zh': '为什么看不到排行榜？',
              'ja': 'なぜランキングが表示されないのですか？',
              'ru': 'Почему не отображается таблица лидеров?',
              'de': 'Warum ist die Rangliste nicht sichtbar?',
              'sw': 'Kwa nini ubao wa wanaoongoza hauonekani?',
              'ha': 'Me ya sa ba a ganin jadawalin jagoranci?',
            }),
            DynamicLocalizationHelper.getText({
              'tr': 'Liderlik tablosu için internet bağlantısı ve paylaşım ayarının açık olması gerekir.',
              'en': 'Leaderboard requires internet connection and sharing setting to be enabled.',
              'ar': 'تتطلب لوحة المتصدرين اتصالاً بالإنترنت وتفعيل إعداد المشاركة.',
              'id': 'Papan peringkat memerlukan koneksi internet dan pengaturan berbagi aktif.',
              'ur': 'لیڈر بورڈ کے لیے انٹرنیٹ کنکشن اور شیئرنگ سیٹنگ آن ہونی چاہیے۔',
              'bn': 'লিডারবোর্ডের জন্য ইন্টারনেট সংযোগ এবং শেয়ারিং সেটিং চালু থাকতে হবে।',
              'ms': 'Papan pendahulu memerlukan sambungan internet dan tetapan perkongsian diaktifkan.',
              'fa': 'نمایش جدول امتیازات نیاز به اینترنت و فعال بودن اشتراک‌گذاری دارد.',
              'fr': 'Le classement nécessite une connexion Internet et le partage activé.',
              'zh': '排行榜需要联网并开启分享设置。',
              'ja': 'ランキングにはインターネット接続と共有設定の有効化が必要です。',
              'ru': 'Для таблицы лидеров требуется интернет и включенный общий доступ.',
              'de': 'Die Rangliste erfordert Internetverbindung und aktivierte Freigabeeinstellung.',
              'sw': 'Ubao wa wanaoongoza unahitaji intaneti na mpangilio wa kushiriki uwashwe.',
              'ha': 'Jadawalin jagoranci na bukatar intanet da kunna saitin rabawa.',
            }),
          ),

          const SizedBox(height: 16),

          _buildFAQItem(
            DynamicLocalizationHelper.getText({
              'tr': 'Çoklu dil desteği olacak mı?',
              'en': 'Will there be more language support?',
              'ar': 'هل سيكون هناك دعم للمزيد من اللغات؟',
              'id': 'Akankah ada dukungan bahasa lebih banyak?',
              'ur': 'کیا مزید زبانوں کی حمایت ہوگی؟',
              'bn': 'আরও ভাষা সমর্থন আসবে কি?',
              'ms': 'Adakah akan ada sokongan bahasa lagi?',
              'fa': 'آیا پشتیبانی زبان‌های بیشتر خواهد بود؟',
              'fr': 'Y aura-t-il plus de langues prises en charge ?',
              'zh': '会支持更多语言吗？',
              'ja': 'さらに多くの言語に対応予定ですか？',
              'ru': 'Будет ли поддержка других языков?',
              'de': 'Wird es weitere Sprachen geben?',
              'sw': 'Je, kutakuwa na msaada wa lugha zaidi?',
              'ha': 'Za a sami goyon bayan harsuna da yawa?',
            }),
            DynamicLocalizationHelper.getText({
              'tr': 'Evet, gelecek güncellemelerde daha fazla dil desteği planlanmaktadır.',
              'en': 'Yes, more languages are planned in future updates.',
              'ar': 'نعم، المزيد من اللغات مخطط لها في التحديثات القادمة.',
              'id': 'Ya, lebih banyak bahasa direncanakan dalam pembaruan mendatang.',
              'ur': 'جی ہاں، آنے والے اپڈیٹس میں مزید زبانیں planned ہیں۔',
              'bn': 'হ্যাঁ, ভবিষ্যত আপডেটে আরও ভাষার পরিকল্পনা রয়েছে।',
              'ms': 'Ya, lebih banyak bahasa dirancang dalam kemas kini akan datang.',
              'fa': 'بله، زبان‌های بیشتر در به‌روزرسانی‌های بعدی برنامه‌ریزی شده‌اند.',
              'fr': 'Oui, d\'autres langues sont prévues dans les prochaines mises à jour.',
              'zh': '是的，后续更新中计划支持更多语言。',
              'ja': 'はい、今後のアップデートでさらに多くの言語をサポートする予定です。',
              'ru': 'Да, в будущих обновлениях планируется поддержка других языков.',
              'de': 'Ja, weitere Sprachen sind in künftigen Updates geplant.',
              'sw': 'Ndiyo, lugha zaidi zimepangwa katika Sasisho la usoni.',
              'ha': 'Ee, ana shirin tallafawa harsuna da yawa a cikin sabuntawa na gaba.',
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.themeConfig.textColor.withValues(alpha: 0.05),
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
              color: widget.themeConfig.textColor.withValues(alpha: 0.8),
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
            widget.themeConfig.accentColor.withValues(alpha: 0.2),
            widget.themeConfig.accentColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.accentColor.withValues(alpha: 0.3),
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
            DynamicLocalizationHelper.getText({
              'tr': 'Geri Bildirim',
              'en': 'Feedback',
              'ar': 'تعليقات',
              'id': 'Umpan Balik',
              'ur': 'رائے',
              'bn': 'মতামত',
              'ms': 'Maklum Balas',
              'fa': 'بازخورد',
              'fr': 'Commentaires',
              'zh': '反馈',
              'ja': 'フィードバック',
              'ru': 'Обратная связь',
              'de': 'Feedback',
              'sw': 'Maoni',
              'ha': 'Ra\'ayi',
            }),
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Uygulamayı geliştirmemiz için geri bildirimlerinizi önemsiyoruz. Öneri ve şikayetlerinizi bizimle paylaşın.',
              'en': 'We value your feedback to improve the app. Share your suggestions and concerns with us.',
              'ar': 'نقدّر ملاحظاتك لتحسين التطبيق. شاركنا اقتراحاتك وملاحظاتك.',
              'id': 'Kami menghargai masukan Anda untuk meningkatkan aplikasi. Bagikan saran dan keluhan Anda.',
              'ur': 'ایپ بہتر بنانے کے لیے ہم آپ کی رائے کی قدر کرتے ہیں۔ اپنے مشورے اور شکایات ہمارے ساتھ شیئر کریں۔',
              'bn': 'অ্যাপ উন্নত করতে আমরা আপনার মতামত মূল্যবান করি। আপনার পরামর্শ এবং অভিযোগ শেয়ার করুন।',
              'ms': 'Kami menghargai maklum balas anda untuk menambah baik aplikasi. Kongsikan cadangan dan aduan anda.',
              'fa': 'برای بهبود برنامه به بازخورد شما اهمیت می‌دهیم. پیشنهادات و شکایات خود را با ما در میان بگذارید.',
              'fr': 'Vos retours comptent pour améliorer l\'app. Partagez vos idées et remarques.',
              'zh': '我们重视您的反馈以改进应用。请与我们分享您的建议和意见。',
              'ja': 'アプリ改善のためフィードバックをお待ちしています。ご意見・ご要望をお送りください。',
              'ru': 'Нам важна ваша обратная связь для улучшения приложения. Поделитесь предложениями и замечаниями.',
              'de': 'Ihr Feedback hilft uns, die App zu verbessern. Teilen Sie uns Ihre Anregungen und Beschwerden mit.',
              'sw': 'Tunathamini maoni yako ili kuboresha programu. Shiriki maoni na malalamiko yako.',
              'ha': 'Muna daraja ra\'ayoyinku don inganta app. Raba shawarwarin ku da korafe-korafen ku da mu.',
            }),
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor.withValues(alpha: 0.8),
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
                DynamicLocalizationHelper.getText({
                  'tr': 'Geri Bildirim Gönder',
                  'en': 'Send Feedback',
                  'ar': 'إرسال تعليقات',
                  'id': 'Kirim Umpan Balik',
                  'ur': 'رائے بھیجیں',
                  'bn': 'মতামত পাঠান',
                  'ms': 'Hantar Maklum Balas',
                  'fa': 'ارسال بازخورد',
                  'fr': 'Envoyer un commentaire',
                  'zh': '发送反馈',
                  'ja': 'フィードバックを送信',
                  'ru': 'Отправить отзыв',
                  'de': 'Feedback senden',
                  'sw': 'Tuma maoni',
                  'ha': 'Aiko ra\'ayi',
                }),
                style: GoogleFonts.notoSans(
                  color: widget.themeConfig.textColor,
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
      query: 'subject=${Uri.encodeComponent(DynamicLocalizationHelper.getText({
        'tr': 'Zikirmatik Destek',
        'en': 'Zikirmatik Support',
        'ur': 'Zikirmatik سپورٹ',
        'ms': 'Sokongan Zikirmatik',
      }))}',
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
      path: _supportEmail,
      query: 'subject=${Uri.encodeComponent(DynamicLocalizationHelper.getText({
        'tr': 'Zikirmatik Geri Bildirim',
        'en': 'Zikirmatik Feedback',
        'ur': 'Zikirmatik فیڈبیک',
        'ms': 'Maklum Balas Zikirmatik',
      }))}',
    );
    
    if (await canLaunchUrl(feedbackUri)) {
      await launchUrl(feedbackUri);
    }
  }
}
