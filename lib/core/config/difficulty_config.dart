/// Drives world speed and spawn-frequency scaling over time/distance (§25/§26).
class SpeedBreakpoint {
  final double atSeconds;
  final double speed;
  const SpeedBreakpoint(this.atSeconds, this.speed);
}

class DifficultyConfig {
  DifficultyConfig._();

  static const double initialSpeed = 200;
  static const double maxSpeed = 450;

  /// Matches spec §25's example table; interpolated smoothly between points
  /// rather than stepping, so difficulty ramps gradually (§26/§57).
  static const List<SpeedBreakpoint> speedTable = [
    SpeedBreakpoint(0, 200),
    SpeedBreakpoint(30, 240),
    SpeedBreakpoint(60, 280),
    SpeedBreakpoint(90, 320),
    SpeedBreakpoint(120, 360),
    SpeedBreakpoint(200, 450),
  ];

  /// Obstacle spawn interval (seconds) shrinks from [obstacleIntervalStart]
  /// down to [obstacleIntervalMin] as elapsed time approaches [rampSeconds].
  static const double obstacleIntervalStart = 2.6;
  static const double obstacleIntervalMin = 1.35;
  static const double collectibleIntervalStart = 1.8;
  static const double collectibleIntervalMin = 1.1;
  static const double powerUpIntervalStart = 18.0;
  static const double powerUpIntervalMin = 11.0;
  static const double rampSeconds = 180.0;

  /// Fairness rules (§26/§57): a safe path must always exist.
  static const double gapHeightStart = 210; // px, generous early game
  static const double gapHeightMin = 130; // px, absolute floor - never smaller
  static const double maxGapCenterShiftFraction = 0.6; // of playable height, per spawn

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  static double _rampProgress(double elapsedSeconds) =>
      (elapsedSeconds / rampSeconds).clamp(0.0, 1.0);

  static double worldSpeedAt(double elapsedSeconds) {
    if (elapsedSeconds <= speedTable.first.atSeconds) return speedTable.first.speed;
    for (int i = 0; i < speedTable.length - 1; i++) {
      final a = speedTable[i];
      final b = speedTable[i + 1];
      if (elapsedSeconds <= b.atSeconds) {
        final t = (elapsedSeconds - a.atSeconds) / (b.atSeconds - a.atSeconds);
        return _lerp(a.speed, b.speed, t.clamp(0.0, 1.0));
      }
    }
    return maxSpeed;
  }

  static double obstacleIntervalAt(double elapsedSeconds) =>
      _lerp(obstacleIntervalStart, obstacleIntervalMin, _rampProgress(elapsedSeconds));

  static double collectibleIntervalAt(double elapsedSeconds) =>
      _lerp(collectibleIntervalStart, collectibleIntervalMin, _rampProgress(elapsedSeconds));

  static double powerUpIntervalAt(double elapsedSeconds) =>
      _lerp(powerUpIntervalStart, powerUpIntervalMin, _rampProgress(elapsedSeconds));

  static double gapHeightAt(double elapsedSeconds) =>
      _lerp(gapHeightStart, gapHeightMin, _rampProgress(elapsedSeconds));
}
