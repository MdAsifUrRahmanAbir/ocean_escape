import 'dart:math';

/// Small helpers shared by the spawn managers.
class RandomUtils {
  RandomUtils._();

  /// Picks a key from a weight map, proportionally to its weight.
  static T weightedPick<T>(Map<T, double> weights, Random rng) {
    final total = weights.values.fold<double>(0, (a, b) => a + b);
    double roll = rng.nextDouble() * total;
    for (final entry in weights.entries) {
      roll -= entry.value;
      if (roll <= 0) return entry.key;
    }
    return weights.keys.last;
  }

  static double lerp(double a, double b, double t) => a + (b - a) * t;

  static double clamp(double v, double lo, double hi) => v < lo ? lo : (v > hi ? hi : v);
}
