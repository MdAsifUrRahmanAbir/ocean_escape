import 'dart:math';

import 'package:flame/components.dart';

import '../components/collectibles/bubble_collectible.dart';
import '../components/collectibles/pearl_collectible.dart';
import '../config/difficulty_config.dart';
import '../config/spawn_config.dart';
import '../game/ocean_escape_game.dart';
import '../models/collectible_pattern.dart';
import '../utils/random_utils.dart';

/// Spawns bubbles/pearls in predefined patterns rather than fully at random
/// (§13/§14/§27). A fraction of patterns are pushed toward the top/bottom
/// edges of the playable band as a risk/reward line the player must detour
/// for (§14).
class CollectibleManager extends Component with HasGameReference<OceanEscapeGame> {
  final Random _rng = Random();
  double _timer = 0;

  void reset() {
    removeAll(children.toList());
    _timer = DifficultyConfig.collectibleIntervalStart * 0.6;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isSimulating) return;
    _timer -= dt;
    if (_timer <= 0) {
      _spawnPattern();
      _timer = game.difficulty.collectibleInterval;
    }
  }

  void _spawnPattern() {
    final top = game.playableTop + 26;
    final bottom = game.playableBottom - 26;
    final band = bottom - top;
    if (band <= 0) return;

    double originYFraction;
    if (_rng.nextDouble() < SpawnConfig.riskRewardChance) {
      originYFraction = _rng.nextBool() ? 0.1 + _rng.nextDouble() * 0.12 : 0.78 + _rng.nextDouble() * 0.12;
    } else {
      originYFraction = 0.25 + _rng.nextDouble() * 0.5;
    }
    final originY = top + band * originYFraction;
    final originX = game.size.x + 60;

    final type = RandomUtils.weightedPick(SpawnConfig.collectiblePatternWeights, _rng);
    final count = 4 + _rng.nextInt(3);
    final points = CollectiblePatterns.generate(type, count: count, spacing: 44, rng: _rng);

    for (final p in points) {
      final y = (originY + p.dy).clamp(game.playableTop + 14, game.playableBottom - 14);
      final x = originX + p.dx;
      final isPearl = _rng.nextDouble() < SpawnConfig.pearlChance;
      add(isPearl ? PearlCollectible(position: Vector2(x, y)) : BubbleCollectible(position: Vector2(x, y)));
    }
  }
}
