import 'dart:async';
import 'dart:ui';

import 'package:flame/game.dart';

import '../components/background/parallax_background.dart';
import '../components/effects/particle_effects.dart';
import '../components/effects/screen_shake.dart';
import '../components/player/player_fish.dart';
import '../config/game_config.dart';
import '../config/powerup_config.dart';
import '../config/score_config.dart';
import '../managers/ad_service.dart';
import '../managers/audio_manager.dart';
import '../managers/collectible_manager.dart';
import '../managers/difficulty_manager.dart';
import '../managers/environment_manager.dart';
import '../managers/haptics_manager.dart';
import '../managers/obstacle_manager.dart';
import '../managers/power_up_manager.dart';
import '../managers/score_manager.dart';
import '../managers/settings_manager.dart';
import '../managers/shop_manager.dart';
import '../models/fish_skin.dart';
import '../models/power_up_type.dart';
import 'game_state.dart';

/// The main game (§41/§43). Owns the state machine, wires the sub-managers
/// together, and is the single source of truth every component reads via
/// `HasGameReference` (`isSimulating`, `effectiveWorldSpeed`,
/// `playableTop`/`playableBottom`). Deliberately does not use Flame's
/// world/camera split (§28 keeps things simple per §56) - every gameplay
/// component is added directly to the game tree, so canvas coordinates are
/// always plain top-left logical pixels matching [size].
class OceanEscapeGame extends FlameGame with HasCollisionDetection {
  OceanEscapeGame({
    required this.settingsManager,
    required this.scoreManager,
    required this.audioManager,
    required this.hapticsManager,
    required this.adService,
    required this.shopManager,
  }) : fishSkin = shopManager.selectedFish;

  final SettingsManager settingsManager;
  final ScoreManager scoreManager;
  final AudioManager audioManager;
  final HapticsManager hapticsManager;
  final AdService adService;
  final ShopManager shopManager;
  final FishSkin fishSkin;

  /// Revives allowed per run (each one costs an ad).
  static const int maxRevives = 3;
  int revivesUsed = 0;

  /// True between game-over and the moment the run is committed (gold
  /// banked). While pending the player may still revive or double gold.
  bool _runPending = false;
  bool get runPending => _runPending;
  bool get canRevive =>
      _runPending && revivesUsed < maxRevives && stateNotifier.state == GameState.gameOver;

  final GameStateNotifier stateNotifier = GameStateNotifier();
  final DifficultyManager difficulty = DifficultyManager();
  final EnvironmentManager environment = EnvironmentManager();
  final Map<PowerUpType, double> activePowerUpTimers = {};

  late final PlayerFish player;
  late final ParallaxBackground background;
  late final ObstacleManager obstacleManager;
  late final CollectibleManager collectibleManager;
  late final PowerUpManager powerUpManager;

  final ScreenShake _screenShake = ScreenShake();
  Vector2 _shakeOffset = Vector2.zero();

  double playableTop = 0;
  double playableBottom = 1000;

  int? countdownNumber; // 3, 2, 1, 0 ("GO"), null when not counting down.
  double _countdownStepTimer = 0;
  static const double _countdownStepDuration = 0.7;
  double _crashTimer = 0;

  bool get isSimulating => stateNotifier.state == GameState.playing;

  double get effectiveWorldSpeed => difficulty.worldSpeed * environment.obstacleSpeedMultiplier;

  bool get magnetActive => (activePowerUpTimers[PowerUpType.magnet] ?? 0) > 0;

  double get collectibleScoreMultiplier {
    double multiplier = 1.0;
    if ((activePowerUpTimers[PowerUpType.speedBoost] ?? 0) > 0) {
      multiplier *= ScoreConfig.speedBoostScoreMultiplier;
    }
    if ((activePowerUpTimers[PowerUpType.pearlMultiplier] ?? 0) > 0) {
      multiplier *= ScoreConfig.pearlPowerUpMultiplier;
    }
    return multiplier;
  }

  @override
  Future<void> onLoad() async {
    // Fire-and-forget: some devices (notably certain emulators) can stall
    // on audio-engine setup. Gameplay must never block on that - sounds
    // just silently no-op via AudioManager's `_pools`/cache checks until
    // preload actually finishes.
    unawaited(audioManager.preload());

    background = ParallaxBackground(
      backgroundLayerCount: settingsManager.backgroundLayerCount,
      particleBudget: settingsManager.particleBudget,
    );
    await add(background);

    obstacleManager = ObstacleManager();
    collectibleManager = CollectibleManager();
    powerUpManager = PowerUpManager();
    await addAll([obstacleManager, collectibleManager, powerUpManager]);

    scoreManager.goldBonus = fishSkin.goldBonus;
    player = PlayerFish(painter: fishSkin.createPainter());
    await add(player);

    _recomputeBounds();
    _placePlayerAtStart();
    background.setEnvironmentBlend(environment.currentPalette, environment.nextPalette, environment.blend);
    _loaded = true;

    _beginReadyCountdown();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _recomputeBounds();
    // GameWidget calls onGameResize once before onLoad() runs (to size the
    // canvas ahead of loading), so `player` may not be assigned yet - guard
    // with `_loaded` rather than touching the late field directly.
    if (_loaded) {
      player.topBound = playableTop + GameConfig.fishRadius;
      player.bottomBound = playableBottom - GameConfig.fishRadius;
    }
  }

