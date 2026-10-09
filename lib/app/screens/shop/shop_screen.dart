import 'package:water_bottle_ais/exports.dart';

/// Modern High-Aesthetic Cosmetic Shop Screen
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShopController());

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with dark luxury glass overlay
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
              final coins = controller.storage.coins.value;
              final selectedTab = controller.selectedTab.value;
              final equippedBottle = controller.storage.equippedBottleSkin.value;
              final equippedBg = controller.storage.equippedBackground.value;
              final unlockedBottles = controller.storage.unlockedBottleSkins.toList();
              final unlockedBgs = controller.storage.unlockedBackgrounds.toList();

              return Column(
                children: [
                  // Top Header Bar
                  _buildTopBar(coins),

                  // Modern Segmented Switcher
                  _buildTabSwitcher(controller, selectedTab),

                  const SizedBox(height: 8),

                  // Content List
                  Expanded(
                    child: selectedTab == 0
                        ? _buildBottleSkinsList(
                            controller,
                            equippedBottle,
                            unlockedBottles,
                          )
                        : _buildBackgroundsList(
                            controller,
                            equippedBg,
                            unlockedBgs,
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

  /// Top Bar with Glass Back Button, Title, and Coins Counter
  Widget _buildTopBar(int coins) {
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
                  'COSMETIC SHOP',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
              ),
              const Text(
                'Customize your bottles & themes',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF14457F), Color(0xFF0B2B54)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: Color(0xFFFFD700),
                  size: 18,
                ),
                const SizedBox(width: 5),
                Text(
                  '$coins',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Modern Tab Switcher
  Widget _buildTabSwitcher(ShopController controller, int selectedTab) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF08182E).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF1B4E8A).withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectTab(0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    gradient: selectedTab == 0
                        ? const LinearGradient(
                            colors: [Color(0xFF00E5FF), Color(0xFF0072FF)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: selectedTab == 0
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.liquor_rounded,
                        size: 18,
                        color: selectedTab == 0 ? Colors.white : Colors.white60,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Bottle Skins',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: selectedTab == 0 ? Colors.white : Colors.white60,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectTab(1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    gradient: selectedTab == 1
                        ? const LinearGradient(
                            colors: [Color(0xFF7C4DFF), Color(0xFF304FFE)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: selectedTab == 1
                        ? [
                            BoxShadow(
                              color: const Color(0xFF7C4DFF).withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wallpaper_rounded,
                        size: 18,
                        color: selectedTab == 1 ? Colors.white : Colors.white60,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Themes & BG',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: selectedTab == 1 ? Colors.white : Colors.white60,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottle Skins List
  Widget _buildBottleSkinsList(
    ShopController controller,
    String equippedBottle,
    List<String> unlockedBottles,
  ) {
    final skins = BottleSkinType.values;
    final sampleBottle = Bottle(layers: [1, 2, 4, 3]);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: skins.length,
      itemBuilder: (context, index) {
        final skin = skins[index];
        final isUnlocked = unlockedBottles.contains(skin.name);
        final isEquipped = equippedBottle == skin.name;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isEquipped
                ? const LinearGradient(
                    colors: [Color(0xFF123D6E), Color(0xFF0B2446)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF0C2448), Color(0xFF081932)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isEquipped
                  ? const Color(0xFF00E5FF)
                  : const Color(0xFF1E5696).withValues(alpha: 0.4),
              width: isEquipped ? 2.0 : 1.2,
            ),
            boxShadow: isEquipped
                ? [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Live Bottle Preview with ambient glow
              Container(
                width: 60,
                height: 105,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isEquipped
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.4)
                        : Colors.white10,
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    width: 44,
                    height: 92,
                    child: CustomPaint(
                      painter: BottlePainter(
                        bottle: sampleBottle,
                        skinType: skin.name,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Info column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            skin.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        if (isEquipped) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF00E676),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF69F0AE),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      skin.description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.monetization_on_rounded,
                              color: Color(0xFFFFD700),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${skin.price} Coins',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Action button
              _buildActionButton(
                isEquipped: isEquipped,
                isUnlocked: isUnlocked,
                onTap: () => controller.onBottleAction(skin),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 60).ms, duration: 400.ms).slideX(begin: 0.05, end: 0);
      },
    );
  }

  /// Background Themes List
  Widget _buildBackgroundsList(
    ShopController controller,
    String equippedBg,
    List<String> unlockedBgs,
  ) {
    final bgs = BackgroundThemeType.values;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: bgs.length,
      itemBuilder: (context, index) {
        final bg = bgs[index];
        final isUnlocked = unlockedBgs.contains(bg.name);
        final isEquipped = equippedBg == bg.name;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isEquipped
                ? const LinearGradient(
                    colors: [Color(0xFF1E2254), Color(0xFF0E1336)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF0C2448), Color(0xFF081932)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isEquipped
                  ? const Color(0xFF7C4DFF)
                  : const Color(0xFF1E5696).withValues(alpha: 0.4),
              width: isEquipped ? 2.0 : 1.2,
            ),
            boxShadow: isEquipped
                ? [
                    BoxShadow(
                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Theme color swatch preview
              Container(
                width: 60,
                height: 74,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: _getThemePreviewGradient(bg.name),
                  border: Border.all(
                    color: isEquipped ? const Color(0xFF7C4DFF) : Colors.white24,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.wallpaper_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 26,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Info column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            bg.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        if (isEquipped) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF00E676),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF69F0AE),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bg.description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.monetization_on_rounded,
                              color: Color(0xFFFFD700),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${bg.price} Coins',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Action button
              _buildActionButton(
                isEquipped: isEquipped,
                isUnlocked: isUnlocked,
                onTap: () => controller.onBackgroundAction(bg),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 60).ms, duration: 400.ms).slideX(begin: 0.05, end: 0);
      },
    );
  }

  LinearGradient _getThemePreviewGradient(String name) {
    switch (name) {
      case 'sunset':
        return const LinearGradient(
          colors: [Color(0xFF3E1F47), Color(0xFFFF6F00), Color(0xFFFF4081)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'space':
        return const LinearGradient(
          colors: [Color(0xFF0B0C10), Color(0xFF311B92), Color(0xFF7C4DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'forest':
        return const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF20BF6B), Color(0xFF0B8793)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'ocean':
      default:
        return const LinearGradient(
          colors: [Color(0xFF0D1B2A), Color(0xFF0072FF), Color(0xFF00E5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  /// Modern High-End Action Button
  Widget _buildActionButton({
    required bool isEquipped,
    required bool isUnlocked,
    required VoidCallback onTap,
  }) {
    if (isEquipped) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF00E676).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF00E676),
            width: 1.2,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, color: Color(0xFF00E676), size: 16),
            SizedBox(width: 4),
            Text(
              'Active',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Color(0xFF00E676),
              ),
            ),
          ],
        ),
      );
    } else if (isUnlocked) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00E5FF), Color(0xFF0072FF)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Text(
            'EQUIP',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFEA79), Color(0xFFFF9800), Color(0xFFE65100)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFFFF176),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9800).withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_open_rounded, color: Colors.white, size: 14),
              SizedBox(width: 4),
              Text(
                'UNLOCK',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
