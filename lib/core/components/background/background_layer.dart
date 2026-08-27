import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// One decorative "bump" (coral/rock/sand clump silhouette) baked once at
/// layer-creation time so nothing is re-generated per frame (§44).
class _Bump {
  final double x; // position within the tile, in logical px
  final double width;
  final double height;
  const _Bump(this.x, this.width, this.height);
}

/// A single tiled, horizontally-scrolling decorative silhouette strip
/// (§22's parallax layers, §24's top/bottom decoration). Purely visual -
/// never a collision object.
class TerrainBumpLayer extends PositionComponent {
  TerrainBumpLayer({
    required this.speedFactor,
    required this.fromTop,
    required this.bandFraction,
    required this.bumpCount,
    required this.bumpHeightRange,
    int seed = 1,
    this.opacity = 1.0,
  }) : _rng = Random(seed);

  static const double tileWidth = 700;

  final double speedFactor;
  final bool fromTop; // true = grows down from the top edge, false = grows up from bottom
  final double bandFraction; // how deep the band is, as a fraction of viewport height
  final int bumpCount;
  final (double, double) bumpHeightRange;
  final double opacity;
  final Random _rng;

  Color color = const Color(0xFF2E9FC2);
  double _offsetX = 0;
  late List<_Bump> _bumps;
  final Paint _paint = Paint()..style = PaintingStyle.fill;

  @override
  Future<void> onLoad() async {
    _bumps = List.generate(bumpCount, (i) {
      final w = 60 + _rng.nextDouble() * 140;
      final h = bumpHeightRange.$1 + _rng.nextDouble() * (bumpHeightRange.$2 - bumpHeightRange.$1);
      final x = (tileWidth / bumpCount) * i + _rng.nextDouble() * 30;
      return _Bump(x, w, h);
    });
  }

  void advance(double worldSpeed, double dt) {
    _offsetX -= worldSpeed * speedFactor * dt;
    _offsetX = ((_offsetX % tileWidth) + tileWidth) % tileWidth;
  }

  @override
  void render(Canvas canvas) {
    final bandDepth = size.y * bandFraction;
    final baseline = fromTop ? 0.0 : size.y;
    final dir = fromTop ? 1.0 : -1.0;
    _paint.color = color.withValues(alpha: color.a * opacity);

    final tilesNeeded = (size.x / tileWidth).ceil() + 2;
    for (int t = -1; t < tilesNeeded; t++) {
      final tileX = _offsetX + t * tileWidth;
      for (final bump in _bumps) {
        final h = min(bump.height, bandDepth * 1.4);
        final cx = tileX + bump.x;
        if (cx < -bump.width || cx > size.x + bump.width) continue;
        final path = Path()
          ..moveTo(cx - bump.width / 2, baseline)
          ..quadraticBezierTo(cx, baseline + dir * h, cx + bump.width / 2, baseline)
          ..close();
        canvas.drawPath(path, _paint);
      }
    }
  }
}

/// A handful of large, very soft, slow-moving blobs for far-depth ambience
/// (§22 layer 1 - "far background, very slow movement").
class FarAmbientBlobLayer extends PositionComponent {
  FarAmbientBlobLayer({required this.speedFactor, this.opacity = 0.16, int seed = 7})
      : _rng = Random(seed);

  static const double tileWidth = 900;
  final double speedFactor;
  final double opacity;
  final Random _rng;

  Color color = const Color(0xFF3FB6D6);
  double _offsetX = 0;
  late List<_Bump> _blobs;
  final Paint _paint = Paint()..style = PaintingStyle.fill;

  @override
  Future<void> onLoad() async {
    _blobs = List.generate(4, (i) {
      final w = 220 + _rng.nextDouble() * 200;
      final x = (tileWidth / 4) * i + _rng.nextDouble() * 60;
      final h = 0.25 + _rng.nextDouble() * 0.5; // fraction of viewport height, resolved at render time
      return _Bump(x, w, h);
    });
  }

  void advance(double worldSpeed, double dt) {
    _offsetX -= worldSpeed * speedFactor * dt;
    _offsetX = ((_offsetX % tileWidth) + tileWidth) % tileWidth;
  }

