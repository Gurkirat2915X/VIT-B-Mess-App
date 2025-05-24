// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 0;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings(
      isFirstBoot: fields[0] as bool,
      hostelType: fields[1] as Hostels,
      selectedMess: fields[2] as MessType,
      onlyVeg: fields[3] as bool,
      version: fields[4] as String,
      newUpdate: fields[5] as bool?,
      messDataVersion: fields[6] as String?,
      newUpdateVersion: fields[7] as String?,
      updatedTill: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.isFirstBoot)
      ..writeByte(1)
      ..write(obj.hostelType)
      ..writeByte(2)
      ..write(obj.selectedMess)
      ..writeByte(3)
      ..write(obj.onlyVeg)
      ..writeByte(4)
      ..write(obj.version)
      ..writeByte(5)
      ..write(obj.newUpdate)
      ..writeByte(6)
      ..write(obj.messDataVersion)
      ..writeByte(7)
      ..write(obj.newUpdateVersion)
      ..writeByte(8)
      ..write(obj.updatedTill);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
