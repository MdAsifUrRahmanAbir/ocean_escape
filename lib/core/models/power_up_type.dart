/// The five collectible power-ups (§15).
enum PowerUpType { shield, magnet, speedBoost, slowMotion, pearlMultiplier }

extension PowerUpTypeX on PowerUpType {
  String get displayName {
    switch (this) {
      case PowerUpType.shield:
        return 'Shield';
      case PowerUpType.magnet:
        return 'Magnet';
      case PowerUpType.speedBoost:
        return 'Speed Boost';
      case PowerUpType.slowMotion:
        return 'Slow Motion';
      case PowerUpType.pearlMultiplier:
        return 'Pearl Multiplier';
    }
  }
}
