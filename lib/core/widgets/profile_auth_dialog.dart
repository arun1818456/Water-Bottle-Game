import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/leaderboard/leaderboard_controller.dart';
import '../services/audio_service.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import '../utils/number_formatter.dart';

/// Luxury Glassmorphic Google Account Hub Dialog
/// Displays Google Profile, Cloud Sync status, Live Stats, and Account Connectivity
class ProfileAuthDialog extends StatefulWidget {
  final int initialTab;
  const ProfileAuthDialog({super.key, this.initialTab = 0});

  @override
  State<ProfileAuthDialog> createState() => _ProfileAuthDialogState();
}

class _ProfileAuthDialogState extends State<ProfileAuthDialog> {
  final storage = StorageService.to;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AudioService.to.playButtonClick();

    final err = await FirebaseService.to.signInWithGoogle();

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (err == null) {
      if (Get.isRegistered<LeaderboardController>()) {
        Get.find<LeaderboardController>().refreshLeaderboard(invalidateCache: true);
      }
      Get.back();
      Get.snackbar(
        'Welcome!',
        'Logged in with Google successfully. Your cloud data is synced!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00E676).withValues(alpha: 0.95),
        colorText: Colors.black,
        duration: const Duration(seconds: 3),
      );
    } else if (err != 'Google Sign-In canceled.') {
      setState(() => _errorMessage = err);
    }
  }

  Future<void> _handleSignOut() async {
    AudioService.to.playButtonClick();
    final confirmed = await Get.dialog<bool>(
      const _SignOutConfirmDialog(),
      barrierDismissible: true,
    );
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    await FirebaseService.to.signOut();
    if (Get.isRegistered<LeaderboardController>()) {
      Get.find<LeaderboardController>().refreshLeaderboard(invalidateCache: true);
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
    Get.snackbar(
      'Signed Out',
      'Your progress is safely backed up in Google Cloud. Local progress on this device has been reset.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.95),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentUserEmail = storage.userEmail.value;
      final currentUserName = storage.getOrCreateUserName();
      final currentPhotoUrl = storage.userPhotoUrl.value;
      final currentFlag = storage.userCountryFlag.value;
      final totalStars = storage.totalStarsCollected;
      final totalCoins = storage.coins.value;
      final unlockedLevel = storage.unlockedLevel.value;
      final isLoggedIn = currentUserEmail.isNotEmpty;

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 390),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0E2442),
                Color(0xFF07172B),
                Color(0xFF040E1B),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.22),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Colors.black87,
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(29),
            child: Stack(
              children: [
                // Ambient Background Glows
                Positioned(
                  top: -50,
                  right: -40,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  left: -50,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00E676).withValues(alpha: 0.08),
                    ),
                  ),
                ),

                // Main Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header: Title Pill & Close Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0F3663), Color(0xFF0A2240)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'G',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF4285F4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isLoggedIn ? 'GOOGLE PROFILE' : 'CONNECT ACCOUNT',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                AudioService.to.playButtonClick();
                                Get.back();
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        if (isLoggedIn) ...[
                          // Profile Photo with Glow Ring & Country Flag Pill
                          Stack(
                            alignment: Alignment.bottomRight,
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF00E5FF), Color(0xFF00E676)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(3),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF0A2244),
                                  ),
                                  child: ClipOval(
                                    child: currentPhotoUrl.isNotEmpty
                                        ? Image.network(
                                            currentPhotoUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(
                                              Icons.person_rounded,
                                              size: 52,
                                              color: Colors.white,
                                            ),
                                            loadingBuilder: (context, child, progress) {
                                              if (progress == null) return child;
                                              return const Center(
                                                child: SizedBox(
                                                  width: 26,
                                                  height: 26,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                        Color(0xFF00E5FF)),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : const Icon(
                                            Icons.person_rounded,
                                            size: 52,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0A2244),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF00E5FF),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    currentFlag,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Player Display Name
                          Text(
                            currentUserName,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Gmail Address Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.email_outlined, size: 13, color: Colors.white60),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    currentUserEmail,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Cloud Synced Status Chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF00E676).withValues(alpha: 0.6),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.cloud_done_rounded, color: Color(0xFF00E676), size: 15),
                                SizedBox(width: 6),
                                Text(
                                  'Cloud Synced & Active',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF00E676),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Live Game Stats Card Row
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: Row(
                              children: [
                                _buildStatColumn(
                                  icon: Icons.military_tech_rounded,
                                  iconColor: const Color(0xFF00E5FF),
                                  value: 'Lvl $unlockedLevel',
                                  label: 'Progress',
                                ),
                                _buildStatDivider(),
                                _buildStatColumn(
                                  icon: Icons.star_rounded,
                                  iconColor: const Color(0xFFFFD700),
                                  value: totalStars.formatCompact,
                                  label: 'Stars',
                                ),
                                _buildStatDivider(),
                                _buildStatColumn(
                                  icon: Icons.monetization_on_rounded,
                                  iconColor: const Color(0xFFFFB300),
                                  value: totalCoins.formatCompact,
                                  label: 'Coins',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Sign Out CTA Button
                          GestureDetector(
                            onTap: _handleSignOut,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5252).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFFF5252).withValues(alpha: 0.65),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.logout_rounded,
                                    color: Color(0xFFFF8A8A),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Sign Out From Google',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFFF8A8A),
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          // Not Logged In View
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  blurRadius: 18,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF4285F4),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'SIGN IN WITH GOOGLE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Connect your Google Account to automatically backup your levels, stars & coins to the cloud and show your real rank on global leaderboards!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.72),
                              height: 1.45,
                            ),
                          ),

                          if (_errorMessage != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFF5252)),
                              ),
                              child: Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFFF8A8A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 22),

                          // Google Sign-In Button
                          GestureDetector(
                            onTap: _isLoading ? null : _handleGoogleSignIn,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    blurRadius: 14,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: _isLoading
                                  ? const Center(
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF4285F4),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'G',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'CONTINUE WITH GOOGLE',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF1E293B),
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStatColumn({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }
}

class _SignOutConfirmDialog extends StatelessWidget {
  const _SignOutConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF15253F), Color(0xFF0A1424)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFF5252).withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5252).withValues(alpha: 0.22),
              blurRadius: 22,
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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                border: Border.all(color: const Color(0xFFFF5252), width: 1.5),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFFF8A8A),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sign Out?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your levels, stars, and coins are safely backed up in your Google account.\n\nSigning out will reset local progress on this device until you sign back in.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.78),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      AudioService.to.playButtonClick();
                      Get.back(result: false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      AudioService.to.playButtonClick();
                      Get.back(result: true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5252), Color(0xFFD50000)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF5252).withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
