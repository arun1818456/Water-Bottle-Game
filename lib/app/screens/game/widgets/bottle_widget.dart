import 'dart:math';
import 'package:water_bottle_ais/exports.dart';

class BottleWidget extends StatefulWidget {
  final Bottle bottle;
  final int index;
  final bool isSelected;
  final bool isHintSource;
  final bool isHintTarget;
  final String skinType;
  final double tiltAngle;
  final Offset tiltOffset;
  final double drainAmount;
  final double fillAmount;
  final int? fillColor;
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
    this.drainAmount = 0.0,
    this.fillAmount = 0.0,
    this.fillColor,
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

    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _elevationController.forward();
      } else {
        _elevationController.reverse();
      }
    }

    final isNowCompleted = widget.bottle.isCompleted && widget.bottle.isNotEmpty;

    if (!_isCurrentlyCompleted && isNowCompleted) {
      _isCurrentlyCompleted = true;
      _burstParticles = BottleSparklesHelper.generateBurstParticles(
        widget.bottle.topColor,
        const Size(58, 150),
      );
      _sparkleBurstController.forward(from: 0.0);
      _capController.forward(from: 0.0);
      HapticFeedbackHelper.mediumImpact();
    } else if (_isCurrentlyCompleted && !isNowCompleted) {
      _isCurrentlyCompleted = false;
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
          final liftY = -24.0 * _elevationController.value;
          final totalTranslate = widget.tiltOffset + Offset(0, liftY);
          final wavePhase = _waveController.value * 2 * pi;

          return Transform.translate(
            offset: totalTranslate,
            child: Transform.rotate(
              angle: widget.tiltAngle,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 58,
                height: 150,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(58, 150),
                      painter: BottlePainter(
                        bottle: widget.bottle,
                        skinType: widget.skinType,
                        isSelected: widget.isSelected,
                        isHintSource: widget.isHintSource,
                        isHintTarget: widget.isHintTarget,
                        wavePhase: wavePhase,
                        tiltAngle: widget.tiltAngle,
                        drainAmount: widget.drainAmount,
                        fillAmount: widget.fillAmount,
                        fillColor: widget.fillColor,
                      ),
                    ),
                    CustomPaint(
                      size: const Size(58, 150),
                      painter: BottleCompletionPainter(
                        skinType: widget.skinType,
                        capProgress: _capController.value,
                        burstProgress: _sparkleBurstController.value,
                        ambientPhase: _ambientSparkleController.value * 2 * pi,
                        burstParticles: _burstParticles,
                        liquidColorId: widget.bottle.topColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
