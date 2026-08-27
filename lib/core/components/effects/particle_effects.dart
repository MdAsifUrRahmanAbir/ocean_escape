import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

class _Particle {
  Offset pos;
  Offset vel;
  double life;
  final double maxLife;
  final double radius;
  final Color color;
  _Particle(this.pos, this.vel, this.life, this.radius, this.color) : maxLife = life;
}

/// A short-lived, self-removing burst of circular particles - used for
/// bubble-collect sparkle, pearl shine, mine explosions and the crash burst
/// (§11/§13/§29/§48). Particle count is fixed at creation (§44 - no
/// unbounded/per-frame allocation).
class ParticleBurst extends PositionComponent {
  ParticleBurst({
    required Vector2 position,
    required this.count,
    required this.colors,
    this.speed = 120,
    this.gravity = 0,
    this.radiusRange = const (2.0, 5.0),
    this.lifeRange = const (0.4, 0.9),
  }) : super(position: position, priority: 20);

  final int count;
  final List<Color> colors;
  final double speed;
  final double gravity;
  final (double, double) radiusRange;
  final (double, double) lifeRange;

  final List<_Particle> _particles = [];
  final Paint _paint = Paint();
  final Random _rng = Random();

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < count; i++) {
      final angle = _rng.nextDouble() * pi * 2;
      final spd = speed * (0.5 + _rng.nextDouble());
      final vel = Offset(cos(angle), sin(angle)) * spd;
      final life = lifeRange.$1 + _rng.nextDouble() * (lifeRange.$2 - lifeRange.$1);
      final radius = radiusRange.$1 + _rng.nextDouble() * (radiusRange.$2 - radiusRange.$1);
      final color = colors[_rng.nextInt(colors.length)];
      _particles.add(_Particle(Offset.zero, vel, life, radius, color));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    bool anyAlive = false;
    for (final p in _particles) {
      if (p.life <= 0) continue;
      p.life -= dt;
      p.vel += Offset(0, gravity) * dt;
      p.pos += p.vel * dt;
      if (p.life > 0) anyAlive = true;
    }
    if (!anyAlive) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    for (final p in _particles) {
      if (p.life <= 0) continue;
      final t = (p.life / p.maxLife).clamp(0.0, 1.0);
      _paint.color = p.color.withValues(alpha: p.color.a * t);
      canvas.drawCircle(p.pos, p.radius * (0.6 + 0.4 * t), _paint);
    }
  }
}
