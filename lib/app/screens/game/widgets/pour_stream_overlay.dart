import 'dart:math';
import 'package:water_bottle_ais/exports.dart';

/// Overlay widget rendering the liquid stream flowing between two bottles during pour animation
class PourStreamOverlay extends StatelessWidget {
  final Offset? startPoint;
  final Offset? endPoint;
  final int? colorId;
  final double streamProgress;

  const PourStreamOverlay({
    super.key,
    required this.startPoint,
    required this.endPoint,
    required this.colorId,
    required this.streamProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (streamProgress <= 0.01 || startPoint == null || endPoint == null || colorId == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _StreamPainter(
            start: startPoint!,
            end: endPoint!,
            colorId: colorId!,
            progress: streamProgress,
          ),
        ),
      ),
    );
  }
}

class _StreamPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final int colorId;
  final double progress;

  _StreamPainter({
    required this.start,
    required this.end,
    required this.colorId,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.01) return;

    final palette = AppColors.getLiquidPalette(colorId);

    final streamWidth = 8.0 * (1.0 - (progress - 0.7).clamp(0.0, 0.3) / 0.3);

    final streamPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          palette.highlight,
          palette.base,
          palette.shadow,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromPoints(start, end))
      ..strokeWidth = streamWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final midX = (start.dx + end.dx) / 2;
    final midY = min(start.dy, end.dy) - 10;
    final controlPoint = Offset(midX, midY);

    final reach = (progress * 2.0).clamp(0.0, 1.0);
    final currentEnd = Offset.lerp(start, end, reach)!;

    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, currentEnd.dx, currentEnd.dy);

    canvas.drawPath(path, streamPaint);

    if (progress > 0.4) {
      final splashPaint = Paint()
        ..color = palette.highlight.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;

      final rand = Random(42);
      for (var i = 0; i < 6; i++) {
        final angle = rand.nextDouble() * pi;
        final dist = 4.0 + rand.nextDouble() * 12.0 * (progress - 0.4);
        final dropX = end.dx + cos(angle) * dist;
        final dropY = end.dy - sin(angle) * dist * 0.8;
        final radius = 2.0 + rand.nextDouble() * 2.0;

        canvas.drawCircle(Offset(dropX, dropY), radius, splashPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StreamPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.colorId != colorId;
  }
}
