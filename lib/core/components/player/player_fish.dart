import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../config/game_config.dart';
import '../../game/ocean_escape_game.dart';
import '../obstacles/obstacle.dart';
import 'fish_painter.dart';

/// The six animation states called for in §5. `idleSwim`/`fastSwim` are
/// continuously re-derived from input each frame; the rest are short,
/// event-triggered states that automatically return to swimming.
enum FishAnimState { idleSwim, fastSwim, hurt, shielded, death, powerUpActivate }

/// The player-controlled fish (§4/§6/§7). Physics is a simple arcade model:
/// gravity always pulls down, holding the pointer adds upward thrust.
class PlayerFish extends PositionComponent
    with CollisionCallbacks, HasGameReference<OceanEscapeGame> {
  PlayerFish() : super(anchor: Anchor.center, size: Vector2.all(GameConfig.fishRadius * 2));

  static const double _deathDuration = 1.1;
  static const double _hurtFlashDuration = 0.35;
  static const double _powerUpFxDuration = 0.5;

  final FishPainter painter = FishPainter();

  double velocityY = 0;
  bool isHolding = false;
  bool hasShield = false;
  FishAnimState state = FishAnimState.idleSwim;

  /// Playable vertical band, set by the game each time the viewport resizes.
  double topBound = 0;
  double bottomBound = 1000;

  double _swimPhase = 0;
  double _visualAngle = 0;
  double _hurtFlashTimer = 0;
  double _powerUpFxTimer = 0;
  double _deathTimer = 0;
  bool controlsEnabled = true;

  bool get isDead => state == FishAnimState.death;

  @override
  Future<void> onLoad() async {
    add(
      CircleHitbox(radius: GameConfig.fishRadius * GameConfig.fishHitboxRadiusFactor)
        ..anchor = Anchor.center
        ..position = size / 2,
    );
  }

  void resetTo(Vector2 pos) {
    position.setFrom(pos);
    velocityY = 0;
    isHolding = false;
    hasShield = false;
    state = FishAnimState.idleSwim;
    _swimPhase = 0;
    _visualAngle = 0;
    _hurtFlashTimer = 0;
    _powerUpFxTimer = 0;
    _deathTimer = 0;
    controlsEnabled = true;
    angle = 0;
  }

  void triggerHurtFlash() {
    if (isDead) return;
    state = FishAnimState.hurt;
    _hurtFlashTimer = _hurtFlashDuration;
  }

  void triggerDeath() {
    state = FishAnimState.death;
    controlsEnabled = false;
    _deathTimer = 0;
    velocityY = -160; // small pop before sinking, per §29's "short crash animation"
  }

  void triggerPowerUpActivate() {
    if (isDead) return;
    state = FishAnimState.powerUpActivate;
    _powerUpFxTimer = _powerUpFxDuration;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (state == FishAnimState.death) {
      _updateDeath(dt);
      return;
    }

    if (controlsEnabled) {
      velocityY += GameConfig.gravity * dt;
      if (isHolding) {
        velocityY -= GameConfig.swimThrust * dt;
      }
      velocityY = velocityY.clamp(-GameConfig.maxUpSpeed, GameConfig.maxFallSpeed).toDouble();
      position.y += velocityY * dt;
      if (position.y < topBound) {
        position.y = topBound;
        if (velocityY < 0) velocityY = 0;
      } else if (position.y > bottomBound) {
        position.y = bottomBound;
        if (velocityY > 0) velocityY = 0;
      }
    }

    if (state == FishAnimState.idleSwim || state == FishAnimState.fastSwim) {
      state = isHolding ? FishAnimState.fastSwim : FishAnimState.idleSwim;
    }

    final wagSpeed = state == FishAnimState.fastSwim ? 13.0 : 7.5;
    _swimPhase += dt * wagSpeed;

    final targetAngle =
        (velocityY / GameConfig.maxFallSpeed).clamp(-1.0, 1.0).toDouble() * GameConfig.maxTiltRadians;
    _visualAngle += (targetAngle - _visualAngle) * min(1.0, dt * 8);
    angle = _visualAngle;

    if (_hurtFlashTimer > 0) {
      _hurtFlashTimer -= dt;
      if (_hurtFlashTimer <= 0 && state == FishAnimState.hurt) {
        state = FishAnimState.idleSwim;
      }
    }
    if (_powerUpFxTimer > 0) {
      _powerUpFxTimer -= dt;
      if (_powerUpFxTimer <= 0 && state == FishAnimState.powerUpActivate) {
        state = FishAnimState.idleSwim;
      }
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Obstacle && controlsEnabled && game.isSimulating) {
      game.handlePlayerCrash();
    }
  }

  void _updateDeath(double dt) {
    _deathTimer += dt;
    velocityY += GameConfig.gravity * 0.6 * dt;
    position.y += velocityY * dt;
    angle += dt * 2.4;
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);

    double expression = 1.0;
    double squash = sin(_swimPhase * 2) * 0.03;
    Color? tint;
    double tintStrength = 0;
    double opacity = 1.0;

    switch (state) {
      case FishAnimState.hurt:
        expression = -1.0;
        tint = const Color(0xFFFF3B30);
        tintStrength = (_hurtFlashTimer / _hurtFlashDuration).clamp(0.0, 1.0) * 0.6;
        break;
      case FishAnimState.death:
        expression = -1.0;
        opacity = (1.0 - _deathTimer / _deathDuration).clamp(0.0, 1.0);
        tint = const Color(0xFFFF3B30);
        tintStrength = 0.35;
        break;
      case FishAnimState.powerUpActivate:
        squash += 0.06;
        break;
      case FishAnimState.idleSwim:
      case FishAnimState.fastSwim:
      case FishAnimState.shielded:
        break;
    }

    painter.paint(
      canvas,
      radius: GameConfig.fishRadius,
      swimPhase: _swimPhase,
      expression: expression,
      squash: squash,
      shielded: hasShield,
      tintOverride: tint,
      tintStrength: tintStrength,
      opacity: opacity,
    );
    canvas.restore();
  }
}
