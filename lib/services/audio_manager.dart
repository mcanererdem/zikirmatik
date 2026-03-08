import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioManager {
  final List<AudioPlayer> _audioPlayers = [];
  int _currentPlayerIndex = 0;
  final int _maxPlayers = 3; // Azaltıldı
  bool _isInitialized = false;
  bool _isPlaying = false;

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
    if (_isPlaying) return; // Ard arda çalmayı engelle
    
    try {
      _isPlaying = true;
      final player = _audioPlayers[_currentPlayerIndex];
      
      // Önceki sesi anında durdur
      await player.stop();
      
      // Asset'i önceden yükle (gecikmeyi azalt)
      await player.setSource(AssetSource('sounds/click.mp3'));
      
      // Anında çal
      await player.resume();
      
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _maxPlayers;
      
      // Kısa gecikme sonra tekrar çalmaya izin ver
      Future.delayed(const Duration(milliseconds: 50), () {
        _isPlaying = false;
      });
      
    } catch (e) {
      _isPlaying = false;
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  Future<void> playSuccess() async {
    try {
      final player = _audioPlayers[0];
      await player.play(AssetSource('sounds/click.mp3'));
      await Future.delayed(const Duration(milliseconds: 100)); // Gecikme azaltıldı
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
    _isPlaying = false;
  }
}
