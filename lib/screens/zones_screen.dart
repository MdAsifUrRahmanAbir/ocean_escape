import 'package:flutter/material.dart';

import '../core/app_services.dart';
import '../core/config/environment_config.dart';
import '../core/models/environment_type.dart';

/// Shows the four ocean zones and how far the player must swim to reach
/// each one (§16/§52). The run always starts in the Coral Reef and
/// progresses by distance, so this screen is a progress/preview view rather
/// than a level-select - the architecture still supports gating menu access
/// to a zone later without changing this screen.
class ZonesScreen extends StatelessWidget {
  const ZonesScreen({super.key, required this.services});
  final AppServices services;

  static const _descriptions = {
    EnvironmentType.coralReef: 'Bright, welcoming waters. Learn the ropes.',
    EnvironmentType.deepOcean: 'Darker currents. Sharks grow bolder.',
    EnvironmentType.shipwreck: 'Wrecked hulls and narrow passages.',
    EnvironmentType.volcanoOcean: 'Scalding currents. Only the best survive.',
  };

  @override
  Widget build(BuildContext context) {
    final best = services.score.bestDistanceMeters;
    return Scaffold(
      backgroundColor: const Color(0xFF0B2A54),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Ocean Zones', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: EnvironmentType.values.length,
        itemBuilder: (context, i) {
          final env = EnvironmentType.values[i];
          final start = EnvironmentConfig.startDistanceMeters[env]!;
          final reached = best >= start;
          final palette = EnvironmentConfig.palettes[env]!;
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [palette.skyTop, palette.skyBottom]),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: reached ? 0.6 : 0.15)),
            ),
            child: Row(
              children: [
                Icon(
                  reached ? Icons.check_circle_rounded : Icons.lock_rounded,
                  color: reached ? const Color(0xFF4CD97B) : Colors.white54,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        env.displayName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _descriptions[env]!,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        reached ? 'Reached' : 'Swim ${start.toInt()}m to reach',
                        style: TextStyle(
                          color: reached ? const Color(0xFF4CD97B) : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
