import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/services/audio_service.dart';

/// Modern Gaming Dialog shown when no valid matching pours remain
class DefeatDialog extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onRestart;
  final VoidCallback onAddBottle;
  final bool extraBottleDisabled;

  const DefeatDialog({
    super.key,
    required this.onUndo,
    required this.onRestart,
    required this.onAddBottle,
    this.extraBottleDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF261208),
              Color(0xFF180A04),
              Color(0xFF0D0402),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFFFF6D00).withValues(alpha: 0.6),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6D00).withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: 2,
            ),
            const BoxShadow(
              color: Colors.black87,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Glowing Lock / Stuck Badge
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF8D3000), Color(0xFF4A1800)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: const Color(0xFFFF9100),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6D00).withValues(alpha: 0.4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(
                Icons.grid_off_rounded,
                color: Color(0xFFFFD180),
                size: 30,
              ),
            ),

            const SizedBox(height: 12),

            // Shader Mask Title
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFFFD180),
                  Color(0xFFFFFFFF),
                  Color(0xFFFF9100),
                ],
              ).createShader(bounds),
              child: const Text(
                'PUZZLE STUCK!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.8,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Subtitle Status Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6D00).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFF6D00).withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: const Text(
                'NO MATCHING POURS LEFT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFFB74D),
                  letterSpacing: 1.0,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Informative Explanation Glass Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFFFB74D),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No bottles can receive water right now. Add a bottle or undo to unlock the board!',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFE0B2),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Add Extra Bottle Button (Primary Glowing CTA)
            Opacity(
              opacity: extraBottleDisabled ? 0.45 : 1.0,
              child: GestureDetector(
                onTap: extraBottleDisabled
                    ? null
                    : () {
                        AudioService.to.playButtonClick();
                        Get.back();
                        onAddBottle();
                      },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: extraBottleDisabled
                          ? [Colors.grey.shade700, Colors.grey.shade900]
                          : [const Color(0xFF00E676), const Color(0xFF00B0FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: !extraBottleDisabled
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00E676).withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_circle_outline_rounded,
                        color: Color(0xFF002233),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        extraBottleDisabled
                            ? 'ADD EXTRA BOTTLE (LIMIT REACHED)'
                            : 'ADD EXTRA BOTTLE (AD)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF002233),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Undo Button (Purple Accent Glass)
            GestureDetector(
              onTap: () {
                AudioService.to.playButtonClick();
                Get.back();
                onUndo();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFF231024).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9C27B0).withValues(alpha: 0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.undo_rounded,
                      color: Color(0xFFE040FB),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'UNDO LAST MOVE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Restart Button (Amber Accent Glass)
            GestureDetector(
              onTap: () {
                AudioService.to.playButtonClick();
                Get.back();
                onRestart();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFF231808).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: Color(0xFFFFB300),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'RESTART LEVEL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 280.ms, curve: Curves.easeOutBack).fadeIn(duration: 220.ms);
  }
}
