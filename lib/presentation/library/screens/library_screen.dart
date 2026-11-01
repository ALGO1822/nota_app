import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/document_model.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/document_card.dart';
import '../widgets/library_app_bar.dart';

/// The primary library screen of Nota displaying imported PDF study documents.
class LibraryScreen extends StatelessWidget {
  final void Function(DocumentModel document)? onDocumentSelected;
  final VoidCallback? onSettingsPressed;

  const LibraryScreen({
    super.key,
    this.onDocumentSelected,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LibraryBloc, LibraryState>(
      listenWhen: (previous, current) =>
          current.userMessage != null || current.errorMessage != null,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (state.userMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.userMessage!),
              duration: const Duration(seconds: 4),
              action: state.recentlyDeletedDocuments.isNotEmpty
                  ? SnackBarAction(
                      label: 'UNDO',
                      textColor: AppColors.paper,
                      onPressed: () {
                        context.read<LibraryBloc>().add(const UndoDeleteEvent());
                      },
                    )
                  : null,
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<LibraryBloc>();

        return Scaffold(
          appBar: LibraryAppBar(
            isSelectionMode: state.isSelectionMode,
            selectedCount: state.selectedCount,
            onImportPressed: () => bloc.add(const ImportDocumentEvent()),
            onSettingsPressed: onSettingsPressed ?? () {},
            onClearSelection: () => bloc.add(const ClearSelectionEvent()),
            onSelectAll: () => bloc.add(const SelectAllDocumentsEvent()),
            onDeleteSelected: () {
              DeleteConfirmationDialog.show(
                context: context,
                count: state.selectedCount,
                onConfirm: () => bloc.add(const DeleteSelectedDocumentsEvent()),
              );
            },
          ),
          body: SafeArea(
            child: _buildBody(context, state, bloc),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, LibraryState state, LibraryBloc bloc) {
    if (state.status == LibraryStatus.loading && state.documents.isEmpty) {
      return const Center(child: NotaLoadingSpinner(size: 28));
    }

    if (state.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: NotaEmptyState(
            icon: PhosphorIconsRegular.filePdf,
            title: 'No Documents in Library',
            message: 'Import a PDF textbook, paper, or lecture to begin your generative study session.',
            actionLabel: 'Import PDF',
            onAction: () => bloc.add(const ImportDocumentEvent()),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20.0),
      itemCount: state.documents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12.0),
      itemBuilder: (context, index) {
        final doc = state.documents[index];
        final bool isMissing = state.isFileMissing(doc.id);
        final bool isSelected = state.isSelected(doc.id);

        return DocumentCard(
          document: doc,
          isMissing: isMissing,
          isSelectionMode: state.isSelectionMode,
          isSelected: isSelected,
          onTap: () {
            if (state.isSelectionMode) {
              bloc.add(ToggleDocumentSelectionEvent(doc.id));
            } else if (isMissing) {
              _showMissingFilePrompt(context, bloc, doc);
            } else {
              onDocumentSelected?.call(doc);
            }
          },
          onLongPress: () {
            bloc.add(ToggleDocumentSelectionEvent(doc.id));
          },
          onLocateFile: () {
            bloc.add(LocateMovedFileEvent(doc.id));
          },
          onRemoveMissing: () {
            bloc.add(RemoveMissingDocumentEvent(doc.id));
          },
        );
      },
    );
  }

  void _showMissingFilePrompt(BuildContext context, LibraryBloc bloc, DocumentModel doc) {
    NotaBottomSheet.show(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('File Moved or Deleted', style: AppTypography.headlineMedium),
          const SizedBox(height: 10),
          Text(
            'The original file for "${doc.title}" could not be found at its saved location.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 24),
          NotaPillButton(
            label: 'Locate File',
            width: double.infinity,
            onPressed: () {
              Navigator.of(ctx).pop();
              bloc.add(LocateMovedFileEvent(doc.id));
            },
          ),
          const SizedBox(height: 10),
          NotaPillButton.outlined(
            label: 'Remove from Library',
            width: double.infinity,
            onPressed: () {
              Navigator.of(ctx).pop();
              bloc.add(RemoveMissingDocumentEvent(doc.id));
            },
          ),
        ],
      ),
    );
  }
}
