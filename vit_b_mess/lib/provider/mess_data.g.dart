// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mess_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HostelsAdapter extends TypeAdapter<Hostels> {
  @override
  final int typeId = 1;

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
        break;
      case Hostels.Girls:
        writer.writeByte(1);
        break;
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
  final int typeId = 2;

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
      default:
        return MessType.CRCL;
    }
  }

  @override
  void write(BinaryWriter writer, MessType obj) {
    switch (obj) {
      case MessType.CRCL:
        writer.writeByte(0);
        break;
      case MessType.BoysMayuri:
        writer.writeByte(1);
        break;
      case MessType.Safal:
        writer.writeByte(2);
        break;
      case MessType.JMB:
        writer.writeByte(3);
        break;
      case MessType.GirlsMayuri:
        writer.writeByte(4);
        break;
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
