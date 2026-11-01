import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Minimalist thin-stroke spinner adhering to the Ink/Paper aesthetic.
class NotaLoadingSpinner extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color color;

  const NotaLoadingSpinner({
    super.key,
    this.size = 18.0,
    this.strokeWidth = 1.75,
    this.color = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
