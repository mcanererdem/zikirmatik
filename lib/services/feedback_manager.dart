import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class FeedbackManager {
  Future<void> vibrateLight() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 50);
      } else {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> vibrateSuccess() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 100);
        await Future.delayed(const Duration(milliseconds: 150));
        Vibration.vibrate(duration: 100);
      } else {
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.mediumImpact();
    }
  }

  void vibrateMedium() {
    HapticFeedback.mediumImpact();
  }
}
