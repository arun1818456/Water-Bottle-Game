import 'dart:math';
import 'package:water_bottle_ais/exports.dart';

class BottleSparkleParticle {
  final double startX;
  final double startY;
  final double targetVx;
  final double targetVy;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final Color color;
  final int shapeType;
  final double delay;

  BottleSparkleParticle({
    required this.startX,
    required this.startY,
    required this.targetVx,
    required this.targetVy,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.shapeType,
    this.delay = 0.0,
  });
}

class BottleSparklesHelper {
  static List<BottleSparkleParticle> generateBurstParticles(int? colorId, Size bottleSize) {
    final rand = Random();
    final particles = <BottleSparkleParticle>[];

    final palette = colorId != null ? AppColors.getLiquidPalette(colorId) : null;
    final colorOptions = [
      const Color(0xFFFFD700),
      const Color(0xFFFFF176),
      const Color(0xFFFFFFFF),
      if (palette != null) palette.highlight,
      if (palette != null) palette.base,
      const Color(0xFF00E5FF),
      const Color(0xFFFF4081),
    ];

    final centerX = bottleSize.width * 0.5;
    final neckY = bottleSize.height * 0.12;

    for (var i = 0; i < 24; i++) {
      final angle = (i / 24.0) * 2 * pi + (rand.nextDouble() - 0.5) * 0.4;
      final speed = 35.0 + rand.nextDouble() * 55.0;
      final vx = cos(angle) * speed;
      final vy = sin(angle) * speed - 20.0;

      final startY = neckY + rand.nextDouble() * (bottleSize.height * 0.4);
      final startX = centerX + (rand.nextDouble() - 0.5) * (bottleSize.width * 0.5);

      particles.add(BottleSparkleParticle(
        startX: startX,
        startY: startY,
        targetVx: vx,
        targetVy: vy,
        size: 7.0 + rand.nextDouble() * 9.0,
        rotation: rand.nextDouble() * 2 * pi,
        rotationSpeed: (rand.nextDouble() - 0.5) * 12.0,
        color: colorOptions[rand.nextInt(colorOptions.length)],
        shapeType: i % 3,
        delay: (rand.nextDouble() * 0.12),
      ));
    }

    return particles;
  }
}

class BottleCompletionPainter extends CustomPainter {
  final String skinType;
  final double capProgress;
  final double burstProgress;
  final double ambientPhase;
  final List<BottleSparkleParticle> burstParticles;
  final int? liquidColorId;

  BottleCompletionPainter({
    required this.skinType,
    required this.capProgress,
    required this.burstProgress,
    required this.ambientPhase,
    required this.burstParticles,
    this.liquidColorId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (burstProgress > 0.0 && burstProgress < 1.0) {
      _drawBurstSparkles(canvas, size);
      _drawShockwaveRing(canvas, size);
    }

    if (capProgress >= 0.8) {
      _drawAmbientSparkles(canvas, size);
    }

    if (capProgress > 0.0) {
      _drawAnimatedCap(canvas, size);
    }
  }

  void _drawAnimatedCap(Canvas canvas, Size size) {
    final w = size.width;
    final neckWidth = w * 0.44;
    final lipWidth = w * 0.54;

    final capHeadWidth = lipWidth + 4.0;
    final capHeadHeight = 13.0;
    final capPlugWidth = neckWidth - 4.0;
    final capPlugHeight = 7.0;

    final startY = -48.0;
    final targetY = -9.0;
    final currentY = startY + (targetY - startY) * capProgress;

    double scaleX = 1.0;
    double scaleY = 1.0;
    if (capProgress > 0.7 && capProgress < 1.0) {
      final bounceT = (capProgress - 0.7) / 0.3;
      scaleX = 1.0 + sin(bounceT * pi) * 0.14;
      scaleY = 1.0 - sin(bounceT * pi) * 0.12;
    }

    final capOpacity = (capProgress * 2.5).clamp(0.0, 1.0);

    canvas.save();
    canvas.translate(w / 2, currentY + capHeadHeight / 2);
    canvas.scale(scaleX, scaleY);
    canvas.translate(-w / 2, -(currentY + capHeadHeight / 2));

    final plugPath = Path();
    plugPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(
        (w - capPlugWidth) / 2,
        currentY + capHeadHeight - 1.0,
        capPlugWidth,
        capPlugHeight,
      ),
      const Radius.circular(3),
    ));

    final plugPaint = Paint()..color = const Color(0xFF8D6E63).withValues(alpha: capOpacity);
    canvas.drawPath(plugPath, plugPaint);

