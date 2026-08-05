import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'saved_scan.g.dart';

/// A scan saved to the local Hive box.
///
/// `typeId: 0` and field order are kept identical to the original
/// `PlantDisease` model so that records written by earlier app versions remain
/// readable.
@HiveType(typeId: 0)
class SavedScan extends HiveObject {
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

  SavedScan({
    required this.plantName,
    required this.causes,
    required this.symptoms,
    required this.treatment,
    this.imageBytes,
    required this.dateCreated,
  });
}