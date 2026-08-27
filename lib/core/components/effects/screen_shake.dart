import 'dart:math';

import 'package:flame/components.dart';

/// Small camera-shake helper for crash impact (§29/§48). Call [trigger] on
/// impact, then feed [update] each frame and apply the returned offset to
/// the camera viewfinder.
class ScreenShake {
  double _timer = 0;
  double _duration = 0;
  double _magnitude = 0;
  final Random _rng = Random();

  void trigger({double duration = 0.28, double magnitude = 12}) {
    _timer = duration;
    _duration = duration;
    _magnitude = magnitude;
  }

  Vector2 update(double dt) {
    if (_timer <= 0) return Vector2.zero();
    _timer -= dt;
    final t = (_timer / _duration).clamp(0.0, 1.0);
    final mag = _magnitude * t;
    return Vector2((_rng.nextDouble() * 2 - 1) * mag, (_rng.nextDouble() * 2 - 1) * mag);
  }
}
