import 'package:flutter/foundation.dart';

import '../config/score_config.dart';
import 'storage_service.dart';

/// Tracks the current round's score/distance/collectibles and persists
/// high-score/best-distance/totals at round end (§30/§31).
class ScoreManager extends ChangeNotifier {
  ScoreManager(this._storage);
  final StorageService _storage;

  int score = 0;
  double distanceMeters = 0;
  int bubblesCollected = 0;
  int pearlsCollected = 0;
  double _distanceScoreAccumulator = 0;

  int highScore = 0;
  double bestDistanceMeters = 0;

  Future<void> load() async {
    highScore = _storage.highScore;
    bestDistanceMeters = _storage.bestDistanceMeters;
    notifyListeners();
  }

  void reset() {
    score = 0;
    distanceMeters = 0;
    bubblesCollected = 0;
    pearlsCollected = 0;
    _distanceScoreAccumulator = 0;
    notifyListeners();
  }

  void addDistance(double deltaMeters) {
    if (deltaMeters <= 0) return;
    distanceMeters += deltaMeters;
    _distanceScoreAccumulator += deltaMeters;
    while (_distanceScoreAccumulator >= ScoreConfig.metersPerDistanceScoreTick) {
      _distanceScoreAccumulator -= ScoreConfig.metersPerDistanceScoreTick;
      score += ScoreConfig.distanceScorePerTick;
    }
    notifyListeners();
  }

  void collectBubble({double multiplier = 1.0}) {
    bubblesCollected++;
    score += (ScoreConfig.bubbleScore * multiplier).round();
    notifyListeners();
  }

  void collectPearl({double multiplier = 1.0}) {
    pearlsCollected++;
    score += (ScoreConfig.pearlScore * multiplier).round();
    notifyListeners();
  }

  /// Persists results at game-over; returns true if a new high score was set.
  Future<bool> finalizeRound() async {
    bool isNewHighScore = false;
    if (score > highScore) {
      highScore = score;
      await _storage.setHighScore(score);
      isNewHighScore = true;
    }
    if (distanceMeters > bestDistanceMeters) {
      bestDistanceMeters = distanceMeters;
      await _storage.setBestDistanceMeters(distanceMeters);
    }
    await _storage.setTotalPearls(_storage.totalPearls + pearlsCollected);
    await _storage.setTotalGames(_storage.totalGames + 1);
    notifyListeners();
    return isNewHighScore;
  }
}
