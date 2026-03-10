import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show Platform;
import '../models/theme_model.dart';
import '../utils/localizations.dart';

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
        title: Text(
          'İçe/Dışa Aktar',
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
            // Açıklama
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
                    'Veri Yedekleme',
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Zikir sayılarınızı, kupalarınızı ve ayarlarınızı yedekleyebilir veya geri yükleyebilirsiniz. Verileriniz JSON formatında saklanır.',
                    style: GoogleFonts.notoSans(
                      color: Colors.white70,
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
                'Dışa Aktar',
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tüm verilerinizi JSON dosyası olarak dışa aktarın.',
            style: GoogleFonts.notoSans(
              color: Colors.white70,
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Dışa Aktarılıyor...',
                          style: GoogleFonts.notoSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Dışa Aktar',
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
                'İçe Aktar',
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Önceki yedeklemelerinizi geri yükleyin.',
            style: GoogleFonts.notoSans(
              color: Colors.white70,
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
                          'İçe Aktarılıyor...',
                          style: GoogleFonts.notoSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'İçe Aktar',
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
