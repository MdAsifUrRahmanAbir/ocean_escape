import 'dart:math';
import 'dart:ui';

/// Draws the cute cartoon player fish (§4/§5) with cached [Paint]/[Path]
/// objects so nothing is allocated per frame (§44).
///
/// The fish always faces right. `swimPhase` drives the tail/fin wag and a
/// subtle body squash/stretch; `openness` (0..1) drives the eye/mouth
/// expression so hurt/shield/death states read clearly at a glance.
class FishPainter {
  final Color bodyColor;
  final Color bellyColor;
  final Color finColor;
  final Color outlineColor;

  /// Optional pair of vertical body stripes (clownfish-style patterns).
  final Color? stripeColor;

  FishPainter({
    this.bodyColor = const Color(0xFFFF8A3D),
    this.bellyColor = const Color(0xFFFFD180),
    this.finColor = const Color(0xFFFFD54F),
    this.outlineColor = const Color(0xFF2B1B12),
    this.stripeColor,
  })  : _stripePaint = Paint()
          ..style = PaintingStyle.fill
          ..color = stripeColor ?? const Color(0x00000000),
        _bodyPaint = Paint()..style = PaintingStyle.fill,
        _bellyPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = bellyColor,
        _finPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = finColor,
        _outlinePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeJoin = StrokeJoin.round
          ..color = outlineColor,
        _eyeWhitePaint = Paint()..color = const Color(0xFFFFFFFF),
        _eyeBlackPaint = Paint()..color = const Color(0xFF25150E),
        _highlightPaint = Paint()..color = const Color(0x99FFFFFF),
        _mouthPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF6E2A18),
        _blushPaint = Paint()..color = const Color(0x55FF6F6F),
        _shieldPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0x996FE0FF),
        _shieldFillPaint = Paint()..color = const Color(0x226FE0FF);

  final Paint _stripePaint;
  final Paint _bodyPaint;
  final Paint _bellyPaint;
  final Paint _finPaint;
  final Paint _outlinePaint;
  final Paint _eyeWhitePaint;
  final Paint _eyeBlackPaint;
  final Paint _highlightPaint;
  final Paint _mouthPaint;
  final Paint _blushPaint;
  final Paint _shieldPaint;
  final Paint _shieldFillPaint;

  /// [radius] is the fish's nominal half-size. [swimPhase] radians for the
  /// tail wag cycle. [expression] in [-1, 1]: -1 hurt/sad, 0 neutral, 1 happy.
  /// [tintOverride]/[tintStrength] let hurt/death flash red or fade.
  void paint(
    Canvas canvas, {
    required double radius,
    required double swimPhase,
    double expression = 1.0,
    double squash = 0.0,
    bool shielded = false,
    Color? tintOverride,
    double tintStrength = 0.0,
    double opacity = 1.0,
  }) {
    final tailWag = sin(swimPhase) * 0.55;
    final finWag = sin(swimPhase + 1.2) * 0.3;

    final sx = 1.0 + squash;
    final sy = 1.0 - squash * 0.6;

    canvas.save();
    canvas.scale(sx, sy);

    if (opacity < 1.0) {
      canvas.saveLayer(Rect.fromCircle(center: Offset.zero, radius: radius * 2.4), Paint()..color = Color.fromRGBO(0, 0, 0, opacity));
    }

    // Tail
    final tailPath = Path()
      ..moveTo(-radius * 0.85, 0)
      ..lineTo(-radius * (1.5 + tailWag.abs() * 0.1), -radius * (0.55 + tailWag * 0.4))
      ..lineTo(-radius * 1.15, 0)
      ..lineTo(-radius * (1.5 + tailWag.abs() * 0.1), radius * (0.55 - tailWag * 0.4))
      ..close();
    canvas.save();
    canvas.translate(-radius * 0.55, 0);
    canvas.rotate(tailWag * 0.5);
    canvas.translate(radius * 0.55, 0);
    canvas.drawPath(tailPath, _finPaint..color = _withTint(finColor, tintOverride, tintStrength));
    canvas.drawPath(tailPath, _outlinePaint);
    canvas.restore();

    // Dorsal fin
    final dorsalPath = Path()
      ..moveTo(-radius * 0.1, -radius * 0.75)
      ..quadraticBezierTo(
        radius * 0.05,
        -radius * (1.25 + finWag * 0.25),
        radius * 0.35,
        -radius * 0.7,
      )
      ..close();
    canvas.drawPath(dorsalPath, _finPaint..color = _withTint(finColor, tintOverride, tintStrength));
    canvas.drawPath(dorsalPath, _outlinePaint);

    // Pectoral fin
    final pectoralPath = Path()
      ..moveTo(-radius * 0.05, radius * 0.25)
      ..quadraticBezierTo(
        radius * 0.05,
        radius * (0.75 + finWag.abs() * 0.3),
        radius * 0.35,
        radius * 0.35,
      )
      ..close();
    canvas.drawPath(pectoralPath, _finPaint..color = _withTint(finColor, tintOverride, tintStrength));
    canvas.drawPath(pectoralPath, _outlinePaint);

    // Body
    final bodyRect = Rect.fromCenter(center: Offset.zero, width: radius * 2.0, height: radius * 1.6);
    final bodyRRect = RRect.fromRectAndRadius(bodyRect, Radius.circular(radius));
    canvas.drawRRect(bodyRRect, _bodyPaint..color = _withTint(bodyColor, tintOverride, tintStrength));
    final stripe = stripeColor;
    if (stripe != null) {
      canvas.save();
      canvas.clipRRect(bodyRRect);
      _stripePaint.color = _withTint(stripe, tintOverride, tintStrength);
      for (final x in const [0.18, -0.45]) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset(radius * x, 0), width: radius * 0.26, height: radius * 2),
          _stripePaint,
        );
      }
      canvas.restore();
    }
    canvas.drawRRect(bodyRRect, _outlinePaint);

    // Belly highlight
    final bellyRect = Rect.fromCenter(
      center: Offset(radius * 0.05, radius * 0.35),
      width: radius * 1.3,
      height: radius * 0.7,
    );
    canvas.drawOval(bellyRect, _bellyPaint..color = _withTint(bellyColor, tintOverride, tintStrength * 0.5));

    // Soft top-left shading highlight
    canvas.drawCircle(Offset(-radius * 0.35, -radius * 0.35), radius * 0.5, _highlightPaint);

    // Blush
    canvas.drawCircle(Offset(radius * 0.25, radius * 0.15), radius * 0.16, _blushPaint);

    // Eye
    final eyeCenter = Offset(radius * 0.55, -radius * 0.12);
    canvas.drawCircle(eyeCenter, radius * 0.34, _eyeWhitePaint);
    canvas.drawCircle(eyeCenter, radius * 0.34, _outlinePaint..strokeWidth = 1.6);
    _outlinePaint.strokeWidth = 2.6;
    final pupilOffset = Offset(radius * 0.06, expression < 0 ? radius * 0.06 : 0);
    canvas.drawCircle(eyeCenter + pupilOffset, radius * 0.17, _eyeBlackPaint);
    canvas.drawCircle(eyeCenter + pupilOffset - Offset(radius * 0.05, radius * 0.05), radius * 0.05, _eyeWhitePaint);

    // Mouth: smile curve, flattens/frowns with expression.
    final mouthPath = Path()..moveTo(radius * 0.55, radius * 0.32);
    final mouthCurveY = radius * (0.32 + 0.18 * expression);
    mouthPath.quadraticBezierTo(radius * 0.75, mouthCurveY, radius * 0.92, radius * 0.3);
    canvas.drawPath(mouthPath, _mouthPaint);

    if (shielded) {
      canvas.drawCircle(Offset.zero, radius * 1.7, _shieldFillPaint);
      canvas.drawCircle(Offset.zero, radius * 1.7, _shieldPaint);
    }

    if (opacity < 1.0) {
      canvas.restore();
    }

    canvas.restore();
  }

  Color _withTint(Color base, Color? tint, double strength) {
    if (tint == null || strength <= 0) return base;
    return Color.lerp(base, tint, strength.clamp(0.0, 1.0))!;
  }
}
