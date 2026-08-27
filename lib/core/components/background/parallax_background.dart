import 'dart:ui';

import 'package:flame/components.dart';

import '../../config/environment_config.dart';
import '../../models/environment_type.dart';
import 'background_layer.dart';

/// Composes the full layered underwater backdrop (§16/§22/§23): a sky
/// gradient, several tiled parallax terrain/light layers, and an ambient
/// bubble layer. [EnvironmentManager] drives [setEnvironmentBlend] to
/// smoothly cross-fade colors as the world scrolls between zones (§21).
class ParallaxBackground extends PositionComponent {
  // Not `this._particleBudget`: that would leak the private field name into the public named-parameter API.
  ParallaxBackground({required this.backgroundLayerCount, required int particleBudget})
      // ignore: prefer_initializing_formals
      : _particleBudget = particleBudget,
        super(priority: -100);

  int backgroundLayerCount;
  final int _particleBudget;

  late final FarAmbientBlobLayer _farBlobs;
  late final TerrainBumpLayer _topMid;
  late final TerrainBumpLayer _bottomMid;
  late final TerrainBumpLayer _topNear;
  late final TerrainBumpLayer _bottomNear;
  late final LightRayLayer _rays;
  late final AmbientParticleLayer _particles;
  late final List<PositionComponent> _orderedOptionalLayers;

  EnvironmentPalette _current = EnvironmentConfig.palettes[EnvironmentType.coralReef]!;
  EnvironmentPalette _next = EnvironmentConfig.palettes[EnvironmentType.coralReef]!;
  double _blend = 0;

  final Paint _skyPaint = Paint();
  final Paint _darknessPaint = Paint();

  @override
  Future<void> onLoad() async {
    _topMid = TerrainBumpLayer(
      speedFactor: 0.3,
      fromTop: true,
      bandFraction: 0.09,
      bumpCount: 6,
      bumpHeightRange: (14, 34),
      seed: 2,
      opacity: 0.85,
    );
    _bottomMid = TerrainBumpLayer(
      speedFactor: 0.3,
      fromTop: false,
      bandFraction: 0.11,
      bumpCount: 6,
      bumpHeightRange: (16, 38),
      seed: 4,
      opacity: 0.85,
    );
    _topNear = TerrainBumpLayer(
      speedFactor: 0.55,
      fromTop: true,
      bandFraction: 0.09,
      bumpCount: 5,
      bumpHeightRange: (18, 44),
      seed: 6,
    );
    _bottomNear = TerrainBumpLayer(
      speedFactor: 0.55,
      fromTop: false,
      bandFraction: 0.11,
      bumpCount: 5,
      bumpHeightRange: (20, 48),
      seed: 8,
    );
    _rays = LightRayLayer(speedFactor: 0.15, seed: 9);
    _farBlobs = FarAmbientBlobLayer(speedFactor: 0.05, seed: 21);

    // Ordered cheapest/most-important first so lower quality tiers still
    // read as a layered scene (§22) while skipping the priciest layers (§44).
    _orderedOptionalLayers = [_topMid, _bottomMid, _topNear, _bottomNear, _rays, _farBlobs];
    final activeCount = backgroundLayerCount.clamp(1, _orderedOptionalLayers.length);
    await addAll(_orderedOptionalLayers.take(activeCount));

    _particles = AmbientParticleLayer(maxParticles: _particleBudget, seed: 13, priority: 10);
    await add(_particles);

    _syncChildSizes();
    _applyPalette();
  }

  void _syncChildSizes() {
    for (final child in children.whereType<PositionComponent>()) {
      child.size = size;
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _syncChildSizes();
  }

  void setEnvironmentBlend(EnvironmentPalette current, EnvironmentPalette next, double blend) {
    _current = current;
    _next = next;
    _blend = blend.clamp(0.0, 1.0);
    _applyPalette();
  }

  void _applyPalette() {
    Color mix(Color a, Color b) => Color.lerp(a, b, _blend)!;
    for (final layer in _orderedOptionalLayers) {
      if (layer == _topMid) {
        (layer as TerrainBumpLayer).color = mix(_current.midLayerColor, _next.midLayerColor);
      } else if (layer == _bottomMid) {
        (layer as TerrainBumpLayer).color = mix(_current.sandColor, _next.sandColor);
      } else if (layer == _topNear) {
        (layer as TerrainBumpLayer).color = mix(_current.nearLayerColor, _next.nearLayerColor);
      } else if (layer == _bottomNear) {
        (layer as TerrainBumpLayer).color =
            mix(_current.coralAccents.first, _next.coralAccents.first);
      } else if (layer == _rays) {
        (layer as LightRayLayer).color = mix(_current.lightColor, _next.lightColor);
      } else if (layer == _farBlobs) {
        (layer as FarAmbientBlobLayer).color = mix(_current.farLayerColor, _next.farLayerColor);
      }
    }
    _particles.color = mix(_current.particleColor, _next.particleColor);
  }

  void updateWorld(double worldSpeed, double dt) {
    for (final layer in _orderedOptionalLayers) {
      if (layer is TerrainBumpLayer) layer.advance(worldSpeed, dt);
      if (layer is LightRayLayer) layer.advance(worldSpeed, dt);
      if (layer is FarAmbientBlobLayer) layer.advance(worldSpeed, dt);
    }
    _particles.advance(worldSpeed, dt);
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final topColor = Color.lerp(_current.skyTop, _next.skyTop, _blend)!;
    final bottomColor = Color.lerp(_current.skyBottom, _next.skyBottom, _blend)!;
    _skyPaint.shader = Gradient.linear(const Offset(0, 0), Offset(0, size.y), [topColor, bottomColor]);
    canvas.drawRect(rect, _skyPaint);

    final darkness = _current.ambientDarkness + (_next.ambientDarkness - _current.ambientDarkness) * _blend;
    if (darkness > 0.001) {
      _darknessPaint.color = Color.fromRGBO(0, 0, 0, darkness * 0.35);
      canvas.drawRect(rect, _darknessPaint);
    }
  }
}
