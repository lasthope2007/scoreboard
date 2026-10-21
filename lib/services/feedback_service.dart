import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../state/settings_controller.dart';

/// Sound and vibration, gated by the user's settings. Fully offline:
/// the sounds are bundled assets.
class FeedbackService {
  FeedbackService(this._settings);

  final SettingsController _settings;
  final AudioPlayer _warningPlayer = AudioPlayer();
  final AudioPlayer _endPlayer = AudioPlayer();

  Future<void> _play(AudioPlayer player, String asset) async {
    if (!_settings.soundOn) return;
    try {
      await player.stop();
      await player.play(AssetSource(asset));
    } catch (_) {
      // Audio problems must never affect the match.
    }
  }

  Future<void> warning() async {
    if (_settings.vibrationOn) HapticFeedback.mediumImpact();
    await _play(_warningPlayer, 'sounds/warning.wav');
  }

  Future<void> end() async {
    if (_settings.vibrationOn) HapticFeedback.vibrate();
    await _play(_endPlayer, 'sounds/end.wav');
  }

  void tap() {
    if (_settings.vibrationOn) HapticFeedback.selectionClick();
  }

  void dispose() {
    _warningPlayer.dispose();
    _endPlayer.dispose();
  }
}
