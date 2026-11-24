import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/widgets/pressable_scale.dart';

/// Builds a crisp 8-directional outline + drop shadow around a single [Text]
/// widget so text pops like casual-game UI without duplicating [Text] nodes.
List<Shadow> cartoonTextOutline({
  Color strokeColor = const Color(0xFF0A2458),
  double strokeWidth = 1.6,
  double shadowOffsetY = 2.4,
}) {
  return [
    Shadow(color: strokeColor, offset: Offset(-strokeWidth, -strokeWidth)),
    Shadow(color: strokeColor, offset: Offset(strokeWidth, -strokeWidth)),
    Shadow(color: strokeColor, offset: Offset(-strokeWidth, strokeWidth)),
    Shadow(color: strokeColor, offset: Offset(strokeWidth, strokeWidth)),
    Shadow(color: strokeColor, offset: Offset(0, -strokeWidth)),
    Shadow(color: strokeColor, offset: Offset(0, strokeWidth)),
    Shadow(color: strokeColor, offset: Offset(-strokeWidth, 0)),
    Shadow(color: strokeColor, offset: Offset(strokeWidth, 0)),
    Shadow(
      color: strokeColor.withValues(alpha: 0.75),
      offset: Offset(0, shadowOffsetY),
      blurRadius: 2.0,
    ),
  ];
}

/// Top-left glossy streak badge with overlapping flame icon and "Day Streak" ribbon.
class CartoonStreakBadge extends StatelessWidget {
  const CartoonStreakBadge({
    super.key,
    required this.streak,
    required this.isBroken,
    required this.onTap,
  });

  final int streak;
  final bool isBroken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pillColors = isBroken
        ? const [Color(0xFF8C1D24), Color(0xFF4A0A0E)]
        : const [Color(0xFF2872C6), Color(0xFF093678)];
    final pillBorder = isBroken ? const Color(0xFFFF6B6B) : const Color(0xFFFFD038);

