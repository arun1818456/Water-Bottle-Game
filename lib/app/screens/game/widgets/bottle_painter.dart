import 'dart:math';
import 'package:water_bottle_ais/exports.dart';

class _LiquidSegment {
  final int colorId;
  final double bottomVol;
  final double topVol;

  _LiquidSegment({
    required this.colorId,
    required this.bottomVol,
    required this.topVol,
  });
}

class BottlePainter extends CustomPainter {
  final Bottle bottle;
  final String skinType;
  final bool isSelected;
  final bool isHintSource;
  final bool isHintTarget;
  final double wavePhase;
  final double tiltAngle;
  final double drainAmount;
  final double fillAmount;
  final int? fillColor;

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
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

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

    final neckWidth = w * 0.44;
    final neckHeight = h * 0.12;
    final lipHeight = h * 0.035;
    final lipWidth = w * 0.54;
    final bodyTop = neckHeight + h * 0.06;
    final cornerRadius = w * 0.28;

    final bottlePath = Path();

    bottlePath.moveTo((w - lipWidth) / 2, lipHeight);
    bottlePath.lineTo((w - neckWidth) / 2, neckHeight);
    bottlePath.quadraticBezierTo(0, neckHeight + (bodyTop - neckHeight) * 0.5, 0, bodyTop);
    bottlePath.lineTo(0, h - cornerRadius);
    bottlePath.quadraticBezierTo(0, h, cornerRadius, h);
    bottlePath.lineTo(w - cornerRadius, h);
    bottlePath.quadraticBezierTo(w, h, w, h - cornerRadius);
    bottlePath.lineTo(w, bodyTop);
    bottlePath.quadraticBezierTo(w, neckHeight + (bodyTop - neckHeight) * 0.5, (w + neckWidth) / 2, neckHeight);
    bottlePath.lineTo((w + lipWidth) / 2, lipHeight);
    bottlePath.close();

    canvas.save();
    canvas.clipPath(bottlePath);

    _drawInteriorBackground(canvas, size);

    _drawLiquidLayers(canvas, size, bodyTop, h);

    _drawSkinOverlays(canvas, size);

    _drawGlassReflections(canvas, size, bodyTop);

    canvas.restore();

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

    final usableHeight = totalHeight - bodyTop - 6;
    final segmentHeight = usableHeight / bottle.capacity;

