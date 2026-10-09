import 'package:water_bottle_ais/exports.dart';

/// Popup modal when no valid moves remain
class DefeatDialog extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onRestart;
  final VoidCallback onAddBottle;

  const DefeatDialog({
    super.key,
    required this.onUndo,
    required this.onRestart,
    required this.onAddBottle,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.backgroundMid.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.accentCoral.withValues(alpha: 0.55), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentCoral.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentCoral.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.block_flipped,
                size: 48,
                color: AppColors.accentCoral,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'NO MOVES LEFT!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'You are stuck! Choose an assist or restart to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            GestureDetector(
              onTap: () {
                AudioService.to.playButtonClick();
                Get.back();
                onAddBottle();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accentNeonGreen, Color(0xFF00B0FF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Add Extra Bottle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: () {
                AudioService.to.playButtonClick();
                Get.back();
                onUndo();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: AppTheme.glassBox(
                  color: AppColors.glassFillHeavy,
                  borderRadius: 16,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.undo_rounded, color: AppColors.primaryCyan, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Undo Last Move',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: () {
                AudioService.to.playButtonClick();
                Get.back();
                onRestart();
              },
              icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
              label: const Text('Restart Level', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}
