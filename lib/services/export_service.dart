import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'settings_service.dart';

class ExportService {
  final SettingsService _settings;

  ExportService(this._settings);

  Future<void> exportToCSV() async {
    final data = await _prepareData();
    final csv = _convertToCSV(data);
    await _saveAndShare(csv, 'zikirmatik_export.csv');
  }

  Future<void> exportToJSON() async {
    final data = await _prepareData();
    final json = jsonEncode(data);
    await _saveAndShare(json, 'zikirmatik_export.json');
  }

  Future<Map<String, dynamic>> _prepareData() async {
    final zikrs = await _settings.getZikrs();
    final currentZikr = await _settings.getCurrentZikr();
    final counter = await _settings.getCounter();
    final totalCounter = await _settings.getTotalCounter();
    final dailyStats = await _settings.getDailyStats();
    final goals = await _settings.getGoals();
    
    return {
      'export_date': DateTime.now().toIso8601String(),
      'current_zikr': currentZikr,
      'counter': counter,
      'total_counter': totalCounter,
      'zikrs': zikrs.map((z) => z.toJson()).toList(),
      'daily_stats': dailyStats,
      'goals': goals.map((g) => g.toJson()).toList(),
    };
  }

  String _convertToCSV(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('Zikirmatik Export - ${data['export_date']}');
    buffer.writeln('');
    buffer.writeln('Current Zikr,${data['current_zikr']}');
    buffer.writeln('Counter,${data['counter']}');
    buffer.writeln('Total Counter,${data['total_counter']}');
    buffer.writeln('');
    buffer.writeln('Zikr Name,Count');
    for (var zikr in data['zikrs']) {
      buffer.writeln('${zikr['name_tr']},${zikr['count']}');
    }
    return buffer.toString();
  }

  Future<void> _saveAndShare(String content, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content);
    await Share.shareXFiles([XFile(file.path)], text: 'Zikirmatik Export');
  }
}
