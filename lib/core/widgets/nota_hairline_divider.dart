import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A 1px hairline divider matching the paper-and-ink design tokens.
class NotaHairlineDivider extends StatelessWidget {
  final double? indent;
  final double? endIndent;
  final Color color;

  const NotaHairlineDivider({
    super.key,
    this.indent,
    this.endIndent,
    this.color = AppColors.hairline,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: indent,
      endIndent: endIndent,
      color: color,
    );
  }
}
