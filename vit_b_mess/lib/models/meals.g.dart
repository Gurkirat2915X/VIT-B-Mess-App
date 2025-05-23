// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meals.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealsAdapter extends TypeAdapter<Meals> {
  @override
  final int typeId = 3;

  @override
  Meals read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Meals(
      messType: fields[0] as MessType,
      breakfast: (fields[1] as List).cast<String>(),
      lunch: (fields[2] as List).cast<String>(),
      snacks: (fields[3] as List).cast<String>(),
      dinner: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Meals obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.messType)
      ..writeByte(1)
      ..write(obj.breakfast)
      ..writeByte(2)
      ..write(obj.lunch)
      ..writeByte(3)
      ..write(obj.snacks)
      ..writeByte(4)
      ..write(obj.dinner);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
