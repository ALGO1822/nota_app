import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';

/// Modal dialog matching Page 12 of the Nota UI Design specification.
class DeleteConfirmationDialog extends StatelessWidget {
  final int documentCount;
  final int highlightCount;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.documentCount,
    this.highlightCount = 0,
    required this.onConfirm,
  });

  static Future<bool?> show({
    required BuildContext context,
    required int documentCount,
    int highlightCount = 0,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: AppColors.scrim,
      builder: (ctx) => DeleteConfirmationDialog(
        documentCount: documentCount,
        highlightCount: highlightCount,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = documentCount == 1 ? 'Delete document?' : 'Delete $documentCount documents?';
    final String description = documentCount == 1
        ? (highlightCount > 0
            ? 'Its $highlightCount ${highlightCount == 1 ? 'highlight is' : 'highlights are'} removed too. The original PDF stays on your device.'
            : 'Its highlights are removed too. The original PDF stays on your device.')
        : (highlightCount > 0
            ? 'Their $highlightCount highlights are removed too. The original PDFs stay on your device.'
            : 'Their highlights are removed too. The original PDFs stay on your device.');

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
            Text(
              description,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: NotaPillButton.outlined(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NotaPillButton(
                    label: 'Delete',
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onConfirm();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
