import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/storage_service.dart';

/// Modern Gaming Pause Menu Dialog with Glassmorphism and Neon Accents
class PauseDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const PauseDialog({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.to;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF091E3A),
              Color(0xFF06152B),
              Color(0xFF030D1C),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
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
            // Top Glowing Pause Badge
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF14457F), Color(0xFF092244)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: const Color(0xFF00E5FF),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(
                Icons.pause_rounded,
                color: Color(0xFF00E5FF),
                size: 32,
              ),
            ),

            const SizedBox(height: 12),

            // Shader Mask Title
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF80E5FF),
                  Color(0xFFFFFFFF),
                  Color(0xFF00E5FF),
                ],
              ).createShader(bounds),
              child: const Text(
                'GAME PAUSED',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Status Subtitle Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Text(
                'TAKE A BREATH',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF80D8FF),
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Sound, Music, Vibration Controls Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF051326).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF1E5898).withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAudioSettingToggle(
                        iconOn: Icons.volume_up_rounded,
                        iconOff: Icons.volume_off_rounded,
                        label: 'SOUND',
                        isEnabled: storage.soundEnabled.value,
                        onTap: () {
                          storage.setSoundEnabled(!storage.soundEnabled.value);
                          AudioService.to.playButtonClick();
                        },
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      _buildAudioSettingToggle(
                        iconOn: Icons.music_note_rounded,
                        iconOff: Icons.music_off_rounded,
                        label: 'MUSIC',
                        isEnabled: storage.musicEnabled.value,
                        onTap: () {
                          storage.setMusicEnabled(!storage.musicEnabled.value);
                          AudioService.to.playButtonClick();
                        },
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      _buildAudioSettingToggle(
                        iconOn: Icons.vibration_rounded,
                        iconOff: Icons.smartphone_rounded,
                        label: 'VIBE',
                        isEnabled: storage.vibrationEnabled.value,
                        onTap: () {
                          storage.setVibrationEnabled(!storage.vibrationEnabled.value);
                          AudioService.to.playButtonClick();
                        },
                      ),
                    ],
                  )),
            ),

            const SizedBox(height: 22),

            // Resume Button (Primary Glowing CTA)
            GestureDetector(
              onTap: () {
                AudioService.to.playButtonClick();
                Get.back();
                onResume();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF0088FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF001E3C),
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'RESUME GAME',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF001E3C),
                        letterSpacing: 1.2,
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
                  color: const Color(0xFF0A2240).withValues(alpha: 0.8),
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

            const SizedBox(height: 12),

            // Home Button (Purple Accent Glass)
            GestureDetector(
              onTap: () {
                AudioService.to.playButtonClick();
                Get.back();
                onHome();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2240).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_rounded,
                      color: Color(0xFFB388FF),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'MAIN MENU',
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

  /// Helper for sound/music/vibration toggle circular item
  Widget _buildAudioSettingToggle({
    required IconData iconOn,
    required IconData iconOff,
    required String label,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    const activeColor = Color(0xFF00E5FF);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isEnabled
                  ? activeColor.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isEnabled
                    ? activeColor
                    : Colors.white24,
                width: 1.5,
              ),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isEnabled ? iconOn : iconOff,
              color: isEnabled ? activeColor : Colors.white38,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isEnabled ? const Color(0xFF80D8FF) : Colors.white38,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
