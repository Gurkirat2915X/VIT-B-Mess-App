// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mess_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HostelsAdapter extends TypeAdapter<Hostels> {
  @override
  final typeId = 1;

  @override
  Hostels read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Hostels.Boys;
      case 1:
        return Hostels.Girls;
      default:
        return Hostels.Boys;
    }
  }

  @override
  void write(BinaryWriter writer, Hostels obj) {
    switch (obj) {
      case Hostels.Boys:
        writer.writeByte(0);
      case Hostels.Girls:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HostelsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessTypeAdapter extends TypeAdapter<MessType> {
  @override
  final typeId = 2;

  @override
  MessType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessType.CRCL;
      case 1:
        return MessType.BoysMayuri;
      case 2:
        return MessType.Safal;
      case 3:
        return MessType.JMB;
      case 4:
        return MessType.GirlsMayuri;
      case 5:
        return MessType.AB;
      default:
        return MessType.CRCL;
    }
  }

  @override
  void write(BinaryWriter writer, MessType obj) {
    switch (obj) {
      case MessType.CRCL:
        writer.writeByte(0);
      case MessType.BoysMayuri:
        writer.writeByte(1);
      case MessType.Safal:
        writer.writeByte(2);
      case MessType.JMB:
        writer.writeByte(3);
      case MessType.GirlsMayuri:
        writer.writeByte(4);
      case MessType.AB:
        writer.writeByte(5);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
