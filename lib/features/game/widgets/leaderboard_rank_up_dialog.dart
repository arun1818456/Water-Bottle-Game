import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/utils/number_formatter.dart';
import '../../leaderboard/leaderboard_controller.dart';

/// Animated local leaderboard rank-up dialog shown after clearing a level
/// when the player's star count overtakes one or more competitors.
class LeaderboardRankUpDialog extends StatefulWidget {
  final List<LeaderboardUser> oldBoard;
  final List<LeaderboardUser> newBoard;
  final int oldRank;
  final int newRank;
  final int oldStars;
  final int newStars;

  const LeaderboardRankUpDialog({
    super.key,
    required this.oldBoard,
    required this.newBoard,
    required this.oldRank,
    required this.newRank,
    required this.oldStars,
    required this.newStars,
  });

  @override
  State<LeaderboardRankUpDialog> createState() => _LeaderboardRankUpDialogState();
}

class _LeaderboardRankUpDialogState extends State<LeaderboardRankUpDialog>
    with SingleTickerProviderStateMixin {
  static const double _rowHeight = 54.0;
  static const double _rowGap = 8.0;
  static const double _stride = _rowHeight + _rowGap;

  late final AnimationController _moveController;
  late final Animation<double> _moveAnim;
  late final List<_AnimatedRowSpec> _rows;
  late final double _boardHeight;

  @override
  void initState() {
    super.initState();
    _prepareRows();

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );
    _moveAnim = CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeInOutCubic,
    );

    // Pause briefly at old position so the player clearly sees their upward climb
    Future.delayed(const Duration(milliseconds: 420), () {
      if (mounted) {
        _moveController.forward();
      }
    });
  }

  void _prepareRows() {
    final board = widget.newBoard;
    final total = board.length;
    final newIdx = board.indexWhere((u) => u.isCurrentUser).clamp(0, total - 1);
    final oldIdxRaw = widget.oldBoard.indexWhere((u) => u.isCurrentUser);
    final oldIdx = oldIdxRaw >= 0 ? oldIdxRaw : newIdx;

    const maxVisible = 6;
    final int windowStart;
    final int windowEnd;
    if (total <= maxVisible) {
      windowStart = 0;
      windowEnd = total;
    } else {
      windowStart = (newIdx - 1).clamp(0, total - maxVisible);
      windowEnd = windowStart + maxVisible;
    }

    final visible = board.sublist(windowStart, windowEnd);
    final visibleCount = visible.length;
    _boardHeight = visibleCount * _stride - _rowGap;

    final userEndSlot = newIdx - windowStart;
    final userStartSlot = (oldIdx - windowStart).clamp(userEndSlot, visibleCount - 1);

    final rivalSpecs = <_AnimatedRowSpec>[];
    _AnimatedRowSpec? userSpec;

    for (var slot = 0; slot < visibleCount; slot++) {
      final globalIdx = windowStart + slot;
      final user = visible[slot];
      if (user.isCurrentUser) {
        userSpec = _AnimatedRowSpec(
          user: user,
          startSlot: userStartSlot,
          endSlot: userEndSlot,
          startRank: widget.oldRank,
          endRank: widget.newRank,
          isCurrentUser: true,
        );
      } else {
        final movedDown = globalIdx > newIdx && globalIdx <= oldIdx;
        final startSlot = movedDown ? (slot - 1).clamp(0, visibleCount - 1) : slot;
        final startRank = movedDown ? user.rank - 1 : user.rank;
        rivalSpecs.add(
          _AnimatedRowSpec(
            user: user,
            startSlot: startSlot,
            endSlot: slot,
            startRank: startRank,
            endRank: user.rank,
            isCurrentUser: false,
          ),
        );
      }
    }

    // Place the current user last in the Stack so their row renders on top while passing rivals
    _rows = [
      ...rivalSpecs,
      ?userSpec,
    ];
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }

  String _cleanName(LeaderboardUser user) {
    const suffix = ' (You)';
    return user.name.endsWith(suffix)
        ? user.name.substring(0, user.name.length - suffix.length)
        : user.name;
  }

  @override
  Widget build(BuildContext context) {
    final rankDelta = (widget.oldRank - widget.newRank).clamp(1, 99);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0E2544),
              Color(0xFF07162B),
              Color(0xFF040D1B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
              blurRadius: 28,
              spreadRadius: 2,
            ),
            const BoxShadow(
              color: Colors.black87,
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Icon & Rank Jump Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E676).withValues(alpha: 0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.trending_up_rounded, color: Color(0xFF001E3C), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'RANK UP!  #${widget.oldRank} → #${widget.newRank}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF001E3C),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ).animate().scale(duration: 320.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 10),

            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF80E5FF), Color(0xFFFFFFFF), Color(0xFFFFD700)],
              ).createShader(bounds),
              child: const Text(
                'LEADERBOARD CLIMB!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'You climbed $rankDelta ${rankDelta == 1 ? 'spot' : 'spots'} with ${widget.newStars.formatCompact} ⭐',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),

            const SizedBox(height: 16),

            // Animated Leaderboard Stack
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF041020).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF1E5898).withValues(alpha: 0.55),
                  width: 1.2,
                ),
              ),
              child: SizedBox(
                height: _boardHeight,
                child: AnimatedBuilder(
                  animation: _moveAnim,
                  builder: (context, _) {
                    final t = _moveAnim.value;
                    final liftScale = 1.0 + 0.045 * math.sin(t * math.pi);
                    final animatedStars =
                        (widget.oldStars + (widget.newStars - widget.oldStars) * t).round();

                    return Stack(
                      clipBehavior: Clip.none,
                      children: _rows.map((spec) {
                        final top = ui.lerpDouble(
                              spec.startSlot * _stride,
                              spec.endSlot * _stride,
                              t,
                            ) ??
                            0.0;
                        final displayedRank = t < 0.5 ? spec.startRank : spec.endRank;
                        final displayedStars =
                            spec.isCurrentUser ? animatedStars : spec.user.stars;

                        Widget card = _buildRowCard(
                          spec: spec,
                          rank: displayedRank,
                          stars: displayedStars,
                          t: t,
                        );

                        if (spec.isCurrentUser) {
                          card = Transform.scale(
                            scale: liftScale,
                            child: card,
                          );
                        }

                        return Positioned(
                          left: 0,
                          right: 0,
                          top: top,
                          height: _rowHeight,
                          child: card,
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Continue CTA
            GestureDetector(
              onTap: () {
                AudioService.to.playButtonClick();
                Get.back();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF0088FF)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'AWESOME!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF001E3C),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 260.ms, curve: Curves.easeOutBack).fadeIn(duration: 200.ms);
  }

  Widget _buildRowCard({
    required _AnimatedRowSpec spec,
    required int rank,
    required int stars,
    required double t,
  }) {
    final isMe = spec.isCurrentUser;
    final settled = t >= 0.95;
    final Color accent = isMe
        ? (settled ? const Color(0xFF00E676) : const Color(0xFF00E5FF))
        : (rank == 1
            ? const Color(0xFFFFD700)
            : (rank == 2
                ? const Color(0xFFE2E8F0)
                : (rank == 3 ? const Color(0xFFFFB300) : const Color(0xFF4FC3F7))));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isMe
              ? [
                  accent.withValues(alpha: 0.34),
                  const Color(0xFF0B2A4E).withValues(alpha: 0.96),
                ]
              : [
                  const Color(0xFF0D2340).withValues(alpha: 0.92),
                  const Color(0xFF08162B).withValues(alpha: 0.92),
                ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isMe ? accent : Colors.white.withValues(alpha: 0.12),
          width: isMe ? 1.8 : 1.0,
        ),
        boxShadow: isMe
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.38),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isMe ? accent : accent.withValues(alpha: 0.16),
              border: Border.all(
                color: accent.withValues(alpha: isMe ? 1.0 : 0.45),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isMe ? const Color(0xFF001E3C) : accent,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Avatar (real Google photo when available/online, clean icon fallback offline)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0B2244),
              border: Border.all(
                color: isMe ? accent : Colors.white24,
                width: 1.2,
              ),
            ),
            child: ClipOval(
              child: spec.user.photoUrl.isNotEmpty
                  ? Image.network(
                      spec.user.photoUrl,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    )
                  : const Icon(
                      Icons.person_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
            ),
          ),

          const SizedBox(width: 10),

          // Name + YOU badge
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    _cleanName(spec.user),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isMe ? FontWeight.w900 : FontWeight.w700,
                      color: isMe ? Colors.white : Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      settled ? '▲ +${widget.oldRank - widget.newRank}' : 'YOU',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF001E3C),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Stars Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.55),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 14),
                const SizedBox(width: 3),
                Text(
                  stars.formatCompact,
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
  }
}

class _AnimatedRowSpec {
  final LeaderboardUser user;
  final int startSlot;
  final int endSlot;
  final int startRank;
  final int endRank;
  final bool isCurrentUser;

  const _AnimatedRowSpec({
    required this.user,
    required this.startSlot,
    required this.endSlot,
    required this.startRank,
    required this.endRank,
    required this.isCurrentUser,
  });
}
