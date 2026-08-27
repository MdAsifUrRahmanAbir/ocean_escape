import '../models/collectible_pattern.dart';
import '../models/power_up_type.dart';

/// Weighting tables for collectible/power-up spawn choices (§14/§15/§27).
class SpawnConfig {
  SpawnConfig._();

  static const Map<CollectiblePatternType, double> collectiblePatternWeights = {
    CollectiblePatternType.straightLine: 3,
    CollectiblePatternType.verticalLine: 2,
    CollectiblePatternType.diagonalLine: 2,
    CollectiblePatternType.wave: 1.5,
    CollectiblePatternType.arc: 1.5,
    CollectiblePatternType.stair: 1.5,
  };

  /// Chance any given collectible in a pattern is a pearl instead of a bubble.
  static const double pearlChance = 0.16;

  /// Chance a collectible pattern is routed through/near an obstacle gap as a
  /// risk/reward line rather than open water (§14).
  static const double riskRewardChance = 0.35;

  static const Map<PowerUpType, double> powerUpWeights = {
    PowerUpType.shield: 1.2,
    PowerUpType.magnet: 1.0,
    PowerUpType.speedBoost: 1.0,
    PowerUpType.slowMotion: 1.0,
    PowerUpType.pearlMultiplier: 0.9,
  };
}
