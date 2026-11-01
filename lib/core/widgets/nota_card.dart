import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Flat paper card with a hairline card edge border and no drop shadow.
class NotaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;

  const NotaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.onTap,
    this.onLongPress,
    this.borderRadius = 20.0,
    this.backgroundColor = AppColors.paper,
    this.borderColor = AppColors.cardEdge,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: BorderSide(color: borderColor, width: 1.0),
    );

    return Container(
      margin: margin,
      child: Material(
        color: backgroundColor,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.rowFill,
          highlightColor: AppColors.rowFill,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
