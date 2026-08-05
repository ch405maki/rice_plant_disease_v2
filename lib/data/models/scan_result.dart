/// Output of a single inference run.
class ScanResult {
  final String label;
  final double confidence;

  const ScanResult({required this.label, required this.confidence});
}