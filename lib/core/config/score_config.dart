/// Score values and rules (§30).
class ScoreConfig {
  ScoreConfig._();

  static const double metersPerDistanceScoreTick = 100;
  static const int distanceScorePerTick = 10;

  static const int bubbleScore = 1;
  static const int pearlScore = 10;

  static const double speedBoostScoreMultiplier = 2.0;
  static const double pearlPowerUpMultiplier = 3.0;

  // Gold earned per run (spent in the fish shop).
  static const int goldPerBubble = 1;
  static const int goldPerPearl = 5;
  static const double metersPerGold = 25;
}
