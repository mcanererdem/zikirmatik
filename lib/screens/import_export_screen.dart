import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
      _statusMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Tüm verileri topla
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
            'theme': prefs.getString('theme') ?? 'ocean_blue',
            'language': prefs.getString('language') ?? 'tr',
            'vibration': prefs.getBool('vibration') ?? true,
            'sound': prefs.getBool('sound') ?? true,
            'confetti': prefs.getBool('confetti') ?? true,
            'reminder': prefs.getBool('reminder_enabled') ?? false,
            'tts': prefs.getBool('tts_enabled') ?? false,
          },
        },
      };

      // Downloads klasörüne kaydet (Android için)
      Directory? targetDir;
      if (Platform.isAndroid) {
        // Android için Downloads klasörünü dene
        targetDir = Directory('/storage/emulated/0/Download');
        
        // Eğer Downloads klasörüne erişilemezse, uygulama dokümanlarını kullan
        if (!await targetDir.exists()) {
          try {
            await targetDir.create(recursive: true);
          } catch (e) {
            print('❌ Cannot create Downloads folder, using app documents');
            targetDir = await getApplicationDocumentsDirectory();
          }
        }
        
        // Yazma izni kontrolü
        try {
          final testFile = File('${targetDir.path}/test_write.tmp');
          await testFile.writeAsString('test');
          await testFile.delete();
        } catch (e) {
          print('❌ Cannot write to Downloads, using app documents');
          targetDir = await getApplicationDocumentsDirectory();
        }
      } else {
        targetDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }
      
      if (targetDir == null) {
        setState(() {
          _statusMessage = '❌ Dosya klasörüne erişilemedi';
        });
        return;
      }

      // Dosyayı oluştur
      final fileName = 'zikirmatik_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${targetDir.path}/$fileName');
      
      print('📁 Saving to: ${file.path}');
      
      // JSON verisini dosyaya yaz
      try {
        await file.writeAsString(jsonEncode(exportData));
        print('✅ File saved successfully');
      } catch (e) {
        print('❌ Error writing file: $e');
        setState(() {
          _statusMessage = '❌ Dosya yazma hatası: $e';
        });
        return;
      }
      
      final folderName = targetDir.path.contains('Download') ? 'Downloads' : 'Uygulama Dokümanları';
      setState(() {
        _statusMessage = '✅ Veriler başarıyla dışa aktarıldı!\nDosya: ${file.path}\n\nNot: Dosyayı $folderName klasöründe bulabilirsiniz.';
      });
      
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Dışa aktarım hatası: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
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
        await prefs.setString('theme', settings['theme'] ?? 'dark_blue');
        await prefs.setString('language', settings['language'] ?? 'tr');
        await prefs.setBool('vibration_on', settings['vibration'] ?? true);
        await prefs.setBool('sound_on', settings['sound'] ?? true);
        await prefs.setBool('confetti_on', settings['confetti'] ?? true);
        await prefs.setBool('reminder_enabled', settings['reminder'] ?? false);
        await prefs.setBool('tts_enabled', settings['tts'] ?? false);
        
        setState(() {
          _statusMessage = '✅ Veriler başarıyla içe aktarıldı!\nDosya: ${result.files.first.name}';
        });
        
      } else {
        setState(() {
          _statusMessage = '❌ Dosya seçilmedi';
        });
      }
      
    } catch (e) {
      setState(() {
        _statusMessage = '❌ İçe aktarım hatası: $e';
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }
}
