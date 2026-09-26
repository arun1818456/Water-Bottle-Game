import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Single sparkle particle for bottle completion explosion
class BottleSparkleParticle {
  final double startX;
  final double startY;
  final double targetVx;
  final double targetVy;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final Color color;
  final int shapeType; // 0: 4-point star, 1: diamond glint, 2: glowing orb
  final double delay; // 0.0 to 0.3 offset

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

/// Helper generating high-energy burst sparkles around bottle
class BottleSparklesHelper {
  static List<BottleSparkleParticle> generateBurstParticles(int? colorId, Size bottleSize) {
    final rand = Random();
    final particles = <BottleSparkleParticle>[];

    final palette = colorId != null ? AppColors.getLiquidPalette(colorId) : null;
    final colorOptions = [
      const Color(0xFFFFD700), // Rich Gold
      const Color(0xFFFFF176), // Bright Yellow Gold
      const Color(0xFFFFFFFF), // Pure Brilliant White
      if (palette != null) palette.highlight,
      if (palette != null) palette.base,
      const Color(0xFF00E5FF), // Bright Cyan Sparkle
      const Color(0xFFFF4081), // Pink Pop Sparkle
    ];

    final centerX = bottleSize.width * 0.5;
    final neckY = bottleSize.height * 0.12;

    for (var i = 0; i < 24; i++) {
      final angle = (i / 24.0) * 2 * pi + (rand.nextDouble() - 0.5) * 0.4;
      final speed = 35.0 + rand.nextDouble() * 55.0;
      final vx = cos(angle) * speed;
      final vy = sin(angle) * speed - 20.0; // Strong upward & outward burst

      // Origin points around neck and upper third of bottle
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

/// Custom painter rendering animated bottle cap, sparkle burst, and ambient magical stars
class BottleCompletionPainter extends CustomPainter {
  final String skinType;
  final double capProgress; // 0.0 (hidden above) -> 1.0 (firmly capped)
  final double burstProgress; // 0.0 -> 1.0 (sparkle explosion)
  final double ambientPhase; // Looping 0.0 -> 2*PI for gentle continuous twinkling
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
    final w = size.width;
    final h = size.height;

    // 1. Draw Sparkle Explosion Burst (behind or around bottle)
    if (burstProgress > 0.0 && burstProgress < 1.0) {
      _drawBurstSparkles(canvas, size);
      _drawShockwaveRing(canvas, size);
    }

    // 2. Draw Ambient Magical Stars on completed bottle
    if (capProgress >= 0.8) {
      _drawAmbientSparkles(canvas, size);
    }

    // 3. Draw Animated Cap / Cork on top of the bottle neck
    if (capProgress > 0.0) {
      _drawAnimatedCap(canvas, size);
    }
  }

  void _drawAnimatedCap(Canvas canvas, Size size) {
    final w = size.width;
    final neckWidth = w * 0.44;
    final lipWidth = w * 0.54;

    // Cap dimensions
    final capHeadWidth = lipWidth + 4.0;
    final capHeadHeight = 13.0;
    final capPlugWidth = neckWidth - 4.0;
    final capPlugHeight = 7.0;

    // Cap vertical motion: falls from y = -45 with bounce/settle to y = -10
    // When capProgress = 1.0, cap head sits perfectly on top rim (y = -10 to +3)
    final startY = -48.0;
    final targetY = -9.0;
    final currentY = startY + (targetY - startY) * capProgress;

    // Subtle squash & stretch bounce upon landing
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

    // Cap Plug (inserted into bottle neck)
    final plugRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        (w - capPlugWidth) / 2,
        currentY + capHeadHeight - 2,
        capPlugWidth,
        capPlugHeight,
      ),
      const Radius.circular(2.5),
    );

    // Cap Head (cork / metallic lid)
    final headRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        (w - capHeadWidth) / 2,
        currentY,
        capHeadWidth,
        capHeadHeight,
      ),
      const Radius.circular(4.5),
    );

    _paintCapBasedOnSkin(canvas, headRect, plugRect, capOpacity);

