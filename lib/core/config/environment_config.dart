import 'dart:ui';

import '../models/environment_type.dart';
import '../models/obstacle_pattern.dart';

/// Visual palette + gameplay tuning for one environment (§17-§20).
class EnvironmentPalette {
  final Color skyTop;
  final Color skyBottom;
  final Color farLayerColor;
  final Color midLayerColor;
  final Color nearLayerColor;
  final Color sandColor;
  final List<Color> coralAccents;
  final Color particleColor;
  final Color lightColor;
  final double ambientDarkness; // 0 = bright, 1 = very dark overlay
  final double obstacleSpeedMultiplier;
  final Map<ObstacleKind, double> obstacleWeights;
  final double mineWeightBonus;
  final double sharkWeightBonus;

  const EnvironmentPalette({
    required this.skyTop,
    required this.skyBottom,
    required this.farLayerColor,
    required this.midLayerColor,
    required this.nearLayerColor,
    required this.sandColor,
    required this.coralAccents,
    required this.particleColor,
    required this.lightColor,
    required this.ambientDarkness,
    required this.obstacleSpeedMultiplier,
    required this.obstacleWeights,
    this.mineWeightBonus = 0,
    this.sharkWeightBonus = 0,
  });
}

class EnvironmentConfig {
  EnvironmentConfig._();

  /// Distance (meters) at which each environment begins (§21's example table).
  static const Map<EnvironmentType, double> startDistanceMeters = {
    EnvironmentType.coralReef: 0,
    EnvironmentType.deepOcean: 2000,
    EnvironmentType.shipwreck: 5000,
    EnvironmentType.volcanoOcean: 8000,
  };

  /// Width (meters) of the smooth cross-fade band before each threshold.
  static const double transitionBandMeters = 260;

  static EnvironmentType environmentForDistance(double meters) {
    EnvironmentType current = EnvironmentType.coralReef;
    for (final entry in startDistanceMeters.entries) {
      if (meters >= entry.value) current = entry.key;
    }
    return current;
  }

  static final Map<EnvironmentType, EnvironmentPalette> palettes = {
    EnvironmentType.coralReef: EnvironmentPalette(
      skyTop: const Color(0xFF7FE0F0),
      skyBottom: const Color(0xFF1E9BC7),
      farLayerColor: const Color(0xFF3FB6D6),
      midLayerColor: const Color(0xFF2E9FC2),
      nearLayerColor: const Color(0xFF1E86A8),
      sandColor: const Color(0xFFF5DE9C),
      coralAccents: const [
        Color(0xFFFF6F91),
        Color(0xFFB768F0),
        Color(0xFF54C6E8),
        Color(0xFF6FE097),
      ],
      particleColor: const Color(0xFFEFFCFF),
      lightColor: const Color(0xFFFFFDE0),
      ambientDarkness: 0.0,
      obstacleSpeedMultiplier: 1.0,
      obstacleWeights: const {
        ObstacleKind.coral: 3,
        ObstacleKind.rock: 1.5,
        ObstacleKind.seaMine: 0.4,
        ObstacleKind.shark: 0.8,
        ObstacleKind.shipDebris: 0,
      },
    ),
    EnvironmentType.deepOcean: EnvironmentPalette(
      skyTop: const Color(0xFF2A5C9A),
      skyBottom: const Color(0xFF0B2A54),
      farLayerColor: const Color(0xFF1D4A82),
      midLayerColor: const Color(0xFF163B69),
      nearLayerColor: const Color(0xFF0F2C52),
      sandColor: const Color(0xFF37547A),
      coralAccents: const [
        Color(0xFF3F7FBF),
        Color(0xFF5B4FA0),
        Color(0xFF2FA3A3),
        Color(0xFF7BD1E8),
      ],
      particleColor: const Color(0xFF9FE8FF),
      lightColor: const Color(0xFFBFE9FF),
      ambientDarkness: 0.35,
      obstacleSpeedMultiplier: 1.08,
      obstacleWeights: const {
        ObstacleKind.coral: 1.2,
        ObstacleKind.rock: 2.2,
        ObstacleKind.seaMine: 1.2,
        ObstacleKind.shark: 1.8,
        ObstacleKind.shipDebris: 0.3,
      },
      sharkWeightBonus: 0.4,
    ),
    EnvironmentType.shipwreck: EnvironmentPalette(
      skyTop: const Color(0xFF264055),
      skyBottom: const Color(0xFF0B1B28),
      farLayerColor: const Color(0xFF203548),
      midLayerColor: const Color(0xFF17293A),
      nearLayerColor: const Color(0xFF101E2B),
      sandColor: const Color(0xFF4A4030),
      coralAccents: const [
        Color(0xFF8A6A3F),
        Color(0xFF6E5636),
        Color(0xFFB08D53),
        Color(0xFF4F7A6E),
      ],
      particleColor: const Color(0xFFE0C892),
      lightColor: const Color(0xFFE7D9A8),
      ambientDarkness: 0.55,
      obstacleSpeedMultiplier: 1.18,
      obstacleWeights: const {
        ObstacleKind.coral: 0.6,
        ObstacleKind.rock: 1.4,
        ObstacleKind.seaMine: 1.4,
        ObstacleKind.shark: 1.6,
        ObstacleKind.shipDebris: 2.6,
      },
      mineWeightBonus: 0.3,
    ),
    EnvironmentType.volcanoOcean: EnvironmentPalette(
      skyTop: const Color(0xFF3A1414),
      skyBottom: const Color(0xFF190505),
      farLayerColor: const Color(0xFF4A1E18),
      midLayerColor: const Color(0xFF33120F),
      nearLayerColor: const Color(0xFF210A08),
      sandColor: const Color(0xFF2A1210),
      coralAccents: const [
        Color(0xFFFF7A3C),
        Color(0xFFFFB23C),
        Color(0xFFB33A2E),
        Color(0xFF8C2A20),
      ],
      particleColor: const Color(0xFFFFB066),
      lightColor: const Color(0xFFFF8A3D),
      ambientDarkness: 0.5,
      obstacleSpeedMultiplier: 1.3,
      obstacleWeights: const {
        ObstacleKind.coral: 0.4,
        ObstacleKind.rock: 2.0,
        ObstacleKind.seaMine: 2.4,
        ObstacleKind.shark: 2.2,
        ObstacleKind.shipDebris: 1.0,
      },
      mineWeightBonus: 0.6,
      sharkWeightBonus: 0.6,
    ),
  };
}
