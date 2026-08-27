import '../config/environment_config.dart';
import '../models/environment_type.dart';
import '../models/obstacle_pattern.dart';

/// Tracks which ocean zone the world is currently in and smoothly blends
/// into the next one as distance crosses each threshold (§16/§21). Purely
/// derives state from distance each frame - no timers of its own.
class EnvironmentManager {
  EnvironmentType current = EnvironmentType.coralReef;
  EnvironmentType next = EnvironmentType.coralReef;
  double blend = 0;

  void reset() {
    current = EnvironmentType.coralReef;
    next = EnvironmentType.coralReef;
    blend = 0;
  }

  void update(double distanceMeters) {
    final env = EnvironmentConfig.environmentForDistance(distanceMeters);
    final values = EnvironmentType.values;
    final idx = env.index0;
    final hasNext = idx < values.length - 1;
    var b = 0.0;
    var nextEnv = env;
    if (hasNext) {
      nextEnv = values[idx + 1];
      final nextStart = EnvironmentConfig.startDistanceMeters[nextEnv]!;
      final band = EnvironmentConfig.transitionBandMeters;
      final distanceToNext = nextStart - distanceMeters;
      if (distanceToNext <= band) {
        b = (1 - distanceToNext / band).clamp(0.0, 1.0);
      }
    }
    current = env;
    next = b > 0 ? nextEnv : env;
    blend = b;
  }

  EnvironmentPalette get currentPalette => EnvironmentConfig.palettes[current]!;
  EnvironmentPalette get nextPalette => EnvironmentConfig.palettes[next]!;

  /// World/obstacle speed scaling for the current blended zone (§20).
  double get obstacleSpeedMultiplier {
    final a = currentPalette.obstacleSpeedMultiplier;
    final b = nextPalette.obstacleSpeedMultiplier;
    return a + (b - a) * blend;
  }

  /// Obstacle-kind spawn weights blended across the transition (§26).
  Map<ObstacleKind, double> get blendedObstacleWeights {
    final a = currentPalette;
    final b = nextPalette;
    final result = <ObstacleKind, double>{};
    for (final kind in ObstacleKind.values) {
      final av = a.obstacleWeights[kind] ?? 0;
      final bv = b.obstacleWeights[kind] ?? 0;
      result[kind] = av + (bv - av) * blend;
    }
    final mineBonus = a.mineWeightBonus + (b.mineWeightBonus - a.mineWeightBonus) * blend;
    final sharkBonus = a.sharkWeightBonus + (b.sharkWeightBonus - a.sharkWeightBonus) * blend;
    result[ObstacleKind.seaMine] = (result[ObstacleKind.seaMine] ?? 0) + mineBonus;
    result[ObstacleKind.shark] = (result[ObstacleKind.shark] ?? 0) + sharkBonus;
    return result;
  }
}
