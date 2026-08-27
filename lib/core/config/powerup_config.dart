import '../models/power_up_type.dart';

/// Durations and effect strengths for each power-up (§15).
class PowerUpConfig {
  PowerUpConfig._();

  static const Map<PowerUpType, double> durationSeconds = {
    PowerUpType.shield: 5.0,
    PowerUpType.magnet: 6.0,
    PowerUpType.speedBoost: 4.0,
    PowerUpType.slowMotion: 5.0,
    PowerUpType.pearlMultiplier: 8.0,
  };

  static const double magnetRadius = 170;
  static const double magnetPullSpeed = 520;
  static const double speedBoostWorldSpeedFactor = 1.35;
  static const double slowMotionWorldSpeedFactor = 0.55;

  /// How rare power-up pickups are relative to collectibles (§15 - "rare
  /// enough to feel valuable"); consumed as a spawn-chance weight.
  static const double spawnChanceWeight = 0.16;
}
