import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';

/// Modal dialog confirming document deletion and warning that local highlights will be removed.
class DeleteConfirmationDialog extends StatelessWidget {
  final int count;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.count,
    required this.onConfirm,
  });

  static Future<bool?> show({
    required BuildContext context,
    required int count,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: AppColors.scrim,
      builder: (ctx) => DeleteConfirmationDialog(
        count: count,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = count == 1 ? 'Delete document?' : 'Delete $count documents?';
    final String description = count == 1
        ? 'This will remove the document and all of its highlights from Nota. The original file on your device will remain untouched.'
        : 'This will remove $count documents and their highlights from Nota. Original files on your device remain untouched.';

    return Dialog(
      backgroundColor: AppColors.paper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: const BorderSide(color: AppColors.cardEdge, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.headlineMedium),
            const SizedBox(height: 12),
            Text(description, style: AppTypography.bodyMedium),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                NotaPillButton.subtle(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                const SizedBox(width: 12),
                NotaPillButton(
                  label: 'Delete',
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    onConfirm();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
