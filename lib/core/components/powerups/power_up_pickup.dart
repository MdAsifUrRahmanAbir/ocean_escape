import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../game/ocean_escape_game.dart';
import '../../models/power_up_type.dart';
import '../player/player_fish.dart';

/// A floating power-up pickup (§15). One class covers all five kinds -
/// [kind] switches the badge icon drawn inside a common glowing bubble
/// (§56 - avoid five near-duplicate classes for a single pickup behavior).
class PowerUpPickup extends PositionComponent
    with CollisionCallbacks, HasGameReference<OceanEscapeGame> {
  PowerUpPickup({required this.kind, required Vector2 position})
      : _phase = _rng.nextDouble() * pi * 2,
        _baseY = position.y,
        super(position: position, size: Vector2.all(46), anchor: Anchor.center);

  final PowerUpType kind;
  static final Random _rng = Random();
  double _phase;
  final double _baseY;
  bool collected = false;

  static const Map<PowerUpType, Color> _colors = {
    PowerUpType.shield: Color(0xFF6FE0FF),
    PowerUpType.magnet: Color(0xFFFF6F91),
    PowerUpType.speedBoost: Color(0xFFFFC93C),
    PowerUpType.slowMotion: Color(0xFFB768F0),
    PowerUpType.pearlMultiplier: Color(0xFFFFE082),
  };

  late final Color _color = _colors[kind]!;
  final Paint _glowPaint = Paint();
  final Paint _badgePaint = Paint()..style = PaintingStyle.fill;
  final Paint _outlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4
    ..color = const Color(0xFFFFFFFF);
  final Paint _iconPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.6
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = const Color(0xFFFFFFFF);
  final Paint _iconFillPaint = Paint()..color = const Color(0xFFFFFFFF);

  @override
  Future<void> onLoad() async {
    _glowPaint.color = _color.withValues(alpha: 0.35);
    _badgePaint.color = _color;
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
    _phase += dt * 2.4;
    position.x -= game.effectiveWorldSpeed * dt;
    position.y = _baseY + sin(_phase) * 12;
    if (position.x < -size.x * 2 - 40) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (!collected && other is PlayerFish && game.isSimulating) {
      collected = true;
      game.onPowerUpCollected(kind, position.clone());
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final r = size.x / 2;
    final center = Offset(r, r);
    final pulse = 1.0 + sin(_phase * 1.5) * 0.06;

    canvas.drawCircle(center, r * 1.35 * pulse, _glowPaint);
    canvas.drawCircle(center, r * 0.82, _badgePaint);
    canvas.drawCircle(center, r * 0.82, _outlinePaint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    _drawIcon(canvas, r * 0.82);
    canvas.restore();
  }

  void _drawIcon(Canvas canvas, double r) {
    switch (kind) {
      case PowerUpType.shield:
        final path = Path()
          ..moveTo(0, -r * 0.5)
          ..lineTo(r * 0.4, -r * 0.28)
          ..lineTo(r * 0.4, r * 0.12)
          ..quadraticBezierTo(r * 0.4, r * 0.48, 0, r * 0.55)
          ..quadraticBezierTo(-r * 0.4, r * 0.48, -r * 0.4, r * 0.12)
          ..lineTo(-r * 0.4, -r * 0.28)
          ..close();
        canvas.drawPath(path, _iconPaint);
        break;
      case PowerUpType.magnet:
        final path = Path()
          ..moveTo(-r * 0.35, -r * 0.45)
          ..lineTo(-r * 0.35, r * 0.15)
          ..arcToPoint(Offset(r * 0.35, r * 0.15), radius: Radius.circular(r * 0.35), clockwise: false)
          ..lineTo(r * 0.35, -r * 0.45);
        canvas.drawPath(path, _iconPaint);
        canvas.drawLine(Offset(-r * 0.35, -r * 0.45), Offset(-r * 0.35, -r * 0.2), _iconPaint..strokeWidth = 5);
        canvas.drawLine(Offset(r * 0.35, -r * 0.45), Offset(r * 0.35, -r * 0.2), _iconPaint..strokeWidth = 5);
        _iconPaint.strokeWidth = 2.6;
        break;
      case PowerUpType.speedBoost:
        final path = Path()
          ..moveTo(r * 0.12, -r * 0.5)
          ..lineTo(-r * 0.28, r * 0.05)
          ..lineTo(0, r * 0.05)
          ..lineTo(-r * 0.12, r * 0.5)
          ..lineTo(r * 0.32, -r * 0.1)
          ..lineTo(r * 0.02, -r * 0.1)
          ..close();
        canvas.drawPath(path, _iconFillPaint);
        break;
      case PowerUpType.slowMotion:
        canvas.drawCircle(Offset.zero, r * 0.42, _iconPaint);
        canvas.drawLine(Offset.zero, Offset(0, -r * 0.28), _iconPaint);
        canvas.drawLine(Offset.zero, Offset(r * 0.2, r * 0.12), _iconPaint);
        break;
      case PowerUpType.pearlMultiplier:
        canvas.drawCircle(Offset(-r * 0.18, 0), r * 0.24, _iconFillPaint);
        final xPaint = _iconPaint;
        canvas.drawLine(Offset(r * 0.05, -r * 0.22), Offset(r * 0.4, r * 0.22), xPaint);
        canvas.drawLine(Offset(r * 0.4, -r * 0.22), Offset(r * 0.05, r * 0.22), xPaint);
        break;
    }
  }
}
