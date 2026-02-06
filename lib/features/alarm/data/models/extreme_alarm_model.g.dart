// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extreme_alarm_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExtremeAlarmAdapter extends TypeAdapter<ExtremeAlarm> {
  @override
  final int typeId = 8;

  @override
  ExtremeAlarm read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExtremeAlarm(
      id: fields[0] as String,
      alarmTime: fields[1] as DateTime,
      isActive: fields[2] as bool,
      stakeAmount: fields[3] as double,
      penaltyPerMinute: fields[4] as double,
      requiredEssayTopic: fields[5] as String,
      minWordCount: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ExtremeAlarm obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.alarmTime)
      ..writeByte(2)
      ..write(obj.isActive)
      ..writeByte(3)
      ..write(obj.stakeAmount)
      ..writeByte(4)
      ..write(obj.penaltyPerMinute)
      ..writeByte(5)
      ..write(obj.requiredEssayTopic)
      ..writeByte(6)
      ..write(obj.minWordCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtremeAlarmAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
