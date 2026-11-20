import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/game/ocean_escape_game.dart';
import 'primary_button.dart';

/// The 3-2-1-GO countdown shown before gameplay starts (§50). Polls
/// [OceanEscapeGame.countdownNumber] via its own ticker since it's a plain
/// field, not a notifier (mirrors [Hud]'s reasoning).
class CountdownOverlay extends StatefulWidget {
  const CountdownOverlay({super.key, required this.game});
  final OceanEscapeGame game;

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => setState(() {}))..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.game.countdownNumber;
    if (n == null) return const SizedBox.shrink();
    final label = n == 0 ? 'GO!' : '$n';
    return IgnorePointer(
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Text(
            label,
            key: ValueKey(label),
            style: TextStyle(
              fontSize: n == 0 ? 80 : 96,
              fontWeight: FontWeight.w900,
              color: n == 0 ? const Color(0xFF4CD97B) : Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pause menu (§35): RESUME / RESTART / HOME.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game, required this.onHome});
  final OceanEscapeGame game;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'RESUME',
              icon: Icons.play_arrow_rounded,
              color: const Color(0xFF4CD97B),
              width: 200,
              onPressed: () {
                game.audioManager.buttonClick();
                game.resumeGame();
              },
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'RESTART',
              icon: Icons.refresh_rounded,
              color: const Color(0xFF3FA9D6),
              width: 200,
              onPressed: () async {
                game.audioManager.buttonClick();
                await game.adService.onRunStarted();
                game.resumeEngine();
                game.restartGame();
              },
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'HOME',
              icon: Icons.home_rounded,
              color: const Color(0xFFE0554F),
              width: 200,
              onPressed: () {
                game.audioManager.buttonClick();
                game.resumeEngine();
                onHome();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a short message when an ad couldn't be shown (no fill / offline).
void showAdNotReady(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text('Ad not ready yet - check your connection and try again.'),
        duration: Duration(seconds: 2),
      ),
    );
}

/// Game-over panel (§34): final stats plus RETRY / HOME, an ad-powered
/// REVIVE (max [OceanEscapeGame.maxRevives] per run) and DOUBLE GOLD.
class GameOverOverlay extends StatefulWidget {
  const GameOverOverlay({super.key, required this.game, required this.onHome});
  final OceanEscapeGame game;
  final VoidCallback onHome;

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  bool _busy = false;
  int? _goldClaimed; // set once the run's gold has been banked x2

  OceanEscapeGame get game => widget.game;

  Future<void> _runAd(Future<void> Function() onRewarded) async {
    if (_busy) return;
    setState(() => _busy = true);
    game.audioManager.buttonClick();
    final shown = await game.adService.showInterstitial();
    if (!mounted) return;
    if (shown) {
      await onRewarded();
    } else {
      showAdNotReady(context);
    }
    if (mounted) setState(() => _busy = false);
  }

  void _revive() => _runAd(() async => game.revive());

  void _doubleGold() => _runAd(() async {
        final gold = await game.endRun(doubled: true);
        if (mounted) setState(() => _goldClaimed = gold);
      });

  Future<void> _retry() async {
    if (_busy) return;
    setState(() => _busy = true);
    game.audioManager.buttonClick();
    await game.adService.onRunStarted();
    if (!mounted) return;
    game.restartGame();
  }

  @override
  Widget build(BuildContext context) {
    final score = game.scoreManager;
    final isNewBest = score.score >= score.highScore && score.score > 0;
    final revivesLeft = OceanEscapeGame.maxRevives - game.revivesUsed;
    final canDouble = game.runPending && score.goldEarned > 0;
    // Landscape phones are short on height, so stats (left) and actions
    // (right) sit side by side; FittedBox guarantees no overflow on tiny
    // screens.
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0B2A54),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GAME OVER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      if (isNewBest) ...[
                        const SizedBox(height: 4),
                        const Text(
                          'NEW BEST!',
                          style: TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.w800),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _StatRow(label: 'Score', value: '${score.score}'),
                      _StatRow(label: 'Best', value: '${score.highScore}'),
                      _StatRow(
                        label: 'Distance',
                        value: '${(score.distanceMeters / 1000).toStringAsFixed(2)} km',
                      ),
                      _StatRow(label: 'Pearls', value: '${score.pearlsCollected}'),
                      const SizedBox(height: 8),
                      _GoldEarned(
                        amount: _goldClaimed ?? score.goldEarned,
                        doubled: _goldClaimed != null,
                      ),
                    ],
                  ),
                  const SizedBox(width: 28),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (game.canRevive) ...[
                        PrimaryButton(
                          label: 'REVIVE ($revivesLeft left)',
                          icon: Icons.favorite_rounded,
                          color: const Color(0xFFB768F0),
                          width: 220,
                          fontSize: 15,
                          padding: _compactPadding,
                          enabled: !_busy,
                          onPressed: _revive,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (canDouble) ...[
                        PrimaryButton(
                          label: 'DOUBLE GOLD',
                          icon: Icons.ondemand_video_rounded,
                          color: const Color(0xFFE0A800),
                          width: 220,
                          fontSize: 15,
                          padding: _compactPadding,
                          enabled: !_busy,
                          onPressed: _doubleGold,
                        ),
                        const SizedBox(height: 8),
                      ],
                      PrimaryButton(
                        label: 'RETRY',
                        icon: Icons.refresh_rounded,
                        color: const Color(0xFF4CD97B),
                        width: 220,
                        fontSize: 15,
                        padding: _compactPadding,
                        enabled: !_busy,
                        onPressed: _retry,
                      ),
                      const SizedBox(height: 8),
                      PrimaryButton(
                        label: 'HOME',
                        icon: Icons.home_rounded,
                        color: const Color(0xFF3FA9D6),
                        width: 220,
                        fontSize: 15,
                        padding: _compactPadding,
                        enabled: !_busy,
                        onPressed: () {
                          game.audioManager.buttonClick();
                          widget.onHome();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _compactPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 11);

class _GoldEarned extends StatelessWidget {
  const _GoldEarned({required this.amount, required this.doubled});
  final int amount;
  final bool doubled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD54F).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD54F), size: 20),
          const SizedBox(width: 6),
          Text(
            '+$amount gold',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
          ),
          if (doubled) ...[
            const SizedBox(width: 6),
            const Text(
              'x2',
              style: TextStyle(color: Color(0xFF4CD97B), fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
