import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'settings_service.dart';
import '../models/zikr_model.dart';
import '../models/goal_model.dart';

class ExportService {
  final SettingsService _settings;

  ExportService(this._settings);

  Future<void> exportData() async {
    final data = await _prepareData();
    final json = jsonEncode(data);
    await _saveAndShare(json, 'zikirmatik_backup.json');
  }

  Future<Map<String, dynamic>> _prepareData() async {
    final zikrs = await _settings.getCustomZikrs();
    final currentZikr = await _settings.getSelectedZikr();
    final counter = await _settings.getCurrentCount();
    final totalCounter = await _settings.getTotalCount();
    final today = DateTime.now();
    final dailyCount = await _settings.getDailyCount(today);
    final goals = await _settings.getGoals();
    
    return {
      'export_date': DateTime.now().toIso8601String(),
      'current_zikr': currentZikr,
      'counter': counter,
      'total_counter': totalCounter,
      'daily_count': dailyCount,
      'zikrs': zikrs.map((z) => z.toJson()).toList(),
      'goals': goals.map((g) => g.toJson()).toList(),
    };
  }

  String _convertToCSV(Map<String, dynamic> data) {
    // Removed - CSV not needed
    return '';
  }

  Future<void> _saveAndShare(String content, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content);
    await Share.shareXFiles([XFile(file.path)], text: 'Zikirmatik Export');
  }

  Future<Map<String, dynamic>?> importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return null;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      return _importFromJSON(content);
    } catch (e) {
      print('Import error: $e');
    }
    return null;
  }

  Map<String, dynamic>? _importFromJSON(String content) {
    try {
      final data = jsonDecode(content) as Map<String, dynamic>;
      return {
        'counter': data['counter'] ?? 0,
        'total_counter': data['total_counter'] ?? 0,
        'zikrs': (data['zikrs'] as List?)?.map((z) => ZikrModel.fromJson(z)).toList() ?? [],
        'goals': (data['goals'] as List?)?.map((g) => Goal.fromJson(g)).toList() ?? [],
      };
    } catch (e) {
      print('JSON import error: $e');
      return null;
    }
  }

  Map<String, dynamic>? _importFromCSV(String content) {
    // Removed - CSV not needed
    return null;
  }
}
