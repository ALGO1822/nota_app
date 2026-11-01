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
/// Managing the Library involves complex asynchronous pipelines with multiple
/// side-effects:
/// 1. Native I/O file picking and sandboxed disk replication.
/// 2. PDFium page-count extraction.
/// 3. Physical file existence verification across documents.
/// 4. Multi-select toggle state management.
/// 5. Cascading bulk deletion with an in-memory Undo restoration buffer.
/// 
/// EVENT -> STATE TRANSITIONS:
/// - [LoadLibraryEvent]            -> Loading -> Success (documents loaded + disk verified)
/// - [ImportDocumentEvent]         -> Success (with optimistic import / snackbar notification)
/// - [ToggleSelectionModeEvent]    -> Toggles multi-select mode & resets selected set
/// - [ToggleDocumentSelectionEvent]-> Adds/removes specific docId from selected set
/// - [SelectAllDocumentsEvent]     -> Populates selected set with all document IDs
/// - [ClearSelectionEvent]         -> Exits selection mode & empties selected set
/// - [DeleteSelectedDocumentsEvent]-> Deletes selected files, arms Undo buffer & emits message
/// - [UndoDeleteEvent]             -> Restores files from Undo buffer back into Hive
/// - [LocateMovedFileEvent]        -> Relocates a missing file and updates its metadata
/// - [RemoveMissingDocumentEvent]  -> Removes a dead document entry from Hive
/// 
/// FAILURE RECOVERY:
/// Any file system or Hive exceptions are trapped defensively, emitting
/// [LibraryStatus.failure] with human-readable error descriptions without
/// crashing the UI or corrupting existing loaded state.
/// ============================================================================
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final DocumentRepository _repository;

  LibraryBloc({required DocumentRepository repository})
      : _repository = repository,
        super(const LibraryState()) {
    on<LoadLibraryEvent>(_onLoadLibrary);
    on<ImportDocumentEvent>(_onImportDocument);
    on<ToggleSelectionModeEvent>(_onToggleSelectionMode);
    on<ToggleDocumentSelectionEvent>(_onToggleDocumentSelection);
    on<SelectAllDocumentsEvent>(_onSelectAllDocuments);
    on<ClearSelectionEvent>(_onClearSelection);
    on<DeleteSelectedDocumentsEvent>(_onDeleteSelectedDocuments);
    on<DeleteSingleDocumentEvent>(_onDeleteSingleDocument);
    on<UndoDeleteEvent>(_onUndoDelete);
    on<LocateMovedFileEvent>(_onLocateMovedFile);
    on<RemoveMissingDocumentEvent>(_onRemoveMissingDocument);
  }

  /// Handles [LoadLibraryEvent]:
  /// Reads all documents from Hive, checks if their physical files exist on disk,
  /// and emits a [LibraryStatus.success] state containing documents and the existence map.
  Future<void> _onLoadLibrary(
    LoadLibraryEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(state.copyWith(status: LibraryStatus.loading, clearError: true, clearMessage: true));
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

  /// Handles [ImportDocumentEvent]:
  /// Launches native file picker, copies the PDF to sandbox, extracts page count,
  /// and appends the new document to the library list.
  Future<void> _onImportDocument(
    ImportDocumentEvent event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      final DocumentModel? importedDoc = await _repository.importDocument();
      if (importedDoc == null) {
        // User cancelled picker - no state change needed
        return;
      }

      final updatedDocs = [importedDoc, ...state.documents];
      final updatedExists = Map<String, bool>.from(state.fileExistsMap)..[importedDoc.id] = true;

      emit(state.copyWith(
        documents: updatedDocs,
        fileExistsMap: updatedExists,
        userMessage: 'Imported "${importedDoc.title}"',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Import failed: ${e.toString()}',
      ));
    }
  }

  /// Handles [ToggleSelectionModeEvent]:
  /// Toggles selection mode on or off. When turning off, clears selected set.
  void _onToggleSelectionMode(
    ToggleSelectionModeEvent event,
    Emitter<LibraryState> emit,
  ) {
    final bool enable = event.enable ?? !state.isSelectionMode;
    emit(state.copyWith(
      isSelectionMode: enable,
      selectedDocumentIds: enable ? state.selectedDocumentIds : {},
    ));
  }

  /// Handles [ToggleDocumentSelectionEvent]:
  /// Adds or removes a document ID from the active selection set.
  /// If the selection set becomes empty, multi-select mode can optionally remain or exit.
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

    // Enter selection mode automatically if not already active
    emit(state.copyWith(
      isSelectionMode: updated.isNotEmpty,
      selectedDocumentIds: updated,
    ));
  }

  /// Handles [SelectAllDocumentsEvent]:
  /// Selects every document currently present in the library.
  void _onSelectAllDocuments(
    SelectAllDocumentsEvent event,
    Emitter<LibraryState> emit,
  ) {
    final allIds = state.documents.map((d) => d.id).toSet();
    emit(state.copyWith(
      isSelectionMode: true,
      selectedDocumentIds: allIds,
    ));
  }

  /// Handles [ClearSelectionEvent]:
  /// Exits multi-select mode and clears the selection set.
  void _onClearSelection(
    ClearSelectionEvent event,
    Emitter<LibraryState> emit,
  ) {
    emit(state.copyWith(
      isSelectionMode: false,
      selectedDocumentIds: {},
    ));
  }

  /// Handles [DeleteSelectedDocumentsEvent]:
  /// Backs up selected documents to [recentlyDeletedDocuments] (for Undo),
  /// deletes them from Hive and sandbox storage, and emits a success snackbar message.
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
          ? 'Deleted "${documentsToBackup.first.title}"'
          : 'Deleted $count documents';

      emit(state.copyWith(
        documents: remainingDocs,
        fileExistsMap: updatedExists,
        isSelectionMode: false,
        selectedDocumentIds: {},
        recentlyDeletedDocuments: documentsToBackup,
        userMessage: msg,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to delete documents: ${e.toString()}',
      ));
    }
  }

  /// Handles [DeleteSingleDocumentEvent]:
  /// Deletes a single document, arms the Undo buffer, and notifies the user.
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
        userMessage: 'Deleted "${doc.title}"',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to delete document: ${e.toString()}',
      ));
    }
  }

  /// Handles [UndoDeleteEvent]:
  /// Restores all items in [recentlyDeletedDocuments] back to Hive and the UI list.
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
        userMessage: 'Restored ${toRestore.length} document(s)',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to undo deletion: ${e.toString()}',
      ));
    }
  }

  /// Handles [LocateMovedFileEvent]:
  /// User picks a new location for a document that was flagged as missing.
  Future<void> _onLocateMovedFile(
    LocateMovedFileEvent event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      final doc = await _repository.importDocument();
      if (doc == null) return;

      // Update the existing document with the new path
      final updated = await _repository.relocateDocument(event.documentId, doc.filePath);
      if (updated != null) {
        final docs = state.documents.map((d) => d.id == event.documentId ? updated : d).toList();
        final updatedExists = Map<String, bool>.from(state.fileExistsMap)..[event.documentId] = true;

        emit(state.copyWith(
          documents: docs,
          fileExistsMap: updatedExists,
          userMessage: 'File relocated successfully',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to relocate file: ${e.toString()}',
      ));
    }
  }

  /// Handles [RemoveMissingDocumentEvent]:
  /// Directly removes a missing file record from Hive when the user chooses "Remove".
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
        userMessage: 'Removed missing document entry',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to remove document: ${e.toString()}',
      ));
    }
  }
}