    return PressableScale(
      onTap: onTap,
      pressedScale: 0.94,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 10),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            // Main dark-blue / crimson glossy capsule
            Container(
              constraints: const BoxConstraints(minWidth: 102),
              padding: const EdgeInsets.only(
                left: 30,
                right: 16,
                top: 4,
                bottom: 9,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: pillColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: pillBorder, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$streak',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                    shadows: cartoonTextOutline(
                      strokeColor: isBroken
                          ? const Color(0xFF3E0508)
                          : const Color(0xFF061E4D),
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // Top glossy shine inside capsule
            Positioned(
              left: 24,
              right: 10,
              top: 2.5,
              height: 8,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.32),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),

            // Overlapping Flame on the left
            Positioned(
              left: -8,
              top: -5,
              child: SizedBox(
                width: 36,
                height: 40,
                child: CustomPaint(
                  painter: _CartoonFlamePainter(isBroken: isBroken),
                ),
              ),
            ),

            // Overlapping Bottom "Day Streak" golden ribbon
            Positioned(
              left: 16,
              bottom: -9,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isBroken
                        ? const [Color(0xFFFF8A8A), Color(0xFFE53935)]
                        : const [Color(0xFFFFE44D), Color(0xFFF59E0B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isBroken
                        ? const Color(0xFF7F1D1D)
                        : const Color(0xFF9A5200),
                    width: 1.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Text(
                  isBroken ? 'Streak Lost' : 'Day Streak',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: isBroken ? Colors.white : const Color(0xFF2D1600),
                    height: 1.15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top-right glossy coins pill with overlapping gold "$" coin and green "+" button.
class CartoonCoinsBadge extends StatelessWidget {
  const CartoonCoinsBadge({
    super.key,
    required this.formattedCoins,
    required this.onTap,
  });

  final String formattedCoins;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.94,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Main dark-blue capsule
            Container(
              constraints: const BoxConstraints(minWidth: 118),
              padding: const EdgeInsets.only(
                left: 32,
                right: 34,
                top: 5,
                bottom: 5,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2872C6), Color(0xFF093678)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFF6CD4FF),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  formattedCoins,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                    shadows: cartoonTextOutline(
                      strokeColor: const Color(0xFF061E4D),
                      strokeWidth: 1.4,
                    ),
                  ),
                ),
              ),
            ),

            // Top glossy shine inside capsule
            Positioned(
              left: 24,
              right: 24,
              top: 2.5,
              height: 8,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.28),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),

            // Left overlapping Gold "$" Coin
            Positioned(
              left: -6,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFEE58), Color(0xFFF59E0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: const Color(0xFF9A5200),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD97706),
                        width: 1.3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '\$',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFF59D),
                          height: 1.05,
                          shadows: cartoonTextOutline(
                            strokeColor: const Color(0xFF9A5200),
                            strokeWidth: 1.0,
                            shadowOffsetY: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Right overlapping Glossy Green "+" Button
            Positioned(
              right: -6,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF63F26E), Color(0xFF139E2B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(
                    color: const Color(0xFF0A5416),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 2.5,
                      left: 5,
                      right: 5,
                      height: 11,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.55),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 24,
                      shadows: cartoonTextOutline(
                        strokeColor: const Color(0xFF0A5416),
                        strokeWidth: 1.2,
                        shadowOffsetY: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact upper-area Leaderboard pill matching the glossy blue & gold theme.
class CartoonLeaderboardPill extends StatelessWidget {
  const CartoonLeaderboardPill({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.94,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2872C6), Color(0xFF093678)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFFD038), width: 1.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.32),
              offset: const Offset(0, 3),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 17,
              height: 17,
              child: CustomPaint(painter: _CartoonTrophyPainter()),
            ),
            const SizedBox(width: 6),
            Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: cartoonTextOutline(
                  strokeColor: const Color(0xFF061E4D),
                  strokeWidth: 1.2,
                  shadowOffsetY: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFFFD038),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Large glossy orange-yellow "PLAY NOW" capsule matching the mockup.
class CartoonPlayNowButton extends StatelessWidget {
  const CartoonPlayNowButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.95,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(42),
          border: Border.all(color: Colors.white, width: 3.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF003D99).withValues(alpha: 0.55),
              offset: const Offset(0, 6),
              blurRadius: 10,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFB33E00),
            borderRadius: BorderRadius.circular(38),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFE946),
                  Color(0xFFFFAA00),
                  Color(0xFFFF6D00),
                ],
                stops: [0.0, 0.52, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(36),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Top glossy white sheen
                Positioned(
                  top: -6,
                  left: 22,
                  right: 22,
                  height: 18,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.52),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: CustomPaint(painter: _CartoonPlayTrianglePainter()),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'PLAY NOW',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.0,
                            height: 1.05,
                            shadows: cartoonTextOutline(
                              strokeColor: const Color(0xFF7A2800),
                              strokeWidth: 2.0,
                              shadowOffsetY: 2.8,
                            ),
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
      ),
    );
  }
}

enum CartoonMenuIconType { levels, shop, daily, settings }

/// Glossy sky-blue rounded-square action card matching Levels/Shop/Daily/Settings.
class CartoonMenuCard extends StatelessWidget {
  const CartoonMenuCard({
    super.key,
    required this.label,
    required this.iconType,
    required this.onTap,
    this.hasBadge = false,
  });

