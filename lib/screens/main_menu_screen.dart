import 'package:flutter/material.dart';

import '../core/app_services.dart';
import '../ui/primary_button.dart';
import '../ui/underwater_backdrop.dart';
import 'about_screen.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'zones_screen.dart';

/// The polished main menu (§33): logo, play button, zones, high score,
/// settings, and quick sound/music toggles over an animated underwater
/// scene.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key, required this.services});
  final AppServices services;

  void _play(BuildContext context) {
    services.audio.buttonClick();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => GameScreen(services: services)));
  }

  @override
  Widget build(BuildContext context) {
    // Landscape phones give very little height to work with, so the menu is
    // split left/right (logo+score, buttons) instead of stacked vertically -
    // a tall Column here would overflow on short landscape screens.
    return Scaffold(
      body: UnderwaterBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _Logo(),
                            const SizedBox(height: 14),
                            AnimatedBuilder(
                              animation: services.score,
                              builder: (context, _) => _HighScorePill(
                                highScore: services.score.highScore,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PrimaryButton(
                              label: 'PLAY',
                              icon: Icons.play_arrow_rounded,
                              color: const Color(0xFF4CD97B),
                              fontSize: 22,
                              width: 210,
                              onPressed: () => _play(context),
                            ),
                            const SizedBox(height: 12),
                            PrimaryButton(
                              label: 'OCEAN ZONES',
                              icon: Icons.map_rounded,
                              color: const Color(0xFF3FA9D6),
                              width: 210,
                              onPressed: () {
                                services.audio.buttonClick();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ZonesScreen(services: services),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    children: [
                      AnimatedBuilder(
                        animation: services.settings,
                        builder: (context, _) => _IconToggle(
                          icon: services.settings.soundOn
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          onTap: () => services.settings.setSoundOn(
                            !services.settings.soundOn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedBuilder(
                        animation: services.settings,
                        builder: (context, _) => _IconToggle(
                          icon: services.settings.musicOn
                              ? Icons.music_note_rounded
                              : Icons.music_off_rounded,
                          onTap: () => services.settings.setMusicOn(
                            !services.settings.musicOn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _IconToggle(
                        icon: Icons.settings_rounded,
                        onTap: () {
                          services.audio.buttonClick();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  SettingsScreen(services: services),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _IconToggle(
                        icon: Icons.info_rounded,
                        onTap: () {
                          services.audio.buttonClick();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AboutScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'OCEAN',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 4,
            shadows: [
              Shadow(
                color: Color(0xFF0B2A54),
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
        ),
        Text(
          'ESCAPE',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFFD54F),
            letterSpacing: 6,
            shadows: const [
              Shadow(
                color: Color(0xFF0B2A54),
                offset: Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HighScorePill extends StatelessWidget {
  const _HighScorePill({required this.highScore});
  final int highScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: Color(0xFFFFD54F),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Best: $highScore',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconToggle extends StatelessWidget {
  const _IconToggle({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
