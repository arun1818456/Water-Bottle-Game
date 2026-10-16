import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/bottle.dart';

/// High-fidelity CustomPainter rendering water bottle, fluid layers, meniscus waves, and skin styling
class BottlePainter extends CustomPainter {
  final Bottle bottle;
  final String skinType; // 'glass', 'neon', 'crystal', 'gold', 'dark'
  final bool isSelected;
  final bool isHintSource;
  final bool isHintTarget;
  final double wavePhase; // For liquid meniscus subtle animation
  final double tiltAngle; // in radians, negative for tilt left, positive for tilt right
  final double drainAmount; // 0.0 to N (number of layers currently drained)
  final double fillAmount; // 0.0 to N (number of layers currently filling)
  final int? fillColor; // color of incoming liquid
  final bool isColorblindMode;

  BottlePainter({
    required this.bottle,
    this.skinType = 'glass',
    this.isSelected = false,
    this.isHintSource = false,
    this.isHintTarget = false,
    this.wavePhase = 0.0,
    this.tiltAngle = 0.0,
    this.drainAmount = 0.0,
    this.fillAmount = 0.0,
    this.fillColor,
    this.isColorblindMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw Hint Glow or Selection Glow behind bottle
    if (isHintSource || isHintTarget || isSelected) {
      final glowPaint = Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

      if (isHintSource) {
        glowPaint.color = AppColors.accentAmber.withAlpha(180);
      } else if (isHintTarget) {
        glowPaint.color = AppColors.accentNeonGreen.withAlpha(180);
      } else {
        glowPaint.color = AppColors.primaryCyan.withAlpha(160);
      }

      final glowRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(-4, -4, w + 8, h + 8),
        const Radius.circular(24),
      );
      canvas.drawRRect(glowRect, glowPaint);
    }

    // Define bottle shape path: neck + shoulder + body + rounded bottom
    final neckWidth = w * 0.44;
    final neckHeight = h * 0.12;
    final lipHeight = h * 0.035;
    final lipWidth = w * 0.54;
    final bodyTop = neckHeight + h * 0.06;
    final cornerRadius = w * 0.28;

    final bottlePath = Path();

    // Lip top left
    bottlePath.moveTo((w - lipWidth) / 2, lipHeight);
    // Neck left
    bottlePath.lineTo((w - neckWidth) / 2, neckHeight);
    // Shoulder left curve to body
    bottlePath.quadraticBezierTo(0, neckHeight + (bodyTop - neckHeight) * 0.5, 0, bodyTop);
    // Body left down to bottom-left corner
    bottlePath.lineTo(0, h - cornerRadius);
    // Bottom curved base
    bottlePath.quadraticBezierTo(0, h, cornerRadius, h);
    bottlePath.lineTo(w - cornerRadius, h);
    bottlePath.quadraticBezierTo(w, h, w, h - cornerRadius);
    // Body right up
    bottlePath.lineTo(w, bodyTop);
    // Shoulder right curve to neck
    bottlePath.quadraticBezierTo(w, neckHeight + (bodyTop - neckHeight) * 0.5, (w + neckWidth) / 2, neckHeight);
    // Neck right
    bottlePath.lineTo((w + lipWidth) / 2, lipHeight);
    bottlePath.close();

    // Clip to inner bottle shape so liquid and effects stay inside
    canvas.save();
    canvas.clipPath(bottlePath);

    // 1. Draw bottle interior background based on skin
    _drawInteriorBackground(canvas, size);

    // 2. Draw Liquid Layers with natural tilt slosh and drain/fill volume dynamics
    _drawLiquidLayers(canvas, size, bodyTop, h);

    // 3. Draw Skin Specific Overlays (Crystal facets, Gold shimmer, etc.)
    _drawSkinOverlays(canvas, size);

    // 4. Draw Glass Highlight / Reflection Arc
    _drawGlassReflections(canvas, size, bodyTop);

    canvas.restore();

    // 5. Draw Outer Bottle Border & Lip Rim
    _drawBottleBorders(canvas, bottlePath, size, neckWidth, neckHeight, lipWidth, lipHeight);
  }

