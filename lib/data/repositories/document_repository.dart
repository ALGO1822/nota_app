import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import '../local/hive_box.dart';
import '../models/document_model.dart';
import '../models/highlight_model.dart';

/// Repository managing PDF file persistence, metadata extraction,
/// and local Hive storage synchronization.
class DocumentRepository {
  final Box<DocumentModel> _documentBox;
  final Box<HighlightModel> _highlightBox;

  DocumentRepository({
    Box<DocumentModel>? documentBox,
    Box<HighlightModel>? highlightBox,
  })  : _documentBox = documentBox ?? Hive.box<DocumentModel>(HiveBoxes.documents),
        _highlightBox = highlightBox ?? Hive.box<HighlightModel>(HiveBoxes.highlights);

  /// Launches the system file picker, copies the selected PDF into
  /// the app's sandboxed storage directory, extracts its page count,
  /// and persists it in Hive.
  ///
  /// Returns the newly created [DocumentModel], or null if the user cancelled.
  Future<DocumentModel?> importDocument() async {
    final List<PlatformFile> files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (files.isEmpty || files.first.path == null) {
      return null;
    }

    final PlatformFile pickedFile = files.first;
    return await _importFromFilePath(
      sourcePath: pickedFile.path!,
      fileName: pickedFile.name,
    );
  }

  /// Imports a PDF file directly given an existing path on disk.
  Future<DocumentModel> importFromPath(String sourcePath) async {
    final String fileName = sourcePath.split(Platform.pathSeparator).last;
    final doc = await _importFromFilePath(
      sourcePath: sourcePath,
      fileName: fileName,
    );
    if (doc == null) {
      throw Exception('Failed to import document from path: $sourcePath');
    }
    return doc;
  }

  /// Internal pipeline to copy the file to sandbox and persist metadata.
  Future<DocumentModel?> _importFromFilePath({
    required String sourcePath,
    required String fileName,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('Source file does not exist at: $sourcePath');
    }

    // 1. Resolve sandboxed documents directory
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory notaDocsDir = Directory('${appDocDir.path}/documents');
    if (!await notaDocsDir.exists()) {
      await notaDocsDir.create(recursive: true);
    }

    // 2. Generate unique filename and copy to sandbox
    final String uniqueId = DateTime.now().microsecondsSinceEpoch.toString();
    // Sanitize filename
    final String sanitizedName = fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');
    final String destinationPath = '${notaDocsDir.path}/${uniqueId}_$sanitizedName';
    final File destinationFile = await sourceFile.copy(destinationPath);
    final int fileSizeBytes = await destinationFile.length();

    // 3. Extract page count via pdfrx
    int pageCount = 1;
    try {
      final pdfDocument = await PdfDocument.openFile(destinationPath);
      pageCount = pdfDocument.pages.length;
      await pdfDocument.dispose();
    } catch (_) {
      // Fallback to default if page count extraction fails
      pageCount = 1;
    }

    // 4. Construct model and persist in Hive
    final DocumentModel newDoc = DocumentModel(
      id: uniqueId,
      title: fileName,
      filePath: destinationPath,
      pageCount: pageCount,
      fileSizeBytes: fileSizeBytes,
      importedAt: DateTime.now(),
      lastOpenedAt: DateTime.now(),
    );

    await _documentBox.put(newDoc.id, newDoc);
    return newDoc;
  }

  /// Retrieves all imported documents sorted by most recently opened first.
  List<DocumentModel> getAllDocuments() {
    final List<DocumentModel> documents = _documentBox.values.toList();
    documents.sort((a, b) => b.lastOpenedAt.compareTo(a.lastOpenedAt));
    return documents;
  }

  /// Retrieves a specific document by its unique ID.
  DocumentModel? getDocumentById(String id) {
    return _documentBox.get(id);
  }

  /// Checks if the physical PDF file still exists at its expected storage path.
  bool doesFileExist(String filePath) {
    return File(filePath).existsSync();
  }

  /// Updates the last read page and touches `lastOpenedAt`.
  Future<void> updateLastReadPage(String documentId, int pageNumber) async {
    final DocumentModel? doc = _documentBox.get(documentId);
    if (doc != null) {
      final updated = doc.copyWith(
        lastReadPage: pageNumber,
        lastOpenedAt: DateTime.now(),
      );
      await _documentBox.put(documentId, updated);
    }
  }

  /// Deletes a document, its physical sandbox file, and its associated highlights.
  Future<void> deleteDocument(String documentId) async {
    final DocumentModel? doc = _documentBox.get(documentId);
    if (doc != null) {
      // Delete physical file from sandbox
      try {
        final file = File(doc.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}

      // Delete associated highlights
      final highlightKeysToDelete = _highlightBox.keys.where((key) {
        final highlight = _highlightBox.get(key);
        return highlight != null && highlight.documentId == documentId;
      }).toList();

      await _highlightBox.deleteAll(highlightKeysToDelete);

      // Delete from Hive
      await _documentBox.delete(documentId);
    }
  }

  /// Bulk deletes multiple documents and their associated highlights.
  Future<void> deleteMultipleDocuments(List<String> documentIds) async {
    for (final id in documentIds) {
      await deleteDocument(id);
    }
  }

  /// Restores a previously deleted document (used for short-window Undo).
  Future<void> restoreDocument(
    DocumentModel document, [
    List<HighlightModel>? highlights,
  ]) async {
    await _documentBox.put(document.id, document);
    if (highlights != null && highlights.isNotEmpty) {
      for (final hl in highlights) {
        await _highlightBox.put(hl.id, hl);
      }
    }
  }

  /// Relocates a document to a newly picked file path if it was moved or deleted.
  Future<DocumentModel?> relocateDocument(String documentId, String newSourcePath) async {
    final DocumentModel? existing = _documentBox.get(documentId);
    if (existing == null) return null;

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory notaDocsDir = Directory('${appDocDir.path}/documents');
    if (!await notaDocsDir.exists()) {
      await notaDocsDir.create(recursive: true);
    }

    final String sanitizedName = existing.title.replaceAll(RegExp(r'[^\w\.\-]'), '_');
    final String destinationPath = '${notaDocsDir.path}/${existing.id}_$sanitizedName';
    final File newFile = await File(newSourcePath).copy(destinationPath);
    final int newSize = await newFile.length();

    int pageCount = existing.pageCount;
    try {
      final pdf = await PdfDocument.openFile(destinationPath);
      pageCount = pdf.pages.length;
      await pdf.dispose();
    } catch (_) {}

    final updated = existing.copyWith(
      filePath: destinationPath,
      fileSizeBytes: newSize,
      pageCount: pageCount,
      lastOpenedAt: DateTime.now(),
    );

    await _documentBox.put(documentId, updated);
    return updated;
  }
}
