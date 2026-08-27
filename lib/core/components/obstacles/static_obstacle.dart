import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show HSLColor;

import '../../models/obstacle_pattern.dart';
import 'obstacle.dart';

/// Coral formations, rocks and shipwreck debris (§12/§19) all share the same
/// shape: a solid cluster growing from the top or bottom edge of the
/// playable band, used to carve out narrow passages together with a gap
/// partner. One class covers all three visual kinds to avoid near-duplicate
/// obstacle classes (§56 - don't over-engineer); [kind] switches the palette
/// and silhouette generator.
class StaticObstacle extends Obstacle {
  StaticObstacle({
    required super.kind,
    required Vector2 position,
    required this.slot,
    required double width,
    required double height,
    required this.color,
    int seed = 0,
  })  : _rng = Random(seed),
        super(
          position: Vector2(position.x - width / 2, slot == VerticalSlot.top ? position.y : position.y - height),
          size: Vector2(width, height),
          anchor: Anchor.topLeft,
        );

  final VerticalSlot slot;
  final Color color;
  final Random _rng;

  late List<_Lobe> _lobes;
  late Color _shadeColor;
  late Color _outlineColor;

  final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  final Paint _shadePaint = Paint()..style = PaintingStyle.fill;
  final Paint _outlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4
    ..strokeJoin = StrokeJoin.round;
  final Paint _boltPaint = Paint()..color = const Color(0xFF2B2118);

  @override
  Future<void> onLoad() async {
    final lobeCount = 3 + _rng.nextInt(3);
    _lobes = List.generate(lobeCount, (i) {
      final x = size.x * (0.15 + _rng.nextDouble() * 0.7);
      final w = size.x * (0.3 + _rng.nextDouble() * 0.35);
      final reach = size.y * (0.55 + _rng.nextDouble() * 0.45);
      return _Lobe(x, w, reach);
    });

    final hsl = HSLColor.fromColor(color);
    _shadeColor = hsl.withLightness((hsl.lightness - 0.16).clamp(0.0, 1.0)).toColor();
    _outlineColor = hsl.withLightness((hsl.lightness - 0.32).clamp(0.0, 1.0)).toColor();
    _outlinePaint.color = _outlineColor;

    add(
      RectangleHitbox(size: Vector2(size.x * 0.62, size.y * 0.82))
        ..anchor = Anchor.center
        ..position = Vector2(
          size.x / 2,
          slot == VerticalSlot.top ? size.y * 0.42 : size.y * 0.58,
        ),
    );
  }

  @override
  void render(Canvas canvas) {
    switch (kind) {
      case ObstacleKind.coral:
        _renderCoral(canvas);
        break;
      case ObstacleKind.rock:
        _renderRock(canvas);
        break;
      case ObstacleKind.shipDebris:
        _renderShipDebris(canvas);
        break;
      case ObstacleKind.shark:
      case ObstacleKind.seaMine:
        break; // handled by their own components
    }
  }

  double _baseY() => slot == VerticalSlot.top ? 0 : size.y;
  double _dir() => slot == VerticalSlot.top ? 1 : -1;

  void _renderCoral(Canvas canvas) {
    _fillPaint.color = color;
    _shadePaint.color = _shadeColor;
    final base = _baseY();
    final dir = _dir();
    for (final lobe in _lobes) {
      final tipY = base + dir * lobe.reach;
      final path = Path()
        ..moveTo(lobe.x - lobe.width / 2, base)
        ..quadraticBezierTo(lobe.x - lobe.width * 0.6, base + dir * lobe.reach * 0.55, lobe.x, tipY)
        ..quadraticBezierTo(lobe.x + lobe.width * 0.6, base + dir * lobe.reach * 0.55, lobe.x + lobe.width / 2, base)
        ..close();
      canvas.drawPath(path, _fillPaint);
      canvas.drawPath(path, _outlinePaint);
      // A smaller inner branch for texture.
      final innerPath = Path()
        ..moveTo(lobe.x - lobe.width * 0.18, base)
        ..quadraticBezierTo(lobe.x, base + dir * lobe.reach * 0.7, lobe.x + lobe.width * 0.05, tipY - dir * lobe.reach * 0.1)
        ..lineTo(lobe.x + lobe.width * 0.18, base);
      canvas.drawPath(innerPath, _shadePaint..style = PaintingStyle.stroke..strokeWidth = 4);
      _shadePaint.style = PaintingStyle.fill;
    }
    // Base mound tying the lobes together.
    final moundRect = Rect.fromLTWH(0, base == 0 ? 0 : base - size.y * 0.14, size.x, size.y * 0.16);
    canvas.drawRect(moundRect, _fillPaint);
  }

  void _renderRock(Canvas canvas) {
    _fillPaint.color = color;
    _shadePaint.color = _shadeColor;
    final base = _baseY();
    final dir = _dir();
    final path = Path()..moveTo(0, base);
    for (final lobe in _lobes) {
      path.quadraticBezierTo(
        lobe.x - lobe.width * 0.3,
        base + dir * lobe.reach * 0.3,
        lobe.x,
        base + dir * lobe.reach,
      );
      path.quadraticBezierTo(
        lobe.x + lobe.width * 0.3,
        base + dir * lobe.reach * 0.3,
        lobe.x + lobe.width * 0.5,
        base,
      );
    }
    path
      ..lineTo(size.x, base)
      ..close();
    canvas.drawPath(path, _fillPaint);
    canvas.drawPath(path, _outlinePaint);
    // Faceted shading marks.
    for (final lobe in _lobes) {
      canvas.drawCircle(Offset(lobe.x, base + dir * lobe.reach * 0.4), lobe.width * 0.12, _shadePaint);
    }
  }

  void _renderShipDebris(Canvas canvas) {
    _fillPaint.color = color;
    _shadePaint.color = _shadeColor;
    final base = _baseY();
    final dir = _dir();
    // Angled planks.
    for (int i = 0; i < _lobes.length; i++) {
      final lobe = _lobes[i];
      final tiltX = (i.isEven ? -1 : 1) * lobe.width * 0.22;
      final plank = Path()
        ..moveTo(lobe.x - lobe.width * 0.22, base)
        ..lineTo(lobe.x + lobe.width * 0.22, base)
        ..lineTo(lobe.x + tiltX + lobe.width * 0.12, base + dir * lobe.reach)
        ..lineTo(lobe.x + tiltX - lobe.width * 0.12, base + dir * lobe.reach)
        ..close();
      canvas.drawPath(plank, _fillPaint);
      canvas.drawPath(plank, _outlinePaint);
      // Plank grain lines.
      final grain = Path()
        ..moveTo(lobe.x - lobe.width * 0.08, base + dir * lobe.reach * 0.15)
        ..lineTo(lobe.x + tiltX * 0.5 - lobe.width * 0.02, base + dir * lobe.reach * 0.85);
      canvas.drawPath(grain, _shadePaint..style = PaintingStyle.stroke..strokeWidth = 2);
      _shadePaint.style = PaintingStyle.fill;
      // Bolt.
      canvas.drawCircle(Offset(lobe.x, base + dir * lobe.reach * 0.3), 3, _boltPaint);
    }
  }
}

class _Lobe {
  final double x;
  final double width;
  final double reach;
  const _Lobe(this.x, this.width, this.reach);
}
