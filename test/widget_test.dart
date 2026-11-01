import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:nota_app/core/theme/app_colors.dart';
import 'package:nota_app/core/widgets/widgets.dart';
import 'package:nota_app/data/local/hive_box.dart';
import 'package:nota_app/data/models/document_model.dart';
import 'package:nota_app/data/models/highlight_model.dart';
import 'package:nota_app/data/repositories/document_repository.dart';
import 'package:nota_app/main.dart';
import 'package:nota_app/presentation/library/widgets/document_card.dart';

void main() {
  late Directory tempDir;
  late Box<DocumentModel> docBox;
  late Box<HighlightModel> hlBox;
  late DocumentRepository repo;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('nota_widget_test_');
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
  });

  testWidgets('Library renders empty state when no documents exist', (WidgetTester tester) async {
    await tester.pumpWidget(NotaApp(documentRepository: repo));
    await tester.pumpAndSettle();

    expect(find.text('Library'), findsOneWidget);
    expect(find.text('No Documents in Library'), findsOneWidget);
    expect(find.text('Import PDF'), findsOneWidget);
  });

  testWidgets('Library renders document cards with page and highlight counts', (WidgetTester tester) async {
    final doc = DocumentModel(
      id: 'doc_1',
      title: 'Operating Systems.pdf',
      filePath: '/mock/os.pdf',
      pageCount: 42,
      highlightCount: 3,
      fileSizeBytes: 2048,
      importedAt: DateTime.now(),
      lastOpenedAt: DateTime.now(),
    );
    await docBox.put(doc.id, doc);

    await tester.pumpWidget(NotaApp(documentRepository: repo));
    await tester.pumpAndSettle();

    expect(find.text('Operating Systems.pdf'), findsOneWidget);
    expect(find.text('42 pages'), findsOneWidget);
    expect(find.text('3 highlights'), findsOneWidget);
    expect(find.byType(DocumentCard), findsOneWidget);
  });

  testWidgets('Long-pressing document enters multi-select mode and allows deletion', (WidgetTester tester) async {
    final doc = DocumentModel(
      id: 'doc_del',
      title: 'Draft Paper.pdf',
      filePath: '${tempDir.path}/draft.pdf',
      pageCount: 12,
      fileSizeBytes: 1024,
      importedAt: DateTime.now(),
      lastOpenedAt: DateTime.now(),
    );
    await docBox.put(doc.id, doc);

    await tester.pumpWidget(NotaApp(documentRepository: repo));
    await tester.pumpAndSettle();

    // Long press to enter selection mode
    await tester.longPress(find.text('Draft Paper.pdf'));
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsOneWidget);

    // Tap trash icon in app bar
    await tester.tap(find.byTooltip('Delete selected'));
    await tester.pumpAndSettle();

    // Confirm deletion dialog appears
    expect(find.text('Delete document?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Document is removed and empty state shown
    expect(find.text('No Documents in Library'), findsOneWidget);
    expect(find.text('Deleted "Draft Paper.pdf"'), findsOneWidget);

    // Tap UNDO on snackbar
    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();

    // Document is restored
    expect(find.text('Draft Paper.pdf'), findsOneWidget);
  });

  testWidgets('Missing file displays warning banner and locate/remove actions', (WidgetTester tester) async {
    final missingDoc = DocumentModel(
      id: 'missing_1',
      title: 'Lost_Notes.pdf',
      filePath: '/non/existent/path/lost.pdf', // Guaranteed missing
      pageCount: 15,
      fileSizeBytes: 500,
      importedAt: DateTime.now(),
      lastOpenedAt: DateTime.now(),
    );
    await docBox.put(missingDoc.id, missingDoc);

    await tester.pumpWidget(NotaApp(documentRepository: repo));
    await tester.pumpAndSettle();

    expect(find.text('Lost_Notes.pdf'), findsOneWidget);
    expect(find.text('File moved or deleted'), findsOneWidget);
    expect(find.text('Locate'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);

    // Tap Remove
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(find.text('Lost_Notes.pdf'), findsNothing);
  });
}
