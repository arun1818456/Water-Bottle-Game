import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_screen_background.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_images.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/widgets/profile_auth_dialog.dart';
import 'settings_controller.dart';

/// Modern High-Aesthetic Settings screen
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final SettingsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController());
  }

  @override
  Widget build(BuildContext context) {
    final storage = controller.storage;

    return Scaffold(
      body: Stack(
        children: [
          // Ambient game background
          const Positioned.fill(child: AppScreenBackground()),

          SafeArea(
            child: Obx(() {
              // Reactive values observed by this top-level Obx
              final soundEnabled = storage.soundEnabled.value;
              final musicEnabled = storage.musicEnabled.value;
              final vibrationEnabled = storage.vibrationEnabled.value;
              final version = controller.versionString.value;

              return Column(
                children: [
                  // Top Navigation Header
                  _buildTopBar(),

                  // Scrollable Content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // App Brand Card
                        _buildBrandHeader(version),

                        const SizedBox(height: 18),

                        // Section 0: Account & Google Connect
                        _buildSectionLabel('ACCOUNT & CLOUD BACKUP'),
                        const SizedBox(height: 8),
                        _buildAccountCard(storage),

                        const SizedBox(height: 18),

                        // Section 1: Audio & Haptics
                        _buildSectionLabel('AUDIO & SENSORY'),
                        const SizedBox(height: 8),
                        _buildCardContainer([
                          _buildSwitchRow(
                            icon: Icons.volume_up_rounded,
                            iconColor: const Color(0xFF00E5FF),
                            title: 'Sound Effects',
                            subtitle: 'Liquid pour, splashes & click sounds',
                            value: soundEnabled,
                            onChanged: controller.toggleSound,
                          ),
                          _buildDivider(),
                          _buildSwitchRow(
                            icon: Icons.music_note_rounded,
                            iconColor: const Color(0xFF7C4DFF),
                            title: 'Background Music',
                            subtitle: 'Relaxing ambient puzzle melodies',
                            value: musicEnabled,
                            onChanged: controller.toggleMusic,
                          ),
                          _buildDivider(),
                          _buildSwitchRow(
                            icon: Icons.vibration_rounded,
                            iconColor: const Color(0xFF00E676),
                            title: 'Vibration & Haptics',
                            subtitle: 'Tactile sensory touch responses',
                            value: vibrationEnabled,
                            onChanged: controller.toggleVibration,
                          ),
                        ]),

                        const SizedBox(height: 20),

                        // Section 2: About & Community
                        _buildSectionLabel('ABOUT & COMMUNITY'),
                        const SizedBox(height: 8),
                        _buildCardContainer([
                          _buildNavActionRow(
                            icon: Icons.privacy_tip_rounded,
                            iconColor: const Color(0xFF00E5FF),
                            title: 'Privacy Policy',
                            subtitle: 'Terms of service & privacy security',
                            onTap: controller.showPrivacyPolicy,
                          ),
                          _buildDivider(),
                          _buildNavActionRow(
                            icon: Icons.system_update_rounded,
                            iconColor: const Color(0xFF42A5F5),
                            title: 'Update App',
                            subtitle: 'Get the latest features & new levels',
                            onTap: controller.updateApp,
                          ),
                          _buildDivider(),
                          _buildNavActionRow(
                            icon: Icons.star_rounded,
                            iconColor: const Color(0xFFFFD700),
                            title: 'Rate App',
                            subtitle: 'Support us with a 5-star review',
                            onTap: controller.rateApp,
                          ),
                          _buildDivider(),
                          _buildNavActionRow(
                            icon: Icons.share_rounded,
                            iconColor: const Color(0xFF00E676),
                            title: 'Share With Friends',
                            subtitle: 'Invite friends to beat Level 120',
                            onTap: controller.shareApp,
                          ),
                        ]),

                        const SizedBox(height: 20),

                        // Section 3: Danger Zone
                        _buildSectionLabel('GAME DATA'),
                        const SizedBox(height: 8),
                        _buildDangerCard(
                          icon: Icons.delete_forever_rounded,
                          title: 'Reset Progress',
                          subtitle: 'Clear all unlocked levels, coins & skins',
                          onTap: controller.confirmResetProgress,
                        ),

                        const SizedBox(height: 28),

                        // Version & Studio Footer
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Text(
                                  '${AppConstants.appName} $version',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Powered by Arun Innovation Studio',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Top Bar with Glass Back Button
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 18, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PressableScale(
            onTap: () => Get.back(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF0E2A52).withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1E60A8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF80E5FF),
                    Color(0xFFFFFFFF),
                    Color(0xFFFFD54F),
                  ],
                ).createShader(bounds),
                child: const Text(
                  'SETTINGS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
              ),
              const Text(
                'Customize your game preferences',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 42), // Balance spacing
        ],
      ),
    );
  }

  /// App Brand Hero Banner
  Widget _buildBrandHeader(String version) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF113465), Color(0xFF0B2142)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF268AFF).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0072FF).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // App Logo Container
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                  blurRadius: 12,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                AppImages.appLogo,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AIS Water Bottle',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Pour, Sort & Relax Puzzle Game',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              version,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF80D8FF),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  /// Dedicated Google Sign-In, Sign-Up & Account Hub in Settings
  Widget _buildAccountCard(StorageService storage) {
    return Obx(() {
      final isLoggedIn = storage.userEmail.value.isNotEmpty;
      final email = storage.userEmail.value;
      final photoUrl = storage.userPhotoUrl.value;
      final flag = storage.userCountryFlag.value;
      final userName = storage.getOrCreateUserName();
      final avatarEmoji = storage.userAvatarEmoji.value;

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoggedIn
                ? [
                    const Color(0xFF0F3663).withValues(alpha: 0.9),
                    const Color(0xFF0A2240).withValues(alpha: 0.9),
                  ]
                : [
                    const Color(0xFF143767).withValues(alpha: 0.9),
                    const Color(0xFF0C2448).withValues(alpha: 0.95),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isLoggedIn
                ? const Color(0xFF00E676).withValues(alpha: 0.45)
                : const Color(0xFF4285F4).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isLoggedIn
                  ? const Color(0xFF00E676).withValues(alpha: 0.12)
                  : const Color(0xFF4285F4).withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (isLoggedIn) ...[
                  // Logged In State
                  Row(
                    children: [
                      // Profile Picture or Avatar with Flag
                      Stack(
                        alignment: Alignment.bottomRight,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00E5FF), Color(0xFF00E676)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E676).withValues(alpha: 0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF0A2244),
                              ),
                              child: ClipOval(
                                child: photoUrl.isNotEmpty
                                    ? Image.network(
                                        photoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(
                                          Icons.person_rounded,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person_rounded,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A2244),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF00E5FF),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                flag,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E676).withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF00E676).withValues(alpha: 0.6),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 11,
                                        color: Color(0xFF00E676),
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        'SYNCED',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF00E676),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Manage / Sign Out CTA button
                  GestureDetector(
                    onTap: () {
                      AudioService.to.playButtonClick();
                      Get.dialog(const ProfileAuthDialog());
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.manage_accounts_rounded,
                            size: 16,
                            color: Color(0xFF00E5FF),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Manage Account / Sign Out',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF80D8FF),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Guest / Sign Up State
                  Row(
                    children: [
                      // Guest Avatar / Icon
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E2A52),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1E60A8),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            avatarEmoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(flag, style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                                  width: 0.8,
                                ),
                              ),
                              child: const Text(
                                'GUEST PLAYER • NOT BACKED UP',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFFD54F),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Dedicated Sign In / Sign Up with Google Button
                  GestureDetector(
                    onTap: () {
                      AudioService.to.playButtonClick();
                      Get.dialog(const ProfileAuthDialog());
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF4285F4),
                            ),
                            child: const Center(
                              child: Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'SIGN UP / SIGN IN WITH GOOGLE',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1F2937),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Backup levels, coins, stars & unlock global rankings',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.05, end: 0);
    });
  }

  /// Section Label
  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFFB0C4DE),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Card Container for groupings
  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C2448).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF1E5696).withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.98, 0.98));
  }

  /// Switch Row for Audio / Vibration toggles
  Widget _buildSwitchRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: iconColor,
              inactiveThumbColor: Colors.white54,
              inactiveTrackColor: Colors.white12,
            ),
          ),
        ],
      ),
    );
  }

  /// Navigation Action Row
  Widget _buildNavActionRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Danger Card for Reset Progress
  Widget _buildDangerCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E0E18).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFFF5252).withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5252).withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Color(0xFFFF5252),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF8A80),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: const Text(
                'RESET',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFF8A80),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  /// Subtle Row Divider
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 68, right: 16),
      child: Divider(
        color: Colors.white.withValues(alpha: 0.07),
        height: 1,
        thickness: 1,
      ),
    );
  }
}
