import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum NotaSnackBarVariant {
  success,
  info,
  warning,
}

/// Custom SnackBar matching Page 10 of the Nota UI Design specification.
class NotaSnackBar {
  NotaSnackBar._();

  static void show({
    required BuildContext context,
    required String title,
    String? subtitle,
    NotaSnackBarVariant variant = NotaSnackBarVariant.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    IconData iconData;
    switch (variant) {
      case NotaSnackBarVariant.success:
        iconData = PhosphorIconsRegular.check;
        break;
      case NotaSnackBarVariant.warning:
        iconData = PhosphorIconsRegular.warning;
        break;
      case NotaSnackBarVariant.info:
        iconData = PhosphorIconsRegular.info;
        break;
    }

    final snackBar = SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      duration: duration,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Row(
          children: [
            PhosphorIcon(
              iconData,
              size: 20,
              color: AppColors.paper,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.button.copyWith(
                      color: AppColors.paper,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.paper.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  messenger.hideCurrentSnackBar();
                  onAction();
                },
                child: Text(
                  actionLabel,
                  style: AppTypography.button.copyWith(
                    color: AppColors.paper,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.paper,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    messenger.showSnackBar(snackBar);
  }
}
