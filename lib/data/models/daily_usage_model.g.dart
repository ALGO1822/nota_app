// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_usage_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyUsageModelAdapter extends TypeAdapter<DailyUsageModel> {
  @override
  final int typeId = 4;

  @override
  DailyUsageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyUsageModel(
      date: fields[0] as DateTime,
      requestCount: fields[1] as int,
      dailyCap: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DailyUsageModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.requestCount)
      ..writeByte(2)
      ..write(obj.dailyCap);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyUsageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