    final capRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        (w - capHeadWidth) / 2,
        currentY,
        capHeadWidth,
        capHeadHeight,
      ),
      const Radius.circular(5),
    );

    Paint headPaint;
    if (skinType == 'gold') {
      headPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: capOpacity),
            const Color(0xFFFFAB00).withValues(alpha: capOpacity),
            const Color(0xFFFF6D00).withValues(alpha: capOpacity),
          ],
        ).createShader(Rect.fromLTWH((w - capHeadWidth) / 2, currentY, capHeadWidth, capHeadHeight));
    } else if (skinType == 'crystal') {
      headPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFE0F7FA).withValues(alpha: capOpacity),
            const Color(0xFF80DEEA).withValues(alpha: capOpacity),
            const Color(0xFF00ACC1).withValues(alpha: capOpacity),
          ],
        ).createShader(Rect.fromLTWH((w - capHeadWidth) / 2, currentY, capHeadWidth, capHeadHeight));
    } else if (skinType == 'neon') {
      headPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF00E5FF).withValues(alpha: capOpacity),
            const Color(0xFF00E676).withValues(alpha: capOpacity),
          ],
        ).createShader(Rect.fromLTWH((w - capHeadWidth) / 2, currentY, capHeadWidth, capHeadHeight));
    } else {
      headPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFA1887F).withValues(alpha: capOpacity),
            const Color(0xFF6D4C41).withValues(alpha: capOpacity),
            const Color(0xFF4E342E).withValues(alpha: capOpacity),
          ],
        ).createShader(Rect.fromLTWH((w - capHeadWidth) / 2, currentY, capHeadWidth, capHeadHeight));
    }

    canvas.drawRRect(capRect, headPaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: capOpacity * 0.6);
    canvas.drawRRect(capRect, borderPaint);

    canvas.restore();
  }

  void _drawShockwaveRing(Canvas canvas, Size size) {
    final t = burstProgress;
    if (t <= 0.0 || t >= 1.0) return;

    final centerX = size.width * 0.5;
    final centerY = size.height * 0.45;
    final maxRadius = size.width * 1.6;

    final radius = maxRadius * sqrt(t);
    final opacity = (1.0 - t).clamp(0.0, 1.0) * 0.7;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (1.0 - t) * 6.0 + 1.0
      ..color = const Color(0xFFFFD700).withValues(alpha: opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(Offset(centerX, centerY), radius, ringPaint);
  }

  void _drawBurstSparkles(Canvas canvas, Size size) {
    for (final p in burstParticles) {
      final effT = (burstProgress - p.delay) / (1.0 - p.delay);
      if (effT <= 0.0 || effT >= 1.0) continue;

      final currentX = p.startX + p.targetVx * effT;
      final currentY = p.startY + p.targetVy * effT + 30.0 * effT * effT;

      final fadeOut = (1.0 - effT).clamp(0.0, 1.0);
      final currentOpacity = (sin(effT * pi) * fadeOut).clamp(0.0, 1.0);
      final currentScale = sin(effT * pi) * p.size;

      final particlePaint = Paint()
        ..color = p.color.withValues(alpha: currentOpacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(p.rotation + p.rotationSpeed * effT);

      if (p.shapeType == 0) {
        _draw4PointStar(canvas, currentScale, particlePaint);
      } else if (p.shapeType == 1) {
        _drawDiamond(canvas, currentScale, particlePaint);
      } else {
        canvas.drawCircle(Offset.zero, currentScale * 0.5, particlePaint);
      }

      canvas.restore();
    }
  }

  void _drawAmbientSparkles(Canvas canvas, Size size) {
    final rand = Random(12345);
    final w = size.width;
    final h = size.height;

    for (var i = 0; i < 5; i++) {
      final relX = 0.2 + rand.nextDouble() * 0.6;
      final relY = 0.25 + rand.nextDouble() * 0.55;
      final starSize = 5.0 + rand.nextDouble() * 4.0;

      final localPhase = (ambientPhase + i * 1.2) % (2 * pi);
      final alpha = (sin(localPhase) * 0.5 + 0.5).clamp(0.1, 0.9);

      final starPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(w * relX, h * relY);
      canvas.rotate(localPhase * 0.5);
      _draw4PointStar(canvas, starSize, starPaint);
      canvas.restore();
    }
  }

  void _draw4PointStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final rOuter = size;
    final rInner = size * 0.25;

    for (var i = 0; i < 8; i++) {
      final r = (i % 2 == 0) ? rOuter : rInner;
      final angle = i * pi / 4;
      final x = cos(angle) * r;
      final y = sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, double size, Paint paint) {
    final path = Path();
    path.moveTo(0, -size);
    path.lineTo(size * 0.6, 0);
    path.lineTo(0, size);
    path.lineTo(-size * 0.6, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BottleCompletionPainter oldDelegate) {
    return oldDelegate.capProgress != capProgress ||
        oldDelegate.burstProgress != burstProgress ||
        oldDelegate.ambientPhase != ambientPhase ||
        oldDelegate.skinType != skinType;
  }
}
