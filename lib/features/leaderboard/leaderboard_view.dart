import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_screen_background.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/utils/number_formatter.dart';
import '../../core/widgets/profile_auth_dialog.dart';
import 'leaderboard_controller.dart';

/// Luxury Glassmorphic Global Leaderboard Screen
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
    final alreadyRegistered = Get.isRegistered<LeaderboardController>();
    controller = alreadyRegistered
        ? Get.find<LeaderboardController>()
        : Get.put(LeaderboardController());
    // Revisit: silent refresh so cached data opens instantly without a blocking loader.
    // First visit: onInit already started the load, so don't fire a duplicate fetch.
    if (alreadyRegistered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.refreshLeaderboard();
      });
    }
  }

  /// Names from the cloud carry a "(You)" suffix; the UI shows a YOU badge instead.
  String _displayName(LeaderboardUser user) {
    const suffix = ' (You)';
    return user.name.endsWith(suffix)
        ? user.name.substring(0, user.name.length - suffix.length)
        : user.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Shared blurred backdrop (same as other screens)
          const Positioned.fill(child: AppScreenBackground()),

          // 4. Foreground Content
          SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                _buildTopBar(context, controller),

                const SizedBox(height: 10),

                // Main Content View (Login CTA vs Live Dynamic Podium & List)
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                                border: Border.all(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                                ),
                              ),
                              child: const SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Syncing Global Ranks...',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryCyan,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Guest / Not Logged In View
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
                    final displayList = remainingList.isNotEmpty ? remainingList : list;

                    return Column(
                      children: [
                        // Live Top 3 Podium
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildTop3Podium(top1, top2, top3),
                        ),

                        const SizedBox(height: 14),

                        // List Header Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E5FF),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'GLOBAL STANDINGS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white70,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.people_alt_rounded, size: 12, color: Color(0xFF00E5FF)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${list.length} Players',
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
                        ),

                        const SizedBox(height: 8),

                        // Dynamic Players List Container
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF0E223D).withValues(alpha: 0.85),
                                  const Color(0xFF081528).withValues(alpha: 0.95),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                              border: Border.all(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 18,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                              child: RefreshIndicator(
                                color: const Color(0xFF00E5FF),
                                backgroundColor: const Color(0xFF0E223D),
                                onRefresh: () => controller.refreshLeaderboard(),
                                child: ListView.separated(
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 16),
                                  itemCount: displayList.length,
                                  itemBuilder: (context, index) {
                                    final user = displayList[index];
                                    return _buildPlayerRow(user, index, top1.stars);
                                  },
                                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),

                // Bottom Sticky Current User Bar (Only when Logged In)
                Obx(() {
                  if (controller.isUserLoggedIn.value) {
                    return _buildBottomUserBar(controller);
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Modern Empty View when logged in but no data
  Widget _buildEmptyListView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.emoji_events_outlined, size: 54, color: Color(0xFF00E5FF)),
          ),
          const SizedBox(height: 18),
          const Text(
            'Be The First On The Board!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Complete levels to claim the #1 spot on the global leaderboard and show your mastery!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ),
    );
  }

  /// User Google Profile Photo with fallback and glowing circular border
  Widget _buildUserPhoto({
    required String photoUrl,
    required double radius,
    required Color borderColor,
    double borderWidth = 2.0,
    List<BoxShadow>? shadows,
  }) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: shadows,
        color: const Color(0xFF082245),
      ),
      child: ClipOval(
        child: photoUrl.isNotEmpty
            ? Image.network(
                photoUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: radius * 1.1,
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: radius * 0.8,
                      height: radius * 0.8,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(borderColor),
                      ),
                    ),
                  );
                },
              )
            : Icon(
                Icons.person_rounded,
                color: Colors.white70,
                size: radius * 1.1,
              ),
      ),
    );
  }

  /// Top Bar with Glass Back Button, Header Pill, and Profile Chip
  Widget _buildTopBar(BuildContext context, LeaderboardController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          PressableScale(
            onTap: controller.onBackPressed,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF0E2A52).withValues(alpha: 0.85),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1E60A8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
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

          // Two-tone title, consistent with the other screens
          Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF80E5FF), Color(0xFFFFFFFF), Color(0xFFFFD54F)],
                ).createShader(bounds),
                child: const Text(
                  'LEADERBOARD',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
              ),
              const Text(
                'Compete with players worldwide',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Profile & Login Action Button
          PressableScale(
            onTap: () {
              AudioService.to.playButtonClick();
              Get.dialog(const ProfileAuthDialog()).then((_) {
                controller.refreshLeaderboard();
              });
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF0072FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF80D8FF), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  /// High-Impact Podium Component (Gold #1 in Center, Silver #2 on Left, Bronze #3 on Right)
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
            height: 195,
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
            width: 145,
            child: _buildPodiumColumn(
              user: top2!,
              rank: 2,
              height: 165,
              accentColor: const Color(0xFFE2E8F0),
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 155,
            child: _buildPodiumColumn(
              user: top1,
              rank: 1,
              height: 195,
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
            height: 168,
            accentColor: const Color(0xFFE2E8F0),
          ),
        ),

        const SizedBox(width: 10),

        // #1 Place (Gold - Tallest & Grandest)
        Expanded(
          flex: 1,
          child: _buildPodiumColumn(
            user: top1,
            rank: 1,
            height: 202,
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
            height: 152,
            accentColor: const Color(0xFFFFB300),
          ),
        ),
      ],
    );
  }

  /// Individual Podium Column with 3D Pedestal, Glowing Avatar & Stars Badge
  Widget _buildPodiumColumn({
    required LeaderboardUser user,
    required int rank,
    required double height,
    required Color accentColor,
    bool isGold = false,
  }) {
    final String medalEmoji = isGold ? '👑' : (rank == 2 ? '🥈' : '🥉');
    final String pedestalSuffix = isGold ? 'ST' : (rank == 2 ? 'ND' : 'RD');
    final int entranceDelayMs = isGold ? 0 : (rank == 2 ? 140 : 260);

    final Widget medal = Text(
      medalEmoji,
      style: TextStyle(
        fontSize: isGold ? 24 : 18,
        shadows: [
          Shadow(color: accentColor.withValues(alpha: 0.8), blurRadius: isGold ? 14 : 8),
        ],
      ),
    );

    final column = Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: isGold ? 0.35 : 0.22),
            const Color(0xFF0A2244).withValues(alpha: 0.90),
            const Color(0xFF061427).withValues(alpha: 0.98),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accentColor.withValues(alpha: isGold ? 0.95 : 0.75),
          width: isGold ? 2.2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isGold ? 0.35 : 0.18),
            blurRadius: isGold ? 18 : 10,
            spreadRadius: isGold ? 1 : 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Upper Content: Crown, Avatar, Name & Stars
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 6, right: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Crown / Medal Icon (gold crown gently floats)
                isGold
                    ? medal
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(begin: 0, end: -3, duration: 1300.ms, curve: Curves.easeInOut)
                    : medal,

                const SizedBox(height: 2),

                // Google Profile Picture with Glow & Flag Pill
                Stack(
                  alignment: Alignment.bottomRight,
                  clipBehavior: Clip.none,
                  children: [
                    _buildUserPhoto(
                      photoUrl: user.photoUrl,
                      radius: isGold ? 24 : 20,
                      borderColor: accentColor,
                      borderWidth: isGold ? 2.5 : 1.8,
                      shadows: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: isGold ? 0.6 : 0.35),
                          blurRadius: isGold ? 14 : 8,
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: -2,
                      right: -3,
                      child: Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1F38),
                          shape: BoxShape.circle,
                          border: Border.all(color: accentColor, width: 1),
                        ),
                        child: Text(
                          user.countryFlag,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Player Name
                Text(
                  _displayName(user),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isGold ? 12 : 11,
                    fontWeight: FontWeight.w900,
                    color: user.isCurrentUser ? const Color(0xFF00E5FF) : Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 3),

                // Stars Badge Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 12),
                      const SizedBox(width: 3),
                      Text(
                        user.stars.formatCompact,
                        style: const TextStyle(
                          fontSize: 10,
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

          // 3D Pedestal Base Footing
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isGold ? 6 : 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: isGold ? 0.5 : 0.35),
                  accentColor.withValues(alpha: isGold ? 0.2 : 0.15),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              border: Border(
                top: BorderSide(
                  color: accentColor.withValues(alpha: 0.6),
                  width: 1.2,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: isGold ? 18 : 15,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    height: 1.0,
                    shadows: [
                      Shadow(color: accentColor.withValues(alpha: 0.7), blurRadius: 8),
                    ],
                  ),
                ),
                Text(
                  pedestalSuffix,
                  style: TextStyle(
                    fontSize: isGold ? 10 : 9,
                    fontWeight: FontWeight.w900,
                    color: accentColor.withValues(alpha: 0.85),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final animated = column
        .animate()
        .fadeIn(duration: 450.ms, delay: entranceDelayMs.ms)
        .slideY(begin: 0.18, end: 0, duration: 550.ms, delay: entranceDelayMs.ms, curve: Curves.easeOutCubic);

    // Soft recurring shine across the champion's pedestal
    return isGold
        ? animated.animate(onPlay: (c) => c.repeat()).shimmer(
              delay: 2200.ms,
              duration: 1400.ms,
              color: Colors.white.withValues(alpha: 0.18),
            )
        : animated;
  }

  /// Individual Player Row in Standings List
  Widget _buildPlayerRow(LeaderboardUser user, int index, int topStars) {
    final isMe = user.isCurrentUser;
    final hasClimbed = isMe && controller.hasRankClimbed.value;
    final Color? medalColor = switch (user.rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFE2E8F0),
      3 => const Color(0xFFFFB300),
      _ => null,
    };
    final double starRatio =
        topStars > 0 ? (user.stars / topStars).clamp(0.0, 1.0).toDouble() : 0.0;
    final Color accent = isMe
        ? (hasClimbed ? const Color(0xFF00E676) : const Color(0xFF00E5FF))
        : (medalColor ?? const Color(0xFF4FC3F7));

    final rowWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isMe
              ? [
                  accent.withValues(alpha: hasClimbed ? 0.26 : 0.18),
                  accent.withValues(alpha: 0.05),
                ]
              : [
                  Colors.white.withValues(alpha: 0.06),
                  Colors.white.withValues(alpha: 0.015),
                ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: isMe
            ? Border.all(
                color: hasClimbed
                    ? const Color(0xFF00E676)
                    : const Color(0xFF00E5FF).withValues(alpha: 0.8),
                width: hasClimbed ? 2.0 : 1.5,
              )
            : Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
        boxShadow: isMe
            ? [
                BoxShadow(
                  color: hasClimbed
                      ? const Color(0xFF00E676).withValues(alpha: 0.45)
                      : const Color(0xFF00E5FF).withValues(alpha: 0.2),
                  blurRadius: hasClimbed ? 14 : 10,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Rank Badge (medal tinted for top 3, cyan for you)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isMe
                    ? [accent, accent.withValues(alpha: 0.7)]
                    : medalColor != null
                        ? [medalColor.withValues(alpha: 0.45), medalColor.withValues(alpha: 0.15)]
                        : [const Color(0xFF14305A), const Color(0xFF0B1E3A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isMe
                    ? Colors.white
                    : (medalColor?.withValues(alpha: 0.8) ?? const Color(0xFF1E4878)),
                width: 1,
              ),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    '${user.rank}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isMe ? Colors.black : (medalColor ?? Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Google Profile Picture & Flag Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildUserPhoto(
                photoUrl: user.photoUrl,
                radius: 18,
                borderColor: isMe
                    ? (hasClimbed ? const Color(0xFF00E676) : const Color(0xFF00E5FF))
                    : Colors.white24,
                borderWidth: isMe ? 2 : 1,
                shadows: isMe
                    ? [
                        BoxShadow(
                          color: (hasClimbed
                                  ? const Color(0xFF00E676)
                                  : const Color(0xFF00E5FF))
                              .withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF061426),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: Text(user.countryFlag, style: const TextStyle(fontSize: 9)),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Name & Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _displayName(user),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isMe
                              ? (hasClimbed ? const Color(0xFF00E676) : const Color(0xFF00E5FF))
                              : Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: hasClimbed
                                ? [const Color(0xFF00E676), const Color(0xFF00B0FF)]
                                : [const Color(0xFF00E5FF), const Color(0xFF0072FF)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          hasClimbed
                              ? '▲ #${controller.previousUserRank.value} → #${user.rank}'
                              : 'YOU',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.water_drop_rounded, size: 9, color: accent.withValues(alpha: 0.9)),
                          const SizedBox(width: 2),
                          Text(
                            'Lv ${user.level}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Progress relative to the #1 player's stars
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Stack(
                          children: [
                            Container(height: 4, color: Colors.white.withValues(alpha: 0.08)),
                            FractionallySizedBox(
                              widthFactor: starRatio,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [accent.withValues(alpha: 0.6), accent],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          ),

          // Stars Counter Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700).withValues(alpha: 0.15),
                  const Color(0xFFFF9100).withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 15),
                const SizedBox(width: 4),
                Text(
                  user.stars.formatCompact,
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
    );

    // If user has climbed rank, play smooth upward slide + glow pulse animation
    if (hasClimbed) {
      return rowWidget
          .animate()
          .slideY(
            begin: 0.45,
            end: 0.0,
            duration: 650.ms,
            curve: Curves.easeOutCubic,
          )
          .scaleXY(
            begin: 0.94,
            end: 1.0,
            duration: 650.ms,
            curve: Curves.easeOutBack,
          )
          .shimmer(
            delay: 400.ms,
            duration: 900.ms,
            color: const Color(0xFF00E676).withValues(alpha: 0.5),
          );
    }

    // Staggered entrance for the first rows on screen
    final delayMs = (index < 10 ? index : 10) * 45;
    return rowWidget
        .animate()
        .fadeIn(duration: 320.ms, delay: delayMs.ms)
        .slideX(begin: 0.06, end: 0, duration: 380.ms, delay: delayMs.ms, curve: Curves.easeOutCubic);
  }

  /// Sticky Bottom Floating Bar with Current User Placement
  Widget _buildBottomUserBar(LeaderboardController controller) {
    return Obx(() {
      final rank = controller.currentUserRank.value;
      final stars = controller.userTotalStars.value;
      final unlockedLevel = controller.userLevel.value;
      final gap = controller.starsToNextRank.value;
      final myName = controller.storage.getOrCreateUserName();
      final myPhotoUrl = controller.storage.userPhotoUrl.value;

      return Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F315E), Color(0xFF091C36)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.85),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, -2),
            ),
            const BoxShadow(
              color: Colors.black54,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // User Rank Badge (with climb green highlight if improved)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: controller.hasRankClimbed.value
                      ? [const Color(0xFF00E676), const Color(0xFF00B0FF)]
                      : [const Color(0xFF00E5FF), const Color(0xFF0072FF)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: (controller.hasRankClimbed.value
                            ? const Color(0xFF00E676)
                            : const Color(0xFF00E5FF))
                        .withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.hasRankClimbed.value) ...[
                    const Icon(Icons.arrow_upward_rounded, size: 14, color: Colors.black),
                    const SizedBox(width: 2),
                  ],
                  Text(
                    rank > 0 ? '#$rank' : '--',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // User Google Profile Picture with Flag
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildUserPhoto(
                  photoUrl: myPhotoUrl,
                  radius: 17,
                  borderColor: const Color(0xFF00E5FF),
                  borderWidth: 2,
                  shadows: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF061426),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00E5FF), width: 0.8),
                    ),
                    child: Text(
                      controller.storage.userCountryFlag.value,
                      style: const TextStyle(fontSize: 8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 10),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          myName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '(You)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00E5FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rank == 1
                        ? 'Lv $unlockedLevel • 👑 You rule the world!'
                        : (rank > 1 && gap > 0)
                            ? 'Lv $unlockedLevel • ⭐ $gap more to reach #${rank - 1}'
                            : 'Lv $unlockedLevel • Global Rank',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: rank == 1
                          ? const Color(0xFFFFD700).withValues(alpha: 0.9)
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // User Total Stars
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    stars.formatCompact,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Premium Login Required Screen when user is a guest (No Static / Dummy Data)
  Widget _buildLoginRequiredView(BuildContext context, LeaderboardController controller) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0D284F).withValues(alpha: 0.95),
                const Color(0xFF071A35).withValues(alpha: 0.98),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                blurRadius: 28,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Colors.black87,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing Trophy Icon
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFF3E2723),
                    size: 46,
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
                'Sign in with Google to view live player ranks, compete on global leaderboards, and backup your level stars safely to the cloud!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 22),

              // Feature Highlights Row (Cloud Sync, Real Ranks, Free)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFeatureBadge('☁️ Cloud Sync'),
                  const SizedBox(width: 8),
                  _buildFeatureBadge('🏆 Live Ranks'),
                  const SizedBox(width: 8),
                  _buildFeatureBadge('⭐ Stars'),
                ],
              ),

              const SizedBox(height: 26),

              // Direct One-Tap Google Sign-In Button
              GestureDetector(
                onTap: _isSigningIn
                    ? null
                    : () async {
                        AudioService.to.playButtonClick();
                        if (!Get.isRegistered<FirebaseService>()) {
                          Get.snackbar(
                            'Unavailable',
                            'Online services are not ready yet. Please try again shortly.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFFFF5252).withValues(alpha: 0.95),
                            colorText: Colors.white,
                          );
                          return;
                        }
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
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 16,
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
                              width: 26,
                              height: 26,
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
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
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

  Widget _buildFeatureBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}
