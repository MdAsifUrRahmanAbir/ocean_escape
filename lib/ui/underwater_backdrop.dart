import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A lightweight animated underwater scene for the main menu (§33): a sky
/// gradient, a few small fish silhouettes swimming across, and bubbles
/// drifting upward. Pure [CustomPainter] - no images, no per-frame
/// allocation beyond the fixed particle lists (§44).
class UnderwaterBackdrop extends StatefulWidget {
  const UnderwaterBackdrop({super.key, this.child});
  final Widget? child;

  @override
  State<UnderwaterBackdrop> createState() => _UnderwaterBackdropState();
}

class _UnderwaterBackdropState extends State<UnderwaterBackdrop> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _t = 0;
  final Random _rng = Random(42);
  late final List<_MenuBubble> _bubbles;
  late final List<_MenuFish> _fish;

  @override
  void initState() {
    super.initState();
    _bubbles = List.generate(14, (i) => _MenuBubble.random(_rng));
    _fish = List.generate(4, (i) => _MenuFish.random(_rng));
    _ticker = createTicker((elapsed) {
      setState(() => _t = elapsed.inMilliseconds / 1000.0);
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _UnderwaterPainter(t: _t, bubbles: _bubbles, fish: _fish),
          size: Size.infinite,
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _MenuBubble {
  double x, y, r, speed;
  _MenuBubble(this.x, this.y, this.r, this.speed);
  factory _MenuBubble.random(Random rng) =>
      _MenuBubble(rng.nextDouble(), rng.nextDouble(), 2 + rng.nextDouble() * 5, 0.02 + rng.nextDouble() * 0.05);
}

class _MenuFish {
  double y, speed, size, phase;
  bool leftToRight;
  _MenuFish(this.y, this.speed, this.size, this.phase, this.leftToRight);
  factory _MenuFish.random(Random rng) => _MenuFish(
        0.15 + rng.nextDouble() * 0.6,
        0.05 + rng.nextDouble() * 0.05,
        14 + rng.nextDouble() * 10,
        rng.nextDouble() * pi * 2,
        rng.nextBool(),
      );
}

class _UnderwaterPainter extends CustomPainter {
  _UnderwaterPainter({required this.t, required this.bubbles, required this.fish});
  final double t;
  final List<_MenuBubble> bubbles;
  final List<_MenuFish> fish;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF7FE0F0), Color(0xFF1462A0)],
      ).createShader(rect);
    canvas.drawRect(rect, sky);

    final bubblePaint = Paint()..color = const Color(0x77FFFFFF);
    for (final b in bubbles) {
      final y = (b.y - (t * b.speed)) % 1.0;
      final wob = sin(t * 2 + b.x * 10) * 6;
      canvas.drawCircle(Offset(b.x * size.width + wob, y * size.height), b.r, bubblePaint);
    }

    final fishPaint = Paint()..color = const Color(0x55FFDD99);
    for (final f in fish) {
      final progress = ((t * f.speed) + f.phase / (2 * pi)) % 1.2 - 0.1;
      final x = f.leftToRight ? progress * size.width : (1 - progress) * size.width;
      final y = f.y * size.height + sin(t * 1.5 + f.phase) * 10;
      canvas.save();
      canvas.translate(x, y);
      if (!f.leftToRight) canvas.scale(-1, 1);
      final path = Path()
        ..moveTo(-f.size, 0)
        ..quadraticBezierTo(-f.size * 0.2, -f.size * 0.5, f.size * 0.6, 0)
        ..quadraticBezierTo(-f.size * 0.2, f.size * 0.5, -f.size, 0)
        ..close();
      canvas.drawPath(path, fishPaint);
      final tail = Path()
        ..moveTo(-f.size, 0)
        ..lineTo(-f.size * 1.5, -f.size * 0.35)
        ..lineTo(-f.size * 1.5, f.size * 0.35)
        ..close();
      canvas.drawPath(tail, fishPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _UnderwaterPainter oldDelegate) => true;
}
