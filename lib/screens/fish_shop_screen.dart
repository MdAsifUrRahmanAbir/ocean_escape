import 'package:flutter/material.dart';

import '../core/app_services.dart';
import '../core/components/player/fish_painter.dart';
import '../core/models/fish_skin.dart';
import '../ui/game_overlays.dart' show showAdNotReady;
import '../ui/primary_button.dart';
import '../ui/underwater_backdrop.dart';

/// Fish shop: spend gold earned in runs (or watch ads) to unlock new fish,
/// and pick which fish to play with.
class FishShopScreen extends StatefulWidget {
  const FishShopScreen({super.key, required this.services});
  final AppServices services;

  @override
  State<FishShopScreen> createState() => _FishShopScreenState();
}

class _FishShopScreenState extends State<FishShopScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _swim =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  bool _busy = false;

  AppServices get s => widget.services;

  @override
  void dispose() {
    _swim.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  Future<void> _onAction(FishSkin fish) async {
    if (_busy) return;
    final shop = s.shop;
    s.audio.buttonClick();

    if (shop.isOwned(fish)) {
      await shop.select(fish);
      return;
    }

    switch (fish.unlockType) {
      case FishUnlockType.free:
        break;
      case FishUnlockType.gold:
        if (shop.gold < fish.price) {
          _toast('Need ${fish.price - shop.gold} more gold. Keep swimming!');
          return;
        }
        final ok = await _confirmBuy(fish);
        if (ok != true) return;
        if (await shop.buyWithGold(fish)) _toast('${fish.name} unlocked!');
        break;
      case FishUnlockType.ad:
        setState(() => _busy = true);
        final shown = await s.ads.showInterstitial();
        if (!mounted) return;
        if (shown) {
          final unlocked = await shop.registerAdWatched(fish);
          if (unlocked) _toast('${fish.name} unlocked!');
        } else {
          showAdNotReady(context);
        }
        if (mounted) setState(() => _busy = false);
        break;
    }
  }

  Future<bool?> _confirmBuy(FishSkin fish) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B2A54),
        title: Text('Unlock ${fish.name}?', style: const TextStyle(color: Colors.white)),
        content: Text(
          'Spend ${fish.price} gold to unlock this fish.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Unlock')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UnderwaterBackdrop(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: s.shop,
            builder: (context, _) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      ),
                      const Text(
                        'FISH SHOP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      GoldBalancePill(gold: s.shop.gold),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    itemCount: FishCatalog.all.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final fish = FishCatalog.all[i];
                      return _FishCard(
                        fish: fish,
                        swim: _swim,
                        owned: s.shop.isOwned(fish),
                        selected: s.shop.isSelected(fish),
                        adProgress: s.shop.adProgress(fish),
                        canAfford: s.shop.gold >= fish.price,
                        busy: _busy,
                        onAction: () => _onAction(fish),
                      );
                    },
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

class _FishCard extends StatelessWidget {
  const _FishCard({
    required this.fish,
    required this.swim,
    required this.owned,
    required this.selected,
    required this.adProgress,
    required this.canAfford,
    required this.busy,
    required this.onAction,
  });

  final FishSkin fish;
  final Animation<double> swim;
  final bool owned;
  final bool selected;
  final int adProgress;
  final bool canAfford;
  final bool busy;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = _actionStyle();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 172,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2A54).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected ? const Color(0xFF4CD97B) : Colors.white.withValues(alpha: 0.25),
          width: selected ? 3 : 2,
        ),
        boxShadow: [
          if (selected)
            BoxShadow(color: const Color(0xFF4CD97B).withValues(alpha: 0.35), blurRadius: 18),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (fish.hasPerk)
                _Chip(text: fish.perkLabel, color: const Color(0xFFFFD54F))
              else
                const SizedBox(height: 20),
              const Spacer(),
              if (!owned) Icon(Icons.lock_rounded, color: Colors.white.withValues(alpha: 0.6), size: 18),
            ],
          ),
          Expanded(
            child: Center(
              child: Opacity(
                opacity: owned ? 1 : 0.75,
                child: FishPreview(fish: fish, swim: swim),
              ),
            ),
          ),
          Text(
            fish.name,
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: label,
            icon: icon,
            color: color,
            width: double.infinity,
            fontSize: 13,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            enabled: !selected && !busy,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }

  (String, IconData, Color) _actionStyle() {
    if (selected) return ('SELECTED', Icons.check_rounded, const Color(0xFF4CD97B));
    if (owned) return ('SELECT', Icons.touch_app_rounded, const Color(0xFF3FA9D6));
    switch (fish.unlockType) {
      case FishUnlockType.gold:
        return (
          '${fish.price}',
          Icons.monetization_on_rounded,
          canAfford ? const Color(0xFFE0A800) : const Color(0xFF6B6B6B),
        );
      case FishUnlockType.ad:
        return ('WATCH AD $adProgress/${fish.adsRequired}', Icons.ondemand_video_rounded, const Color(0xFFB768F0));
      case FishUnlockType.free:
        return ('SELECT', Icons.touch_app_rounded, const Color(0xFF3FA9D6));
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

/// Live, swimming preview of a fish using the in-game painter.
class FishPreview extends StatelessWidget {
  const FishPreview({super.key, required this.fish, required this.swim, this.size = 84});
  final FishSkin fish;
  final Animation<double> swim;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.6,
      height: size,
      child: CustomPaint(painter: _FishPreviewPainter(fish.createPainter(), swim)),
    );
  }
}

class _FishPreviewPainter extends CustomPainter {
  _FishPreviewPainter(this.fishPainter, this.swim) : super(repaint: swim);
  final FishPainter fishPainter;
  final Animation<double> swim;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height * 0.3;
    final bob = (swim.value * 2 - 1).abs() * 4 - 2;
    canvas.save();
    canvas.translate(size.width / 2 + radius * 0.25, size.height / 2 + bob);
    fishPainter.paint(canvas, radius: radius, swimPhase: swim.value * 6.283 * 2);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FishPreviewPainter old) => old.fishPainter != fishPainter;
}

/// Small rounded pill showing the player's gold balance.
class GoldBalancePill extends StatelessWidget {
  const GoldBalancePill({super.key, required this.gold});
  final int gold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD54F), size: 20),
          const SizedBox(width: 6),
          Text(
            '$gold',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
