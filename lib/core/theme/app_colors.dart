import 'package:flutter/material.dart';

/// Nota Design System Color Palette.
/// Flat Apple-style minimalism with strictly two tones: Ink on Paper.
class AppColors {
  AppColors._();

  /// Ink: Primary foreground, typography, high-contrast actions.
  static const Color ink = Color(0xFF17120D);

  /// Paper: Warm canvas background for all screens, sheets, and cards.
  static const Color paper = Color(0xFFEAE3D3);

  /// Muted: Secondary body text, counters, and labels (70% ink).
  static const Color muted = Color(0xB317120D);

  /// Hairline: Thin 1px dividers and separators (22% ink).
  static const Color hairline = Color(0x3817120D);

  /// Card Edge: Structural borders for cards, modals, and outlines (28% ink).
  static const Color cardEdge = Color(0x4717120D);

  /// Row Fill: Subtle tint for selected rows or hovered items (8% ink).
  static const Color rowFill = Color(0x1417120D);

  /// Highlight Fill: Saved highlight overlay fill in PDF reader (16% ink).
  static const Color hlFill = Color(0x2917120D);

  /// Scrim: Backdrop opacity for modal bottom sheets (38% ink).
  static const Color scrim = Color(0x6117120D);
}
