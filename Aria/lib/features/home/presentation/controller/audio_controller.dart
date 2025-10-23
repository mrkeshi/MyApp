import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioController with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = true;
  bool get isPlaying => _isPlaying;

  AudioController() {

    if (_isPlaying) {
      _playMusic();
    }
  }

  Future<void> _playMusic() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('audio/background_music.mp3'));
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> toggleMusic() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    } else {
      await _audioPlayer.resume();
      _isPlaying = true;
    }
    notifyListeners();
  }

  void disposePlayer() {
    _audioPlayer.dispose();
  }
}
