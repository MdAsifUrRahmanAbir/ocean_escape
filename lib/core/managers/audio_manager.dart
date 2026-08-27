import 'package:flame_audio/flame_audio.dart';

import '../models/environment_type.dart';
import 'settings_manager.dart';

/// Plays the procedurally-synthesized SFX bundled at assets/audio/sfx/
/// (§36/§45 - fully offline, no network, all assets bundled).
///
/// No looping background music tracks are bundled (see build plan) -
/// [playMusicFor]/[stopMusic]/[pauseMusic]/[resumeMusic] are kept as a
/// silent no-op API surface so real tracks can be dropped in later without
/// touching call sites.
class AudioManager {
  AudioManager(this._settings);
  final SettingsManager _settings;

  bool _ready = false;
  final Map<String, AudioPool> _pools = {};

  static const List<String> _simpleSfx = [
    'pearl_collect',
    'powerup_activate',
    'shield_activate',
    'magnet_activate',
    'speed_boost',
    'slow_motion',
    'pearl_multiplier',
    'shark_warning',
    'crash',
    'game_start',
    'game_over',
    'countdown_tick',
    'countdown_go',
  ];

  static const List<String> _pooledSfx = ['bubble_collect', 'button_click'];

  Future<void> preload() async {
    if (_ready) return;
    final all = [..._simpleSfx, ..._pooledSfx].map((n) => 'sfx/$n.wav').toList();
    await FlameAudio.audioCache.loadAll(all);
    for (final name in _pooledSfx) {
      _pools[name] = await FlameAudio.createPool('sfx/$name.wav', maxPlayers: 4);
    }
    _ready = true;
  }

  void _playSimple(String name, {double volume = 1.0}) {
    if (!_settings.soundOn) return;
    FlameAudio.play('sfx/$name.wav', volume: volume);
  }

  void _playPooled(String name) {
    if (!_settings.soundOn) return;
    _pools[name]?.start();
  }

  void bubbleCollect() => _playPooled('bubble_collect');
  void buttonClick() => _playPooled('button_click');
  void pearlCollect() => _playSimple('pearl_collect');
  void powerUpActivate() => _playSimple('powerup_activate');
  void shieldActivate() => _playSimple('shield_activate');
  void magnetActivate() => _playSimple('magnet_activate');
  void speedBoostActivate() => _playSimple('speed_boost');
  void slowMotionActivate() => _playSimple('slow_motion');
  void pearlMultiplierActivate() => _playSimple('pearl_multiplier');
  void sharkWarning() => _playSimple('shark_warning', volume: 0.7);
  void crash() => _playSimple('crash');
  void gameStart() => _playSimple('game_start');
  void gameOver() => _playSimple('game_over');
  void countdownTick() => _playSimple('countdown_tick');
  void countdownGo() => _playSimple('countdown_go');

  void playMusicFor(EnvironmentType environment) {
    // Intentionally silent: no bundled loop tracks yet.
  }

  void stopMusic() {}
  void pauseMusic() {}
  void resumeMusic() {}
}
