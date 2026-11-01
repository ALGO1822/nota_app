// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'highlight_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HighlightModelAdapter extends TypeAdapter<HighlightModel> {
  @override
  final int typeId = 2;

  @override
  HighlightModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HighlightModel(
      id: fields[0] as String,
      documentId: fields[1] as String,
      pageNumber: fields[2] as int,
      selectedText: fields[3] as String,
      rects: (fields[4] as List).cast<double>(),
      createdAt: fields[5] as DateTime,
      note: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HighlightModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.documentId)
      ..writeByte(2)
      ..write(obj.pageNumber)
      ..writeByte(3)
      ..write(obj.selectedText)
      ..writeByte(4)
      ..write(obj.rects)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HighlightModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
