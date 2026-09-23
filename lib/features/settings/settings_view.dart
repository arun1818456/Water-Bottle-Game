import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'settings_controller.dart';

/// Settings & Options screen
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final storage = controller.storage;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundTop, AppColors.backgroundMid, AppColors.backgroundBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                      onPressed: () => Get.back(),
                    ),
                    const Spacer(),
                    const Text(
                      'SETTINGS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48), // Balance back button
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Audio & Haptics Section
                    _buildSectionHeader('AUDIO & HAPTICS'),

                    Container(
                      decoration: AppTheme.glassBox(borderRadius: 20),
                      child: Column(
                        children: [
                          // Sound FX Toggle
                          Obx(() => _buildSwitchTile(
                                icon: Icons.volume_up_rounded,
                                title: 'Sound Effects',
                                subtitle: 'Pour, click, and victory sounds',
                                value: storage.soundEnabled.value,
                                onChanged: controller.toggleSound,
                              )),
                          const Divider(color: Colors.white12, height: 1),

                          // Background Music Toggle
                          Obx(() => _buildSwitchTile(
                                icon: Icons.music_note_rounded,
                                title: 'Background Music',
                                subtitle: 'Calming ambient melody',
                                value: storage.musicEnabled.value,
                                onChanged: controller.toggleMusic,
                              )),
                          const Divider(color: Colors.white12, height: 1),

                          // Vibration Toggle
                          Obx(() => _buildSwitchTile(
                                icon: Icons.vibration_rounded,
                                title: 'Vibration & Haptics',
                                subtitle: 'Tactile touch responses',
                                value: storage.vibrationEnabled.value,
                                onChanged: controller.toggleVibration,
                              )),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Game Data Section
                    _buildSectionHeader('GAME PROGRESS'),

                    Container(
                      decoration: AppTheme.glassBox(borderRadius: 20),
                      child: _buildActionTile(
                        icon: Icons.delete_forever_rounded,
                        iconColor: const Color(0xFFFF5252),
                        title: 'Reset Progress',
                        subtitle: 'Clear all unlocked levels and cosmetics',
                        onTap: controller.confirmResetProgress,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // About & Legal Section
                    _buildSectionHeader('ABOUT & SUPPORT'),

                    Container(
                      decoration: AppTheme.glassBox(borderRadius: 20),
                      child: Column(
                        children: [
                          _buildActionTile(
                            icon: Icons.privacy_tip_rounded,
                            iconColor: AppColors.primaryCyan,
                            title: 'Privacy Policy',
                            subtitle: 'Terms of service & privacy',
                            onTap: controller.showPrivacyPolicy,
                          ),
                          const Divider(color: Colors.white12, height: 1),
                          _buildActionTile(
                            icon: Icons.update_rounded,
                            iconColor: const Color(0xFF42A5F5),
                            title: 'Update App',
                            subtitle: 'Get the latest version from Play Store',
                            onTap: controller.updateApp,
                          ),
                          const Divider(color: Colors.white12, height: 1),
                          _buildActionTile(
                            icon: Icons.star_rate_rounded,
                            iconColor: const Color(0xFFFFD700),
                            title: 'Rate App',
                            subtitle: 'Leave a 5-star review',
                            onTap: controller.rateApp,
                          ),
                          const Divider(color: Colors.white12, height: 1),
                          _buildActionTile(
                            icon: Icons.share_rounded,
                            iconColor: AppColors.accentNeonGreen,
                            title: 'Share With Friends',
                            subtitle: 'Challenge your friends to play',
                            onTap: controller.shareApp,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Version Info
                    Center(
                      child: Obx(() => Text(
                            'Aqua Sort Master v${controller.versionString.value}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryCyan, size: 22),
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
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
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
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primaryCyan,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.white38,
      ),
    );
  }
}
