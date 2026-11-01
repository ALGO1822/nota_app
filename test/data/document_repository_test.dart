import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:nota_app/data/local/hive_box.dart';
import 'package:nota_app/data/models/document_model.dart';
import 'package:nota_app/data/models/highlight_model.dart';
import 'package:nota_app/data/repositories/document_repository.dart';

void main() {
  late Directory tempDir;
  late Box<DocumentModel> docBox;
  late Box<HighlightModel> hlBox;
  late DocumentRepository repository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('nota_repo_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DocumentModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(HighlightModelAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    docBox = await Hive.openBox<DocumentModel>(HiveBoxes.documents);
    hlBox = await Hive.openBox<HighlightModel>(HiveBoxes.highlights);
    await docBox.clear();
    await hlBox.clear();
    repository = DocumentRepository(documentBox: docBox, highlightBox: hlBox);
  });

  test('getAllDocuments sorts by lastOpenedAt descending', () async {
    final doc1 = DocumentModel(
      id: 'doc1',
      title: 'Old Doc.pdf',
      filePath: '/path/1',
      pageCount: 10,
      fileSizeBytes: 1000,
      importedAt: DateTime.now().subtract(const Duration(days: 2)),
      lastOpenedAt: DateTime.now().subtract(const Duration(days: 2)),
    );

    final doc2 = DocumentModel(
      id: 'doc2',
      title: 'New Doc.pdf',
      filePath: '/path/2',
      pageCount: 20,
      fileSizeBytes: 2000,
      importedAt: DateTime.now().subtract(const Duration(days: 1)),
      lastOpenedAt: DateTime.now(), // More recent
    );

    await docBox.put(doc1.id, doc1);
    await docBox.put(doc2.id, doc2);

    final docs = repository.getAllDocuments();
    expect(docs.length, 2);
    expect(docs.first.id, 'doc2'); // Most recently opened first
    expect(docs.last.id, 'doc1');
  });

  test('deleteDocument removes document and associated highlights', () async {
    final doc = DocumentModel(
      id: 'doc_to_delete',
      title: 'Delete Me.pdf',
      filePath: '${tempDir.path}/dummy.pdf',
      pageCount: 5,
      fileSizeBytes: 500,
      importedAt: DateTime.now(),
      lastOpenedAt: DateTime.now(),
    );

    final hl = HighlightModel(
      id: 'hl1',
      documentId: 'doc_to_delete',
      pageNumber: 1,
      selectedText: 'Test excerpt',
      rects: [0.0, 0.0, 10.0, 10.0],
      createdAt: DateTime.now(),
    );

    await docBox.put(doc.id, doc);
    await hlBox.put(hl.id, hl);

    expect(docBox.containsKey('doc_to_delete'), isTrue);
    expect(hlBox.containsKey('hl1'), isTrue);

    await repository.deleteDocument('doc_to_delete');

    expect(docBox.containsKey('doc_to_delete'), isFalse);
    expect(hlBox.containsKey('hl1'), isFalse);
  });

  test('updateLastReadPage updates page number and touches lastOpenedAt', () async {
    final doc = DocumentModel(
      id: 'doc_read',
      title: 'Reading.pdf',
      filePath: '/path/read',
      pageCount: 50,
      lastReadPage: 1,
      fileSizeBytes: 1000,
      importedAt: DateTime.now(),
      lastOpenedAt: DateTime(2025, 1, 1),
    );

    await docBox.put(doc.id, doc);

    await repository.updateLastReadPage('doc_read', 15);

    final updated = repository.getDocumentById('doc_read');
    expect(updated?.lastReadPage, 15);
    expect(updated?.lastOpenedAt.isAfter(DateTime(2025, 1, 1)), isTrue);
  });
}
