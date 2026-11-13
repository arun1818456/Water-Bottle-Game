import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/widgets/profile_auth_dialog.dart';
import 'leaderboard_controller.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  late final LeaderboardController controller;
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LeaderboardController>()
        ? Get.find<LeaderboardController>()
        : Get.put(LeaderboardController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundTop,
              AppColors.backgroundMid,
              AppColors.backgroundBottom,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Bar
              _buildTopBar(context, controller),

              const SizedBox(height: 8),

              // 2. Main Content
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00E5FF),
                      ),
                    );
                  }

                  // If user is not logged in: Show Beautiful Login Prompt with Google CTA
                  if (!controller.isUserLoggedIn.value) {
                    return _buildLoginRequiredView(context, controller);
                  }

                  final list = controller.leaderboardUsers;
                  if (list.isEmpty) {
                    return _buildEmptyListView();
                  }

                  final top1 = list[0];
                  final top2 = list.length > 1 ? list[1] : null;
                  final top3 = list.length > 2 ? list[2] : null;
                  final remainingList = list.length > 3 ? list.sublist(3) : <LeaderboardUser>[];
                  // If <= 3 players exist globally, display all players in the list so the player always sees their row
                  final displayList = remainingList.isNotEmpty ? remainingList : list;

                  return Column(
                    children: [
                      // Top Podium Display
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildTop3Podium(top1, top2, top3),
                      ),

                      const SizedBox(height: 16),

                      // Real Dynamic Players List Container
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF091D3A).withValues(alpha: 0.7),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                            border: Border.all(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                              width: 1.2,
                            ),
                          ),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              final user = displayList[index];
                              return _buildPlayerRow(user);
                            },
                            separatorBuilder: (context, index) => const Divider(
                              color: Color(0x1A00E5FF),
                              height: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),

              // 3. Fixed Bottom Current User Summary Bar (Only if Logged In)
              Obx(() {
                if (controller.isUserLoggedIn.value) {
                  return _buildBottomUserBar(controller);
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// Modern Empty View when logged in but no data
  Widget _buildEmptyListView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_outlined, size: 64, color: Color(0xFF00E5FF)),
          const SizedBox(height: 16),
          const Text(
            'No Leaderboard Data Yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete levels to claim the #1 spot on the global leaderboard!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  /// Beautiful Login Required screen when user is a guest (No Static / Dummy Data)
  Widget _buildLoginRequiredView(BuildContext context, LeaderboardController controller) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0B2447),
                Color(0xFF071933),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                blurRadius: 24,
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
              // Trophy / Badge Icon
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFF3E2723),
                    size: 42,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'JOIN GLOBAL LEADERBOARD',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Sign in with Google to view live global player ranks, compete with friends, and backup your level stars to the cloud!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 26),

              // Direct One-Tap Google Sign-In Button
              GestureDetector(
                onTap: _isSigningIn
                    ? null
                    : () async {
                        AudioService.to.playButtonClick();
                        setState(() => _isSigningIn = true);
                        final err = await FirebaseService.to.signInWithGoogle();
                        if (mounted) setState(() => _isSigningIn = false);
                        if (err == null) {
                          controller.refreshLeaderboard(invalidateCache: true);
                          Get.snackbar(
                            'Welcome!',
                            'Logged in successfully! Dynamic leaderboard loaded.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF00E676).withValues(alpha: 0.95),
                            colorText: Colors.black,
                            duration: const Duration(seconds: 3),
                          );
                        } else if (err != 'Google Sign-In canceled.') {
                          Get.snackbar(
                            'Sign-In Failed',
                            err,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFFFF5252).withValues(alpha: 0.95),
                            colorText: Colors.white,
                          );
                        }
                      },
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
                  child: _isSigningIn
                      ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
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
                              'SIGN IN WITH GOOGLE',
                              style: TextStyle(
                                fontSize: 14,
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
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, LeaderboardController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 18, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: controller.onBackPressed,
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

          // Title Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E24AA), Color(0xFF4A148C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFE040FB).withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE040FB).withValues(alpha: 0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFFFD700),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'GLOBAL LEADERBOARD',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Profile & Login Action Button
          GestureDetector(
            onTap: () {
              AudioService.to.playButtonClick();
              Get.dialog(ProfileAuthDialog(
                initialTab: controller.isUserLoggedIn.value ? 0 : 1,
              )).then((_) {
                controller.refreshLeaderboard();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF0072FF)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTop3Podium(
    LeaderboardUser top1,
    LeaderboardUser? top2,
    LeaderboardUser? top3,
  ) {
    if (top2 == null && top3 == null) {
      return Center(
        child: SizedBox(
          width: 160,
          child: _buildPodiumColumn(
            user: top1,
            rank: 1,
            height: 175,
            accentColor: const Color(0xFFFFD700),
            isGold: true,
          ),
        ),
      );
    }

    if (top3 == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: _buildPodiumColumn(
              user: top2!,
              rank: 2,
              height: 145,
              accentColor: const Color(0xFFC0C0C0),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: _buildPodiumColumn(
              user: top1,
              rank: 1,
              height: 175,
              accentColor: const Color(0xFFFFD700),
              isGold: true,
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // #2 Place (Silver)
        Expanded(
          child: _buildPodiumColumn(
            user: top2!,
            rank: 2,
            height: 145,
            accentColor: const Color(0xFFC0C0C0),
          ),
        ),

        const SizedBox(width: 10),

        // #1 Place (Gold - Taller)
        Expanded(
          flex: 1,
          child: _buildPodiumColumn(
            user: top1,
            rank: 1,
            height: 175,
            accentColor: const Color(0xFFFFD700),
            isGold: true,
          ),
        ),

        const SizedBox(width: 10),

        // #3 Place (Bronze)
        Expanded(
          child: _buildPodiumColumn(
            user: top3,
            rank: 3,
            height: 130,
            accentColor: const Color(0xFFCD7F32),
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumColumn({
    required LeaderboardUser user,
    required int rank,
    required double height,
    required Color accentColor,
    bool isGold = false,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.25),
            const Color(0xFF0A244D).withValues(alpha: 0.85),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.8),
          width: isGold ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isGold ? 0.4 : 0.2),
            blurRadius: isGold ? 16 : 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Crown / Badge
          Text(
            isGold ? '👑' : (rank == 2 ? '🥈' : '🥉'),
            style: const TextStyle(fontSize: 18),
          ),

          const SizedBox(height: 2),

          // Avatar Circle
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accentColor, width: 2),
            ),
            child: CircleAvatar(
              radius: isGold ? 22 : 18,
              backgroundColor: const Color(0xFF0F3A75),
              child: Text(
                user.avatarEmoji,
                style: TextStyle(fontSize: isGold ? 20 : 16),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // User Name
          Text(
            user.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isGold ? 11 : 10,
              fontWeight: FontWeight.bold,
              color: user.isCurrentUser ? const Color(0xFF00E5FF) : Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          // Stars Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 12),
                const SizedBox(width: 2),
                Text(
                  '${user.stars}',
                  style: const TextStyle(
                    fontSize: 10,
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

  Widget _buildPlayerRow(LeaderboardUser user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: user.isCurrentUser
            ? const Color(0xFF00E5FF).withValues(alpha: 0.18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: user.isCurrentUser
            ? Border.all(color: const Color(0xFF00E5FF), width: 1.2)
            : null,
      ),
      child: Row(
        children: [
          // Rank Badge
          SizedBox(
            width: 32,
            child: Text(
              '#${user.rank}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: user.isCurrentUser ? const Color(0xFF00E5FF) : Colors.white70,
              ),
            ),
          ),

          // Avatar & Flag
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF0F3A75),
                child: Text(user.avatarEmoji, style: const TextStyle(fontSize: 16)),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Text(user.countryFlag, style: const TextStyle(fontSize: 10)),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Name & Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: user.isCurrentUser ? const Color(0xFF00E5FF) : Colors.white,
                        ),
                      ),
                    ),
                    if (user.isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF00E5FF),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'Level ${user.level}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Stars Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 14),
                const SizedBox(width: 4),
                Text(
                  '${user.stars}',
                  style: const TextStyle(
                    fontSize: 11,
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

  Widget _buildBottomUserBar(LeaderboardController controller) {
    return Obx(() {
      final rank = controller.currentUserRank.value;
      final stars = controller.userTotalStars.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF081B38),
          border: const Border(top: BorderSide(color: Color(0xFF00E5FF), width: 1.5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // User Rank Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'YOUR RANK #$rank',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 0.8,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Your Global Placement',
                    style: TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                  Text(
                    'Level ${controller.storage.unlockedLevel.value}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // User Total Stars
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 4),
                Text(
                  '$stars ⭐',
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
      );
    });
  }
}