  final String label;
  final CartoonMenuIconType iconType;
  final VoidCallback onTap;
  final bool hasBadge;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.92,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 78,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2.6),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00327D).withValues(alpha: 0.55),
                  offset: const Offset(0, 5),
                  blurRadius: 7,
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.only(bottom: 3.5),
              decoration: BoxDecoration(
                color: const Color(0xFF0444A3),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4AD2FF),
                      Color(0xFF0692FF),
                      Color(0xFF005BD4),
                    ],
                    stops: [0.0, 0.52, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Inner top gloss
                    Positioned(
                      top: 2,
                      left: 6,
                      right: 6,
                      height: 18,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.45),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 38,
                          height: 36,
                          child: CustomPaint(
                            painter: _iconPainterFor(iconType),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              label,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.05,
                                shadows: cartoonTextOutline(
                                  strokeColor: const Color(0xFF052E78),
                                  strokeWidth: 1.4,
                                  shadowOffsetY: 1.6,
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
            ),
          ),

          if (hasBadge)
            Positioned(
              top: -4,
              right: -3,
              child: Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5252), Color(0xFFD50000)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(color: Colors.white, width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      offset: const Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  CustomPainter _iconPainterFor(CartoonMenuIconType type) {
    switch (type) {
      case CartoonMenuIconType.levels:
        return _CartoonTrophyPainter();
      case CartoonMenuIconType.shop:
        return _CartoonShopPainter();
      case CartoonMenuIconType.daily:
        return _CartoonCalendarPainter();
      case CartoonMenuIconType.settings:
        return _CartoonGearPainter();
    }
  }
}

class _CartoonFlamePainter extends CustomPainter {
  const _CartoonFlamePainter({required this.isBroken});

  final bool isBroken;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final outerPath = Path()
      ..moveTo(w * 0.52, h * 0.04)
      ..cubicTo(w * 0.68, h * 0.24, w * 0.94, h * 0.42, w * 0.90, h * 0.68)
      ..cubicTo(w * 0.86, h * 0.90, w * 0.68, h * 0.98, w * 0.48, h * 0.98)
      ..cubicTo(w * 0.22, h * 0.98, w * 0.08, h * 0.80, w * 0.12, h * 0.56)
      ..cubicTo(w * 0.14, h * 0.42, w * 0.24, h * 0.30, w * 0.28, h * 0.20)
      ..cubicTo(w * 0.30, h * 0.30, w * 0.35, h * 0.36, w * 0.39, h * 0.36)
      ..cubicTo(w * 0.41, h * 0.22, w * 0.44, h * 0.12, w * 0.52, h * 0.04)
      ..close();

    // Dark outline
    canvas.drawPath(
      outerPath,
      Paint()
        ..color = isBroken ? const Color(0xFF4A0A0E) : const Color(0xFF8B1D00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeJoin = StrokeJoin.round,
    );

    // Outer flame fill
    canvas.drawPath(
      outerPath,
      Paint()
        ..shader = LinearGradient(
          colors: isBroken
              ? const [Color(0xFFFF8A80), Color(0xFFD32F2F)]
              : const [Color(0xFFFF9800), Color(0xFFFF3D00)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Inner bright yellow core
    final innerPath = Path()
      ..moveTo(w * 0.52, h * 0.36)
      ..cubicTo(w * 0.68, h * 0.50, w * 0.76, h * 0.66, w * 0.70, h * 0.82)
      ..cubicTo(w * 0.64, h * 0.92, w * 0.36, h * 0.92, w * 0.30, h * 0.78)
      ..cubicTo(w * 0.24, h * 0.64, w * 0.36, h * 0.48, w * 0.52, h * 0.36)
      ..close();

    canvas.drawPath(
      innerPath,
      Paint()
        ..shader = LinearGradient(
          colors: isBroken
              ? const [Color(0xFFFFCDD2), Color(0xFFFF8A80)]
              : const [Color(0xFFFFF59D), Color(0xFFFFCA28)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, h * 0.3, w, h * 0.7)),
    );
  }

  @override
  bool shouldRepaint(covariant _CartoonFlamePainter oldDelegate) =>
      oldDelegate.isBroken != isBroken;
}

class _CartoonPlayTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.20, h * 0.14)
      ..quadraticBezierTo(w * 0.20, h * 0.06, w * 0.30, h * 0.11)
      ..lineTo(w * 0.88, h * 0.44)
      ..quadraticBezierTo(w * 0.96, h * 0.50, w * 0.88, h * 0.56)
      ..lineTo(w * 0.30, h * 0.89)
      ..quadraticBezierTo(w * 0.20, h * 0.94, w * 0.20, h * 0.86)
      ..close();

    // Drop shadow
    canvas.save();
    canvas.translate(0, 2.2);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF7A2800).withValues(alpha: 0.65)
        ..style = PaintingStyle.fill,
    );
    canvas.restore();

    // Brown outline
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF7A2800)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeJoin = StrokeJoin.round,
    );

    // Crisp white fill
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CartoonTrophyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = Paint()
      ..color = const Color(0xFF7A4400)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.8, w * 0.06)
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final gold = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF176), Color(0xFFFFCA28), Color(0xFFF57F17)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Handles
    final leftHandle = Path()
      ..moveTo(w * 0.26, h * 0.20)
      ..cubicTo(w * 0.06, h * 0.20, w * 0.06, h * 0.52, w * 0.28, h * 0.50);
    final rightHandle = Path()
      ..moveTo(w * 0.74, h * 0.20)
      ..cubicTo(w * 0.94, h * 0.20, w * 0.94, h * 0.52, w * 0.72, h * 0.50);

    canvas.drawPath(leftHandle, stroke..strokeWidth = math.max(2.5, w * 0.11));
    canvas.drawPath(rightHandle, stroke);

    final goldHandle = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, w * 0.06)
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(leftHandle, goldHandle);
    canvas.drawPath(rightHandle, goldHandle);

    // Stem + Base
    final base = Path()
      ..moveTo(w * 0.44, h * 0.62)
      ..lineTo(w * 0.56, h * 0.62)
      ..lineTo(w * 0.56, h * 0.76)
      ..lineTo(w * 0.72, h * 0.80)
      ..lineTo(w * 0.74, h * 0.92)
      ..lineTo(w * 0.26, h * 0.92)
      ..lineTo(w * 0.28, h * 0.80)
      ..lineTo(w * 0.44, h * 0.76)
      ..close();
    canvas.drawPath(base, stroke..strokeWidth = math.max(1.8, w * 0.06));
    canvas.drawPath(base, gold);

    // Cup
    final cup = Path()
      ..moveTo(w * 0.22, h * 0.12)
      ..lineTo(w * 0.78, h * 0.12)
      ..cubicTo(w * 0.78, h * 0.48, w * 0.64, h * 0.66, w * 0.50, h * 0.66)
      ..cubicTo(w * 0.36, h * 0.66, w * 0.22, h * 0.48, w * 0.22, h * 0.12)
      ..close();
    canvas.drawPath(cup, stroke);
    canvas.drawPath(cup, gold);

    // Cup specular highlight
    canvas.drawLine(
      Offset(w * 0.32, h * 0.20),
      Offset(w * 0.36, h * 0.46),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..strokeWidth = math.max(1.5, w * 0.06)
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CartoonShopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final outline = Paint()
      ..color = const Color(0xFF3E180B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round;

    // Storefront body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.44, w * 0.72, h * 0.46),
      const Radius.circular(4),
    );
    canvas.drawRRect(bodyRect, outline);
    canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFFFFF3E0));

    // Door / window
    final doorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.37, h * 0.58, w * 0.26, h * 0.32),
      const Radius.circular(3),
    );
    canvas.drawRRect(doorRect, Paint()..color = const Color(0xFF38BDF8));
    canvas.drawRRect(doorRect, outline..strokeWidth = 1.6);

    // Scalloped striped awning (5 stripes)
    final awningPath = Path()
      ..moveTo(w * 0.16, h * 0.14)
      ..lineTo(w * 0.84, h * 0.14)
      ..lineTo(w * 0.94, h * 0.44)
      ..lineTo(w * 0.06, h * 0.44)
      ..close();
    canvas.drawPath(awningPath, outline..strokeWidth = 2.4);

    final colors = [
      const Color(0xFFEF4444),
      Colors.white,
      const Color(0xFFEF4444),
      Colors.white,
      const Color(0xFFEF4444),
    ];
    for (int i = 0; i < 5; i++) {
      final topLeftX = w * (0.16 + (0.68 / 5) * i);
      final topRightX = w * (0.16 + (0.68 / 5) * (i + 1));
      final botLeftX = w * (0.06 + (0.88 / 5) * i);
      final botRightX = w * (0.06 + (0.88 / 5) * (i + 1));

      final stripe = Path()
        ..moveTo(topLeftX, h * 0.14)
        ..lineTo(topRightX, h * 0.14)
        ..lineTo(botRightX, h * 0.44)
        ..arcToPoint(
          Offset(botLeftX, h * 0.44),
          radius: Radius.circular(w * 0.09),
          clockwise: true,
        )
        ..close();
      canvas.drawPath(stripe, Paint()..color = colors[i]);
      canvas.drawPath(stripe, outline..strokeWidth = 1.3);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CartoonCalendarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final outline = Paint()
      ..color = const Color(0xFF3E180B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round;

    // White calendar body
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.18, w * 0.72, h * 0.74),
      const Radius.circular(6),
    );
    canvas.drawRRect(body, outline);
    canvas.drawRRect(body, Paint()..color = Colors.white);

    // Red top header
    final header = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.14, h * 0.18, w * 0.72, h * 0.24),
      topLeft: const Radius.circular(6),
      topRight: const Radius.circular(6),
    );
    canvas.drawRRect(header, Paint()..color = const Color(0xFFEF4444));
    canvas.drawRRect(header, outline..strokeWidth = 1.8);

    // Two rings
    for (final rx in [w * 0.32, w * 0.68]) {
      final ring = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(rx, h * 0.18), width: w * 0.11, height: h * 0.18),
        const Radius.circular(3),
      );
      canvas.drawRRect(ring, Paint()..color = const Color(0xFFE2E8F0));
      canvas.drawRRect(ring, outline..strokeWidth = 1.6);
    }

    // Center gold star
    final cx = w * 0.50;
    final cy = h * 0.66;
    final outerR = w * 0.20;
    final innerR = w * 0.09;
    final star = Path();
    for (int i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? outerR : innerR;
      final pt = Offset(cx + math.cos(angle) * r, cy + math.sin(angle) * r);
      if (i == 0) {
        star.moveTo(pt.dx, pt.dy);
      } else {
        star.lineTo(pt.dx, pt.dy);
      }
    }
    star.close();
    canvas.drawPath(star, Paint()..color = const Color(0xFFFF9800));
    canvas.drawPath(
      star,
      Paint()
        ..color = const Color(0xFFB45309)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CartoonGearPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final teeth = 8;
    final outerR = math.min(w, h) * 0.45;
    final innerR = math.min(w, h) * 0.33;

    final path = Path();
    for (int i = 0; i < teeth; i++) {
      final baseAngle = i * (2 * math.pi / teeth);
      final step = (2 * math.pi / teeth) / 4;
      final pts = [
        Offset(center.dx + math.cos(baseAngle) * innerR, center.dy + math.sin(baseAngle) * innerR),
        Offset(center.dx + math.cos(baseAngle + step * 0.7) * outerR, center.dy + math.sin(baseAngle + step * 0.7) * outerR),
        Offset(center.dx + math.cos(baseAngle + step * 2.1) * outerR, center.dy + math.sin(baseAngle + step * 2.1) * outerR),
        Offset(center.dx + math.cos(baseAngle + step * 2.8) * innerR, center.dy + math.sin(baseAngle + step * 2.8) * innerR),
      ];
      if (i == 0) {
        path.moveTo(pts[0].dx, pts[0].dy);
      } else {
        path.lineTo(pts[0].dx, pts[0].dy);
      }
      path.lineTo(pts[1].dx, pts[1].dy);
      path.lineTo(pts[2].dx, pts[2].dy);
      path.lineTo(pts[3].dx, pts[3].dy);
    }
    path.close();

    // Hole in center using evenOdd
    path.addOval(Rect.fromCircle(center: center, radius: math.min(w, h) * 0.14));
    path.fillType = PathFillType.evenOdd;

    // Dark blue outline
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF0A2A66)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeJoin = StrokeJoin.round,
    );

    // White-silver glossy fill
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [Colors.white, Color(0xFFD8E6FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
