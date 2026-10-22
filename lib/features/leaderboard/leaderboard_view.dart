import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import 'leaderboard_controller.dart';

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LeaderboardController());

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
          bottom: false,
          child: Column(
            children: [
              // 1. Top Bar
              _buildTopBar(context, controller),

              const SizedBox(height: 12),

              // 2. Main Content
              Expanded(
                child: Obx(() {
                  final list = controller.leaderboardUsers;
                  if (list.isEmpty) return const SizedBox.shrink();

                  final top1 = list[0];
                  final top2 = list.length > 1 ? list[1] : null;
                  final top3 = list.length > 2 ? list[2] : null;
                  final remainingList = list.length > 3 ? list.sublist(3) : <LeaderboardUser>[];

                  return Column(
                    children: [
                      // Top 3 Podium Display
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildTop3Podium(top1, top2, top3),
                      ),

                      const SizedBox(height: 16),

                      // Rest of Players List
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
                            itemCount: remainingList.length,
                            itemBuilder: (context, index) {
                              final user = remainingList[index];
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

              // 3. Fixed Bottom Current User Summary Bar
              _buildBottomUserBar(controller),
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

          const SizedBox(width: 42),
        ],
      ),
    );
  }

  Widget _buildTop3Podium(
    LeaderboardUser? top1,
    LeaderboardUser? top2,
    LeaderboardUser? top3,
  ) {
    return SizedBox(
      height: 190,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place (Silver)
          if (top2 != null)
            Expanded(child: _buildPodiumCard(top2, 2, const Color(0xFFC0C0C0), 150))
          else
            const Spacer(),

          const SizedBox(width: 8),

          // 1st Place (Gold Center)
          if (top1 != null)
            Expanded(child: _buildPodiumCard(top1, 1, const Color(0xFFFFD700), 185))
          else
            const Spacer(),

          const SizedBox(width: 8),

          // 3rd Place (Bronze)
          if (top3 != null)
            Expanded(child: _buildPodiumCard(top3, 3, const Color(0xFFCD7F32), 140))
          else
            const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPodiumCard(LeaderboardUser user, int rank, Color accentColor, double height) {
    final isGold = rank == 1;

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
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: user.isCurrentUser ? const Color(0xFF00E5FF) : Colors.white,
                        ),
                      ),
                    ),
                    if (user.isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'Level ${user.level}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),

          // Stars Count Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0B2C5C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E60A8)),
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
