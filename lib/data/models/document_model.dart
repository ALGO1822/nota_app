import 'package:hive/hive.dart';
part 'document_model.g.dart';

@HiveType(typeId: 1)
class DocumentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String filePath;

  @HiveField(3)
  final int pageCount;

  @HiveField(4)
  final int lastReadPage;

  @HiveField(5)
  final int highlightCount;

  @HiveField(6)
  final int fileSizeBytes;

  @HiveField(7)
  final DateTime importedAt;

  @HiveField(8)
  final DateTime lastOpenedAt;

  DocumentModel({
  required this.id, 
  required this.title, 
  required this.filePath, 
  required this.pageCount,
  this.lastReadPage = 1, 
  this.highlightCount = 0, 
  required this.fileSizeBytes, 
  required this.importedAt, 
  required this.lastOpenedAt
  });

   DocumentModel copyWith({
      String? title,
      String? filePath,
      int? pageCount,
      int? lastReadPage,
      int? highlightCount,
      int? fileSizeBytes,
      DateTime? lastOpenedAt,
    }) {
      return DocumentModel(
        id: id,
        title: title ?? this.title,
        filePath: filePath ?? this.filePath,
        pageCount: pageCount ?? this.pageCount,
        lastReadPage: lastReadPage ?? this.lastReadPage,
        highlightCount: highlightCount ?? this.highlightCount,
        fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
        importedAt: importedAt,
        lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      );
    }
}