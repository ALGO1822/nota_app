import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Nota Typography Hierarchy.
/// All fonts are bundled locally in assets/ (Inter, JetBrainsMono, Newsreader).
class AppTypography {
  AppTypography._();

  static const String fontInter = 'Inter';
  static const String fontJetBrainsMono = 'JetBrainsMono';
  static const String fontNewsreader = 'Newsreader';

  // --- Inter Styles (UI & Controls) ---
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontInter,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontInter,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    letterSpacing: -0.2,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontInter,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontInter,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontInter,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontInter,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontInter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
  );

  // --- JetBrains Mono Styles (Status, Monospace Values, Labels) ---
  static const TextStyle mono = TextStyle(
    fontFamily: fontJetBrainsMono,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
  );

  static const TextStyle monoSmall = TextStyle(
    fontFamily: fontJetBrainsMono,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
    letterSpacing: 0.5,
  );

  static const TextStyle badge = TextStyle(
    fontFamily: fontJetBrainsMono,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    letterSpacing: 0.8,
  );

  // --- Newsreader Styles (PDF Quotes & Reading Passages) ---
  static const TextStyle quote = TextStyle(
    fontFamily: fontNewsreader,
    fontSize: 16,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    height: 1.5,
  );

  static const TextStyle readerSerif = TextStyle(
    fontFamily: fontNewsreader,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    height: 1.6,
  );
}
