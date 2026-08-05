import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../models/disease.dart';

/// Loads the bundled disease catalog (`assets/disease_data.json`) and resolves
/// model labels to catalog entries. No network access.
class DiseaseRepository {
  DiseaseRepository._(this._diseases);

  final List<Disease> _diseases;

  /// Loads and caches the catalog from the bundled asset.
  static Future<DiseaseRepository> load() async {
    final raw = await rootBundle.loadString(AppConstants.diseaseDataAsset);
    final decoded = jsonDecode(raw) as List<dynamic>;
    final entries = decoded.cast<Map<String, dynamic>>();
    final diseases = [for (final e in entries) Disease.fromJson(e)];
    return DiseaseRepository._(diseases);
  }

  /// All catalog entries, starting with the fallback entry (id 0).
  List<Disease> get all => List.unmodifiable(_diseases);

  /// The fallback entry shown when a scan is unrecognised or low confidence.
  Disease get fallback => _diseases.firstWhere((d) => d.modelLabel == null);

  /// First catalog entry that matches [label] (case-insensitive).
  Disease? byLabel(String label) => matchByLabel(_diseases, label);

  /// Pure lookup: returns the entry whose `modelLabel` equals [label] ignoring
  /// case and surrounding whitespace, or `null` when nothing matches.
  static Disease? matchByLabel(List<Disease> catalog, String label) {
    final normalized = label.trim().toUpperCase();
    for (final disease in catalog) {
      final candidate = disease.modelLabel;
      if (candidate != null &&
          candidate.trim().toUpperCase() == normalized) {
        return disease;
      }
    }
    return null;
  }
}