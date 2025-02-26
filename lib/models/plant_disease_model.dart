import 'package:hive/hive.dart';
import 'dart:typed_data';

part 'plant_disease_model.g.dart';

@HiveType(typeId: 0)
class PlantDisease extends HiveObject {
  @HiveField(0)
  String plantName;

  @HiveField(1)
  String causes;

  @HiveField(2)
  String symptoms;

  @HiveField(3)
  String treatment;

  @HiveField(4)
  Uint8List? imageBytes;

  @HiveField(5)
  String dateCreated;

  PlantDisease({
    required this.plantName,
    required this.causes,
    required this.symptoms,
    required this.treatment,
    this.imageBytes,
    required this.dateCreated,
  });
}
