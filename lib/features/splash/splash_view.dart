import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:water_bottle_ais/core/constants/app_images.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'splash_controller.dart';

/// Animated Splash Screen
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  late final SplashController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SplashController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.startLoading(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF040D1A),
              Color(0xFF0A1E3D),
              Color(0xFF0D2B52),
              Color(0xFF061225),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Floating bubbles background
            const _SplashBubblesBackground(),

            // Ambient glow orbs
            Positioned(
              top: -80,
              left: -60,
              child: _SplashGlowOrb(
                size: 240,
                color: AppColors.primaryCyan,
                alpha: 0.08,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              right: -100,
              child: _SplashGlowOrb(
                size: 220,
                color: AppColors.primaryPurple,
                alpha: 0.07,
              ),
            ),
            Positioned(
              bottom: -100,
              left: -40,
              child: _SplashGlowOrb(
                size: 280,
                color: AppColors.primaryBlue,
                alpha: 0.06,
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Animated glowing ring behind logo
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer pulse ring
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryCyan.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1.15, 1.15),
                            duration: 2000.ms,
                            curve: Curves.easeInOut,
                          )
                          .fadeIn(duration: 800.ms),

                      // Middle glow ring
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryCyan.withValues(alpha: 0.15),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(1.0, 1.0),
                            end: const Offset(1.1, 1.1),
                            duration: 1500.ms,
                            curve: Curves.easeInOut,
                          ),

                      // Logo container
                      Container(
                        width: 115,
                        height: 115,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C8E8), Color(0xFF1565C0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryCyan.withAlpha(140),
                              blurRadius: 36,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: AppColors.primaryBlue.withAlpha(80),
                              blurRadius: 50,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Image.asset(AppImages.appLogo),
                      )
                          .animate()
                          .scale(duration: 900.ms, curve: Curves.elasticOut)
                          .shimmer(delay: 600.ms, duration: 1400.ms, color: Colors.white24),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Game Title with enhanced shader
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF00E5FF),
                        Color(0xFF80D8FF),
                        Colors.white,
                        Color(0xFF80D8FF),
                        Color(0xFF00E5FF),
                      ],
                      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                    ).createShader(bounds),
                    child: Text(
                      AppConstants.appName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3.0,
                        color: Colors.white,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 700.ms)
                      .slideY(begin: 0.3, end: 0)
                      .then()
                      .shimmer(duration: 2000.ms, delay: 1000.ms, color: Colors.white38),

                  const SizedBox(height: 8),

                  // Tagline with water drop icon
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.water_drop_rounded,
                        color: AppColors.primaryCyan.withValues(alpha: 0.6),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Pour, Sort & Relax',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.water_drop_rounded,
                        color: AppColors.primaryCyan.withValues(alpha: 0.6),
                        size: 16,
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

                  const SizedBox(height: 56),

                  // Enhanced Loading Bar with glow
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Obx(() => Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryCyan.withValues(
                                    alpha: 0.15 + controller.progress.value * 0.25),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: controller.progress.value,
                              minHeight: 8,
                              backgroundColor: Colors.white.withValues(alpha: 0.08),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryCyan),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Loading ${(controller.progress.value * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryCyan.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    )),
                  ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

                  const Spacer(flex: 2),

                  // Footer branding
                  Opacity(
                    opacity: 0.5,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          color: AppColors.primaryCyan.withValues(alpha: 0.6),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Powered by Arun Innovation Studio',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 800.ms, duration: 600.ms),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft glow orb for splash ambient lighting
class _SplashGlowOrb extends StatelessWidget {
  const _SplashGlowOrb({required this.size, required this.color, required this.alpha});

  final double size;
  final Color color;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

/// Animated floating water bubbles on the splash screen
class _SplashBubblesBackground extends StatefulWidget {
  const _SplashBubblesBackground();

  @override
  State<_SplashBubblesBackground> createState() => _SplashBubblesBackgroundState();
}

class _SplashBubblesBackgroundState extends State<_SplashBubblesBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_SplashBubble> _bubbles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _bubbles = List.generate(20, (_) => _SplashBubble.random(_random));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _SplashBubblesPainter(_bubbles),
        );
      },
    );
  }
}

class _SplashBubble {
  double x, y, radius, speed, opacity, wobble, phase;

  _SplashBubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
    required this.wobble,
    required this.phase,
  });

  factory _SplashBubble.random(Random r) {
    return _SplashBubble(
      x: r.nextDouble(),
      y: r.nextDouble() * 1.5 + 0.5, // start below or at bottom
      radius: 1.5 + r.nextDouble() * 3.5,
      speed: 0.0006 + r.nextDouble() * 0.0015,
      opacity: 0.06 + r.nextDouble() * 0.18,
      wobble: 0.003 + r.nextDouble() * 0.01,
      phase: r.nextDouble() * 2 * pi,
    );
  }
}

class _SplashBubblesPainter extends CustomPainter {
  final List<_SplashBubble> bubbles;

  _SplashBubblesPainter(this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;

    for (final b in bubbles) {
      b.y -= b.speed;
      if (b.y < -0.05) {
        b.y = 1.1;
        b.x = Random().nextDouble();
      }

      final dx = b.x * size.width + sin(time * 0.6 + b.phase) * b.wobble * size.width;
      final dy = b.y * size.height;

      // Bubble body
      paint.color = const Color(0xFF00E5FF).withValues(alpha: b.opacity);
      canvas.drawCircle(Offset(dx, dy), b.radius, paint);

      // Bubble highlight
      paint.color = Colors.white.withValues(alpha: b.opacity * 0.4);
      canvas.drawCircle(
        Offset(dx - b.radius * 0.3, dy - b.radius * 0.3),
        b.radius * 0.4,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SplashBubblesPainter oldDelegate) => true;
}
