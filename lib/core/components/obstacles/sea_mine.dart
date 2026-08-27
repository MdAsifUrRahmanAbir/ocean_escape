import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../models/obstacle_pattern.dart';
import 'obstacle.dart';

/// A cartoon underwater mine (§11): round spiked body, small floating bob,
/// subtle rotation, and a blinking warning light. [behavior] reuses the same
/// mover vocabulary as [Shark] so the spawner can treat both uniformly (§27).
class SeaMine extends Obstacle {
  SeaMine({
    required super.position,
    this.behavior = MoverBehavior.staticHover,
    double speedFactor = 1.0,
  }) : super(kind: ObstacleKind.seaMine, size: Vector2(52, 52));

  final MoverBehavior behavior;

  double _t = 0;
  late double _baseY;
  final Random _rng = Random();
  late double _phase;

  final Paint _bodyPaint = Paint()..color = const Color(0xFF3D4A52);
  final Paint _bodyShadePaint = Paint()..color = const Color(0xFF2B3439);
  final Paint _spikePaint = Paint()..color = const Color(0xFF4A5A63);
  final Paint _outlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4
    ..strokeJoin = StrokeJoin.round
    ..color = const Color(0xFF15191C);
  final Paint _boltPaint = Paint()..color = const Color(0xFF6C7C86);
  final Paint _lightOnPaint = Paint()..color = const Color(0xFFFF4B3E);
  final Paint _lightOffPaint = Paint()..color = const Color(0xFF7A2A24);
  final Paint _lightGlowPaint = Paint()..color = const Color(0x55FF4B3E);

  @override
  Future<void> onLoad() async {
    _baseY = position.y;
    _phase = _rng.nextDouble() * pi * 2;
    add(
      CircleHitbox(radius: size.x * 0.36)
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
        offset = sin(_t * 1.6 + _phase) * 10;
        break;
      case MoverBehavior.verticalPatrol:
        offset = sin(_t * 1.1 + _phase) * 70;
        break;
      case MoverBehavior.horizontalPatrol:
        offset = sin(_t * 1.8 + _phase) * 14;
        break;
      case MoverBehavior.fastDart:
        offset = sin(_t * 2.6 + _phase) * 18;
        break;
      case MoverBehavior.slowDrift:
        offset = sin(_t * 0.7 + _phase) * 40;
        break;
    }
    final top = game.playableTop + size.y / 2;
    final bottom = game.playableBottom - size.y / 2;
    position.y = (_baseY + offset).clamp(top, bottom);
    angle += dt * 0.6;
  }

  @override
  void render(Canvas canvas) {
    final r = size.x / 2;
    final center = Offset(r, r);

    // Spikes.
    const spikeCount = 8;
    for (int i = 0; i < spikeCount; i++) {
      final a = (i / spikeCount) * pi * 2;
      final baseAngle1 = a - 0.16;
      final baseAngle2 = a + 0.16;
      final tip = center + Offset(cos(a), sin(a)) * (r * 1.35);
      final b1 = center + Offset(cos(baseAngle1), sin(baseAngle1)) * (r * 0.92);
      final b2 = center + Offset(cos(baseAngle2), sin(baseAngle2)) * (r * 0.92);
      final path = Path()
        ..moveTo(b1.dx, b1.dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(b2.dx, b2.dy)
        ..close();
      canvas.drawPath(path, _spikePaint);
      canvas.drawPath(path, _outlinePaint);
    }

    // Body.
    canvas.drawCircle(center, r * 0.92, _bodyPaint);
    canvas.drawCircle(center, r * 0.92, _outlinePaint);
    canvas.drawCircle(center + Offset(r * 0.22, r * 0.22), r * 0.55, _bodyShadePaint);

    // Rivets/bolts around the body.
    for (int i = 0; i < 6; i++) {
      final a = (i / 6) * pi * 2 + 0.3;
      final p = center + Offset(cos(a), sin(a)) * (r * 0.55);
      canvas.drawCircle(p, r * 0.07, _boltPaint);
    }

    // Blinking warning light on top.
    final lightOn = sin(_t * 5 + _phase) > 0.2;
    final lightPos = center - Offset(0, r * 0.15);
    if (lightOn) {
      canvas.drawCircle(lightPos, r * 0.32, _lightGlowPaint);
    }
    canvas.drawCircle(lightPos, r * 0.14, lightOn ? _lightOnPaint : _lightOffPaint);
    canvas.drawCircle(lightPos, r * 0.14, _outlinePaint..strokeWidth = 1.4);
    _outlinePaint.strokeWidth = 2.4;
  }
}
