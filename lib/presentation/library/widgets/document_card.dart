import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/document_model.dart';

/// Card displaying document metadata (icon, title, page count, highlights, and missing state).
class DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final bool isMissing;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onLocateFile;
  final VoidCallback? onRemoveMissing;

  const DocumentCard({
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
    final borderColor = isSelected ? AppColors.ink : AppColors.cardEdge;
    final backgroundColor = isSelected ? AppColors.rowFill : AppColors.paper;

    return NotaCard(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      padding: const EdgeInsets.all(16.0),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PDF Icon or Selection Checkbox
              Container(
                width: 40,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.ink : AppColors.rowFill,
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(
                    color: isSelected ? AppColors.ink : AppColors.cardEdge,
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: isSelectionMode
                      ? (isSelected
                          ? const PhosphorIcon(PhosphorIconsRegular.check, color: AppColors.paper, size: 20)
                          : const SizedBox.shrink())
                      : const PhosphorIcon(PhosphorIconsRegular.filePdf, color: AppColors.ink, size: 24),
                ),
              ),
              const SizedBox(width: 14),

              // Title and Page/Highlight Meta
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
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${document.pageCount} ${document.pageCount == 1 ? 'page' : 'pages'}',
                          style: AppTypography.monoSmall,
                        ),
                        const SizedBox(width: 8),
                        const Text('•', style: AppTypography.monoSmall),
                        const SizedBox(width: 8),
                        Text(
                          '${document.highlightCount} ${document.highlightCount == 1 ? 'highlight' : 'highlights'}',
                          style: AppTypography.monoSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Missing file warning banner if physical file is gone
          if (isMissing) ...[
            const SizedBox(height: 14),
            const NotaHairlineDivider(),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: AppColors.rowFill,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: AppColors.cardEdge, width: 1.0),
              ),
              child: Row(
                children: [
                  const PhosphorIcon(PhosphorIconsRegular.warning, size: 16, color: AppColors.ink),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'File moved or deleted',
                      style: AppTypography.monoSmall,
                    ),
                  ),
                  if (onLocateFile != null)
                    NotaPillButton.subtle(
                      label: 'Locate',
                      isDense: true,
                      onPressed: onLocateFile,
                    ),
                  const SizedBox(width: 6),
                  if (onRemoveMissing != null)
                    NotaPillButton.subtle(
                      label: 'Remove',
                      isDense: true,
                      onPressed: onRemoveMissing,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
