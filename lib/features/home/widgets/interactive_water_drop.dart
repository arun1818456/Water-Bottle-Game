import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class InteractiveWaterDrop extends StatefulWidget {
  const InteractiveWaterDrop({super.key});

  @override
  State<InteractiveWaterDrop> createState() => _InteractiveWaterDropState();
}

class _InteractiveWaterDropState extends State<InteractiveWaterDrop> {
  bool _isBursting = false;
  int _counter = 0; // To trigger rebuild/restart of animation if needed

  void _handleTap() {
    if (_isBursting) return;

    setState(() {
      _isBursting = true;
      _counter++;
    });

    // Automatically refill after a short delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isBursting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 25,
        height: 25,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Glow (Pulse)
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryCyan.withAlpha(_isBursting ? 0 : 100),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ).animate(target: _isBursting ? 0 : 1).shimmer(duration: 2.seconds),

            // The main drop or burst particles
            if (!_isBursting)
              const Icon(
                Icons.water_drop_rounded,
                size: 25,
                color: Colors.white,
              )
                  .animate(key: ValueKey('drop_$_counter'))
                  .scale(
                    begin: const Offset(0.2, 0.2),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .moveY(begin: 20, end: 0, duration: 600.ms)
            else ...[
              // Burst effect: Rapid expansion and fade out
              const Icon(
                Icons.water_drop_rounded,
                size: 28,
                color: Colors.white,
              )
                  .animate()
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(2.2, 2.2),
                    duration: 200.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeOut(duration: 200.ms),

              // Particles
              ...List.generate(8, (i) {
                final angle = (i * 45) * math.pi / 180;
                final dist = 45.0;
                return Positioned(
                  child: const Icon(Icons.circle, size: 8, color: Colors.white)
                      .animate()
                      .move(
                        begin: Offset.zero,
                        end: Offset(math.cos(angle) * dist, math.sin(angle) * dist),
                        duration: 300.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .scale(begin: const Offset(1, 1), end: const Offset(0.1, 0.1), duration: 300.ms)
                      .fadeOut(duration: 300.ms),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
