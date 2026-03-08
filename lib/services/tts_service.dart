import 'package:flutter_tts/flutter_tts.dart';
import '../models/zikr_model.dart';
import '../services/settings_service.dart';
import '../utils/localizations.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  final SettingsService _settings = SettingsService();
  bool _enabled = false;
  String _language = 'en';
  double _rate = 0.4;
  double _pitch = 1.0;
  String? _voiceName;

  Future<void> initialize(String languageCode) async {
    _language = languageCode;
    await _tts.setLanguage(_mapLanguage(languageCode));
    _rate = await _settings.getTtsRate();
    _pitch = await _settings.getTtsPitch();
    _voiceName = await _settings.getTtsVoice();
    await _tts.setSpeechRate(_rate);
    await _tts.setVolume(1.0);
    await _tts.setPitch(_pitch);
    await _applyVoiceIfAvailable();
    _enabled = await _settings.getTtsEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    await _settings.saveTtsEnabled(enabled);
  }

  Future<void> setLanguage(String languageCode) async {
    _language = languageCode;
    await _tts.setLanguage(_mapLanguage(languageCode));
    await _applyVoiceIfAvailable();
  }

  Future<void> setRate(double rate) async {
    _rate = rate;
    await _settings.saveTtsRate(rate);
    await _tts.setSpeechRate(rate);
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
    await _settings.saveTtsPitch(pitch);
    await _tts.setPitch(pitch);
  }

  Future<List<Map<String, dynamic>>> getVoices() async {
    final voices = await _tts.getVoices;
    final list = <Map<String, dynamic>>[];
    for (final v in voices) {
      if (v is Map) {
        list.add(v.map((k, val) => MapEntry(k.toString(), val)));
      }
    }
    return list;
  }

  Future<void> setVoiceByName(String name) async {
    _voiceName = name;
    await _settings.saveTtsVoice(name);
    await _applyVoiceIfAvailable();
  }

  Future<void> speakZikr(ZikrModel? zikr) async {
    if (!_enabled || zikr == null) return;
    await _tts.stop();
    final text = _getZikrNameByLanguage(zikr, _language);
    if (text.isNotEmpty) {
      await _tts.speak(text);
    }
  }

  Future<void> _applyVoiceIfAvailable() async {
    if (_voiceName == null || _voiceName!.isEmpty) return;
    final voices = await getVoices();
    final locale = _mapLanguage(_language);
    Map<String, dynamic>? selected;
    for (final v in voices) {
      final vName = v['name']?.toString() ?? '';
      final vLocale = v['locale']?.toString() ?? '';
      if (vName == _voiceName && (vLocale == locale || vLocale.startsWith(locale.split('-').first))) {
        selected = v;
        break;
      }
    }
    if (selected != null) {
      final voiceMap = <String, String>{
        'name': selected['name']?.toString() ?? '',
        'locale': selected['locale']?.toString() ?? locale,
      };
      await _tts.setVoice(voiceMap);
    }
  }

  String _getZikrNameByLanguage(ZikrModel zikr, String code) {
    switch (code) {
      case 'ar':
        return zikr.nameAr;
      case 'en':
        return zikr.nameEn;
      default:
        return zikr.nameTr;
    }
  }

  String _mapLanguage(String code) {
    switch (code) {
      case 'ar':
        return 'ar-SA';
      case 'en':
        return 'en-US';
      case 'tr':
        return 'tr-TR';
      case 'id':
        return 'id-ID';
      case 'ur':
        return 'ur-PK';
      case 'bn':
        return 'bn-BD';
      case 'ms':
        return 'ms-MY';
      case 'fa':
        return 'fa-IR';
      case 'fr':
        return 'fr-FR';
      case 'zh':
        return 'zh-CN';
      case 'ja':
        return 'ja-JP';
      case 'ru':
        return 'ru-RU';
      case 'de':
        return 'de-DE';
      case 'sw':
        return 'sw-TZ';
      case 'ha':
        return 'ha-NG';
      default:
        return 'en-US';
    }
  }

  void dispose() {
    _tts.stop();
  }
}
