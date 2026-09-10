import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Represents a single layer segment of liquid in a bottle
class LiquidLayer {
  final int colorId;

  const LiquidLayer(this.colorId);

  LiquidPalette get palette => AppColors.getLiquidPalette(colorId);

  Color get baseColor => palette.base;
  Color get highlightColor => palette.highlight;
  Color get shadowColor => palette.shadow;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiquidLayer && runtimeType == other.runtimeType && colorId == other.colorId;

  @override
  int get hashCode => colorId.hashCode;
}