  void _drawInteriorBackground(Canvas canvas, Size size) {
    final bgPaint = Paint();
    if (skinType == 'dark') {
      bgPaint.color = const Color(0x33000000);
    } else if (skinType == 'crystal') {
      bgPaint.color = const Color(0x1A00FFFF);
    } else if (skinType == 'gold') {
      bgPaint.color = const Color(0x1AFFD700);
    } else {
      bgPaint.color = const Color(0x14FFFFFF);
    }
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
  }

  void _drawLiquidLayers(Canvas canvas, Size size, double bodyTop, double totalHeight) {
    final effectiveLayers = List<int>.from(bottle.layers);
    if (effectiveLayers.isEmpty && (fillAmount <= 0.0 || fillColor == null)) return;

    final usableHeight = totalHeight - bodyTop - 6; // Leave slight room at base
    final segmentHeight = usableHeight / bottle.capacity;

    // Calculate total liquid volume units currently in bottle
    double totalVolume = effectiveLayers.length.toDouble();
    if (drainAmount > 0.0) {
      totalVolume = max(0.0, totalVolume - drainAmount);
    }

    // Build visual layer segments
    final segments = <_LiquidSegment>[];
    double accumulated = 0.0;

    for (var i = 0; i < effectiveLayers.length; i++) {
      if (accumulated >= totalVolume) break;
      final segBottom = accumulated;
      final segTop = min(accumulated + 1.0, totalVolume);
      if (segTop > segBottom) {
        segments.add(_LiquidSegment(
          colorId: effectiveLayers[i],
          bottomVol: segBottom,
          topVol: segTop,
          layerIndex: i,
        ));
      }
      accumulated += 1.0;
    }

    // If filling, add incoming fill segment on top
    if (fillAmount > 0.0 && fillColor != null) {
      final fillBottom = accumulated;
      final fillTop = accumulated + fillAmount;
      segments.add(_LiquidSegment(
        colorId: fillColor!,
        bottomVol: fillBottom,
        topVol: fillTop,
        layerIndex: effectiveLayers.length,
      ));
    }

    if (segments.isEmpty) return;

    // Tilt slosh geometry calculation: exact gravity-aligned surface delta across bottle width
    final tiltDelta = size.width * tan(tiltAngle.clamp(-1.25, 1.25));

    Offset getSurfacePoint(double volFraction, double x) {
      final yMid = totalHeight - 3.0 - (volFraction * usableHeight);
      final normX = (x / size.width) - 0.5;
      final y = yMid - (normX * tiltDelta);
      return Offset(x, y);
    }

    for (var i = 0; i < segments.length; i++) {
      final seg = segments[i];
      final isTopMost = (i == segments.length - 1);
      final isHidden = bottle.isLayerHidden(seg.layerIndex);

      final bottomFrac = seg.bottomVol / bottle.capacity;
      final topFrac = seg.topVol / bottle.capacity;

      final pBottomLeft = getSurfacePoint(bottomFrac, 0);
      final pBottomRight = getSurfacePoint(bottomFrac, size.width);
      final pTopLeft = getSurfacePoint(topFrac, 0);
      final pTopRight = getSurfacePoint(topFrac, size.width);

      final layerPath = Path();

      if (i == 0) {
        // Bottom layer covers the entire rounded bottle base
        layerPath.moveTo(0, totalHeight + 10);
        layerPath.lineTo(size.width, totalHeight + 10);
        layerPath.lineTo(pTopRight.dx, pTopRight.dy);
      } else {
        layerPath.moveTo(pBottomLeft.dx, pBottomLeft.dy);
        layerPath.lineTo(pBottomRight.dx, pBottomRight.dy);
        layerPath.lineTo(pTopRight.dx, pTopRight.dy);
      }

      if (isTopMost) {
        // Top-most surface has dynamic wavy meniscus
        final midY = (pTopLeft.dy + pTopRight.dy) / 2 + sin(wavePhase) * 2.0;
        layerPath.quadraticBezierTo(
          size.width * 0.5,
          midY - 2.5,
          pTopLeft.dx,
          pTopLeft.dy,
        );
      } else {
        layerPath.lineTo(pTopLeft.dx, pTopLeft.dy);
      }

      layerPath.close();

      final minY = min(pTopLeft.dy, pTopRight.dy);
      final maxY = max(pBottomLeft.dy, pBottomRight.dy).clamp(minY + 10, totalHeight + 10);

      if (isHidden) {
        // Semi-transparent glassy frosted translucent liquid layer
        final mysteryPaint = Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0x994F46E5), // Translucent Indigo
              const Color(0x7706B6D4), // Translucent Cyan
              const Color(0x997C3AED), // Translucent Purple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTRB(0, minY, size.width, maxY));

        canvas.drawPath(layerPath, mysteryPaint);

        // Draw sparkling star glints inside the mystery layer
        final centerY = (minY + maxY) / 2;
        final pulse1 = (sin(wavePhase + seg.layerIndex * 1.5) + 1.0) / 2.0;
        final pulse2 = (cos(wavePhase * 1.3 + seg.layerIndex) + 1.0) / 2.0;

        _drawStarGlint(
          canvas,
          Offset(size.width * 0.22, centerY - 2 + sin(wavePhase) * 2),
          3.0 + pulse1 * 2.0,
          Colors.cyanAccent.withAlpha((140 + pulse1 * 115).toInt()),
        );

        _drawStarGlint(
          canvas,
          Offset(size.width * 0.78, centerY + 3 - cos(wavePhase) * 2),
          2.5 + pulse2 * 2.0,
          Colors.purpleAccent.withAlpha((140 + pulse2 * 115).toInt()),
        );

        _drawStarGlint(
          canvas,
          Offset(size.width * 0.5, minY + 5),
          2.0 + pulse1 * 1.5,
          Colors.white.withAlpha((160 + pulse1 * 95).toInt()),
        );

        // Draw glowing question mark '?' in center of mystery layer segment
        final tp = TextPainter(
          text: TextSpan(
            text: '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: max(14.0, (maxY - minY) * 0.58),
              fontWeight: FontWeight.w900,
              shadows: [
                const Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
                Shadow(color: const Color(0xFF00E5FF), blurRadius: 10 + pulse1 * 6),
                Shadow(color: const Color(0xFFD500F9), blurRadius: 14 + pulse2 * 6),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        tp.paint(canvas, Offset((size.width - tp.width) / 2, centerY - (tp.height / 2)));
      } else {
        final palette = AppColors.getLiquidPalette(seg.colorId);
        final liquidPaint = Paint()
          ..shader = LinearGradient(
            colors: [
              palette.highlight,
              palette.base,
              palette.shadow,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTRB(0, minY, size.width, maxY));

        canvas.drawPath(layerPath, liquidPaint);

        // Add subtle glossy shine streak down along the fluid
        final shinePaint = Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.white.withAlpha(70),
              Colors.white.withAlpha(0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(Rect.fromLTWH(4, minY, size.width * 0.3, segmentHeight));

        canvas.drawRect(
          Rect.fromLTWH(4, minY, size.width * 0.25, maxY - minY),
          shinePaint,
        );

        // Draw distinct symbol for Colorblind Mode
        if (isColorblindMode) {
          final symbol = AppColors.getColorblindSymbol(seg.colorId);
          final tp = TextPainter(
            text: TextSpan(
              text: symbol,
              style: TextStyle(
                color: Colors.white.withAlpha(240),
                fontSize: max(12.0, (maxY - minY) * 0.52),
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
                  Shadow(color: Colors.black54, blurRadius: 2),
                ],
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();

          final centerY = (minY + maxY) / 2;
          tp.paint(canvas, Offset((size.width - tp.width) / 2, centerY - (tp.height / 2)));
        }
      }
    }
  }

  void _drawStarGlint(Canvas canvas, Offset center, double radius, Color color) {
    if (radius <= 0) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius);

    canvas.drawPath(path, paint);

    final glowPaint = Paint()
      ..color = Colors.white.withAlpha((color.a * 0.9).toInt().clamp(0, 255))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(center, max(0.8, radius * 0.35), glowPaint);
  }

  void _drawSkinOverlays(Canvas canvas, Size size) {
    if (skinType == 'crystal') {
      // Geometric facet lines
      final facetPaint = Paint()
        ..color = Colors.white.withAlpha(45)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(size.width * 0.2, 0),
        Offset(size.width * 0.8, size.height),
        facetPaint,
      );
      canvas.drawLine(
        Offset(size.width * 0.8, 0),
        Offset(size.width * 0.2, size.height),
        facetPaint,
      );
    } else if (skinType == 'gold') {
      // Golden corner glints
      final glintPaint = Paint()
        ..color = const Color(0x66FFD700)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), 8, glintPaint);
    }
  }

  void _drawGlassReflections(Canvas canvas, Size size, double bodyTop) {
    // Glass reflection vertical stripe on left side
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withAlpha(75),
          Colors.white.withAlpha(25),
          Colors.white.withAlpha(0),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(6, bodyTop, size.width * 0.18, size.height - bodyTop));

    final highlightPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(5, bodyTop + 4, size.width * 0.14, size.height - bodyTop - 14),
        const Radius.circular(8),
      ));

