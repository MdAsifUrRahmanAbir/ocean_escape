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
              onPressed: () {
                game.audioManager.buttonClick();
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

/// Game-over panel (§34): final stats plus RETRY / HOME (and a disabled
/// "watch ad to revive" seam for §53's future rewarded-ad flow).
class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game, required this.onHome});
  final OceanEscapeGame game;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final score = game.scoreManager;
    final isNewBest = score.score >= score.highScore && score.score > 0;
    // Landscape phones are short on height, so stats (left) and actions
    // (right) sit side by side rather than stacked - keeps the panel's total
    // height small enough to never overflow even on compact screens.
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                      style: TextStyle(
                        color: Color(0xFFFFD54F),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _StatRow(label: 'Score', value: '${score.score}'),
                  _StatRow(label: 'Best', value: '${score.highScore}'),
                  _StatRow(
                    label: 'Distance',
                    value:
                        '${(score.distanceMeters / 1000).toStringAsFixed(2)} km',
                  ),
                  _StatRow(
                    label: 'Bubbles',
                    value: '${score.bubblesCollected}',
                  ),
                  _StatRow(label: 'Pearls', value: '${score.pearlsCollected}'),
                ],
              ),
              const SizedBox(width: 28),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    label: 'RETRY',
                    icon: Icons.refresh_rounded,
                    color: const Color(0xFF4CD97B),
                    width: 200,
                    onPressed: () {
                      game.audioManager.buttonClick();
                      game.restartGame();
                    },
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: 'HOME',
                    icon: Icons.home_rounded,
                    color: const Color(0xFF3FA9D6),
                    width: 200,
                    onPressed: () {
                      game.audioManager.buttonClick();
                      onHome();
                    },
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: 'WATCH AD TO REVIVE',
                    icon: Icons.ondemand_video_rounded,
                    color: const Color(0xFFB768F0),
                    width: 200,
                    fontSize: 13,
                    enabled: game.adService.rewardedAdAvailable,
                    onPressed: game.adService.rewardedAdAvailable
                        ? () {}
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
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
