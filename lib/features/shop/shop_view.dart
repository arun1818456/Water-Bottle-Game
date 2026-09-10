import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../game/models/bottle.dart';
import '../game/widgets/bottle_painter.dart';
import 'shop_controller.dart';

/// Shop UI for unlocking and equipping bottle skins and backgrounds
class ShopView extends StatelessWidget {
  const ShopView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShopController());
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
                      'COSMETIC SHOP',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    // Coins Pill
                    Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: AppTheme.glassBox(borderRadius: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD700), size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${storage.coins.value}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),

              // Segmented Tabs: Bottle Skins & Backgrounds
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Obx(() => Container(
                      padding: const EdgeInsets.all(4),
                      decoration: AppTheme.glassBox(borderRadius: 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.selectTab(0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: controller.selectedTab.value == 0
                                      ? AppColors.primaryCyan
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    'Bottle Skins',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: controller.selectedTab.value == 0
                                          ? const Color(0xFF002244)
                                          : Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.selectTab(1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: controller.selectedTab.value == 1
                                      ? AppColors.primaryCyan
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    'Backgrounds',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: controller.selectedTab.value == 1
                                          ? const Color(0xFF002244)
                                          : Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),

              const SizedBox(height: 12),

              // Content List
              Expanded(
                child: Obx(() {
                  if (controller.selectedTab.value == 0) {
                    return _buildBottleSkinsList(controller);
                  } else {
                    return _buildBackgroundsList(controller);
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottleSkinsList(ShopController controller) {
    final storage = controller.storage;
    final skins = BottleSkinType.values;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: skins.length,
      itemBuilder: (context, index) {
        final skin = skins[index];
        final isUnlocked = storage.unlockedBottleSkins.contains(skin.name);
        final isEquipped = storage.equippedBottleSkin.value == skin.name;

        // Sample bottle filled with 4 colored layers for live preview
        final sampleBottle = Bottle(layers: [1, 2, 4, 3]);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassBox(
            color: isEquipped ? AppColors.primaryCyan.withAlpha(40) : AppColors.glassFill,
            borderColor: isEquipped ? AppColors.primaryCyan : AppColors.glassBorder,
            borderRadius: 22,
          ),
          child: Row(
            children: [
              // Preview Bottle
              SizedBox(
                width: 48,
                height: 110,
                child: CustomPaint(
                  painter: BottlePainter(
                    bottle: sampleBottle,
                    skinType: skin.name,
                  ),
                ),
              ),

              const SizedBox(width: 18),

              // Title & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skin.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      skin.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isUnlocked)
                      Row(
                        children: [
                          const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD700), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${skin.price} Coins',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Action Button (Equipped / Equip / Buy)
              _buildActionButton(
                isEquipped: isEquipped,
                isUnlocked: isUnlocked,
                onTap: () => controller.onBottleAction(skin),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundsList(ShopController controller) {
    final storage = controller.storage;
    final bgs = BackgroundThemeType.values;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: bgs.length,
      itemBuilder: (context, index) {
        final bg = bgs[index];
        final isUnlocked = storage.unlockedBackgrounds.contains(bg.name);
        final isEquipped = storage.equippedBackground.value == bg.name;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassBox(
            color: isEquipped ? AppColors.primaryCyan.withAlpha(40) : AppColors.glassFill,
            borderColor: isEquipped ? AppColors.primaryCyan : AppColors.glassBorder,
            borderRadius: 22,
          ),
          child: Row(
            children: [
              // Theme color swatch preview
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: _getThemePreviewGradient(bg.name),
                  border: Border.all(color: Colors.white30, width: 1.5),
                ),
              ),

              const SizedBox(width: 18),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bg.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bg.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (!isUnlocked)
                      Row(
                        children: [
                          const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD700), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${bg.price} Coins',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              _buildActionButton(
                isEquipped: isEquipped,
                isUnlocked: isUnlocked,
                onTap: () => controller.onBackgroundAction(bg),
              ),
            ],
          ),
        );
      },
    );
  }

  LinearGradient _getThemePreviewGradient(String name) {
    switch (name) {
      case 'sunset':
        return const LinearGradient(colors: [Color(0xFF2D1B4E), Color(0xFF9E2A2B)]);
      case 'space':
        return const LinearGradient(colors: [Color(0xFF0B0C10), Color(0xFF110726)]);
      case 'forest':
        return const LinearGradient(colors: [Color(0xFF0F2027), Color(0xFF2C5364)]);
      case 'ocean':
      default:
        return const LinearGradient(colors: [AppColors.backgroundTop, AppColors.primaryBlue]);
    }
  }

  Widget _buildActionButton({
    required bool isEquipped,
    required bool isUnlocked,
    required VoidCallback onTap,
  }) {
    if (isEquipped) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.accentNeonGreen.withAlpha(50),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accentNeonGreen, width: 1.2),
        ),
        child: const Text(
          'Equipped',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.accentNeonGreen,
          ),
        ),
      );
    } else if (isUnlocked) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryCyan,
          foregroundColor: const Color(0xFF002244),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        child: const Text('Equip'),
      );
    } else {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD700),
          foregroundColor: const Color(0xFF002244),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        child: const Text('Unlock'),
      );
    }
  }
}
