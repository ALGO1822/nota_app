import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:nota_app/data/local/hive_box.dart';
import 'package:nota_app/data/models/document_model.dart';
import 'package:nota_app/data/models/highlight_model.dart';
import 'package:nota_app/data/repositories/document_repository.dart';
import 'package:nota_app/presentation/library/bloc/library_bloc.dart';
import 'package:nota_app/presentation/library/bloc/library_event.dart';
import 'package:nota_app/presentation/library/bloc/library_state.dart';

void main() {
  late Directory tempDir;
  late Box<DocumentModel> docBox;
  late Box<HighlightModel> hlBox;
  late DocumentRepository repo;
  late LibraryBloc bloc;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('nota_bloc_test_');
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
    repo = DocumentRepository(documentBox: docBox, highlightBox: hlBox);
    bloc = LibraryBloc(repository: repo);
  });

  tearDown(() {
    bloc.close();
  });

  test('LoadLibraryEvent emits success with documents and file existence map', () async {
    final doc = DocumentModel(
      id: 'doc_1',
      title: 'Doc 1.pdf',
      filePath: '/non/existent/path.pdf',
      pageCount: 5,
      fileSizeBytes: 100,
      importedAt: DateTime.now(),
      lastOpenedAt: DateTime.now(),
    );
    await docBox.put(doc.id, doc);

    bloc.add(const LoadLibraryEvent());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<LibraryState>((s) => s.status == LibraryStatus.loading),
        predicate<LibraryState>((s) =>
            s.status == LibraryStatus.success &&
            s.documents.length == 1 &&
            s.fileExistsMap['doc_1'] == false), // correctly detects missing file!
      ]),
    );
  });

  test('ToggleDocumentSelectionEvent enters selection mode and selects document', () async {
    bloc.add(const ToggleDocumentSelectionEvent('doc_1'));

    await expectLater(
      bloc.stream,
      emits(predicate<LibraryState>((s) =>
          s.isSelectionMode == true && s.selectedDocumentIds.contains('doc_1'))),
    );

    // Toggle again deselects
    bloc.add(const ToggleDocumentSelectionEvent('doc_1'));

    await expectLater(
      bloc.stream,
      emits(predicate<LibraryState>((s) =>
          s.isSelectionMode == false && s.selectedDocumentIds.isEmpty)),
    );
  });

  test('DeleteSelectedDocumentsEvent deletes documents and arms Undo buffer', () async {
    final doc = DocumentModel(
      id: 'doc_del',
      title: 'To Delete.pdf',
      filePath: '${tempDir.path}/del.pdf',
      pageCount: 10,
      fileSizeBytes: 500,
      importedAt: DateTime.now(),
      lastOpenedAt: DateTime.now(),
    );
    await docBox.put(doc.id, doc);

    // First load
    bloc.add(const LoadLibraryEvent());
    await bloc.stream.firstWhere((s) => s.status == LibraryStatus.success);

    // Select document
    bloc.add(const ToggleDocumentSelectionEvent('doc_del'));
    await bloc.stream.firstWhere((s) => s.isSelectionMode);

    // Delete
    bloc.add(const DeleteSelectedDocumentsEvent());
    final deletedState = await bloc.stream.firstWhere((s) => s.recentlyDeletedDocuments.isNotEmpty);

    expect(deletedState.documents.isEmpty, isTrue);
    expect(deletedState.recentlyDeletedDocuments.length, 1);
    expect(deletedState.userMessage, contains('Deleted'));
    expect(docBox.containsKey('doc_del'), isFalse);

    // Undo
    bloc.add(const UndoDeleteEvent());
    final restoredState = await bloc.stream.firstWhere((s) => s.documents.isNotEmpty);

    expect(restoredState.documents.length, 1);
    expect(docBox.containsKey('doc_del'), isTrue);
  });
}
