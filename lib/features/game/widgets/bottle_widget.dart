import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/utils/haptic_feedback_helper.dart';
import '../models/bottle.dart';
import 'bottle_completion_effects.dart';
import 'bottle_painter.dart';

/// Interactive bottle widget with lift-on-select, pour tilting animations,
/// and game-feel animated cap & sparkle explosion upon single-color completion.
class BottleWidget extends StatefulWidget {
  final Bottle bottle;
  final int index;
  final bool isSelected;
  final bool isHintSource;
  final bool isHintTarget;
  final String skinType;
  final double tiltAngle; // in radians, negative for tilt left, positive for tilt right
  final Offset tiltOffset; // translation offset during pour
  final VoidCallback onTap;

  const BottleWidget({
    super.key,
    required this.bottle,
    required this.index,
    required this.isSelected,
    required this.onTap,
    this.isHintSource = false,
    this.isHintTarget = false,
    this.skinType = 'glass',
    this.tiltAngle = 0.0,
    this.tiltOffset = Offset.zero,
  });

  @override
  State<BottleWidget> createState() => _BottleWidgetState();
}

class _BottleWidgetState extends State<BottleWidget>
    with TickerProviderStateMixin {
  late final AnimationController _waveController;
  late final AnimationController _elevationController;
  late final AnimationController _capController;
  late final AnimationController _sparkleBurstController;
  late final AnimationController _ambientSparkleController;

  List<BottleSparkleParticle> _burstParticles = [];
  bool _isCurrentlyCompleted = false;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _elevationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _capController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _sparkleBurstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _ambientSparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    if (widget.isSelected) {
      _elevationController.value = 1.0;
    }

    _isCurrentlyCompleted = widget.bottle.isCompleted && widget.bottle.isNotEmpty;
    if (_isCurrentlyCompleted) {
      _capController.value = 1.0;
      _burstParticles = BottleSparklesHelper.generateBurstParticles(
        widget.bottle.topColor,
        const Size(58, 150),
      );
    }
  }

  @override
  void didUpdateWidget(covariant BottleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Selection elevation animation
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _elevationController.forward();
      } else {
        _elevationController.reverse();
      }
    }

    // Bottle completion detection
    final isNowCompleted = widget.bottle.isCompleted && widget.bottle.isNotEmpty;

    if (!_isCurrentlyCompleted && isNowCompleted) {
      _isCurrentlyCompleted = true;
      // Bottle just completed: Trigger burst sparkles, drop cap, and haptic impact
      _burstParticles = BottleSparklesHelper.generateBurstParticles(
        widget.bottle.topColor,
        const Size(58, 150),
      );
      _sparkleBurstController.forward(from: 0.0);
      _capController.forward(from: 0.0);
      HapticFeedbackHelper.mediumImpact();
    } else if (_isCurrentlyCompleted && !isNowCompleted) {
      _isCurrentlyCompleted = false;
      // Reverted (e.g. Undo or Restart): Retract cap and clear sparkles
      _capController.reset();
      _sparkleBurstController.reset();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _elevationController.dispose();
    _capController.dispose();
    _sparkleBurstController.dispose();
    _ambientSparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _waveController,
          _elevationController,
          _capController,
          _sparkleBurstController,
          _ambientSparkleController,
        ]),
        builder: (context, child) {
          // Elevation translation: lifts bottle up by 24px when selected
          final elevationOffset =
              -24.0 * Curves.easeOutBack.transform(_elevationController.value);

          // Subtle squash impact when cap slams down
          double bottleScaleY = 1.0;
          double bottleScaleX = 1.0;
          final capVal = _capController.value;
          if (_capController.isAnimating && capVal > 0.65 && capVal < 0.95) {
            final t = (capVal - 0.65) / 0.3;
            final impactCurve = sin(t * pi);
            bottleScaleY = 1.0 - 0.04 * impactCurve;
            bottleScaleX = 1.0 + 0.03 * impactCurve;
          }

          final curvedCapVal = Curves.easeOutBack.transform(capVal);

          return Transform.translate(
            offset: Offset(
              widget.tiltOffset.dx,
              widget.tiltOffset.dy + elevationOffset,
            ),
            child: Transform.rotate(
              angle: widget.tiltAngle,
              alignment: Alignment.topCenter,
              child: Transform.scale(
                scaleX: bottleScaleX,
                scaleY: bottleScaleY,
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 58,
                  height: 150,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 1. Core Bottle & Liquid Canvas
                      Positioned.fill(
                        child: CustomPaint(
                          painter: BottlePainter(
                            bottle: widget.bottle,
                            skinType: widget.skinType,
                            isSelected: widget.isSelected,
                            isHintSource: widget.isHintSource,
                            isHintTarget: widget.isHintTarget,
                            wavePhase: _waveController.value * 2 * pi,
                          ),
                        ),
                      ),

                      // 2. Animated Cap & Sparkle Burst Effects Overlay
                      Positioned.fill(
                        child: CustomPaint(
                          painter: BottleCompletionPainter(
                            skinType: widget.skinType,
                            capProgress: curvedCapVal,
                            burstProgress: _sparkleBurstController.value,
                            ambientPhase: _ambientSparkleController.value * 2 * pi,
                            burstParticles: _burstParticles,
                            liquidColorId: widget.bottle.topColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