  bool _loaded = false;

  void _recomputeBounds() {
    final h = size.y;
    playableTop = h * GameConfig.topMarginFraction;
    playableBottom = h - h * GameConfig.bottomMarginFraction;
    if (playableBottom <= playableTop) {
      playableBottom = playableTop + 1;
    }
  }

  void _placePlayerAtStart() {
    final x = size.x * GameConfig.fishScreenXFraction;
    final y = (playableTop + playableBottom) / 2;
    player.topBound = playableTop + GameConfig.fishRadius;
    player.bottomBound = playableBottom - GameConfig.fishRadius;
    player.resetTo(Vector2(x, y));
    player.controlsEnabled = false;
  }

  // --- Input (§7) ---
  //
  // Handled from the Flutter side (GameScreen wraps GameWidget in a
  // Listener + KeyboardListener) rather than Flame's game-level gesture
  // mixins, so tap/space just flow into this one setter.

  void setHolding(bool value) {
    player.isHolding = value && stateNotifier.state == GameState.playing;
  }

  // --- State machine (§42/§50/§51) ---

  void _beginReadyCountdown() {
    stateNotifier.set(GameState.ready);
    player.controlsEnabled = false;
    countdownNumber = 3;
    _countdownStepTimer = _countdownStepDuration;
    audioManager.countdownTick();
  }

  void pauseGame() {
    if (stateNotifier.state != GameState.playing) return;
    player.isHolding = false;
    stateNotifier.set(GameState.paused);
    audioManager.pauseMusic();
    pauseEngine();
  }

  void resumeGame() {
    if (stateNotifier.state != GameState.paused) return;
    resumeEngine();
    stateNotifier.set(GameState.playing);
    audioManager.resumeMusic();
  }

  void restartGame() {
    unawaited(endRun());
    revivesUsed = 0;
    stateNotifier.set(GameState.restarting);
    obstacleManager.reset();
    collectibleManager.reset();
    powerUpManager.reset();
    difficulty.reset();
    environment.reset();
    activePowerUpTimers.clear();
    scoreManager.reset();
    _crashTimer = 0;
    _shakeOffset = Vector2.zero();
    background.setEnvironmentBlend(environment.currentPalette, environment.nextPalette, environment.blend);
    _placePlayerAtStart();
    player.hasShield = false;
    _beginReadyCountdown();
  }

  void handlePlayerCrash() {
    if (stateNotifier.state != GameState.playing) return;
    if (player.hasShield) {
      player.hasShield = false;
      activePowerUpTimers.remove(PowerUpType.shield);
      player.triggerHurtFlash();
      hapticsManager.light();
      spawnParticleBurst(
        position: player.position.clone(),
        count: 10,
        colors: const [Color(0xFF6FE0FF), Color(0xFFFFFFFF)],
        speed: 110,
      );
      return;
    }
    _crash();
  }

  void _crash() {
    stateNotifier.set(GameState.crashed);
    player.triggerDeath();
    audioManager.crash();
    hapticsManager.heavy();
    _screenShake.trigger();
    spawnParticleBurst(
      position: player.position.clone(),
      count: 22,
      colors: const [Color(0xFFFFFFFF), Color(0xFFCFF3FF), Color(0xFFFF6F6F)],
      speed: 170,
      gravity: 60,
    );
    audioManager.stopMusic();
    _crashTimer = 1.2;
  }

  Future<void> _completeGameOver() async {
    _runPending = true;
    stateNotifier.set(GameState.gameOver);
    audioManager.gameOver();
    await scoreManager.finalizeRound();
  }

  /// Continues the current run after a game-over: score, distance, gold and
  /// zone are kept, on-screen hazards are cleared and the fish gets a short
  /// shield, then the 3-2-1 countdown plays again.
  void revive() {
    if (!canRevive) return;
    revivesUsed++;
    _runPending = false;
    stateNotifier.set(GameState.restarting);
    obstacleManager.reset();
    activePowerUpTimers.clear();
    _crashTimer = 0;
    _shakeOffset = Vector2.zero();
    _placePlayerAtStart();
    player.hasShield = true;
    activePowerUpTimers[PowerUpType.shield] = PowerUpConfig.durationSeconds[PowerUpType.shield]!;
    _beginReadyCountdown();
  }

