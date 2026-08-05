/// Unified disease reference model (single source of truth).
///
/// Mirrors one entry of `assets/disease_data.json`. `modelLabel` holds the
/// exact string the model outputs for this disease (including known data typos
/// such as "SHEALTH BLIGHT"); `name` is the corrected user-facing name.
class Disease {
  final int id;
  final String name;
  final String? modelLabel;
  final String? imageUrl;
  final String description;
  final String causes;
  final String symptoms;
  final String treatment;

  const Disease({
    required this.id,
    required this.name,
    this.modelLabel,
    this.imageUrl,
    required this.description,
    required this.causes,
    required this.symptoms,
    required this.treatment,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      id: json['id'] as int,
      name: json['name'] as String,
      modelLabel: json['modelLabel'] as String?,
      imageUrl: json['image'] as String?,
      description: json['description'] as String,
      causes: json['causes'] as String,
      symptoms: json['symptoms'] as String,
      treatment: json['treatment'] as String,
    );
  }
}