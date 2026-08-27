import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../game/ocean_escape_game.dart';
import '../../models/obstacle_pattern.dart';

/// Base class for every obstacle type (§9). Handles common scroll movement,
/// off-screen cleanup, and the pause/crash freeze rule (§29/§35); concrete
/// obstacles only implement their own [behaviorUpdate] (movement pattern)
/// and [render].
abstract class Obstacle extends PositionComponent
    with CollisionCallbacks, HasGameReference<OceanEscapeGame> {
  Obstacle({
    required this.kind,
    required Vector2 position,
    required Vector2 size,
    Anchor anchor = Anchor.center,
    this.speedFactor = 1.0,
  }) : super(position: position, size: size, anchor: anchor);

  final ObstacleKind kind;
  final double speedFactor;

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isSimulating) return;
    position.x -= game.effectiveWorldSpeed * speedFactor * dt;
    behaviorUpdate(dt);
    if (position.x < -size.x * 2 - 40) {
      removeFromParent();
    }
  }

  /// Override for patrol/bob/dart/fall movement (§10/§11/§19).
  void behaviorUpdate(double dt) {}
}
