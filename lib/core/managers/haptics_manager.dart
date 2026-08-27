import 'package:flutter/services.dart';

import 'settings_manager.dart';

/// Optional haptic feedback (§47), gated by the vibration setting. Uses
/// Flutter's built-in [HapticFeedback] - no extra plugin dependency needed.
class HapticsManager {
  HapticsManager(this._settings);
  final SettingsManager _settings;

  void light() {
    if (_settings.vibrationOn) HapticFeedback.lightImpact();
  }

  void medium() {
    if (_settings.vibrationOn) HapticFeedback.mediumImpact();
  }

  void heavy() {
    if (_settings.vibrationOn) HapticFeedback.heavyImpact();
  }
}
