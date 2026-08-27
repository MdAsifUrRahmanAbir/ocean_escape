import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../models/obstacle_pattern.dart';
import 'obstacle.dart';

/// A cute-but-dangerous cartoon shark (§10). Movement pattern is driven by
/// [behavior]; all variants stay within the game's playable band via a
/// clamp against the spawn point.
class Shark extends Obstacle {
  Shark({
    required super.position,
    required this.behavior,
    double speedFactor = 1.0,
    this.facingLeft = true,
  }) : super(kind: ObstacleKind.shark, size: Vector2(100, 58));

  final MoverBehavior behavior;
  final bool facingLeft;

  double _t = 0;
  late double _baseY;

  final Paint _bodyPaint = Paint()..color = const Color(0xFF7C8A99);
  final Paint _bellyPaint = Paint()..color = const Color(0xFFEFF3F5);
  final Paint _finPaint = Paint()..color = const Color(0xFF60707D);
  final Paint _outlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.6
    ..strokeJoin = StrokeJoin.round
    ..color = const Color(0xFF232B33);
  final Paint _eyePaint = Paint()..color = const Color(0xFF1A1A1A);
  final Paint _teethPaint = Paint()..color = const Color(0xFFFFFFFF);

  @override
  Future<void> onLoad() async {
    _baseY = position.y;
    add(
      RectangleHitbox(size: Vector2(size.x * 0.82, size.y * 0.62))
        ..anchor = Anchor.center
        ..position = size / 2,
    );
  }

  @override
  void behaviorUpdate(double dt) {
    _t += dt;
    double offset;
    switch (behavior) {
      case MoverBehavior.staticHover:
        offset = sin(_t * 2) * 6;
        break;
      case MoverBehavior.verticalPatrol:
        offset = sin(_t * 1.4) * 78;
        break;
      case MoverBehavior.horizontalPatrol:
        offset = sin(_t * 2.2) * 16;
        break;
      case MoverBehavior.fastDart:
        offset = sin(_t * 3.2) * 20;
        break;
      case MoverBehavior.slowDrift:
        offset = sin(_t * 0.9) * 34;
        break;
    }
    final top = game.playableTop + size.y / 2;
    final bottom = game.playableBottom - size.y / 2;
    position.y = (_baseY + offset).clamp(top, bottom);
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    canvas.save();
    if (!facingLeft) {
      canvas.translate(w, 0);
      canvas.scale(-1, 1);
    }

    final tail = Path()
      ..moveTo(w * 0.05, h * 0.5)
      ..lineTo(-w * 0.18, h * 0.12)
      ..lineTo(-w * 0.02, h * 0.5)
      ..lineTo(-w * 0.18, h * 0.88)
      ..close();
    canvas.drawPath(tail, _finPaint);
    canvas.drawPath(tail, _outlinePaint);

    final body = Path()
      ..moveTo(0, h * 0.5)
      ..quadraticBezierTo(w * 0.15, h * 0.05, w * 0.55, h * 0.14)
      ..quadraticBezierTo(w * 0.92, h * 0.24, w, h * 0.44)
      ..quadraticBezierTo(w * 0.94, h * 0.56, w * 0.68, h * 0.56)
      ..quadraticBezierTo(w * 0.4, h * 0.98, w * 0.06, h * 0.85)
      ..quadraticBezierTo(-w * 0.02, h * 0.68, 0, h * 0.5)
      ..close();
    canvas.drawPath(body, _bodyPaint);
    canvas.drawPath(body, _outlinePaint);

    final belly = Path()
      ..moveTo(w * 0.14, h * 0.58)
      ..quadraticBezierTo(w * 0.4, h * 0.8, w * 0.66, h * 0.62)
      ..quadraticBezierTo(w * 0.4, h * 0.7, w * 0.14, h * 0.58)
      ..close();
    canvas.drawPath(belly, _bellyPaint);

    final dorsal = Path()
      ..moveTo(w * 0.34, h * 0.16)
      ..lineTo(w * 0.48, -h * 0.28)
      ..lineTo(w * 0.62, h * 0.2)
      ..close();
    canvas.drawPath(dorsal, _finPaint);
    canvas.drawPath(dorsal, _outlinePaint);

    canvas.drawCircle(Offset(w * 0.74, h * 0.3), h * 0.075, _eyePaint);

    // A couple of small teeth for a friendly-but-toothy grin.
    final mouth = Path()
      ..moveTo(w * 0.88, h * 0.45)
      ..lineTo(w * 0.92, h * 0.5)
      ..lineTo(w * 0.86, h * 0.5)
      ..close();
    canvas.drawPath(mouth, _teethPaint);

    canvas.restore();
  }
}
