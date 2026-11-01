import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/document_model.dart';
import '../../../data/repositories/document_repository.dart';
import 'library_event.dart';
import 'library_state.dart';

/// ============================================================================
/// STATE ARCHITECTURE SPECIFICATION: LibraryBloc (Heavy State Management)
/// ============================================================================
/// 
/// WHY BLOC WAS CHOSEN:
/// Manages heavy async I/O document lifecycle, disk synchronization, search filtering,
/// multi-select batch deletion, and in-memory Undo restoration.
/// 
/// TRANSIENT NOTIFICATION HANDLING:
/// Notifications (Snackbars) are strictly one-shot events. Any subsequent state
/// emission (like toggling a selection or reloading) clears the notification
/// to prevent duplicate or sticky snackbars.
/// ============================================================================
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final DocumentRepository _repository;

  LibraryBloc({required DocumentRepository repository})
      : _repository = repository,
        super(const LibraryState()) {
    on<LoadLibraryEvent>(_onLoadLibrary);
    on<ImportDocumentEvent>(_onImportDocument);
    on<SearchDocumentsEvent>(_onSearchDocuments);
    on<ToggleSelectionModeEvent>(_onToggleSelectionMode);
    on<ToggleDocumentSelectionEvent>(_onToggleDocumentSelection);
    on<SelectAllDocumentsEvent>(_onSelectAllDocuments);
    on<ClearSelectionEvent>(_onClearSelection);
    on<DeleteSelectedDocumentsEvent>(_onDeleteSelectedDocuments);
    on<DeleteSingleDocumentEvent>(_onDeleteSingleDocument);
    on<UndoDeleteEvent>(_onUndoDelete);
    on<LocateMovedFileEvent>(_onLocateMovedFile);
    on<RemoveMissingDocumentEvent>(_onRemoveMissingDocument);
    on<ClearUserMessageEvent>(_onClearUserMessage);
  }

  Future<void> _onLoadLibrary(
    LoadLibraryEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(state.copyWith(
      status: LibraryStatus.loading,
      clearError: true,
      clearNotification: true,
    ));
    try {
      final documents = _repository.getAllDocuments();
      final Map<String, bool> fileExistsMap = {};

      for (final doc in documents) {
        fileExistsMap[doc.id] = _repository.doesFileExist(doc.filePath);
      }

      emit(state.copyWith(
        status: LibraryStatus.success,
        documents: documents,
        fileExistsMap: fileExistsMap,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LibraryStatus.failure,
        errorMessage: 'Failed to load library: ${e.toString()}',
      ));
    }
  }

  Future<void> _onImportDocument(
    ImportDocumentEvent event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      final DocumentModel? importedDoc = await _repository.importDocument();
      if (importedDoc == null) return;

      final updatedDocs = [importedDoc, ...state.documents];
      final updatedExists = Map<String, bool>.from(state.fileExistsMap)..[importedDoc.id] = true;

      emit(state.copyWith(
        documents: updatedDocs,
        fileExistsMap: updatedExists,
        notification: LibraryNotification(
          title: 'Imported "${importedDoc.title}"',
          type: SnackBarType.success,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Import failed: ${e.toString()}',
      ));
    }
  }

  void _onSearchDocuments(
    SearchDocumentsEvent event,
    Emitter<LibraryState> emit,
  ) {
    emit(state.copyWith(
      searchQuery: event.query,
      clearNotification: true,
    ));
  }

  void _onToggleSelectionMode(
    ToggleSelectionModeEvent event,
    Emitter<LibraryState> emit,
  ) {
    final bool enable = event.enable ?? !state.isSelectionMode;
    emit(state.copyWith(
      isSelectionMode: enable,
      selectedDocumentIds: enable ? state.selectedDocumentIds : {},
      clearNotification: true,
    ));
  }

  void _onToggleDocumentSelection(
    ToggleDocumentSelectionEvent event,
    Emitter<LibraryState> emit,
  ) {
    final updated = Set<String>.from(state.selectedDocumentIds);
    if (updated.contains(event.documentId)) {
      updated.remove(event.documentId);
    } else {
      updated.add(event.documentId);
    }

    emit(state.copyWith(
      isSelectionMode: updated.isNotEmpty,
      selectedDocumentIds: updated,
      clearNotification: true, // Prevents stale import snackbar on selection
    ));
  }

  void _onSelectAllDocuments(
    SelectAllDocumentsEvent event,
    Emitter<LibraryState> emit,
  ) {
    final allIds = state.documents.map((d) => d.id).toSet();
    emit(state.copyWith(
      isSelectionMode: true,
      selectedDocumentIds: allIds,
      clearNotification: true,
    ));
  }

  void _onClearSelection(
    ClearSelectionEvent event,
    Emitter<LibraryState> emit,
  ) {
    emit(state.copyWith(
      isSelectionMode: false,
      selectedDocumentIds: {},
      clearNotification: true,
    ));
  }

  Future<void> _onDeleteSelectedDocuments(
    DeleteSelectedDocumentsEvent event,
    Emitter<LibraryState> emit,
  ) async {
    final List<String> idsToDelete = state.selectedDocumentIds.toList();
    if (idsToDelete.isEmpty) return;

    final documentsToBackup = state.documents.where((d) => idsToDelete.contains(d.id)).toList();

    try {
      await _repository.deleteMultipleDocuments(idsToDelete);

      final remainingDocs = state.documents.where((d) => !idsToDelete.contains(d.id)).toList();
      final updatedExists = Map<String, bool>.from(state.fileExistsMap)
        ..removeWhere((key, _) => idsToDelete.contains(key));

      final int count = idsToDelete.length;
      final String msg = count == 1
          ? '1 document deleted'
          : '$count documents deleted';

      emit(state.copyWith(
        documents: remainingDocs,
        fileExistsMap: updatedExists,
        isSelectionMode: false,
        selectedDocumentIds: {},
        recentlyDeletedDocuments: documentsToBackup,
        notification: LibraryNotification(
          title: msg,
          type: SnackBarType.success,
          hasUndo: true,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to delete documents: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteSingleDocument(
    DeleteSingleDocumentEvent event,
    Emitter<LibraryState> emit,
  ) async {
    final doc = state.documents.firstWhere((d) => d.id == event.documentId);
    try {
      await _repository.deleteDocument(event.documentId);

      final remainingDocs = state.documents.where((d) => d.id != event.documentId).toList();
      final updatedExists = Map<String, bool>.from(state.fileExistsMap)..remove(event.documentId);

      emit(state.copyWith(
        documents: remainingDocs,
        fileExistsMap: updatedExists,
        recentlyDeletedDocuments: [doc],
        notification: LibraryNotification(
          title: 'Deleted "${doc.title}"',
          type: SnackBarType.success,
          hasUndo: true,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to delete document: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUndoDelete(
    UndoDeleteEvent event,
    Emitter<LibraryState> emit,
  ) async {
    final toRestore = state.recentlyDeletedDocuments;
    if (toRestore.isEmpty) return;

    try {
      for (final doc in toRestore) {
        await _repository.restoreDocument(doc);
      }

      final updatedDocs = [...toRestore, ...state.documents];
      final updatedExists = Map<String, bool>.from(state.fileExistsMap);
      for (final doc in toRestore) {
        updatedExists[doc.id] = _repository.doesFileExist(doc.filePath);
      }

      emit(state.copyWith(
        documents: updatedDocs,
        fileExistsMap: updatedExists,
        recentlyDeletedDocuments: const [],
        notification: LibraryNotification(
          title: 'Restored ${toRestore.length} document(s)',
          type: SnackBarType.info,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to undo deletion: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLocateMovedFile(
    LocateMovedFileEvent event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      final doc = await _repository.importDocument();
      if (doc == null) return;

      final updated = await _repository.relocateDocument(event.documentId, doc.filePath);
      if (updated != null) {
        final docs = state.documents.map((d) => d.id == event.documentId ? updated : d).toList();
        final updatedExists = Map<String, bool>.from(state.fileExistsMap)..[event.documentId] = true;

        emit(state.copyWith(
          documents: docs,
          fileExistsMap: updatedExists,
          notification: const LibraryNotification(
            title: 'File relocated successfully',
            type: SnackBarType.success,
          ),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to relocate file: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRemoveMissingDocument(
    RemoveMissingDocumentEvent event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await _repository.deleteDocument(event.documentId);
      final remaining = state.documents.where((d) => d.id != event.documentId).toList();
      final updatedExists = Map<String, bool>.from(state.fileExistsMap)..remove(event.documentId);

      emit(state.copyWith(
        documents: remaining,
        fileExistsMap: updatedExists,
        notification: const LibraryNotification(
          title: 'Removed missing document entry',
          type: SnackBarType.info,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to remove document: ${e.toString()}',
      ));
    }
  }

  void _onClearUserMessage(
    ClearUserMessageEvent event,
    Emitter<LibraryState> emit,
  ) {
    emit(state.copyWith(clearNotification: true));
  }
}
