import 'package:flutter/material.dart';

/// Central color definitions for Aqua Sort Master
class AppColors {
  AppColors._();

  // Primary Theme Gradients
  static const Color backgroundTop = Color(0xFF0D1B2A);
  static const Color backgroundMid = Color(0xFF1B263B);
  static const Color backgroundBottom = Color(0xFF0F172A);

  // Accent Colors
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color primaryBlue = Color(0xFF2979FF);
  static const Color primaryPurple = Color(0xFF7C4DFF);
  static const Color accentNeonGreen = Color(0xFF00E676);
  static const Color accentAmber = Color(0xFFFFD600);
  static const Color accentCoral = Color(0xFFFF5252);

  // Glassmorphism Surfaces
  static const Color glassFill = Color(0x1AFFFFFF);
  static const Color glassFillHeavy = Color(0x28FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color cardShadow = Color(0x66000000);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textMuted = Color(0x80FFFFFF);
  static const Color textGold = Color(0xFFFFD700);

  // Liquid Colors (16 Distinct Vibrant Shades)
  // Each color has base, highlight (shine), and shadow (depth)
  static final List<LiquidPalette> liquidPalettes = [
    LiquidPalette(
      id: 1,
      name: 'Ocean Blue',
      base: const Color(0xFF00B0FF),
      highlight: const Color(0xFF80D8FF),
      shadow: const Color(0xFF0091EA),
    ),
    LiquidPalette(
      id: 2,
      name: 'Vibrant Orange',
      base: const Color(0xFFFF6D00),
      highlight: const Color(0xFFFFAB40),
      shadow: const Color(0xFFE65100),
    ),
    LiquidPalette(
      id: 3,
      name: 'Ruby Red',
      base: const Color(0xFFFF1744),
      highlight: const Color(0xFFFF8A80),
      shadow: const Color(0xFFD50000),
    ),
    LiquidPalette(
      id: 4,
      name: 'Emerald Green',
      base: const Color(0xFF00E676),
      highlight: const Color(0xFFB9F6CA),
      shadow: const Color(0xFF00C853),
    ),
    LiquidPalette(
      id: 5,
      name: 'Royal Purple',
      base: const Color(0xFF651FFF),
      highlight: const Color(0xFFB388FF),
      shadow: const Color(0xFF4615B2),
    ),
    LiquidPalette(
      id: 6,
      name: 'Sunshine Yellow',
      base: const Color(0xFFFFD600),
      highlight: const Color(0xFFFFFF8D),
      shadow: const Color(0xFFFFAB00),
    ),
    LiquidPalette(
      id: 7,
      name: 'Electric Pink',
      base: const Color(0xFFF50057),
      highlight: const Color(0xFFFF80AB),
      shadow: const Color(0xFFC51162),
    ),
    LiquidPalette(
      id: 8,
      name: 'Aqua Teal',
      base: const Color(0xFF1DE9B6),
      highlight: const Color(0xFFA7FFEB),
      shadow: const Color(0xFF00BFA5),
    ),
    LiquidPalette(
      id: 9,
      name: 'Deep Navy',
      base: const Color(0xFF2979FF),
      highlight: const Color(0xFF82B1FF),
      shadow: const Color(0xFF0D47A1),
    ),
    LiquidPalette(
      id: 10,
      name: 'Lime Spark',
      base: const Color(0xFFAEEA00),
      highlight: const Color(0xFFCCFF90),
      shadow: const Color(0xFF64DD17),
    ),
    LiquidPalette(
      id: 11,
      name: 'Amber Gold',
      base: const Color(0xFFFF9100),
      highlight: const Color(0xFFFFD180),
      shadow: const Color(0xFFFF6D00),
    ),
    LiquidPalette(
      id: 12,
      name: 'Violet Dream',
      base: const Color(0xFFD500F9),
      highlight: const Color(0xFFEA80FC),
      shadow: const Color(0xFFAA00FF),
    ),
    LiquidPalette(
      id: 13,
      name: 'Cyan Frost',
      base: const Color(0xFF00E5FF),
      highlight: const Color(0xFF84FFFF),
      shadow: const Color(0xFF00B8D4),
    ),
    LiquidPalette(
      id: 14,
      name: 'Coral Glow',
      base: const Color(0xFFFF3D00),
      highlight: const Color(0xFFFF9E80),
      shadow: const Color(0xFFDD2C00),
    ),
    LiquidPalette(
      id: 15,
      name: 'Mint Breeze',
      base: const Color(0xFF00BFA5),
      highlight: const Color(0xFF64FFDA),
      shadow: const Color(0xFF00897B),
    ),
    LiquidPalette(
      id: 16,
      name: 'Hot Magenta',
      base: const Color(0xFFC51162),
      highlight: const Color(0xFFFF4081),
      shadow: const Color(0xFF880E4F),
    ),
  ];

  static LiquidPalette getLiquidPalette(int colorId) {
    if (colorId <= 0 || colorId > liquidPalettes.length) {
      return liquidPalettes[0];
    }
    return liquidPalettes[colorId - 1];
  }
}

class LiquidPalette {
  final int id;
  final String name;
  final Color base;
  final Color highlight;
  final Color shadow;

  const LiquidPalette({
    required this.id,
    required this.name,
    required this.base,
    required this.highlight,
    required this.shadow,
  });
}
