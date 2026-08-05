import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:agri_guard/data/models/saved_scan.dart';
import 'package:agri_guard/data/repositories/scan_repository.dart';

void main() {
  late Directory tempDir;
  late Box<SavedScan> box;
  late ScanRepository repository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('scan_repository_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(SavedScanAdapter());
    box = await Hive.openBox<SavedScan>('test_scans');
    repository = ScanRepository(box);
  });

  tearDownAll(() async {
    await box.close();
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('starts empty', () {
    expect(repository.scans, isEmpty);
  });

  test('adds a scan and exposes it', () async {
    await repository.add(
      SavedScan(
        plantName: 'Brown Spot',
        causes: 'causes',
        symptoms: 'symptoms',
        treatment: 'treatment',
        dateCreated: DateTime.now().toIso8601String(),
      ),
    );
    expect(repository.scans.length, 1);
    expect(repository.scans.first.plantName, 'Brown Spot');
  });

  test('deletes a scan by index', () async {
    await repository.add(
      SavedScan(
        plantName: 'Leaf Blast',
        causes: 'c',
        symptoms: 's',
        treatment: 't',
        dateCreated: DateTime.now().toIso8601String(),
      ),
    );
    final countBefore = repository.scans.length;
    await repository.deleteAt(countBefore - 1);
    expect(repository.scans.length, countBefore - 1);
  });

  test('notifies listeners on change', () async {
    var notified = false;
    repository.listenable.addListener(() => notified = true);
    await repository.add(
      SavedScan(
        plantName: 'Tungro',
        causes: 'c',
        symptoms: 's',
        treatment: 't',
        dateCreated: DateTime.now().toIso8601String(),
      ),
    );
    expect(notified, isTrue);
  });
}