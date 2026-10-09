import 'package:water_bottle_ais/exports.dart';

/// Modern High-Aesthetic Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final storage = controller.storage;

    return Scaffold(
      body: Stack(
        children: [
          // Ambient game background
          Positioned.fill(
            child: Image.asset(
              AppImages.backGround,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF07152B).withValues(alpha: 0.90),
                    const Color(0xFF091F3D).withValues(alpha: 0.94),
                    const Color(0xFF050E1B).withValues(alpha: 0.97),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Obx(() {
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
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
          const SizedBox(width: 42),
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
