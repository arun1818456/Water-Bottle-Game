import 'dart:math';
import 'package:lottie/lottie.dart';
import 'package:water_bottle_ais/exports.dart';

class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({super.key});

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_ConfettiPiece> _particles = [];
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();

    final colors = [
      const Color(0xFF00E5FF),
      const Color(0xFFFFD600),
      const Color(0xFFFF1744),
      const Color(0xFF00E676),
      const Color(0xFF7C4DFF),
      const Color(0xFFFF6D00),
      const Color(0xFFE040FB),
    ];

    for (var i = 0; i < 70; i++) {
      _particles.add(_ConfettiPiece(
        x: 0.2 + _rand.nextDouble() * 0.6,
        y: -0.1 - _rand.nextDouble() * 0.2,
        vx: (_rand.nextDouble() - 0.5) * 0.6,
        vy: 0.8 + _rand.nextDouble() * 0.8,
        color: colors[_rand.nextInt(colors.length)],
        size: 8.0 + _rand.nextDouble() * 8.0,
        rotation: _rand.nextDouble() * 2 * pi,
        rotationSpeed: (_rand.nextDouble() - 0.5) * 8.0,
      ));
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;

            return Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: t,
                  ),
                ),
                Center(
                  child: Opacity(
                    opacity: (1.0 - t).clamp(0.0, 1.0),
                    child: SizedBox(
                      width: 260,
                      height: 260,
                      child: Lottie.asset(
                        AssetsConstants.lottieCelebration,
                        repeat: false,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ConfettiPiece {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final Color color;
  final double size;
  final double rotation;
  final double rotationSpeed;

  _ConfettiPiece({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> particles;
  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (final p in particles) {
      final currentX = (p.x + p.vx * progress) * w;
      final currentY = (p.y + p.vy * progress * 1.5) * h;
      final currentRot = p.rotation + p.rotationSpeed * progress;

      final paint = Paint()
        ..color = p.color.withValues(alpha: (1.0 - progress * 0.8).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRot);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
