import 'dart:math';

import 'package:flame/components.dart';

import '../components/powerups/power_up_pickup.dart';
import '../config/difficulty_config.dart';
import '../config/spawn_config.dart';
import '../game/ocean_escape_game.dart';
import '../utils/random_utils.dart';

/// Spawns power-up pickups on a slow timer (§15/§27) so they stay rare
/// enough to feel valuable; [DifficultyConfig.powerUpIntervalAt] is the
/// single rarity knob (`PowerUpConfig.spawnChanceWeight` is reserved for
/// finer-grained tuning later, same as the audio manager's music seam).
class PowerUpManager extends Component with HasGameReference<OceanEscapeGame> {
  final Random _rng = Random();
  double _timer = 0;

  void reset() {
    removeAll(children.toList());
    _timer = DifficultyConfig.powerUpIntervalStart * 0.5;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isSimulating) return;
    _timer -= dt;
    if (_timer <= 0) {
      _spawnOne();
      _timer = game.difficulty.powerUpInterval;
    }
  }

  void _spawnOne() {
    final type = RandomUtils.weightedPick(SpawnConfig.powerUpWeights, _rng);
    final top = game.playableTop + 34;
    final bottom = game.playableBottom - 34;
    if (bottom <= top) return;
    final y = top + _rng.nextDouble() * (bottom - top);
    final x = game.size.x + 60;
    add(PowerUpPickup(kind: type, position: Vector2(x, y)));
  }
}
