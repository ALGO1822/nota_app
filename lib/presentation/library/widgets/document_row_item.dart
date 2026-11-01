import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/document_model.dart';

/// Document row item matching Page 2 and Page 11 of Nota UI Design.
class DocumentRowItem extends StatelessWidget {
  final DocumentModel document;
  final bool isMissing;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onLocateFile;
  final VoidCallback? onRemoveMissing;

  const DocumentRowItem({
    super.key,
    required this.document,
    this.isMissing = false,
    this.isSelectionMode = false,
    this.isSelected = false,
    required this.onTap,
    required this.onLongPress,
    this.onLocateFile,
    this.onRemoveMissing,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress percentage
    final double progress = document.pageCount > 0
        ? (document.lastReadPage / document.pageCount).clamp(0.0, 1.0)
        : 0.0;
    final int progressPercent = (progress * 100).toInt();

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      splashColor: AppColors.rowFill,
      highlightColor: AppColors.rowFill,
      borderRadius: BorderRadius.circular(12.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection Checkbox Circle (Page 11)
            if (isSelectionMode) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 14.0),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.ink : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.ink : AppColors.cardEdge,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: PhosphorIcon(
                            PhosphorIconsRegular.check,
                            size: 14,
                            color: AppColors.paper,
                          ),
                        )
                      : null,
                ),
              ),
            ],

            // Minimalist Document Icon (Page 2: page shape with text lines)
            _buildDocumentIcon(),
            const SizedBox(width: 16),

            // Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.ink,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),

                  if (isMissing) ...[
                    // Missing State (Page 2)
                    const Text(
                      'file moved or deleted',
                      style: AppTypography.monoSmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: NotaPillButton.outlined(
                            label: 'Locate file',
                            isDense: true,
                            onPressed: onLocateFile,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: NotaPillButton.outlined(
                            label: 'Remove',
                            isDense: true,
                            onPressed: onRemoveMissing,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Normal State (Page 2)
                    Text(
                      '${document.pageCount} pages  ·  ${document.highlightCount} highlights',
                      style: AppTypography.monoSmall.copyWith(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Progress Bar & Percentage
                    Row(
                      children: [
                        Expanded(
                          child: NotaLinearProgressBar(
                            value: progress,
                            height: 2.5,
                            backgroundColor: AppColors.hairline,
                            foregroundColor: AppColors.ink,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$progressPercent%',
                          style: AppTypography.monoSmall.copyWith(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Custom icon matching Page 2 & 11: paper rectangle with lines inside.
  Widget _buildDocumentIcon() {
    return Container(
      width: 44,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: isMissing ? AppColors.hairline : AppColors.ink,
          width: 1.2,
          style: isMissing ? BorderStyle.solid : BorderStyle.solid,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          return Container(
            height: 1.5,
            width: double.infinity,
            color: isMissing ? AppColors.hairline : AppColors.ink.withOpacity(0.85),
          );
        }),
      ),
    );
  }
}
