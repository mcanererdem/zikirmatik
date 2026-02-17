import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioManager {
  final List<AudioPlayer> _audioPlayers = [];
  int _currentPlayerIndex = 0;
  final int _maxPlayers = 5;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    for (int i = 0; i < _maxPlayers; i++) {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(1.0);
      _audioPlayers.add(player);
    }
    _isInitialized = true;
  }

  Future<void> playClick() async {
    try {
      final player = _audioPlayers[_currentPlayerIndex];
      await player.stop();
      await player.setSource(AssetSource('sounds/click.mp3'));
      await player.resume();
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _maxPlayers;
    } catch (e) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  Future<void> playSuccess() async {
    try {
      final player = _audioPlayers[0];
      await player.play(AssetSource('sounds/click.mp3'));
      await Future.delayed(const Duration(milliseconds: 200));
      await player.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }
  }

  void dispose() {
    for (var player in _audioPlayers) {
      player.dispose();
    }
    _audioPlayers.clear();
    _isInitialized = false;
  }
}
