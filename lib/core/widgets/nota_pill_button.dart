import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'nota_loading_spinner.dart';

enum NotaButtonVariant {
  filled,
  outlined,
  subtle,
}

/// A pill-shaped flat button conforming to Apple-style minimalism.
/// Meets the >= 44px touch-target requirement.
class NotaPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final NotaButtonVariant variant;
  final bool isLoading;
  final bool isDense;
  final double? width;

  const NotaPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = NotaButtonVariant.filled,
    this.isLoading = false,
    this.isDense = false,
    this.width,
  });

  const NotaPillButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDense = false,
    this.width,
  }) : variant = NotaButtonVariant.outlined;

  const NotaPillButton.subtle({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDense = false,
    this.width,
  }) : variant = NotaButtonVariant.subtle;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;

    Color backgroundColor;
    Color foregroundColor;
    Border? border;

    switch (variant) {
      case NotaButtonVariant.filled:
        backgroundColor = isEnabled ? AppColors.ink : AppColors.muted;
        foregroundColor = AppColors.paper;
        border = null;
        break;
      case NotaButtonVariant.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? AppColors.ink : AppColors.muted;
        border = Border.all(
          color: isEnabled ? AppColors.cardEdge : AppColors.hairline,
          width: 1,
        );
        break;
      case NotaButtonVariant.subtle:
        backgroundColor = isEnabled ? AppColors.rowFill : Colors.transparent;
        foregroundColor = isEnabled ? AppColors.ink : AppColors.muted;
        border = null;
        break;
    }

    final double height = isDense ? 36.0 : 44.0;
    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: isDense ? 14.0 : 20.0,
      vertical: isDense ? 8.0 : 10.0,
    );

    Widget content;
    if (isLoading) {
      content = NotaLoadingSpinner(
        size: 16,
        color: variant == NotaButtonVariant.filled ? AppColors.paper : AppColors.ink,
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: AppTypography.button.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: height,
        minWidth: isDense ? 44.0 : 64.0,
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: Material(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: border != null ? border.top : BorderSide.none,
          ),
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: padding,
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}
