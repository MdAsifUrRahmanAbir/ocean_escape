import 'package:flutter/material.dart';

import '../core/app_services.dart';
import '../ui/primary_button.dart';

/// User-configurable settings (§46): music/sound/vibration toggles, render
/// quality, and a reset-progress action.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.services});
  final AppServices services;

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text('This clears your high score, best distance and totals. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
        ],
      ),
    );
    if (confirmed == true) {
      await services.settings.resetProgress();
      await services.score.load();
      services.score.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2A54),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AnimatedBuilder(
        animation: services.settings,
        builder: (context, _) {
          final s = services.settings;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SwitchTile(
                label: 'Music',
                value: s.musicOn,
                onChanged: s.setMusicOn,
              ),
              _SwitchTile(
                label: 'Sound Effects',
                value: s.soundOn,
                onChanged: s.setSoundOn,
              ),
              _SwitchTile(
                label: 'Vibration',
                value: s.vibrationOn,
                onChanged: s.setVibrationOn,
              ),
              const SizedBox(height: 20),
              const Text('Quality', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final q in const ['low', 'medium', 'high'])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _QualityChip(
                          label: q,
                          selected: s.quality == q,
                          onTap: () => s.setQuality(q),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: PrimaryButton(
                  label: 'RESET PROGRESS',
                  icon: Icons.restart_alt_rounded,
                  color: const Color(0xFFE0554F),
                  fontSize: 16,
                  onPressed: () => _confirmReset(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        value: value,
        activeTrackColor: const Color(0xFF4CD97B),
        onChanged: onChanged,
      ),
    );
  }
}

class _QualityChip extends StatelessWidget {
  const _QualityChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3FA9D6) : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.white : Colors.transparent),
        ),
        child: Text(
          label[0].toUpperCase() + label.substring(1),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