  /// Banks the run's gold (optionally doubled) and lifetime totals. Runs at
  /// most once per run; returns the gold added (0 if already committed).
  Future<int> endRun({bool doubled = false}) async {
    if (!_runPending) return 0;
    _runPending = false;
    // Snapshot synchronously: restartGame() resets the score right after.
    final gold = scoreManager.goldEarned * (doubled ? 2 : 1);
    final pearls = scoreManager.pearlsCollected;
    await shopManager.addGold(gold);
    await scoreManager.commitRunTotals(pearls: pearls);
    return gold;
  }

  void onPowerUpCollected(PowerUpType kind, Vector2 position) {
    activePowerUpTimers[kind] = PowerUpConfig.durationSeconds[kind]!;
    player.triggerPowerUpActivate();
    hapticsManager.medium();
    spawnParticleBurst(
      position: position,
      count: 16,
      colors: const [Color(0xFFFFFFFF), Color(0xFFFFE082)],
      speed: 140,
    );
    switch (kind) {
      case PowerUpType.shield:
        player.hasShield = true;
        audioManager.shieldActivate();
        break;
      case PowerUpType.magnet:
        audioManager.magnetActivate();
        break;
      case PowerUpType.speedBoost:
        audioManager.speedBoostActivate();
        break;
      case PowerUpType.slowMotion:
        audioManager.slowMotionActivate();
        break;
      case PowerUpType.pearlMultiplier:
        audioManager.pearlMultiplierActivate();
        break;
    }
  }

  void spawnParticleBurst({
    required Vector2 position,
    required int count,
    required List<Color> colors,
    double speed = 120,
    double gravity = 0,
    (double, double) radiusRange = const (2.0, 5.0),
    (double, double) lifeRange = const (0.4, 0.9),
  }) {
    add(ParticleBurst(
      position: position,
      count: count,
      colors: colors,
      speed: speed,
      gravity: gravity,
      radiusRange: radiusRange,
      lifeRange: lifeRange,
    ));
  }

  // --- Per-frame simulation ---

  @override
  void update(double dt) {
    super.update(dt);

    switch (stateNotifier.state) {
      case GameState.ready:
        _updateCountdown(dt);
        break;
      case GameState.playing:
        _updatePlaying(dt);
        break;
      case GameState.crashed:
        _crashTimer -= dt;
        if (_crashTimer <= 0) {
          unawaited(_completeGameOver());
        }
        break;
      case GameState.loading:
      case GameState.paused:
      case GameState.gameOver:
      case GameState.restarting:
        break;
    }

    _shakeOffset = _screenShake.update(dt);
  }

  void _updateCountdown(double dt) {
    if (countdownNumber == null) return;
    _countdownStepTimer -= dt;
    if (_countdownStepTimer > 0) return;
    if (countdownNumber! > 1) {
      countdownNumber = countdownNumber! - 1;
      _countdownStepTimer = _countdownStepDuration;
      audioManager.countdownTick();
    } else if (countdownNumber == 1) {
      countdownNumber = 0;
      _countdownStepTimer = _countdownStepDuration;
      audioManager.countdownGo();
    } else {
      countdownNumber = null;
      player.controlsEnabled = true;
      stateNotifier.set(GameState.playing);
      audioManager.gameStart();
      audioManager.playMusicFor(environment.current);
    }
  }

  void _updatePlaying(double dt) {
    difficulty.update(dt);
    environment.update(scoreManager.distanceMeters);
    background.setEnvironmentBlend(environment.currentPalette, environment.nextPalette, environment.blend);
    background.updateWorld(effectiveWorldSpeed, dt);
    scoreManager.addDistance(effectiveWorldSpeed * dt / GameConfig.pixelsPerMeter);
    _updatePowerUpTimers(dt);
  }

  void _updatePowerUpTimers(double dt) {
    if (activePowerUpTimers.isEmpty) {
      difficulty.speedMultiplier = 1.0;
      return;
    }
    final expiredShield = <PowerUpType>[];
    activePowerUpTimers.updateAll((key, value) => value - dt);
    activePowerUpTimers.removeWhere((key, value) {
      final expired = value <= 0;
      if (expired && key == PowerUpType.shield) expiredShield.add(key);
      return expired;
    });
    if (expiredShield.isNotEmpty) player.hasShield = false;

    double speedMult = 1.0;
    if ((activePowerUpTimers[PowerUpType.speedBoost] ?? 0) > 0) {
      speedMult *= PowerUpConfig.speedBoostWorldSpeedFactor;
    }
    if ((activePowerUpTimers[PowerUpType.slowMotion] ?? 0) > 0) {
      speedMult *= PowerUpConfig.slowMotionWorldSpeedFactor;
    }
    difficulty.speedMultiplier = speedMult;
  }

  @override
  void render(Canvas canvas) {
    if (_shakeOffset.x == 0 && _shakeOffset.y == 0) {
      super.render(canvas);
      return;
    }
    canvas.save();
    canvas.translate(_shakeOffset.x, _shakeOffset.y);
    super.render(canvas);
    canvas.restore();
  }
}
