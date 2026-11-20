import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/game/ocean_escape_game.dart';
import '../core/models/power_up_type.dart';

/// The in-gameplay HUD (§32): score top-left, distance top-center, pause
/// top-right, and a row of active power-up badges with countdowns. Ticks
/// every frame via its own [Ticker] since power-up timers live as plain
/// fields on [OceanEscapeGame] rather than a `ChangeNotifier` (§56 - no
/// need to wire notifier plumbing through the whole game for HUD polling).
class Hud extends StatefulWidget {
  const Hud({super.key, required this.game, required this.onPause});
  final OceanEscapeGame game;
  final VoidCallback onPause;

  @override
  State<Hud> createState() => _HudState();
}

class _HudState extends State<Hud> with SingleTickerProviderStateMixin {
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

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.toInt()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  IconData _iconFor(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        return Icons.shield_rounded;
      case PowerUpType.magnet:
        return Icons.attractions_rounded;
      case PowerUpType.speedBoost:
        return Icons.bolt_rounded;
      case PowerUpType.slowMotion:
        return Icons.hourglass_bottom_rounded;
      case PowerUpType.pearlMultiplier:
        return Icons.stars_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Pill(child: Text('${game.scoreManager.score}', style: _statStyle)),
                const SizedBox(width: 8),
                _Pill(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD54F), size: 20),
                      const SizedBox(width: 6),
                      Text('${game.scoreManager.goldEarned}', style: _statStyle),
                    ],
                  ),
                ),
                const Spacer(),
                _Pill(child: Text(_formatDistance(game.scoreManager.distanceMeters), style: _statStyle)),
                const Spacer(),
                _PauseButton(onTap: widget.onPause),
              ],
            ),
            if (game.activePowerUpTimers.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final entry in game.activePowerUpTimers.entries)
                      _PowerUpBadge(icon: _iconFor(entry.key), seconds: entry.value),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

const _statStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.w800,
  fontSize: 20,
  shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1))],
);

class _Pill extends StatelessWidget {
  const _Pill({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.pause_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}

class _PowerUpBadge extends StatelessWidget {
  const _PowerUpBadge({required this.icon, required this.seconds});
  final IconData icon;
  final double seconds;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFFE082), size: 16),
          const SizedBox(width: 4),
          Text(
            seconds.ceil().toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
