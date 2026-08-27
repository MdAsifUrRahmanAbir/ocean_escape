import 'dart:math';
import 'dart:ui';

enum CollectibleKind { bubble, pearl }

/// Named collectible layouts (§14). Each returns a list of offsets (in
/// world pixels) relative to a pattern origin point; the manager places the
/// origin and picks bubble/pearl per point.
enum CollectiblePatternType { straightLine, verticalLine, diagonalLine, wave, arc, stair }

class CollectiblePatterns {
  CollectiblePatterns._();

  static List<Offset> generate(
    CollectiblePatternType type, {
    int count = 5,
    double spacing = 46,
    Random? rng,
  }) {
    final points = <Offset>[];
    switch (type) {
      case CollectiblePatternType.straightLine:
        for (int i = 0; i < count; i++) {
          points.add(Offset(i * spacing, 0));
        }
        break;
      case CollectiblePatternType.verticalLine:
        for (int i = 0; i < count; i++) {
          points.add(Offset(0, i * spacing * 0.6));
        }
        break;
      case CollectiblePatternType.diagonalLine:
        for (int i = 0; i < count; i++) {
          points.add(Offset(i * spacing, i * spacing * 0.55));
        }
        break;
      case CollectiblePatternType.wave:
        for (int i = 0; i < count; i++) {
          final x = i * spacing;
          final y = sin(i / (count - 1) * pi * 2) * spacing * 1.3;
          points.add(Offset(x, y));
        }
        break;
      case CollectiblePatternType.arc:
        for (int i = 0; i < count; i++) {
          final t = i / (count - 1);
          final x = i * spacing;
          final y = -sin(t * pi) * spacing * 2.0;
          points.add(Offset(x, y));
        }
        break;
      case CollectiblePatternType.stair:
        for (int i = 0; i < count; i++) {
          points.add(Offset(i * spacing, (i ~/ 1) * spacing * 0.5));
        }
        break;
    }
    return points;
  }
}