    canvas.restore();
  }

  void _paintCapBasedOnSkin(
    Canvas canvas,
    RRect headRect,
    RRect plugRect,
    double opacity,
  ) {
    Paint plugPaint = Paint();
    Paint headPaint = Paint();
    Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final alpha255 = (opacity * 255).toInt().clamp(0, 255);

    if (skinType == 'gold') {
      // Polished 24K Gold Crown Cap
      headPaint.shader = LinearGradient(
        colors: [
          const Color(0xFFFFF176).withAlpha(alpha255),
          const Color(0xFFFFD54F).withAlpha(alpha255),
          const Color(0xFFFF8F00).withAlpha(alpha255),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(headRect.outerRect);

      plugPaint.color = const Color(0xFFB8860B).withAlpha(alpha255);
      strokePaint.color = const Color(0xFFFFF9C4).withAlpha(alpha255);

      canvas.drawRRect(plugRect, plugPaint);
      canvas.drawRRect(headRect, headPaint);
      canvas.drawRRect(headRect, strokePaint);

      // Gold center jewel / gem
      final gemPaint = Paint()..color = const Color(0xFFE91E63).withAlpha(alpha255);
      canvas.drawCircle(headRect.center, 3.2, gemPaint);
      final gemShine = Paint()..color = Colors.white.withAlpha((alpha255 * 0.8).toInt());
      canvas.drawCircle(headRect.center - const Offset(1, 1), 1.0, gemShine);

    } else if (skinType == 'neon') {
      // Cyber Dark Titanium + Neon Cyan Ring Cap
      headPaint.shader = LinearGradient(
        colors: [
          const Color(0xFF263238).withAlpha(alpha255),
          const Color(0xFF102027).withAlpha(alpha255),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(headRect.outerRect);

      plugPaint.color = const Color(0xFF004D40).withAlpha(alpha255);
      strokePaint.color = AppColors.primaryCyan.withAlpha(alpha255);

      canvas.drawRRect(plugRect, plugPaint);
      canvas.drawRRect(headRect, headPaint);
      canvas.drawRRect(headRect, strokePaint);

      // Neon glowing line through center
      final neonLinePaint = Paint()
        ..color = AppColors.primaryCyan.withAlpha(alpha255)
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawLine(
        Offset(headRect.left + 4, headRect.center.dy),
        Offset(headRect.right - 4, headRect.center.dy),
        neonLinePaint,
      );

    } else if (skinType == 'crystal') {
      // Prismatic Crystal Gem Cap
      headPaint.shader = LinearGradient(
        colors: [
          Colors.white.withAlpha(alpha255),
          const Color(0xFFB2EBF2).withAlpha(alpha255),
          const Color(0xFF00ACC1).withAlpha(alpha255),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(headRect.outerRect);

      plugPaint.color = const Color(0xFF00838F).withAlpha((alpha255 * 0.7).toInt());
      strokePaint.color = Colors.white.withAlpha(alpha255);

      canvas.drawRRect(plugRect, plugPaint);
      canvas.drawRRect(headRect, headPaint);
      canvas.drawRRect(headRect, strokePaint);

      // Crystal facet highlight lines
      final facetPaint = Paint()
        ..color = Colors.white.withAlpha((alpha255 * 0.6).toInt())
        ..strokeWidth = 1.0;
      canvas.drawLine(
        Offset(headRect.left, headRect.top),
        Offset(headRect.right, headRect.bottom),
        facetPaint,
      );
      canvas.drawLine(
        Offset(headRect.right, headRect.top),
        Offset(headRect.left, headRect.bottom),
        facetPaint,
      );

    } else if (skinType == 'dark') {
      // Obsidian Matte Cap with Chrome Rim
      headPaint.shader = LinearGradient(
        colors: [
          const Color(0xFF455A64).withAlpha(alpha255),
          const Color(0xFF212121).withAlpha(alpha255),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(headRect.outerRect);

      plugPaint.color = const Color(0xFF1C1C1C).withAlpha(alpha255);
      strokePaint.color = const Color(0xFFCFD8DC).withAlpha(alpha255);

      canvas.drawRRect(plugRect, plugPaint);
      canvas.drawRRect(headRect, headPaint);
      canvas.drawRRect(headRect, strokePaint);

    } else {
      // Default: Premium Natural Oak Cork with Golden Seal Ring
      headPaint.shader = LinearGradient(
        colors: [
          const Color(0xFFE0B589).withAlpha(alpha255),
          const Color(0xFFBA8250).withAlpha(alpha255),
          const Color(0xFF8D5B2F).withAlpha(alpha255),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(headRect.outerRect);

      plugPaint.shader = LinearGradient(
        colors: [
          const Color(0xFFBA8250).withAlpha(alpha255),
          const Color(0xFF7A4820).withAlpha(alpha255),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(plugRect.outerRect);

      strokePaint.color = const Color(0xFF5D3817).withAlpha(alpha255);

      canvas.drawRRect(plugRect, plugPaint);
      canvas.drawRRect(headRect, headPaint);
      canvas.drawRRect(headRect, strokePaint);

      // Gold seal band across cork bottom
      final goldBandRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          headRect.left + 1,
          headRect.bottom - 3.5,
          headRect.width - 2,
          2.5,
        ),
        const Radius.circular(1.0),
      );
      final goldBandPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFFFE082).withAlpha(alpha255),
            const Color(0xFFFFB300).withAlpha(alpha255),
            const Color(0xFFFFE082).withAlpha(alpha255),
          ],
        ).createShader(goldBandRect.outerRect);
      canvas.drawRRect(goldBandRect, goldBandPaint);

      // Subtle horizontal cork grain lines
      final grainPaint = Paint()
        ..color = const Color(0xFF6B4226).withAlpha((alpha255 * 0.45).toInt())
        ..strokeWidth = 0.8;
      canvas.drawLine(
        Offset(headRect.left + 3, headRect.top + 4),
        Offset(headRect.right - 3, headRect.top + 4),
        grainPaint,
      );
      canvas.drawLine(
        Offset(headRect.left + 5, headRect.top + 7.5),
        Offset(headRect.right - 5, headRect.top + 7.5),
        grainPaint,
      );

      // Specular highlight gleam on top left
      final gleamPaint = Paint()
        ..color = Colors.white.withAlpha((alpha255 * 0.6).toInt())
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(headRect.left + 4, headRect.top + 2),
        Offset(headRect.left + 12, headRect.top + 2),
        gleamPaint,
      );
    }
  }

  void _drawBurstSparkles(Canvas canvas, Size size) {
    for (final p in burstParticles) {
      final adjustedProgress = (burstProgress - p.delay) / (1.0 - p.delay);
      if (adjustedProgress <= 0.0 || adjustedProgress >= 1.0) continue;

      // EaseOutQuad trajectory
      final t = adjustedProgress;
      final curvedT = Curves.easeOutCubic.transform(t);

      final currentX = p.startX + p.targetVx * curvedT;
      final currentY = p.startY + p.targetVy * curvedT;

      // Scale: quick pop up, then shrink and fade
      final scaleFactor = (t < 0.25)
          ? (t / 0.25) * 1.3
          : (1.0 - (t - 0.25) / 0.75);

      final alpha = ((1.0 - t) * 255).toInt().clamp(0, 255);
      final currentSize = p.size * scaleFactor;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(p.rotation + p.rotationSpeed * t);

      final particlePaint = Paint()
        ..color = p.color.withAlpha(alpha)
        ..style = PaintingStyle.fill;

      if (p.shapeType == 0) {
        // 4-point magic star sparkle
        _drawFourPointStar(canvas, currentSize, particlePaint);

        // Core white center for diamond gleam
        final corePaint = Paint()..color = Colors.white.withAlpha(alpha);
        _drawFourPointStar(canvas, currentSize * 0.45, corePaint);

      } else if (p.shapeType == 1) {
        // Diamond glint
        final diamondPath = Path()
          ..moveTo(0, -currentSize)
          ..lineTo(currentSize * 0.65, 0)
          ..lineTo(0, currentSize)
          ..lineTo(-currentSize * 0.65, 0)
          ..close();
        canvas.drawPath(diamondPath, particlePaint);

      } else {
        // Glowing round orb
        final glowPaint = Paint()
          ..color = p.color.withAlpha((alpha * 0.5).toInt())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
        canvas.drawCircle(Offset.zero, currentSize * 1.2, glowPaint);
        canvas.drawCircle(Offset.zero, currentSize * 0.7, particlePaint);
      }

      canvas.restore();
    }
  }

  void _drawShockwaveRing(Canvas canvas, Size size) {
    if (burstProgress > 0.0 && burstProgress < 0.8) {
      final t = burstProgress / 0.8;
      final radius = 10.0 + t * 42.0;
      final alpha = ((1.0 - t) * 200).toInt().clamp(0, 255);

      final shockwavePaint = Paint()
        ..color = const Color(0xFFFFD700).withAlpha(alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.0 - t) * 3.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(size.width / 2, size.height * 0.12),
        radius,
        shockwavePaint,
      );
    }
  }

  void _drawAmbientSparkles(Canvas canvas, Size size) {
    // 3 subtle magical stars gently twinkling around completed bottle
    final stars = [
      Offset(size.width * 0.15, size.height * 0.28),
      Offset(size.width * 0.85, size.height * 0.52),
      Offset(size.width * 0.22, size.height * 0.75),
    ];

    for (var i = 0; i < stars.length; i++) {
      final phaseOffset = i * (2 * pi / 3);
      final intensity = (sin(ambientPhase + phaseOffset) + 1.0) / 2.0; // 0.0 to 1.0

      if (intensity > 0.2) {
        final starSize = 4.0 + intensity * 4.5;
        final alpha = (intensity * 230).toInt().clamp(0, 255);

        canvas.save();
        canvas.translate(stars[i].dx, stars[i].dy);
        canvas.rotate((ambientPhase + phaseOffset) * 0.5);

        final starPaint = Paint()..color = const Color(0xFFFFD700).withAlpha(alpha);
        _drawFourPointStar(canvas, starSize, starPaint);

        final whiteCenter = Paint()..color = Colors.white.withAlpha(alpha);
        _drawFourPointStar(canvas, starSize * 0.45, whiteCenter);

        canvas.restore();
      }
    }
  }

  void _drawFourPointStar(Canvas canvas, double radius, Paint paint) {
    if (radius <= 0.1) return;
    final path = Path();
    final inner = radius * 0.22;

    for (var i = 0; i < 4; i++) {
      final a = i * (pi / 2);
      final x1 = cos(a) * radius;
      final y1 = sin(a) * radius;
      final x2 = cos(a + pi / 4) * inner;
      final y2 = sin(a + pi / 4) * inner;

      if (i == 0) {
        path.moveTo(x1, y1);
      } else {
        path.lineTo(x1, y1);
      }
      path.lineTo(x2, y2);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BottleCompletionPainter oldDelegate) {
    return oldDelegate.skinType != skinType ||
        oldDelegate.capProgress != capProgress ||
        oldDelegate.burstProgress != burstProgress ||
        oldDelegate.ambientPhase != ambientPhase ||
        oldDelegate.liquidColorId != liquidColorId;
  }
}
