/// Global, tunable constants for player physics, world layout and rendering.
/// Nothing here should be hardcoded elsewhere in the game.
class GameConfig {
  GameConfig._();

  /// Reference design resolution used only for scaling UI text/icons; the
  /// actual play area always fills the device viewport (§3 - no hardcoded res).
  static const double designWidth = 800;
  static const double designHeight = 450;

  /// Horizontal fraction of the screen where the fish is kept (§3).
  static const double fishScreenXFraction = 0.25;

  /// Fish visual radius in logical pixels (hitbox is slightly smaller, §28).
  static const double fishRadius = 26;
  static const double fishHitboxRadiusFactor = 0.78;

  /// Vertical playable band, as a fraction of screen height reserved for
  /// decorative top/bottom strips (coral/sand) that the fish is clamped
  /// away from (§8/§24).
  static const double topMarginFraction = 0.08;
  static const double bottomMarginFraction = 0.10;

  // --- Player physics (§6) ---
  static const double gravity = 900; // px/s^2 pulling the fish down
  static const double swimThrust = 2000; // px/s^2 applied while holding
  static const double maxFallSpeed = 420; // px/s
  static const double maxUpSpeed = 420; // px/s
  static const double maxTiltRadians = 0.45; // clamp rotation so it stays cute, not silly

  // --- Meters/score distance conversion ---
  /// How many world pixels of scroll equal one "meter" for distance/score/env thresholds.
  static const double pixelsPerMeter = 22;
}