  @override
  void render(Canvas canvas) {
    _paint.color = color.withValues(alpha: color.a * opacity);
    final tilesNeeded = (size.x / tileWidth).ceil() + 2;
    for (int t = -1; t < tilesNeeded; t++) {
      final tileX = _offsetX + t * tileWidth;
      for (final blob in _blobs) {
        final cx = tileX + blob.x;
        if (cx < -blob.width || cx > size.x + blob.width) continue;
        final cy = size.y * blob.height;
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: blob.width, height: blob.width * 0.6), _paint);
      }
    }
  }
}

/// A few soft, slow-scrolling light shafts (or ambient glow shafts in dark
/// zones) descending from above (§17's "sun rays", §23's "light rays").
class LightRayLayer extends PositionComponent {
  LightRayLayer({required this.speedFactor, this.opacity = 0.18, int seed = 3}) : _rng = Random(seed);

  static const double tileWidth = 500;
  final double speedFactor;
  final double opacity;
  final Random _rng;

  Color color = const Color(0xFFFFFDE0);
  double _offsetX = 0;
  late List<double> _rayX;
  late List<double> _rayWidth;
  final Paint _paint = Paint()..style = PaintingStyle.fill;

  @override
  Future<void> onLoad() async {
    _rayX = List.generate(2, (i) => (tileWidth / 2) * i + _rng.nextDouble() * 60);
    _rayWidth = List.generate(2, (i) => 50 + _rng.nextDouble() * 40);
  }

  void advance(double worldSpeed, double dt) {
    _offsetX -= worldSpeed * speedFactor * dt;
    _offsetX = ((_offsetX % tileWidth) + tileWidth) % tileWidth;
  }

  @override
  void render(Canvas canvas) {
    _paint.color = color.withValues(alpha: color.a * opacity);
    final tilesNeeded = (size.x / tileWidth).ceil() + 2;
    for (int t = -1; t < tilesNeeded; t++) {
      final tileX = _offsetX + t * tileWidth;
      for (int i = 0; i < _rayX.length; i++) {
        final cx = tileX + _rayX[i];
        final w = _rayWidth[i];
        if (cx < -w * 2 || cx > size.x + w * 2) continue;
        final path = Path()
          ..moveTo(cx - w * 0.3, 0)
          ..lineTo(cx + w * 0.3, 0)
          ..lineTo(cx + w, size.y)
          ..lineTo(cx - w, size.y)
          ..close();
        canvas.drawPath(path, _paint);
      }
    }
  }
}

class _AmbientParticle {
  double x;
  double y;
  double radius;
  double speed;
  double drift;
  _AmbientParticle(this.x, this.y, this.radius, this.speed, this.drift);
}

/// Small rising bubbles / drifting motes for underwater atmosphere (§23).
/// Count is capped by the caller via [maxParticles] (quality-scaled, §44).
class AmbientParticleLayer extends PositionComponent {
  AmbientParticleLayer({required this.maxParticles, int seed = 11, super.priority})
      : _rng = Random(seed);

  final int maxParticles;
  final Random _rng;
  final List<_AmbientParticle> _particles = [];
  Color color = const Color(0xFFEFFCFF);
  final Paint _paint = Paint()..style = PaintingStyle.fill;

  @override
  Future<void> onLoad() async {
    _respawnAll();
  }

  void _respawnAll() {
    _particles.clear();
    for (int i = 0; i < maxParticles; i++) {
      _particles.add(_spawnOne(randomY: true));
    }
  }

  _AmbientParticle _spawnOne({bool randomY = false}) {
    final r = 1.5 + _rng.nextDouble() * 3.5;
    final x = _rng.nextDouble() * (size.x > 0 ? size.x : 800);
    final y = randomY ? _rng.nextDouble() * (size.y > 0 ? size.y : 450) : (size.y > 0 ? size.y : 450) + r;
    final speed = 20 + _rng.nextDouble() * 40;
    final drift = -10 + _rng.nextDouble() * 20;
    return _AmbientParticle(x, y, r, speed, drift);
  }

  void advance(double worldSpeed, double dt) {
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      p.y -= p.speed * dt;
      p.x += (p.drift - worldSpeed * 0.05) * dt;
      if (p.y < -p.radius) {
        _particles[i] = _spawnOne();
      } else if (p.x < -20) {
        p.x = size.x + 20;
      } else if (p.x > size.x + 20) {
        p.x = -20;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    _paint.color = color;
    for (final p in _particles) {
      canvas.drawCircle(Offset(p.x, p.y), p.radius, _paint);
    }
  }
}
