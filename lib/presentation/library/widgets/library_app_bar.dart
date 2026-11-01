import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Contextual app bar transitioning smoothly between normal and multi-select modes.
class LibraryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSelectionMode;
  final int selectedCount;
  final VoidCallback onImportPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onClearSelection;
  final VoidCallback onSelectAll;
  final VoidCallback onDeleteSelected;

  const LibraryAppBar({
    super.key,
    required this.isSelectionMode,
    required this.selectedCount,
    required this.onImportPressed,
    required this.onSettingsPressed,
    required this.onClearSelection,
    required this.onSelectAll,
    required this.onDeleteSelected,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    if (isSelectionMode) {
      return AppBar(
        leading: IconButton(
          icon: const PhosphorIcon(PhosphorIconsRegular.x, color: AppColors.ink),
          onPressed: onClearSelection,
          tooltip: 'Exit selection',
        ),
        title: Text(
          '$selectedCount selected',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: onSelectAll,
            child: Text(
              'Select all',
              style: AppTypography.button.copyWith(color: AppColors.ink),
            ),
          ),
          IconButton(
            icon: const PhosphorIcon(PhosphorIconsRegular.trash, color: AppColors.ink),
            onPressed: selectedCount > 0 ? onDeleteSelected : null,
            tooltip: 'Delete selected',
          ),
          const SizedBox(width: 8),
        ],
      );
    }

    return AppBar(
      title: const Text('Library', style: AppTypography.headlineMedium),
      actions: [
        IconButton(
          icon: const PhosphorIcon(PhosphorIconsRegular.plus, color: AppColors.ink),
          onPressed: onImportPressed,
          tooltip: 'Import PDF',
        ),
        IconButton(
          icon: const PhosphorIcon(PhosphorIconsRegular.slidersHorizontal, color: AppColors.ink),
          onPressed: onSettingsPressed,
          tooltip: 'Settings',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
