/// Formatting helpers used across features.

/// Render a classification confidence as a percentage label.
String formatAccuracy(double confidence) {
  return 'Accuracy: ${(confidence * 100).toStringAsFixed(2)}%';
}

/// Render a saved scan timestamp (ISO-8601 string) for display.
String formatTimestamp(String isoDateTime) {
  final truncated =
      isoDateTime.length >= 16 ? isoDateTime.substring(0, 16) : isoDateTime;
  return truncated.replaceFirst('T', ' ');
}