    double totalVolume = effectiveLayers.length.toDouble();
    if (drainAmount > 0.0) {
      totalVolume = max(0.0, totalVolume - drainAmount);
    }

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
        ));
      }
      accumulated += 1.0;
    }

    if (fillAmount > 0.0 && fillColor != null) {
      final fillBottom = totalVolume;
      final fillTop = min(totalVolume + fillAmount, bottle.capacity.toDouble());
      if (fillTop > fillBottom) {
        segments.add(_LiquidSegment(
          colorId: fillColor!,
          bottomVol: fillBottom,
          topVol: fillTop,
        ));
      }
    }

    for (var i = 0; i < segments.length; i++) {
      final seg = segments[i];
      final isTopSegment = (i == segments.length - 1);

      final yBottom = totalHeight - (seg.bottomVol * segmentHeight);
      final yTop = totalHeight - (seg.topVol * segmentHeight);

      final palette = AppColors.getLiquidPalette(seg.colorId);

      final layerPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            palette.highlight,
            palette.base,
            palette.shadow,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTRB(0, yTop, size.width, yBottom));

      final path = Path();
      path.moveTo(0, yBottom);
      path.lineTo(size.width, yBottom);

      if (isTopSegment) {
        final waveAmplitude = 2.8;
        final wavePoints = 12;
        for (var p = 0; p <= wavePoints; p++) {
          final x = size.width * (1.0 - p / wavePoints);
          final sineVal = sin(wavePhase + (p / wavePoints) * 2 * pi);
          final y = yTop + sineVal * waveAmplitude;
          path.lineTo(x, y);
        }
      } else {
        path.lineTo(size.width, yTop);
        path.lineTo(0, yTop);
      }

      path.close();
      canvas.drawPath(path, layerPaint);

      if (isTopSegment) {
        final meniscusPaint = Paint()
          ..color = palette.highlight.withAlpha(180)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;

        final meniscusPath = Path();
        meniscusPath.moveTo(0, yTop);
        for (var p = 0; p <= 12; p++) {
          final x = size.width * (p / 12.0);
          final sineVal = sin(wavePhase + (p / 12.0) * 2 * pi);
          final y = yTop + sineVal * 2.8;
          meniscusPath.lineTo(x, y);
        }
        canvas.drawPath(meniscusPath, meniscusPaint);
      }
    }
  }

  void _drawSkinOverlays(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (skinType == 'crystal') {
      final facetPaint = Paint()
        ..color = Colors.white.withAlpha(22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final fPath = Path();
      fPath.moveTo(w * 0.2, h * 0.2);
      fPath.lineTo(w * 0.8, h * 0.4);
      fPath.lineTo(w * 0.5, h * 0.8);
      fPath.close();

      fPath.moveTo(w * 0.8, h * 0.3);
      fPath.lineTo(w * 0.3, h * 0.65);
      fPath.lineTo(w * 0.7, h * 0.9);

      canvas.drawPath(fPath, facetPaint);
    } else if (skinType == 'gold') {
      final goldGlow = Paint()
        ..color = const Color(0x22FFD700)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.4, goldGlow);
    }
  }

  void _drawGlassReflections(Canvas canvas, Size size, double bodyTop) {
    final w = size.width;
    final h = size.height;

    final highlightPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withAlpha(110),
          Colors.white.withAlpha(20),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final streakPath = Path();
    strokeArcLeft(streakPath, w, h, bodyTop);
    canvas.drawPath(streakPath, highlightPaint);
  }

  void strokeArcLeft(Path p, double w, double h, double bodyTop) {
    p.moveTo(w * 0.12, bodyTop + 8);
    p.lineTo(w * 0.12, h * 0.88);
    p.quadraticBezierTo(w * 0.12, h * 0.94, w * 0.24, h * 0.94);
    p.lineTo(w * 0.28, h * 0.94);
    p.quadraticBezierTo(w * 0.18, h * 0.94, w * 0.18, h * 0.88);
    p.lineTo(w * 0.18, bodyTop + 8);
    p.close();
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
    Color borderColor;
    double borderWidth = 2.0;

    switch (skinType) {
      case 'neon':
        borderColor = AppColors.primaryCyan;
        borderWidth = 2.5;
        break;
      case 'crystal':
        borderColor = const Color(0xFF80DEEA);
        borderWidth = 2.2;
        break;
      case 'gold':
        borderColor = const Color(0xFFFFD700);
        borderWidth = 2.4;
        break;
      case 'dark':
        borderColor = const Color(0xFF64748B);
        borderWidth = 2.0;
        break;
      case 'glass':
      default:
        borderColor = AppColors.glassBorder;
        borderWidth = 2.0;
        break;
    }

    final borderPaint = Paint()
      ..color = isSelected ? AppColors.primaryCyan : borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawPath(bottlePath, borderPaint);

    final lipPaint = Paint()
      ..color = (isSelected ? AppColors.primaryCyan : borderColor).withAlpha(220)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth + 0.5;

    final w = size.width;
    final lipRect = RRect.fromRectAndRadius(
      Rect.fromLTWH((w - lipWidth) / 2, 0, lipWidth, lipHeight * 1.5),
      const Radius.circular(4),
    );
    canvas.drawRRect(lipRect, lipPaint);
  }

  @override
  bool shouldRepaint(covariant BottlePainter oldDelegate) {
    return oldDelegate.bottle != bottle ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.isHintSource != isHintSource ||
        oldDelegate.isHintTarget != isHintTarget ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.tiltAngle != tiltAngle ||
        oldDelegate.drainAmount != drainAmount ||
        oldDelegate.fillAmount != fillAmount ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.skinType != skinType;
  }
}
