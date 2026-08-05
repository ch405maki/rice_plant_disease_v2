// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_scan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedScanAdapter extends TypeAdapter<SavedScan> {
  @override
  final int typeId = 0;

  @override
  SavedScan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedScan(
      plantName: fields[0] as String,
      causes: fields[1] as String,
      symptoms: fields[2] as String,
      treatment: fields[3] as String,
      imageBytes: fields[4] as Uint8List?,
      dateCreated: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SavedScan obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.plantName)
      ..writeByte(1)
      ..write(obj.causes)
      ..writeByte(2)
      ..write(obj.symptoms)
      ..writeByte(3)
      ..write(obj.treatment)
      ..writeByte(4)
      ..write(obj.imageBytes)
      ..writeByte(5)
      ..write(obj.dateCreated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedScanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}