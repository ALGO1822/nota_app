import 'package:equatable/equatable.dart';
import '../../../data/models/document_model.dart';

enum LibraryStatus {
  initial,
  loading,
  success,
  failure,
}

/// Immutable state emitted by [LibraryBloc].
class LibraryState extends Equatable {
  final LibraryStatus status;
  final List<DocumentModel> documents;
  final Map<String, bool> fileExistsMap;
  final bool isSelectionMode;
  final Set<String> selectedDocumentIds;
  final List<DocumentModel> recentlyDeletedDocuments;
  final String? userMessage;
  final String? errorMessage;

  const LibraryState({
    this.status = LibraryStatus.initial,
    this.documents = const [],
    this.fileExistsMap = const {},
    this.isSelectionMode = false,
    this.selectedDocumentIds = const {},
    this.recentlyDeletedDocuments = const [],
    this.userMessage,
    this.errorMessage,
  });

  bool get isEmpty => documents.isEmpty;
  int get selectedCount => selectedDocumentIds.length;
  bool isSelected(String docId) => selectedDocumentIds.contains(docId);
  bool isFileMissing(String docId) => fileExistsMap[docId] == false;

  LibraryState copyWith({
    LibraryStatus? status,
    List<DocumentModel>? documents,
    Map<String, bool>? fileExistsMap,
    bool? isSelectionMode,
    Set<String>? selectedDocumentIds,
    List<DocumentModel>? recentlyDeletedDocuments,
    String? userMessage,
    String? errorMessage,
    bool clearMessage = false,
    bool clearError = false,
  }) {
    return LibraryState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      fileExistsMap: fileExistsMap ?? this.fileExistsMap,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedDocumentIds: selectedDocumentIds ?? this.selectedDocumentIds,
      recentlyDeletedDocuments: recentlyDeletedDocuments ?? this.recentlyDeletedDocuments,
      userMessage: clearMessage ? null : (userMessage ?? this.userMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        documents,
        fileExistsMap,
        isSelectionMode,
        selectedDocumentIds,
        recentlyDeletedDocuments,
        userMessage,
        errorMessage,
      ];
}
