import 'package:equatable/equatable.dart';
import '../../../data/models/document_model.dart';

enum LibraryStatus {
  initial,
  loading,
  success,
  failure,
}

/// Notification type matching Page 10 of UI Design.
enum SnackBarType {
  info,
  success,
  warning,
}

class LibraryNotification extends Equatable {
  final String title;
  final String? subtitle;
  final SnackBarType type;
  final bool hasUndo;

  const LibraryNotification({
    required this.title,
    this.subtitle,
    this.type = SnackBarType.info,
    this.hasUndo = false,
  });

  @override
  List<Object?> get props => [title, subtitle, type, hasUndo];
}

/// Immutable state emitted by [LibraryBloc].
class LibraryState extends Equatable {
  final LibraryStatus status;
  final List<DocumentModel> documents;
  final Map<String, bool> fileExistsMap;
  final bool isSelectionMode;
  final Set<String> selectedDocumentIds;
  final List<DocumentModel> recentlyDeletedDocuments;
  final String searchQuery;
  final LibraryNotification? notification;
  final String? errorMessage;

  const LibraryState({
    this.status = LibraryStatus.initial,
    this.documents = const [],
    this.fileExistsMap = const {},
    this.isSelectionMode = false,
    this.selectedDocumentIds = const {},
    this.recentlyDeletedDocuments = const [],
    this.searchQuery = '',
    this.notification,
    this.errorMessage,
  });

  bool get isEmpty => documents.isEmpty;
  int get documentCount => documents.length;
  int get selectedCount => selectedDocumentIds.length;
  bool isSelected(String docId) => selectedDocumentIds.contains(docId);
  bool isFileMissing(String docId) => fileExistsMap[docId] == false;

  /// Returns documents filtered by search query.
  List<DocumentModel> get filteredDocuments {
    if (searchQuery.trim().isEmpty) {
      return documents;
    }
    final q = searchQuery.toLowerCase().trim();
    return documents.where((d) => d.title.toLowerCase().contains(q)).toList();
  }

  /// Calculates total highlights across all currently selected documents (Page 11).
  int get selectedHighlightCount {
    return documents
        .where((d) => selectedDocumentIds.contains(d.id))
        .fold(0, (sum, d) => sum + d.highlightCount);
  }

  LibraryState copyWith({
    LibraryStatus? status,
    List<DocumentModel>? documents,
    Map<String, bool>? fileExistsMap,
    bool? isSelectionMode,
    Set<String>? selectedDocumentIds,
    List<DocumentModel>? recentlyDeletedDocuments,
    String? searchQuery,
    LibraryNotification? notification,
    String? errorMessage,
    bool clearNotification = false,
    bool clearError = false,
  }) {
    return LibraryState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      fileExistsMap: fileExistsMap ?? this.fileExistsMap,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedDocumentIds: selectedDocumentIds ?? this.selectedDocumentIds,
      recentlyDeletedDocuments: recentlyDeletedDocuments ?? this.recentlyDeletedDocuments,
      searchQuery: searchQuery ?? this.searchQuery,
      notification: clearNotification ? null : (notification ?? this.notification),
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
        searchQuery,
        notification,
        errorMessage,
      ];
}
