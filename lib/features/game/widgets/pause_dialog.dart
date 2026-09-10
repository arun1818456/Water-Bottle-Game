import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_theme.dart';

/// Pause menu dialog with sound toggles and level navigation
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.backgroundMid.withAlpha(245),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.glassBorder, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME PAUSED',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Sound & Vibration quick toggles row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: AppTheme.glassBox(borderRadius: 16),
              child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Sound Toggle
                      IconButton(
                        icon: Icon(
                          storage.soundEnabled.value ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                          color: storage.soundEnabled.value ? AppColors.primaryCyan : Colors.white38,
                          size: 28,
                        ),
                        onPressed: () {
                          storage.setSoundEnabled(!storage.soundEnabled.value);
                          AudioService.to.playButtonClick();
                        },
                      ),
                      // Music Toggle
                      IconButton(
                        icon: Icon(
                          storage.musicEnabled.value ? Icons.music_note_rounded : Icons.music_off_rounded,
                          color: storage.musicEnabled.value ? AppColors.primaryCyan : Colors.white38,
                          size: 28,
                        ),
                        onPressed: () {
                          storage.setMusicEnabled(!storage.musicEnabled.value);
                          AudioService.to.playButtonClick();
                        },
                      ),
                      // Vibration Toggle
                      IconButton(
                        icon: Icon(
                          storage.vibrationEnabled.value ? Icons.vibration_rounded : Icons.smartphone_rounded,
                          color: storage.vibrationEnabled.value ? AppColors.primaryCyan : Colors.white38,
                          size: 28,
                        ),
                        onPressed: () {
                          storage.setVibrationEnabled(!storage.vibrationEnabled.value);
                          AudioService.to.playButtonClick();
                        },
                      ),
                    ],
                  )),
            ),

            const SizedBox(height: 24),

            // Resume Button
            GestureDetector(
              onTap: () {
                AudioService.to.playButtonClick();
                Get.back();
                onResume();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: AppTheme.gradientButtonBox(),
                child: const Center(
                  child: Text(
                    'RESUME',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF002244),
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Restart Button
            GestureDetector(
              onTap: () {
                AudioService.to.playButtonClick();
                Get.back();
                onRestart();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: AppTheme.glassBox(borderRadius: 16),
                child: const Center(
                  child: Text(
                    'RESTART LEVEL',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Level Select / Home Button
            TextButton.icon(
              onPressed: () {
                AudioService.to.playButtonClick();
                Get.back();
                onHome();
              },
              icon: const Icon(Icons.grid_view_rounded, color: Colors.white70),
              label: const Text('Exit to Level Select', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}
