import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../models/collectible_pattern.dart';
import 'collectible.dart';

/// A rare, higher-value glowing pearl (§13). Sits with a soft outer glow and
/// a rotating sparkle cross; bobs gently in place rather than drifting.
class PearlCollectible extends Collectible {
  PearlCollectible({required super.position})
      : _phase = _rng.nextDouble() * pi * 2,
        _baseY = position.y,
        super(kind: CollectibleKind.pearl, size: Vector2.all(20));

  static final Random _rng = Random();
  double _phase;
  final double _baseY;

  final Paint _glowPaint = Paint()..color = const Color(0x55FFF9E0);
  final Paint _bodyPaint = Paint()..color = const Color(0xFFFFFDF5);
  final Paint _shadePaint = Paint()..color = const Color(0xFFE7DEC2);
  final Paint _outlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..color = const Color(0xFFC9BE95);
  final Paint _sparklePaint = Paint()..color = const Color(0xFFFFFFFF);
  final Paint _highlightPaint = Paint()..color = const Color(0xCCFFFFFF);

  @override
  void behaviorUpdate(double dt) {
    _phase += dt * 2.2;
    position.y = _baseY + sin(_phase) * 6;
  }

  @override
  void render(Canvas canvas) {
    final r = size.x / 2;
    final center = Offset(r, r);

    canvas.drawCircle(center, r * 1.7, _glowPaint);
    canvas.drawCircle(center, r, _bodyPaint);
    canvas.drawCircle(center + Offset(r * 0.15, r * 0.2), r * 0.65, _shadePaint);
    canvas.drawCircle(center, r, _outlinePaint);
    canvas.drawCircle(center - Offset(r * 0.28, r * 0.28), r * 0.22, _highlightPaint);

    final sparkleAlpha = sin(_phase * 1.6) * 0.5 + 0.5;
    _sparklePaint.color = Color.fromRGBO(255, 255, 255, sparkleAlpha);
    final sparkleR = r * 1.9;
    final sp = center + Offset(r * 1.3, -r * 0.6);
    _drawSparkle(canvas, sp, sparkleR * 0.22);
  }

  void _drawSparkle(Canvas canvas, Offset center, double s) {
    final path = Path()
      ..moveTo(center.dx, center.dy - s)
      ..lineTo(center.dx + s * 0.22, center.dy - s * 0.22)
      ..lineTo(center.dx + s, center.dy)
      ..lineTo(center.dx + s * 0.22, center.dy + s * 0.22)
      ..lineTo(center.dx, center.dy + s)
      ..lineTo(center.dx - s * 0.22, center.dy + s * 0.22)
      ..lineTo(center.dx - s, center.dy)
      ..lineTo(center.dx - s * 0.22, center.dy - s * 0.22)
      ..close();
    canvas.drawPath(path, _sparklePaint);
  }

  @override
  void onCollected() {
    game.audioManager.pearlCollect();
    game.hapticsManager.medium();
    game.scoreManager.collectPearl(multiplier: game.collectibleScoreMultiplier);
    game.spawnParticleBurst(
      position: position.clone(),
      count: 14,
      colors: const [Color(0xFFFFFDF5), Color(0xFFFFE9A8), Color(0xFFFFFFFF)],
      speed: 130,
      radiusRange: (1.5, 4.0),
      lifeRange: (0.35, 0.7),
    );
  }
}
