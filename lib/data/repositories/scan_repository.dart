import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart' show BoxX;

import '../models/saved_scan.dart';

/// Thin wrapper over the Hive box that stores saved scans.
class ScanRepository {
  ScanRepository(this._box);

  final Box<SavedScan> _box;

  /// All saved scans in insertion order.
  List<SavedScan> get scans => _box.values.toList();

  /// Notifies listeners whenever the box changes (for live UI updates).
  ValueListenable<Box<SavedScan>> get listenable => _box.listenable();

  Future<int> add(SavedScan scan) => _box.add(scan);

  Future<void> deleteAt(int index) => _box.deleteAt(index);
}