import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show Platform;
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';

class ImportExportScreen extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String currentUserId;

  const ImportExportScreen({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.currentUserId,
  });

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  bool _isExporting = false;
  bool _isImporting = false;
  String _statusMessage = '';

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
          DynamicLocalizationHelper.getText({
            'tr': 'İçe/Dışa Aktar',
            'en': 'Import/Export',
            'ar': 'استيراد/تصدير',
            'id': 'Impor/Ekspor',
            'ur': 'درآمد/برآمد',
            'bn': 'আমদানি/রপ্তানি',
            'ms': 'Import/Eksport',
            'fa': 'وارد/صادر',
            'fr': 'Importer/Exporter',
            'zh': '导入/导出',
            'ja': 'インポート/エクスポート',
            'ru': 'Импорт/Экспорт',
            'de': 'Importieren/Exportieren',
            'sw': 'Uagizaji/Utoaji',
            'ha': 'Fito/Fito',
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
      body: Container(
        decoration: BoxDecoration(
          gradient: widget.themeConfig.backgroundGradient,
        ),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DynamicLocalizationHelper.getText({
                      'tr': 'Veri Yedekleme',
                      'en': 'Data Backup',
                      'ar': 'نسخ احتياطي للبيانات',
                      'id': 'Cadangan Data',
                      'ur': 'ڈیٹا بیک اپ',
                      'bn': 'ডেটা ব্যাকআপ',
                      'ms': 'Sandaran Data',
                      'fa': 'پشتیبان‌گیری داده',
                      'fr': 'Sauvegarde des données',
                      'zh': '数据备份',
                      'ja': 'データバックアップ',
                      'ru': 'Резервная копия',
                      'de': 'Datensicherung',
                      'sw': 'Hifadhi ya Data',
                      'ha': 'Ajiye Bayanai',
                    }),
                    style: GoogleFonts.notoSans(
                      color: widget.themeConfig.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    DynamicLocalizationHelper.getText({
                      'tr': 'Zikir sayılarınızı, kupalarınızı ve ayarlarınızı yedekleyebilir veya geri yükleyebilirsiniz. Verileriniz JSON formatında saklanır.',
                      'en': 'You can backup or restore your dhikr counts, trophies and settings. Your data is saved in JSON format.',
                      'ar': 'يمكنك نسخ احتياطي أو استعادة عدد الذكر والجوائز والإعدادات. يتم حفظ بياناتك بتنسيق JSON.',
                      'id': 'Anda dapat mencadangkan atau memulih hitungan dhikr, piala, dan pengaturan. Data disimpan dalam format JSON.',
                      'zh': '您可以备份或恢复赞念数、奖杯和设置。数据以 JSON 格式保存。',
                      'ja': 'ズィクル数、トロフィー、設定をバックアップまたは復元できます。データはJSON形式で保存されます。',
                      'ru': 'Можно создавать резервные копии или восстанавливать зикры, трофеи и настройки. Данные сохраняются в формате JSON.',
                      'de': 'Sie können Dhikr-Zählungen, Trophäen und Einstellungen sichern oder wiederherstellen. Daten werden im JSON-Format gespeichert.',
                      'fr': 'Vous pouvez sauvegarder ou restaurer compteurs, trophées et paramètres. Les données sont enregistrées au format JSON.',
                    }),
                    style: GoogleFonts.notoSans(
                      color: widget.themeConfig.textColor.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Dışa Aktar
            _buildExportSection(),
            
            const SizedBox(height: 30),
            
            // İçe Aktar
            _buildImportSection(),
            
            const SizedBox(height: 30),
            
            // Durum Mesajı
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  _statusMessage,
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExportSection() {
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
          Row(
            children: [
              Icon(
                Icons.upload_file,
                color: widget.themeConfig.accentColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                DynamicLocalizationHelper.getText({
                  'tr': 'Dışa Aktar',
                  'en': 'Export',
                  'ar': 'تصدير',
                  'id': 'Ekspor',
                  'zh': '导出',
                  'ja': 'エクスポート',
                  'ru': 'Экспорт',
                  'de': 'Exportieren',
                  'fr': 'Exporter',
                }),
                style: GoogleFonts.notoSans(
                  color: widget.themeConfig.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Tüm verilerinizi JSON dosyası olarak dışa aktarın.',
              'en': 'Export all your data as a JSON file.',
              'ar': 'تصدير جميع بياناتك كملف JSON.',
              'id': 'Ekspor semua data Anda sebagai file JSON.',
              'zh': '将所有数据导出为 JSON 文件。',
              'ja': 'すべてのデータをJSONファイルとしてエクスポートします。',
              'ru': 'Экспортируйте все данные в файл JSON.',
              'de': 'Exportieren Sie alle Daten als JSON-Datei.',
              'fr': 'Exportez toutes vos données en fichier JSON.',
            }),
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isExporting ? null : _exportData,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeConfig.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isExporting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(widget.themeConfig.textColor),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          DynamicLocalizationHelper.getText({
                            'tr': 'Dışa Aktarılıyor...',
                            'en': 'Exporting...',
                            'ar': 'جاري التصدير...',
                            'id': 'Mengekspor...',
                            'zh': '导出中...',
                            'ja': 'エクスポート中...',
                            'ru': 'Экспорт...',
                            'de': 'Exportieren...',
                            'fr': 'Exportation...',
                          }),
                          style: GoogleFonts.notoSans(
                            color: widget.themeConfig.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      DynamicLocalizationHelper.getText({
                        'tr': 'Dışa Aktar',
                        'en': 'Export',
                        'ar': 'تصدير',
                        'id': 'Ekspor',
                        'zh': '导出',
                        'ja': 'エクスポート',
                        'ru': 'Экспорт',
                        'de': 'Exportieren',
                        'fr': 'Exporter',
                      }),
                      style: GoogleFonts.notoSans(
                        color: widget.themeConfig.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isExporting ? null : _exportToDownloads,
              icon: const Icon(Icons.folder_outlined, size: 20),
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.themeConfig.accentColor,
                side: BorderSide(color: widget.themeConfig.accentColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              label: Text(
                DynamicLocalizationHelper.getText({
                  'tr': 'İndirilenler\'e kaydet',
                  'en': 'Save to Downloads',
                  'ar': 'حفظ في التنزيلات',
                  'id': 'Simpan ke Unduhan',
                  'zh': '保存到下载',
                  'ja': 'ダウンロードに保存',
                  'ru': 'Сохранить в Загрузки',
                  'de': 'In Downloads speichern',
                  'fr': 'Enregistrer dans Téléchargements',
                }),
                style: GoogleFonts.notoSans(
                  color: widget.themeConfig.accentColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportSection() {
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
          Row(
            children: [
              Icon(
                Icons.download,
                color: widget.themeConfig.accentColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                widget.localizations.import,
                style: GoogleFonts.notoSans(
                  color: widget.themeConfig.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Önceki yedeklemelerinizi geri yükleyin.',
              'en': 'Restore your previous backups.',
              'ar': 'استعد النسخ الاحتياطية السابقة.',
              'id': 'Pulihkan cadangan Anda sebelumnya.',
              'ur': 'اپنی پچھلی بیک اپ بحال کریں۔',
              'bn': 'আপনার আগের ব্যাকআপ পুনরুদ্ধার করুন।',
              'ms': 'Pulihkan sandaran anda sebelum ini.',
              'fa': 'پشتیبان‌های قبلی را بازیابی کنید.',
              'fr': 'Restaurer vos sauvegardes précédentes.',
              'zh': '恢复您之前的备份。',
              'ja': '以前のバックアップを復元します。',
              'ru': 'Восстановите предыдущие резервные копии.',
              'de': 'Stellen Sie frühere Sicherungen wieder her.',
              'sw': 'Rejesha nakala zako za awali.',
              'ha': 'Maido backup ɗinku na baya.',
            }),
            style: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isImporting ? null : _importData,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeConfig.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isImporting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          DynamicLocalizationHelper.getText({
                            'tr': 'İçe Aktarılıyor...',
                            'en': 'Importing...',
                            'ar': 'جاري الاستيراد...',
                            'id': 'Mengimpor...',
                            'ur': 'درآمد ہو رہا ہے...',
                            'bn': 'আমদানি করা হচ্ছে...',
                            'ms': 'Mengimport...',
                            'fa': 'در حال وارد کردن...',
                            'fr': 'Importation...',
                            'zh': '导入中...',
                            'ja': 'インポート中...',
                            'ru': 'Импорт...',
                            'de': 'Importieren...',
                            'sw': 'Inapakia...',
                            'ha': 'Ana shigarwa...',
                          }),
                          style: GoogleFonts.notoSans(
                            color: widget.themeConfig.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      widget.localizations.import,
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

  String _msg(String key, [String? param]) {
    final messages = {
      'export_no_folder': {'tr': 'Dosya klasörüne erişilemedi', 'en': 'Could not access folder', 'ar': 'تعذر الوصول إلى المجلد', 'zh': '无法访问文件夹', 'ja': 'フォルダにアクセスできません', 'ru': 'Не удалось получить доступ к папке', 'de': 'Ordner nicht erreichbar'},
      'export_write_error': {'tr': 'Dosya yazma hatası', 'en': 'File write error', 'ar': 'خطأ في كتابة الملف', 'zh': '文件写入错误', 'ja': 'ファイル書き込みエラー', 'ru': 'Ошибка записи файла', 'de': 'Fehler beim Schreiben'},
      'export_success': {'tr': 'Veriler dışa aktarıldı. Paylaş menüsünden dosyayı İndirilenler\'e veya başka bir yere kaydedebilirsiniz.', 'en': 'Export ready. Use the share menu to save the file to Downloads or elsewhere.', 'ar': 'تم التصدير. استخدم قائمة المشاركة لحفظ الملف في التنزيلات أو مكان آخر.', 'zh': '导出完成。请通过分享菜单将文件保存到“下载”或其他位置。', 'ja': 'エクスポート完了。共有メニューからファイルをダウンロードなどに保存できます。', 'ru': 'Экспорт готов. Используйте меню «Поделиться», чтобы сохранить файл в «Загрузки» или другое место.', 'de': 'Export fertig. Nutzen Sie das Teilen-Menü, um die Datei in Downloads oder anderswo zu speichern.'},
      'export_error': {'tr': 'Dışa aktarım hatası', 'en': 'Export error', 'ar': 'خطأ في التصدير', 'zh': '导出错误', 'ja': 'エクスポートエラー', 'ru': 'Ошибка экспорта', 'de': 'Exportfehler'},
      'import_success': {'tr': 'Veriler başarıyla içe aktarıldı', 'en': 'Data imported successfully', 'ar': 'تم استيراد البيانات بنجاح', 'zh': '数据导入成功', 'ja': 'データをインポートしました', 'ru': 'Данные успешно импортированы', 'de': 'Daten erfolgreich importiert'},
      'import_no_file': {'tr': 'Dosya seçilmedi', 'en': 'No file selected', 'ar': 'لم يتم اختيار ملف', 'zh': '未选择文件', 'ja': 'ファイルが選択されていません', 'ru': 'Файл не выбран', 'de': 'Keine Datei ausgewählt'},
      'import_error': {'tr': 'İçe aktarım hatası', 'en': 'Import error', 'ar': 'خطأ في الاستيراد', 'zh': '导入错误', 'ja': 'インポートエラー', 'ru': 'Ошибка импорта', 'de': 'Importfehler'},
    };
    final text = DynamicLocalizationHelper.getText(messages[key] ?? {'tr': key});
    return param != null ? '$text: $param' : text;
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
      _statusMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final exportData = {
        'userId': widget.currentUserId,
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
        'data': {
          'zikirCounts': {
            'total_zikrs': prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0,
            'current_count': prefs.getInt('current_count') ?? 0,
            'last_zikr_date': prefs.getString('last_zikr_date_${widget.currentUserId}'),
          },
          'achievements': {
            'bronze_kupa_unlocked': prefs.getBool('bronze_kupa_unlocked_${widget.currentUserId}') ?? false,
            'silver_kupa_unlocked': prefs.getBool('silver_kupa_unlocked_${widget.currentUserId}') ?? false,
            'gold_kupa_unlocked': prefs.getBool('gold_kupa_unlocked_${widget.currentUserId}') ?? false,
            'diamond_kupa_unlocked': prefs.getBool('diamond_kupa_unlocked_${widget.currentUserId}') ?? false,
            'platinum_kupa_unlocked': prefs.getBool('platinum_kupa_unlocked_${widget.currentUserId}') ?? false,
          },
          'settings': {
            'theme': prefs.getString('theme_id') ?? prefs.getString('theme') ?? 'dark_blue',
            'language': prefs.getString('language_code') ?? prefs.getString('language') ?? 'tr',
            'vibration': prefs.getBool('vibration_enabled') ?? prefs.getBool('vibration') ?? true,
            'sound': prefs.getBool('sound_enabled') ?? prefs.getBool('sound') ?? true,
            'confetti': prefs.getBool('confetti_enabled') ?? prefs.getBool('confetti') ?? true,
            'reminder': prefs.getBool('reminder_enabled') ?? false,
            'tts': prefs.getBool('tts_enabled') ?? false,
          },
        },
      };

      // Geçici dizine yaz, sonra paylaş menüsü ile kullanıcı İndirilenler'e veya istediği yere kaydetsin
      final dir = await getTemporaryDirectory();
      final fileName = 'zikirmatik_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${dir.path}/$fileName');

      await file.writeAsString(jsonEncode(exportData));
      print('✅ Export file created: ${file.path}');

      final shareText = DynamicLocalizationHelper.getText({
        'tr': 'Zikirmatik yedek dosyam. İndirilenler\'e veya istediğiniz yere kaydedebilirsiniz.',
        'en': 'My Zikirmatik backup. You can save it to Downloads or anywhere you like.',
        'zh': 'Zikirmatik 备份文件，可保存到“下载”或任意位置。',
        'ja': 'Zikirmatikのバックアップです。ダウンロードなどに保存できます。',
        'ru': 'Резервная копия Zikirmatik. Сохраните в «Загрузки» или в любое место.',
        'de': 'Meine Zikirmatik-Sicherung. In Downloads oder anderswo speichern.',
      });
      await Share.shareXFiles([XFile(file.path)], text: shareText);

      if (mounted) {
        setState(() {
          _statusMessage = '✅ ${_msg('export_success')}';
        });
      }
    } catch (e) {
      print('❌ Export error: $e');
      if (mounted) {
        setState(() {
          _statusMessage = '❌ ${_msg('export_write_error')}: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _exportToDownloads() async {
    setState(() {
      _isExporting = true;
      _statusMessage = '';
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final exportData = {
        'userId': widget.currentUserId,
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
        'data': {
          'zikirCounts': {
            'total_zikrs': prefs.getInt('total_zikrs_${widget.currentUserId}') ?? 0,
            'current_count': prefs.getInt('current_count') ?? 0,
            'last_zikr_date': prefs.getString('last_zikr_date_${widget.currentUserId}'),
          },
          'achievements': {
            'bronze_kupa_unlocked': prefs.getBool('bronze_kupa_unlocked_${widget.currentUserId}') ?? false,
            'silver_kupa_unlocked': prefs.getBool('silver_kupa_unlocked_${widget.currentUserId}') ?? false,
            'gold_kupa_unlocked': prefs.getBool('gold_kupa_unlocked_${widget.currentUserId}') ?? false,
            'diamond_kupa_unlocked': prefs.getBool('diamond_kupa_unlocked_${widget.currentUserId}') ?? false,
            'platinum_kupa_unlocked': prefs.getBool('platinum_kupa_unlocked_${widget.currentUserId}') ?? false,
          },
          'settings': {
            'theme': prefs.getString('theme_id') ?? prefs.getString('theme') ?? 'dark_blue',
            'language': prefs.getString('language_code') ?? prefs.getString('language') ?? 'tr',
            'vibration': prefs.getBool('vibration_enabled') ?? prefs.getBool('vibration') ?? true,
            'sound': prefs.getBool('sound_enabled') ?? prefs.getBool('sound') ?? true,
            'confetti': prefs.getBool('confetti_enabled') ?? prefs.getBool('confetti') ?? true,
            'reminder': prefs.getBool('reminder_enabled') ?? false,
            'tts': prefs.getBool('tts_enabled') ?? false,
          },
        },
      };
      final fileName = 'zikirmatik_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final bytes = Uint8List.fromList(utf8.encode(jsonEncode(exportData)));
      final path = await FilePicker.platform.saveFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
        fileName: fileName,
      );
      if (mounted) {
        setState(() {
          _statusMessage = path != null && path.isNotEmpty
              ? '✅ ${DynamicLocalizationHelper.getText({'tr': 'Dosya kaydedildi.', 'en': 'File saved.', 'ar': 'تم حفظ الملف.', 'id': 'File disimpan.', 'zh': '文件已保存。', 'ja': 'ファイルを保存しました。', 'ru': 'Файл сохранён.', 'de': 'Datei gespeichert.', 'fr': 'Fichier enregistré.'})}'
              : '';
        });
        if (path != null && path.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                DynamicLocalizationHelper.getText({
                  'tr': 'Yedek İndirilenler\'e (veya seçtiğiniz konuma) kaydedildi.',
                  'en': 'Backup saved to Downloads (or your chosen location).',
                  'ar': 'تم حفظ النسخة الاحتياطية في التنزيلات.',
                  'id': 'Cadangan disimpan ke Unduhan.',
                  'zh': '备份已保存到下载。',
                  'ja': 'バックアップをダウンロードに保存しました。',
                  'ru': 'Резервная копия сохранена в Загрузки.',
                  'de': 'Sicherung in Downloads gespeichert.',
                  'fr': 'Sauvegarde enregistrée dans Téléchargements.',
                }),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Export to Downloads error: $e');
      if (mounted) {
        setState(() {
          _statusMessage = '❌ ${DynamicLocalizationHelper.getText({'tr': 'Kaydetme hatası', 'en': 'Save error', 'ar': 'خطأ في الحفظ', 'id': 'Kesalahan menyimpan', 'zh': '保存错误', 'ja': '保存エラー', 'ru': 'Ошибка сохранения', 'de': 'Speicherfehler', 'fr': 'Erreur d\'enregistrement'})}: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _importData() async {
    setState(() {
      _isImporting = true;
      _statusMessage = '';
    });

    try {
      // Downloads klasöründen dosya seç (Android için)
      Directory? initialDirectory;
      if (Platform.isAndroid) {
        initialDirectory = Directory('/storage/emulated/0/Download');
        
        // Downloads klasörü var mı kontrol et
        if (!await initialDirectory.exists()) {
          initialDirectory = await getApplicationDocumentsDirectory();
        }
      } else {
        initialDirectory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }

      // FilePicker ile dosya seç
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        initialDirectory: initialDirectory?.path,
      );

      if (result != null && result.files.first.path != null) {
        final file = File(result.files.first.path!);
        final content = await file.readAsString();
        
        print('📁 Importing from: ${file.path}');
        
        // JSON verisini parse et
        final importData = jsonDecode(content);
        
        // Verileri SharedPreferences'a kaydet
        final prefs = await SharedPreferences.getInstance();
        final data = importData['data'];
        
        // Zikir sayıları
        final zikirCounts = data['zikirCounts'];
        await prefs.setInt('total_zikrs_${widget.currentUserId}', zikirCounts['total_zikrs'] ?? 0);
        await prefs.setInt('current_count', zikirCounts['current_count'] ?? 0);
        if (zikirCounts['last_zikr_date'] != null) {
          await prefs.setString('last_zikr_date_${widget.currentUserId}', zikirCounts['last_zikr_date']);
        }
        
        // Başarılar
        final achievements = data['achievements'];
        await prefs.setBool('bronze_kupa_unlocked_${widget.currentUserId}', achievements['bronze_kupa_unlocked'] ?? false);
        await prefs.setBool('silver_kupa_unlocked_${widget.currentUserId}', achievements['silver_kupa_unlocked'] ?? false);
        await prefs.setBool('gold_kupa_unlocked_${widget.currentUserId}', achievements['gold_kupa_unlocked'] ?? false);
        await prefs.setBool('diamond_kupa_unlocked_${widget.currentUserId}', achievements['diamond_kupa_unlocked'] ?? false);
        await prefs.setBool('platinum_kupa_unlocked_${widget.currentUserId}', achievements['platinum_kupa_unlocked'] ?? false);
        
        // Ayarlar
        final settings = data['settings'];
        await prefs.setString('theme_id', settings['theme'] ?? 'dark_blue');
        await prefs.setString('language_code', settings['language'] ?? 'tr');
        await prefs.setBool('vibration_enabled', settings['vibration'] ?? true);
        await prefs.setBool('sound_enabled', settings['sound'] ?? true);
        await prefs.setBool('confetti_enabled', settings['confetti'] ?? true);
        await prefs.setBool('reminder_enabled', settings['reminder'] ?? false);
        await prefs.setBool('tts_enabled', settings['tts'] ?? false);
        
        if (mounted) {
          setState(() {
            _statusMessage = '✅ ${_msg('import_success')} • ${result.files.first.name}';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _statusMessage = '❌ ${_msg('import_no_file')}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = '❌ ${_msg('import_error')}: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }
}
