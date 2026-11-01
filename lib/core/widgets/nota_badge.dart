import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Minimalist tag/badge for statuses like [ ELABORATED FROM CONTEXT ].
class NotaBadge extends StatelessWidget {
  final String label;
  final Widget? icon;
  final bool isOutlined;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const NotaBadge({
    super.key,
    required this.label,
    this.icon,
    this.isOutlined = true,
    this.foregroundColor = AppColors.ink,
    this.backgroundColor = AppColors.rowFill,
    this.borderColor = AppColors.cardEdge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : backgroundColor,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4.0),
          ],
          Text(
            label.toUpperCase(),
            style: AppTypography.badge.copyWith(
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
