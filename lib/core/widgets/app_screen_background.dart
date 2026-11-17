import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../constants/app_images.dart';

/// Shared backdrop for secondary screens (Levels, Shop, Daily, Settings, Leaderboard).
///
/// The background artwork contains the game logo; drawn sharp behind a translucent
/// overlay it ghosted through every screen header. Blurring it keeps the colour
/// and atmosphere while removing the distracting logo, and gives every screen
/// the same look.
class AppScreenBackground extends StatelessWidget {
  const AppScreenBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Soft-focus artwork
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18, tileMode: TileMode.clamp),
          child: Image.asset(AppImages.backGround, fit: BoxFit.cover),
        ),

        // Deep-ocean glass tint
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF07152B).withValues(alpha: 0.86),
                const Color(0xFF091F3D).withValues(alpha: 0.90),
                const Color(0xFF050E1B).withValues(alpha: 0.97),
              ],
              stops: const [0.0, 0.45, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Ambient light pools for depth
        const Positioned(
          top: -90,
          left: -70,
          child: _GlowOrb(size: 260, color: Color(0xFF00E5FF), alpha: 0.10),
        ),
        const Positioned(
          top: 220,
          right: -110,
          child: _GlowOrb(size: 280, color: Color(0xFF7C4DFF), alpha: 0.10),
        ),
        const Positioned(
          bottom: -120,
          left: -60,
          child: _GlowOrb(size: 300, color: Color(0xFF2979FF), alpha: 0.08),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color, required this.alpha});

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
