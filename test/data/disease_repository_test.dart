import 'package:flutter_test/flutter_test.dart';
import 'package:agri_guard/data/models/disease.dart';
import 'package:agri_guard/data/repositories/disease_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DiseaseRepository', () {
    late DiseaseRepository repository;

    setUpAll(() async {
      repository = await DiseaseRepository.load();
    });

    test('loads the bundled catalog', () {
      expect(repository.all.length, 7);
    });

    test('fallback is the id-0 "Fail to recognise" entry', () {
      expect(repository.fallback.id, 0);
      expect(repository.fallback.name, 'Fail to recognise');
    });

    test('byLabel matches canonical labels case-insensitively', () {
      expect(repository.byLabel('BROWN SPOT')?.id, 2);
      expect(repository.byLabel('brown spot')?.id, 2);
    });

    test('byLabel resolves the Shealth typo to Sheath Blight', () {
      expect(repository.byLabel('SHEALTH BLIGHT')?.name, 'Sheath Blight');
    });

    test('byLabel returns null for unknown labels', () {
      expect(repository.byLabel('NOT A DISEASE'), isNull);
    });

    test('every label from the model labels file resolves', () {
      const labels = [
        'BACTERIAL BLIGHT',
        'BROWN SPOT',
        'LEAF BLAST',
        'NORMAL RICE PLANT',
        'SHEALTH BLIGHT',
        'TUNGRO',
      ];
      for (final label in labels) {
        expect(repository.byLabel(label), isNotNull,
            reason: 'label "$label" should resolve');
      }
    });
  });

  group('Disease.fromJson', () {
    test('parses all fields and optional ones', () {
      final disease = Disease.fromJson(const <String, dynamic>{
        'id': 3,
        'name': 'Leaf Blast',
        'image': 'assets/images/leafblast.jpeg',
        'modelLabel': 'LEAF BLAST',
        'description': 'desc',
        'causes': 'cause',
        'symptoms': 'sym',
        'treatment': 'treat',
      });
      expect(disease.id, 3);
      expect(disease.name, 'Leaf Blast');
      expect(disease.modelLabel, 'LEAF BLAST');
      expect(disease.imageUrl, 'assets/images/leafblast.jpeg');
    });

    test('parses a fallback entry with null optional fields', () {
      final disease = Disease.fromJson(const <String, dynamic>{
        'id': 0,
        'name': 'Fail to recognise',
        'image': null,
        'modelLabel': null,
        'description': 'Fail to recognise',
        'causes': 'Fail to recognise',
        'symptoms': 'Fail to recognise',
        'treatment': 'Fail to recognise',
      });
      expect(disease.modelLabel, isNull);
      expect(disease.imageUrl, isNull);
    });
  });
}