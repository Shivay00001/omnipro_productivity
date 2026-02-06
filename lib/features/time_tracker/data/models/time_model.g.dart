// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeSessionAdapter extends TypeAdapter<TimeSession> {
  @override
  final int typeId = 3;

  @override
  TimeSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeSession(
      id: fields[0] as String,
      projectName: fields[1] as String,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TimeSession obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectName)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
