import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.themeConfig.primaryColor,
      appBar: AppBar(
        backgroundColor: widget.themeConfig.primaryColor,
        elevation: 0,
        foregroundColor: widget.themeConfig.textColor,
        title: Text(
          DynamicLocalizationHelper.getText({
            'tr': 'Bize Destek Ol',
            'en': 'Support Us',
            'ar': 'ادعمنا',
            'id': 'Dukung Kami',
            'ur': 'ہمیں سپورٹ کریں',
            'bn': 'আমাদের সমর্থন করুন',
            'ms': 'Sokong Kami',
            'fa': 'از ما حمایت کنید',
            'fr': 'Soutenez-nous',
            'zh': '支持我们',
            'ja': '私たちをサポート',
            'ru': 'Поддержите нас',
            'de': 'Unterstützen Sie uns',
            'sw': 'Tusaidie',
            'ha': 'Tallafa Mu',
          }),
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
                    DynamicLocalizationHelper.getText({
                      'tr': 'Yardıma mı ihtiyacınız var?',
                      'en': 'Need help?',
                      'ar': 'هل تحتاج مساعدة؟',
                      'id': 'Butuh bantuan?',
                      'ur': 'کیا آپ کو مدد چاہیے؟',
                      'bn': 'সাহায্য দরকার?',
                      'ms': 'Perlukan bantuan?',
                      'fa': 'نیاز به کمک دارید؟',
                      'fr': 'Besoin d\'aide ?',
                      'zh': '需要帮助？',
                      'ja': 'お困りですか？',
                      'ru': 'Нужна помощь?',
                      'de': 'Brauchen Sie Hilfe?',
                      'sw': 'Unahitaji msaada?',
                      'ha': 'Kuna buƙatar taimako?',
                    }),
                    style: GoogleFonts.notoSans(
                      color: widget.themeConfig.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DynamicLocalizationHelper.getText({
                      'tr': 'Sorunlarınızı yanıtlamak ve geri bildirimlerinizi değerlendirmek için buradayız.',
                      'en': 'We are here to answer your questions and review your feedback.',
                      'ar': 'نحن هنا للإجابة على أسئلتك وتقييم ملاحظاتك.',
                      'id': 'Kami di sini untuk menjawab pertanyaan dan meninjau masukan Anda.',
                      'ur': 'ہم آپ کے سوالات کے جوابات اور آپ کی رائے کا جائزہ لینے کے لیے یہاں ہیں۔',
                      'bn': 'আপনার প্রশ্নের উত্তর এবং মতামত মূল্যায়নের জন্য আমরা এখানে আছি।',
                      'ms': 'Kami di sini untuk menjawab soalan dan menilai maklum balas anda.',
                      'fa': 'ما اینجا هستیم تا به سوالات شما پاسخ دهیم و بازخورد شما را بررسی کنیم.',
                      'fr': 'Nous sommes là pour répondre à vos questions et évaluer vos retours.',
                      'zh': '我们在此解答您的问题并查看您的反馈。',
                      'ja': 'ご質問への回答とフィードバックの確認のため、こちらにいます。',
                      'ru': 'Мы здесь, чтобы ответить на ваши вопросы и учесть отзывы.',
                      'de': 'Wir sind da, um Ihre Fragen zu beantworten und Ihr Feedback auszuwerten.',
                      'sw': 'Tuko hapa kujibu maswali yako na kukagua maoni yako.',
                      'ha': "Muna nan don amsa tambayoyinku da kimanta ra'ayoyinku.",
                    }),
                    style: GoogleFonts.notoSans(
                      color: widget.themeConfig.textColor.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

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
        color: widget.themeConfig.textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.textColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'İletişim Yöntemleri',
              'en': 'Contact Methods',
              'ar': 'طرق التواصل',
              'id': 'Metode Kontak',
              'ur': 'رابطے کے طریقے',
              'bn': 'যোগাযোগের পদ্ধতি',
              'ms': 'Kaedah Hubungan',
              'fa': 'روش‌های تماس',
              'fr': 'Moyens de contact',
              'zh': '联系方式',
              'ja': 'お問い合わせ方法',
              'ru': 'Способы связи',
              'de': 'Kontaktmöglichkeiten',
              'sw': 'Njia za Mawasiliano',
              'ha': 'Hanyoyin Tuntuɓa',
            }),
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          _buildContactItem(
            DynamicLocalizationHelper.getText({
              'tr': 'E-posta',
              'en': 'Email',
              'ar': 'البريد الإلكتروني',
              'id': 'Email',
              'ur': 'ای میل',
              'bn': 'ইমেইল',
              'ms': 'E-mel',
              'fa': 'ایمیل',
              'fr': 'E-mail',
              'zh': '电子邮件',
              'ja': 'メール',
              'ru': 'Эл. почта',
              'de': 'E-Mail',
              'sw': 'Barua pepe',
              'ha': 'Imel',
            }),
            'support@mcanererdem.com',
            Icons.email,
            () => _launchEmail('support@mcanererdem.com'),
          ),
          
          const SizedBox(height: 16),
          
          _buildContactItem(
            DynamicLocalizationHelper.getText({
              'tr': 'Web Sitesi',
              'en': 'Website',
              'ar': 'الموقع',
              'id': 'Situs Web',
              'ur': 'ویب سائٹ',
              'bn': 'ওয়েবসাইট',
              'ms': 'Laman Web',
              'fa': 'وب‌سایت',
              'fr': 'Site web',
              'zh': '网站',
              'ja': 'ウェブサイト',
              'ru': 'Веб-сайт',
              'de': 'Webseite',
              'sw': 'Tovuti',
              'ha': 'Gidan yanar gizo',
            }),
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
          color: widget.themeConfig.textColor.withOpacity(0.05),
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
                      color: widget.themeConfig.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSans(
                      color: widget.themeConfig.textColor.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: widget.themeConfig.textColor.withOpacity(0.6),
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
        color: widget.themeConfig.textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeConfig.textColor.withOpacity(0.2),
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
              'ha': "Bayananka yana adana a na'urarka. Muna ba da shawarar yin backup ta Import/Export kafin in sauke.",
            }),
          ),

          const SizedBox(height: 16),

          _buildFAQItem(
            DynamicLocalizationHelper.getText({
              'tr': 'Reklamları nasıl kaldırabilirim?',
              'en': 'How can I remove ads?',
              'ar': 'كيف يمكنني إزالة الإعلانات؟',
              'id': 'Bagaimana cara menghapus iklan?',
              'ur': 'میں اشتہارات کیسے ہٹا سکتا ہوں؟',
              'bn': 'আমি বিজ্ঞাপন কীভাবে সরাতে পারি?',
              'ms': 'Bagaimana saya boleh membuang iklan?',
              'fa': 'چگونه می‌توانم تبلیغات را حذف کنم؟',
              'fr': 'Comment supprimer les publicités ?',
              'zh': '如何移除广告？',
              'ja': '広告を削除するには？',
              'ru': 'Как убрать рекламу?',
              'de': 'Wie kann ich Anzeigen entfernen?',
              'sw': 'Nawezaje kuondoa matangazo?',
              'ha': 'Ta yaya zan iya cire talla?',
            }),
            DynamicLocalizationHelper.getText({
              'tr': 'Reklamlar uygulamanın geliştirilmesi için gereklidir. Ayarlar menüsünden reklam izleme seçeneğini inceleyebilirsiniz.',
              'en': 'Ads help support app development. You can check the watch ad option in the settings menu.',
              'ar': 'الإعلانات تدعم تطوير التطبيق. يمكنك الاطلاع على خيار مشاهدة الإعلان في قائمة الإعدادات.',
              'id': 'Iklan mendukung pengembangan aplikasi. Anda dapat memeriksa opsi tonton iklan di menu pengaturan.',
              'ur': 'اشتہارات ایپ کی ترقی کے لیے ہیں۔ آپ ترتیبات مینو میں اشتہار دیکھنے کا آپشن دیکھ سکتے ہیں۔',
              'bn': 'বিজ্ঞাপন অ্যাপ বিকাশে সহায়তা করে। সেটিংস মেনুতে বিজ্ঞাপন দেখার বিকল্প দেখুন।',
              'ms': 'Iklan menyokong pembangunan aplikasi. Anda boleh semak pilihan tonton iklan dalam menu tetapan.',
              'fa': 'تبلیغات از توسعه برنامه پشتیبانی می‌کنند. می‌توانید گزینه تماشای تبلیغ را در منوی تنظیمات ببینید.',
              'fr': 'Les publicités aident au développement. Consultez l\'option regarder une pub dans les paramètres.',
              'zh': '广告用于支持应用开发。您可以在设置菜单中查看观看广告选项。',
              'ja': '広告はアプリの開発を支えています。設定メニューで広告視聴オプションをご確認ください。',
              'ru': 'Реклама поддерживает разработку. В настройках можно посмотреть опцию просмотра рекламы.',
              'de': 'Anzeigen unterstützen die App-Entwicklung. In den Einstellungen finden Sie die Option „Anzeige ansehen“.',
              'sw': 'Matangazo yanasaidia ukuzaji wa programu. Unaweza kuangalia chaguo la kutazama tangazo kwenye menyu ya mipangilio.',
              'ha': 'Talla suna tallafawa ci gaba da app. Zaka iya duba zaɓin kallon talla a cikin menu saituna.',
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
        color: widget.themeConfig.textColor.withOpacity(0.05),
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
              color: widget.themeConfig.textColor.withOpacity(0.8),
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
              color: widget.themeConfig.textColor.withOpacity(0.8),
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
