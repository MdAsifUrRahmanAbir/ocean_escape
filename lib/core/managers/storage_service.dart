import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] (§31/§46). All game persistence
/// goes through here so the rest of the codebase never touches prefs keys.
class StorageService {
  StorageService._(this._prefs);
  final SharedPreferences _prefs;

  static StorageService? _instance;

  static Future<StorageService> getInstance() async {
    final existing = _instance;
    if (existing != null) return existing;
    final prefs = await SharedPreferences.getInstance();
    final created = StorageService._(prefs);
    _instance = created;
    return created;
  }

  static const _kHighScore = 'high_score';
  static const _kBestDistance = 'best_distance';
  static const _kTotalPearls = 'total_pearls';
  static const _kTotalGames = 'total_games';
  static const _kMusicOn = 'music_on';
  static const _kSoundOn = 'sound_on';
  static const _kVibrationOn = 'vibration_on';
  static const _kQuality = 'quality';
  static const _kUnlockedEnvIndex = 'unlocked_env_index';

  int get highScore => _prefs.getInt(_kHighScore) ?? 0;
  Future<void> setHighScore(int v) => _prefs.setInt(_kHighScore, v);

  double get bestDistanceMeters => _prefs.getDouble(_kBestDistance) ?? 0;
  Future<void> setBestDistanceMeters(double v) => _prefs.setDouble(_kBestDistance, v);

  int get totalPearls => _prefs.getInt(_kTotalPearls) ?? 0;
  Future<void> setTotalPearls(int v) => _prefs.setInt(_kTotalPearls, v);

  int get totalGames => _prefs.getInt(_kTotalGames) ?? 0;
  Future<void> setTotalGames(int v) => _prefs.setInt(_kTotalGames, v);

  bool get musicOn => _prefs.getBool(_kMusicOn) ?? true;
  Future<void> setMusicOn(bool v) => _prefs.setBool(_kMusicOn, v);

  bool get soundOn => _prefs.getBool(_kSoundOn) ?? true;
  Future<void> setSoundOn(bool v) => _prefs.setBool(_kSoundOn, v);

  bool get vibrationOn => _prefs.getBool(_kVibrationOn) ?? true;
  Future<void> setVibrationOn(bool v) => _prefs.setBool(_kVibrationOn, v);

  /// 'low' | 'medium' | 'high'.
  String get quality => _prefs.getString(_kQuality) ?? 'medium';
  Future<void> setQuality(String v) => _prefs.setString(_kQuality, v);

  /// Highest environment index (0-3) unlocked by best distance so far.
  int get unlockedEnvIndex => _prefs.getInt(_kUnlockedEnvIndex) ?? 0;
  Future<void> setUnlockedEnvIndex(int v) => _prefs.setInt(_kUnlockedEnvIndex, v);

  Future<void> resetProgress() async {
    await _prefs.remove(_kHighScore);
    await _prefs.remove(_kBestDistance);
    await _prefs.remove(_kTotalPearls);
    await _prefs.remove(_kTotalGames);
    await _prefs.remove(_kUnlockedEnvIndex);
  }
}
