import 'package:flutter/foundation.dart';

import 'storage_service.dart';

/// User-configurable settings (§46), persisted via [StorageService].
/// A [ChangeNotifier] so both game code and settings UI can react to changes.
class SettingsManager extends ChangeNotifier {
  SettingsManager(this._storage)
      : musicOn = _storage.musicOn,
        soundOn = _storage.soundOn,
        vibrationOn = _storage.vibrationOn,
        quality = _storage.quality;

  final StorageService _storage;

  bool musicOn;
  bool soundOn;
  bool vibrationOn;
  String quality; // 'low' | 'medium' | 'high'

  Future<void> setMusicOn(bool value) async {
    musicOn = value;
    await _storage.setMusicOn(value);
    notifyListeners();
  }

  Future<void> setSoundOn(bool value) async {
    soundOn = value;
    await _storage.setSoundOn(value);
    notifyListeners();
  }

  Future<void> setVibrationOn(bool value) async {
    vibrationOn = value;
    await _storage.setVibrationOn(value);
    notifyListeners();
  }

  Future<void> setQuality(String value) async {
    quality = value;
    await _storage.setQuality(value);
    notifyListeners();
  }

  Future<void> resetProgress() async {
    await _storage.resetProgress();
    notifyListeners();
  }

  /// Max simultaneous decorative particles, scaled by quality (§44 - avoid
  /// unbounded particle creation on mid-range Android devices).
  int get particleBudget {
    switch (quality) {
      case 'low':
        return 20;
      case 'high':
        return 70;
      case 'medium':
      default:
        return 40;
    }
  }

  /// How many parallax layers to render (§22).
  int get backgroundLayerCount {
    switch (quality) {
      case 'low':
        return 3;
      case 'high':
        return 6;
      case 'medium':
      default:
        return 5;
    }
  }
}
