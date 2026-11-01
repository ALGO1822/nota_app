import 'package:hive/hive.dart';
part 'highlight_model.g.dart';

@HiveType(typeId: 2)
class HighlightModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String documentId;

  @HiveField(2)
  final int pageNumber;

  @HiveField(3)
  final String selectedText;

  @HiveField(4)
  final List<double> rects;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final String? note;

  HighlightModel({
    required this.id, 
    required this.documentId, 
    required this.pageNumber, 
    required this.selectedText, 
    required this.rects, 
    required this.createdAt, 
    this.note
    });

    HighlightModel copyWith({
      String? selectedText,
      List<double>? rects,
      String? note,
    }) {
      return HighlightModel(
        id: id,
        documentId: documentId,
        pageNumber: pageNumber,
        selectedText: selectedText ?? this.selectedText,
        rects: rects ?? this.rects,
        createdAt: createdAt,
        note: note ?? this.note,
      );
    }
}