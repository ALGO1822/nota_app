import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Flat minimal linear progress bar replacing ASCII progress meters.
class NotaLinearProgressBar extends StatelessWidget {
  /// Value between 0.0 and 1.0. Null indicates indeterminate.
  final double? value;
  final double height;
  final Color foregroundColor;
  final Color backgroundColor;
  final double borderRadius;

  const NotaLinearProgressBar({
    super.key,
    this.value,
    this.height = 4.0,
    this.foregroundColor = AppColors.ink,
    this.backgroundColor = AppColors.hairline,
    this.borderRadius = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: value,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
          backgroundColor: backgroundColor,
          minHeight: height,
        ),
      ),
    );
  }
}
