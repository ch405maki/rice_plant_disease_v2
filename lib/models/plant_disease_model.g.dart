// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_disease_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlantDiseaseAdapter extends TypeAdapter<PlantDisease> {
  @override
  final int typeId = 0;

  @override
  PlantDisease read(BinaryReader reader) { 
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlantDisease(
      plantName: fields[0] as String,
      causes: fields[1] as String,
      symptoms: fields[2] as String,
      treatment: fields[3] as String,
      imageBytes: fields[4] as Uint8List?,
      dateCreated: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PlantDisease obj) {
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
      other is PlantDiseaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
