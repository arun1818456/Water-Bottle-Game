import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../services/audio_service.dart';

/// Reusable cyber-styled dialog shown when an ad or online feature
/// cannot proceed because the internet connection is off.
class InternetRequiredDialog extends StatelessWidget {
  final String title;
  final String message;

  const InternetRequiredDialog({
    super.key,
    required this.title,
    required this.message,
  });

  static bool _isShowing = false;

  /// Helper to safely show the dialog from anywhere without closing parent dialogs
  static Future<void> show({
    String title = 'Internet Required',
    required String message,
  }) async {
    if (_isShowing) return;
    final context = Get.overlayContext ?? Get.context;
    if (context == null) return;

    _isShowing = true;
    try {
      await Get.dialog(
        InternetRequiredDialog(title: title, message: message),
        barrierDismissible: true,
      );
    } finally {
      _isShowing = false;
    }
  }

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
              Color(0xFF162A45),
              Color(0xFF0D1B2A),
              Color(0xFF08101A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFFF9100).withValues(alpha: 0.7),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9100).withValues(alpha: 0.25),
              blurRadius: 28,
              spreadRadius: 1,
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
            // Glowing Offline Icon Badge
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
                    color: const Color(0xFFFF6D00).withValues(alpha: 0.45),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Color(0xFFFFD180),
                size: 30,
              ),
            ).animate().scale(duration: 250.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 14),

            // Title
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFFFD180),
                  Color(0xFFFFFFFF),
                  Color(0xFFFF9100),
                ],
              ).createShader(bounds),
              child: Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Informative Message Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFFFB74D),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFE0B2),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Dismiss / OK Button
            GestureDetector(
              onTap: () {
                AudioService.to.playButtonClick();
                Get.back();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9100), Color(0xFFFF6D00)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6D00).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'GOT IT',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
