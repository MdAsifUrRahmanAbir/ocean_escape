import 'managers/ad_service.dart';
import 'managers/audio_manager.dart';
import 'managers/haptics_manager.dart';
import 'managers/score_manager.dart';
import 'managers/settings_manager.dart';
import 'managers/storage_service.dart';

/// Bundles the app-lifetime services (§41) so screens only need to thread a
/// single object through navigation instead of five separate constructor
/// params. Created once in `main.dart` and shared for the whole app session.
class AppServices {
  AppServices({
    required this.storage,
    required this.settings,
    required this.score,
    required this.audio,
    required this.haptics,
    required this.ads,
  });

  final StorageService storage;
  final SettingsManager settings;
  final ScoreManager score;
  final AudioManager audio;
  final HapticsManager haptics;
  final AdService ads;

  static Future<AppServices> bootstrap() async {
    final storage = await StorageService.getInstance();
    final settings = SettingsManager(storage);
    final score = ScoreManager(storage);
    await score.load();
    final audio = AudioManager(settings);
    final haptics = HapticsManager(settings);
    final ads = AdService();
    return AppServices(
      storage: storage,
      settings: settings,
      score: score,
      audio: audio,
      haptics: haptics,
      ads: ads,
    );
  }
}
