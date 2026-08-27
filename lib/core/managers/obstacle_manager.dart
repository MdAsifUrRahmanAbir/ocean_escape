import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show HSLColor;

import '../components/obstacles/sea_mine.dart';
import '../components/obstacles/shark.dart';
import '../components/obstacles/static_obstacle.dart';
import '../config/difficulty_config.dart';
import '../game/ocean_escape_game.dart';
import '../models/obstacle_pattern.dart';
import '../utils/random_utils.dart';

/// Procedurally spawns obstacles (§9/§27). Every spawn either guarantees a
/// safe gap between a top/bottom pair, or places a single free-floating
/// hazard with generous clearance on both sides - never a combination that
/// blocks the whole playable band (§26/§57).
class ObstacleManager extends Component with HasGameReference<OceanEscapeGame> {
  final Random _rng = Random();
  double _timer = 0;
  double _lastGapCenterFraction = 0.5;

  static const double _edgeMargin = 22;
  static const double _minSlotHeight = 16;

  void reset() {
    removeAll(children.toList());
    _timer = DifficultyConfig.obstacleIntervalStart * 0.7;
    _lastGapCenterFraction = 0.5;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isSimulating) return;
    _timer -= dt;
    if (_timer <= 0) {
      _spawn();
      _timer = game.difficulty.obstacleInterval;
    }
  }

  double get _spawnX => game.size.x + 70;

  void _spawn() {
    final roll = _rng.nextDouble();
    if (roll < 0.55) {
      _spawnGapPair();
    } else if (roll < 0.85) {
      _spawnSingleHazard(_spawnX);
    } else {
      _spawnGapPair();
      _spawnSingleHazard(_spawnX + 230 + _rng.nextDouble() * 80);
    }
  }

  double _pickGapCenterFraction() {
    const maxShift = DifficultyConfig.maxGapCenterShiftFraction;
    final shift = (_rng.nextDouble() * 2 - 1) * maxShift;
    final target = (_lastGapCenterFraction + shift).clamp(0.18, 0.82);
    _lastGapCenterFraction = target;
    return target;
  }

  void _spawnGapPair() {
    final top = game.playableTop;
    final bottom = game.playableBottom;
    final bandHeight = bottom - top;
    final gapHeight = min(game.difficulty.gapHeight, bandHeight * 0.82);
    final gapHalf = gapHeight / 2;

    final minCenter = top + _edgeMargin + gapHalf;
    final maxCenter = bottom - _edgeMargin - gapHalf;
    double gapCenterY;
    if (minCenter >= maxCenter) {
      gapCenterY = (top + bottom) / 2;
    } else {
      gapCenterY = top + bandHeight * _pickGapCenterFraction();
      gapCenterY = gapCenterY.clamp(minCenter, maxCenter);
    }

    final x = _spawnX;
    final width = 70 + _rng.nextDouble() * 55;
    final weights = _staticWeights();

    final topHeight = gapCenterY - gapHalf - top;
    if (topHeight >= _minSlotHeight) {
      final kind = RandomUtils.weightedPick(weights, _rng);
      add(StaticObstacle(
        kind: kind,
        position: Vector2(x, top),
        slot: VerticalSlot.top,
        width: width,
        height: topHeight,
        color: _colorForKind(kind),
        seed: _rng.nextInt(1 << 30),
      ));
    }

    final bottomHeight = bottom - (gapCenterY + gapHalf);
    if (bottomHeight >= _minSlotHeight) {
      final kind = RandomUtils.weightedPick(weights, _rng);
      add(StaticObstacle(
        kind: kind,
        position: Vector2(x, bottom),
        slot: VerticalSlot.bottom,
        width: 70 + _rng.nextDouble() * 55,
        height: bottomHeight,
        color: _colorForKind(kind),
        seed: _rng.nextInt(1 << 30),
      ));
    }
  }

  void _spawnSingleHazard(double x) {
    final top = game.playableTop;
    final bottom = game.playableBottom;
    final weights = _moverWeights();
    final kind = RandomUtils.weightedPick(weights, _rng);
    final y = top + (bottom - top) * (0.22 + _rng.nextDouble() * 0.56);
    final behavior = _pickBehavior();

    if (kind == ObstacleKind.shark) {
      final fast = behavior == MoverBehavior.fastDart;
      add(Shark(
        position: Vector2(x, y),
        behavior: behavior,
        speedFactor: fast ? 1.15 + _rng.nextDouble() * 0.15 : 0.95 + _rng.nextDouble() * 0.15,
      ));
    } else {
      add(SeaMine(
        position: Vector2(x, y),
        behavior: behavior,
        speedFactor: 1.0,
      ));
    }
  }

  MoverBehavior _pickBehavior() {
    final t = (game.difficulty.elapsed / DifficultyConfig.rampSeconds).clamp(0.0, 1.0);
    final weights = <MoverBehavior, double>{
      MoverBehavior.staticHover: 1.0,
      MoverBehavior.slowDrift: 1.0,
      MoverBehavior.horizontalPatrol: 0.4 + t * 0.8,
      MoverBehavior.verticalPatrol: 0.3 + t * 1.0,
      MoverBehavior.fastDart: 0.1 + t * 1.1,
    };
    return RandomUtils.weightedPick(weights, _rng);
  }

  Map<ObstacleKind, double> _staticWeights() {
    final all = game.environment.blendedObstacleWeights;
    return {
      ObstacleKind.coral: all[ObstacleKind.coral] ?? 0.01,
      ObstacleKind.rock: all[ObstacleKind.rock] ?? 0.01,
      ObstacleKind.shipDebris: all[ObstacleKind.shipDebris] ?? 0.01,
    };
  }

  Map<ObstacleKind, double> _moverWeights() {
    final all = game.environment.blendedObstacleWeights;
    return {
      ObstacleKind.shark: all[ObstacleKind.shark] ?? 0.01,
      ObstacleKind.seaMine: all[ObstacleKind.seaMine] ?? 0.01,
    };
  }

  Color _colorForKind(ObstacleKind kind) {
    final palette = game.environment.currentPalette;
    switch (kind) {
      case ObstacleKind.coral:
        return palette.coralAccents[_rng.nextInt(palette.coralAccents.length)];
      case ObstacleKind.rock:
        final hsl = HSLColor.fromColor(palette.nearLayerColor);
        return hsl
            .withSaturation((hsl.saturation * 0.25).clamp(0.0, 1.0))
            .withLightness((0.32 + _rng.nextDouble() * 0.12).clamp(0.0, 1.0))
            .toColor();
      case ObstacleKind.shipDebris:
        final base = HSLColor.fromColor(const Color(0xFF6E5233));
        return base.withLightness((base.lightness + (_rng.nextDouble() - 0.5) * 0.1).clamp(0.0, 1.0)).toColor();
      case ObstacleKind.shark:
      case ObstacleKind.seaMine:
        return const Color(0xFFFFFFFF);
    }
  }
}
