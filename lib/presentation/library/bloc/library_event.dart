import 'package:equatable/equatable.dart';

/// Events triggering state transitions in [LibraryBloc].
abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers loading of all documents from Hive and verifies physical file existence.
class LoadLibraryEvent extends LibraryEvent {
  const LoadLibraryEvent();
}

/// Triggers the system file picker to import and copy a new PDF into sandbox.
class ImportDocumentEvent extends LibraryEvent {
  const ImportDocumentEvent();
}

/// Toggles whether multi-select mode is currently active.
class ToggleSelectionModeEvent extends LibraryEvent {
  final bool? enable;
  const ToggleSelectionModeEvent([this.enable]);

  @override
  List<Object?> get props => [enable];
}

/// Toggles selection of a specific document by [documentId].
class ToggleDocumentSelectionEvent extends LibraryEvent {
  final String documentId;
  const ToggleDocumentSelectionEvent(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

/// Selects all currently loaded documents in multi-select mode.
class SelectAllDocumentsEvent extends LibraryEvent {
  const SelectAllDocumentsEvent();
}

/// Clears all selections and exits multi-select mode.
class ClearSelectionEvent extends LibraryEvent {
  const ClearSelectionEvent();
}

/// Deletes all documents currently in [selectedDocumentIds] and arms the Undo buffer.
class DeleteSelectedDocumentsEvent extends LibraryEvent {
  const DeleteSelectedDocumentsEvent();
}

/// Deletes a single document by [documentId] and arms the Undo buffer.
class DeleteSingleDocumentEvent extends LibraryEvent {
  final String documentId;
  const DeleteSingleDocumentEvent(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

/// Restores the most recently deleted documents from the in-memory Undo buffer.
class UndoDeleteEvent extends LibraryEvent {
  const UndoDeleteEvent();
}

/// Launches the file picker to relocate a document whose physical file was moved or deleted.
class LocateMovedFileEvent extends LibraryEvent {
  final String documentId;
  const LocateMovedFileEvent(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

/// Permanently removes a missing document record from the library.
class RemoveMissingDocumentEvent extends LibraryEvent {
  final String documentId;
  const RemoveMissingDocumentEvent(this.documentId);

  @override
  List<Object?> get props => [documentId];
}
