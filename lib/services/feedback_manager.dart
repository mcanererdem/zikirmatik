import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class FeedbackManager {
  bool _isVibrating = false;
  bool? _hasVibratorCache;

  Future<void> vibrateLight() async {
    if (_isVibrating) return; // Ard arda titreşimi engelle
    
    try {
      _isVibrating = true;
      _hasVibratorCache ??= await Vibration.hasVibrator() ?? false;
      if (_hasVibratorCache == true) {
        Vibration.vibrate(duration: 30); // Süre azaltıldı
      } else {
        HapticFeedback.lightImpact();
      }
      
      // Kısa gecikme sonra tekrar titreşime izin ver
      Future.delayed(const Duration(milliseconds: 30), () {
        _isVibrating = false;
      });
      
    } catch (e) {
      _isVibrating = false;
      HapticFeedback.lightImpact();
    }
  }

  Future<void> vibrateSuccess() async {
    try {
      _hasVibratorCache ??= await Vibration.hasVibrator() ?? false;
      if (_hasVibratorCache == true) {
        Vibration.vibrate(duration: 80); // Süre azaltıldı
        await Future.delayed(const Duration(milliseconds: 80)); // Gecikme azaltıldı
        Vibration.vibrate(duration: 80);
      } else {
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 80)); // Gecikme azaltıldı
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 80)); // Gecikme azaltıldı
      HapticFeedback.mediumImpact();
    }
  }

  void vibrateMedium() {
    if (!_isVibrating) {
      HapticFeedback.mediumImpact();
    }
  }
}
