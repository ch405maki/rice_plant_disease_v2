import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import '../../core/constants/app_constants.dart';
import '../models/scan_result.dart';

/// Wraps the TensorFlow Lite interpreter: loads the bundled model and labels,
/// pre-processes images, runs inference and returns a typed [ScanResult].
class InferenceService {
  InferenceService._({
    required Interpreter interpreter,
    required List<String> labels,
    required List<int> inputShape,
    required List<int> outputShape,
    required TfLiteType inputType,
    required TfLiteType outputType,
  })  : _interpreter = interpreter,
        _labels = labels,
        _inputShape = inputShape,
        _outputShape = outputShape,
        _inputType = inputType,
        _outputType = outputType;

  final Interpreter _interpreter;
  final List<String> _labels;
  final List<int> _inputShape;
  final List<int> _outputShape;
  final TfLiteType _inputType;
  final TfLiteType _outputType;

  /// Loads the model and labels from the bundled assets. Returns `null` when
  /// loading fails so callers can surface an error instead of crashing.
  static Future<InferenceService?> load({
    String modelAsset = AppConstants.modelAsset,
    String labelsAsset = AppConstants.labelsAsset,
    String? labelsFilePath,
  }) async {
    try {
      final interpreter = await Interpreter.fromAsset(modelAsset);
      final labels = labelsFilePath != null
          ? await _loadLabelsFromFile(File(labelsFilePath))
          : await _loadLabels(labelsAsset);
      return InferenceService._(
        interpreter: interpreter,
        labels: labels,
        inputShape: interpreter.getInputTensor(0).shape,
        outputShape: interpreter.getOutputTensor(0).shape,
        inputType: interpreter.getInputTensor(0).type,
        outputType: interpreter.getOutputTensor(0).type,
      );
    } catch (e) {
      debugPrint('InferenceService load failed: $e');
      return null;
    }
  }

  /// Loads a user-supplied `.tflite` model from disk, using the uploaded
  /// labels file when provided and the bundled default labels otherwise.
  /// Returns `null` when the model cannot be loaded so callers can keep the
  /// current engine.
  static Future<InferenceService?> loadFromFile({
    required File modelFile,
    File? labelsFile,
  }) async {
    try {
      final interpreter = Interpreter.fromFile(modelFile);
      final labels = labelsFile != null
          ? await _loadLabelsFromFile(labelsFile)
          : await _loadLabels(AppConstants.labelsAsset);
      return InferenceService._(
        interpreter: interpreter,
        labels: labels,
        inputShape: interpreter.getInputTensor(0).shape,
        outputShape: interpreter.getOutputTensor(0).shape,
        inputType: interpreter.getInputTensor(0).type,
        outputType: interpreter.getOutputTensor(0).type,
      );
    } catch (e) {
      debugPrint('InferenceService loadFromFile failed: $e');
      return null;
    }
  }

  /// Number of classes the loaded model outputs.
  int get labelCount => _labels.length;

  /// Reads labels and strips the numeric index prefix ("0 BACTERIAL BLIGHT").
  static Future<List<String>> _loadLabels(String labelsAsset) async {
    final rawLabels = await FileUtil.loadLabels(labelsAsset);
    return _cleanLabels(rawLabels);
  }

  static Future<List<String>> _loadLabelsFromFile(File file) async {
    final content = await file.readAsString();
    final lines = content.split('\n').map((line) => line.trim());
    return _cleanLabels(lines.where((line) => line.isNotEmpty).toList());
  }

  static List<String> _cleanLabels(List<String> raw) {
    return raw.map((label) {
      final index = label.indexOf(' ');
      return index == -1 ? label.trim() : label.substring(index).trim();
    }).toList();
  }

  /// Runs inference on a decoded image and returns the top category.
  ScanResult predict(img.Image image) {
    final inputImage = _preProcessInput(image);
    final outputBuffer = TensorBuffer.createFixedSize(
      _outputShape,
      _outputType,
    );
    _interpreter.run(inputImage.buffer, outputBuffer.buffer);
    final top = _topCategory(outputBuffer);
    return ScanResult(label: top.label, confidence: top.score);
  }

  void dispose() {
    _interpreter.close();
  }

  TensorImage _preProcessInput(img.Image image) {
    final inputTensor = TensorImage(_inputType);
    inputTensor.loadImage(image);

    final minLength = min(inputTensor.height, inputTensor.width);
    final cropOp = ResizeWithCropOrPadOp(minLength, minLength);

    final shapeLength = _inputShape[1];
    final resizeOp = ResizeOp(shapeLength, shapeLength, ResizeMethod.BILINEAR);

    final normalizeOp = NormalizeOp(127.5, 127.5);

    final processor = ImageProcessorBuilder()
        .add(cropOp)
        .add(resizeOp)
        .add(normalizeOp)
        .build();

    processor.process(inputTensor);
    return inputTensor;
  }

  _LabelScore _topCategory(TensorBuffer outputBuffer) {
    final processor = TensorProcessorBuilder().build();
    processor.process(outputBuffer);
    final labelled = TensorLabel.fromList(_labels, outputBuffer);

    var bestLabel = _labels.isEmpty ? '' : _labels.first;
    var bestScore = double.negativeInfinity;
    labelled.getMapWithFloatValue().forEach((label, score) {
      if (score > bestScore) {
        bestLabel = label;
        bestScore = score;
      }
    });
    return _LabelScore(bestLabel, bestScore);
  }
}

class _LabelScore {
  const _LabelScore(this.label, this.score);

  final String label;
  final double score;
}