    canvas.drawPath(highlightPath, highlightPaint);
  }

  void _drawBottleBorders(
    Canvas canvas,
    Path bottlePath,
    Size size,
    double neckWidth,
    double neckHeight,
    double lipWidth,
    double lipHeight,
  ) {
    // Border color depending on skin
    Color borderColor;
    double borderWidth = 2.5;

    switch (skinType) {
      case 'neon':
        borderColor = AppColors.primaryCyan;
        borderWidth = 3.0;
        break;
      case 'gold':
        borderColor = const Color(0xFFFFD700);
        borderWidth = 2.8;
        break;
      case 'crystal':
        borderColor = const Color(0xFFE0F7FA);
        borderWidth = 2.5;
        break;
      case 'dark':
        borderColor = const Color(0xFF455A64);
        borderWidth = 2.5;
        break;
      case 'glass':
      default:
        borderColor = Colors.white.withAlpha(180);
        borderWidth = 2.4;
        break;
    }

    // Outer Stroke
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(bottlePath, borderPaint);

    // Lip top rim cap
    final lipRect = RRect.fromRectAndRadius(
      Rect.fromLTWH((size.width - lipWidth) / 2, 0, lipWidth, lipHeight + 2),
      const Radius.circular(4),
    );

    final lipFillPaint = Paint()
      ..color = (skinType == 'gold')
          ? const Color(0xFFFFD700)
          : (skinType == 'neon' ? AppColors.primaryCyan : Colors.white.withAlpha(120))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(lipRect, lipFillPaint);
  }

  @override
  bool shouldRepaint(covariant BottlePainter oldDelegate) {
    return oldDelegate.bottle != bottle ||
        oldDelegate.skinType != skinType ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.isHintSource != isHintSource ||
        oldDelegate.isHintTarget != isHintTarget ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.tiltAngle != tiltAngle ||
        oldDelegate.drainAmount != drainAmount ||
        oldDelegate.fillAmount != fillAmount ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.isColorblindMode != isColorblindMode;
  }
}

class _LiquidSegment {
  final int colorId;
  final double bottomVol;
  final double topVol;
  final int layerIndex;

  _LiquidSegment({
    required this.colorId,
    required this.bottomVol,
    required this.topVol,
    required this.layerIndex,
  });
}

