// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlashcardAdapter extends TypeAdapter<Flashcard> {
  @override
  final int typeId = 4;

  @override
  Flashcard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Flashcard(
      id: fields[0] as String,
      front: fields[1] as String,
      back: fields[2] as String,
      easeFactor: fields[3] as double,
      interval: fields[4] as int,
      repetitions: fields[5] as int,
      nextReview: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Flashcard obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.front)
      ..writeByte(2)
      ..write(obj.back)
      ..writeByte(3)
      ..write(obj.easeFactor)
      ..writeByte(4)
      ..write(obj.interval)
      ..writeByte(5)
      ..write(obj.repetitions)
      ..writeByte(6)
      ..write(obj.nextReview);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashcardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
