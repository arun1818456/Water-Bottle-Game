import 'dart:math';
import 'package:flutter/material.dart';
import '../models/bottle.dart';
import 'bottle_painter.dart';

/// Interactive bottle widget with lift-on-select and pour tilting animations
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

    if (widget.isSelected) {
      _elevationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant BottleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _elevationController.forward();
      } else {
        _elevationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _elevationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_waveController, _elevationController]),
        builder: (context, child) {
          // Elevation translation: lifts bottle up by 24px when selected
          final elevationOffset = -24.0 * Curves.easeOutBack.transform(_elevationController.value);

          return Transform.translate(
            offset: Offset(
              widget.tiltOffset.dx,
              widget.tiltOffset.dy + elevationOffset,
            ),
            child: Transform.rotate(
              angle: widget.tiltAngle,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 58,
                height: 150,
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
            ),
          );
        },
      ),
    );
  }
}
