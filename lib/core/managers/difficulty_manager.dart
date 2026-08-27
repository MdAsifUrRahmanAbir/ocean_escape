import '../config/difficulty_config.dart';

/// Derives world speed and spawn-frequency scaling from elapsed play time
/// (§25/§26). [speedMultiplier] lets power-ups (speed boost/slow motion)
/// modulate the effective speed and, since it also scales how fast
/// [elapsed] advances, the whole difficulty ramp slows/speeds with it.
class DifficultyManager {
  double elapsed = 0;
  double speedMultiplier = 1.0;

  double get baseWorldSpeed => DifficultyConfig.worldSpeedAt(elapsed);
  double get worldSpeed => baseWorldSpeed * speedMultiplier;

  double get obstacleInterval => DifficultyConfig.obstacleIntervalAt(elapsed);
  double get collectibleInterval => DifficultyConfig.collectibleIntervalAt(elapsed);
  double get powerUpInterval => DifficultyConfig.powerUpIntervalAt(elapsed);
  double get gapHeight => DifficultyConfig.gapHeightAt(elapsed);

  void reset() {
    elapsed = 0;
    speedMultiplier = 1.0;
  }

  void update(double dt) {
    elapsed += dt * speedMultiplier;
  }
}
