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

  BottlePainter({
    required this.bottle,
    this.skinType = 'glass',
    this.isSelected = false,
    this.isHintSource = false,
    this.isHintTarget = false,
    this.wavePhase = 0.0,
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

    // 2. Draw Liquid Layers
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
    if (bottle.layers.isEmpty) return;

    final usableHeight = totalHeight - bodyTop - 6; // Leave slight room at base
    final segmentHeight = usableHeight / bottle.capacity;

    for (var i = 0; i < bottle.layers.length; i++) {
      final colorId = bottle.layers[i];
      final palette = AppColors.getLiquidPalette(colorId);

      final bottomY = totalHeight - (i * segmentHeight);
      final topY = bottomY - segmentHeight;

      // Draw liquid gradient for this segment
      final layerRect = Rect.fromLTRB(0, topY, size.width, bottomY);
      final liquidPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            palette.highlight,
            palette.base,
            palette.shadow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(layerRect);

      final layerPath = Path();
      if (i == bottle.layers.length - 1) {
        // Top-most layer has a subtle wavy meniscus
        layerPath.moveTo(0, bottomY);
        layerPath.lineTo(size.width, bottomY);
        layerPath.lineTo(size.width, topY);

        // Animated wavy surface
        final waveMid = topY + sin(wavePhase) * 2.0;
        layerPath.quadraticBezierTo(
          size.width * 0.5,
          waveMid - 3.0,
          0,
          topY,
        );
        layerPath.close();
      } else {
        layerPath.addRect(layerRect);
      }

      canvas.drawPath(layerPath, liquidPaint);

      // Add subtle glossy shine streak down the left of liquid
      final shinePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withAlpha(70),
            Colors.white.withAlpha(0),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(4, topY, size.width * 0.3, segmentHeight));

      canvas.drawRect(
        Rect.fromLTWH(4, topY, size.width * 0.25, segmentHeight),
        shinePaint,
      );
    }
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
        oldDelegate.wavePhase != wavePhase;
  }
}
