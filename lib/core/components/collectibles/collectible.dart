import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../config/powerup_config.dart';
import '../../game/ocean_escape_game.dart';
import '../../models/collectible_pattern.dart';
import '../player/player_fish.dart';

/// Base class for bubbles and pearls (§13). Handles common scroll movement,
/// magnet-power-up homing (§15), off-screen cleanup and collect-on-touch;
/// concrete collectibles only implement their own gentle motion, [render],
/// and [onCollected] (score/audio/particles).
abstract class Collectible extends PositionComponent
    with CollisionCallbacks, HasGameReference<OceanEscapeGame> {
  Collectible({required this.kind, required Vector2 position, required Vector2 size})
      : super(position: position, size: size, anchor: Anchor.center);

  final CollectibleKind kind;
  bool collected = false;

  @override
  Future<void> onLoad() async {
    add(
      CircleHitbox(radius: size.x * 0.42)
        ..anchor = Anchor.center
        ..position = size / 2,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isSimulating || collected) return;

    if (game.magnetActive) {
      final target = game.player.position;
      final dir = target - position;
      final dist = dir.length;
      if (dist > 4) {
        position.add(dir.normalized() * min(PowerUpConfig.magnetPullSpeed * dt, dist));
      }
    } else {
      position.x -= game.effectiveWorldSpeed * dt;
      behaviorUpdate(dt);
    }

    if (position.x < -size.x * 2 - 40) {
      removeFromParent();
    }
  }

  /// Override for float/bob/rotate motion (§13).
  void behaviorUpdate(double dt) {}

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (!collected && other is PlayerFish && game.isSimulating) {
      collected = true;
      onCollected();
      removeFromParent();
    }
  }

  /// Handles score/audio/haptics/particles for this collectible kind.
  void onCollected();
}
