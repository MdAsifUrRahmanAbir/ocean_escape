import 'dart:ui';

/// The obstacle categories from spec §9-§12.
enum ObstacleKind { shark, seaMine, coral, rock, shipDebris }

/// Movement behaviors a shark (or other moving obstacle) can use (§10).
enum MoverBehavior { staticHover, horizontalPatrol, verticalPatrol, fastDart, slowDrift }

/// Which edge of the playable band a coral/rock/debris obstacle grows from.
enum VerticalSlot { top, bottom }

/// A single obstacle to spawn: its kind, vertical placement and any behavior
/// tuning. `gapCenterFraction`/`gapHeight` describe the safe passage the
/// spawner guarantees around this obstacle set (§9/§26/§57).
class ObstacleSpawnSpec {
  final ObstacleKind kind;
  final VerticalSlot? slot; // null for free-floating obstacles like sharks/mines
  final MoverBehavior behavior;
  final double speedFactor; // relative to world speed, for movers
  final Color colorSeed;

  const ObstacleSpawnSpec({
    required this.kind,
    this.slot,
    this.behavior = MoverBehavior.staticHover,
    this.speedFactor = 1.0,
    this.colorSeed = const Color(0xFFFFFFFF),
  });
}

/// A named group of [ObstacleSpawnSpec]s spawned together at one world-x
/// position, sharing a single guaranteed gap (§27's `ObstaclePattern`).
class ObstaclePattern {
  final String name;
  final List<ObstacleSpawnSpec> specs;
  final double weight;

  const ObstaclePattern({required this.name, required this.specs, this.weight = 1.0});
}
