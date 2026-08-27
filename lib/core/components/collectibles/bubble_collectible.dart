import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../models/collectible_pattern.dart';
import 'collectible.dart';

/// A small transparent blue/white bubble (§13). Floats gently upward,
/// wobbles side to side, and has a tiny fixed shine highlight.
class BubbleCollectible extends Collectible {
  BubbleCollectible({required super.position})
      : _phase = _rng.nextDouble() * pi * 2,
        super(kind: CollectibleKind.bubble, size: Vector2.all(22));

  static final Random _rng = Random();
  double _phase;

  final Paint _fillPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0x77CFF3FF);
  final Paint _outlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..color = const Color(0xBBFFFFFF);
  final Paint _shinePaint = Paint()..color = const Color(0xDDFFFFFF);

  @override
  void behaviorUpdate(double dt) {
    _phase += dt * 2.4;
    position.y -= 15 * dt;
    position.x += sin(_phase) * 6 * dt;
  }

  @override
  void render(Canvas canvas) {
    final r = size.x / 2;
    final center = Offset(r, r);
    canvas.drawCircle(center, r, _fillPaint);
    canvas.drawCircle(center, r, _outlinePaint);
    canvas.drawCircle(center + Offset(-r * 0.32, -r * 0.32), r * 0.26, _shinePaint);
  }

  @override
  void onCollected() {
    game.audioManager.bubbleCollect();
    game.hapticsManager.light();
    game.scoreManager.collectBubble(multiplier: game.collectibleScoreMultiplier);
    game.spawnParticleBurst(
      position: position.clone(),
      count: 8,
      colors: const [Color(0xFFCFF3FF), Color(0xFFFFFFFF)],
      speed: 90,
      radiusRange: (1.5, 3.5),
      lifeRange: (0.25, 0.5),
    );
  }
}
