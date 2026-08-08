import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../app_dependencies.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_styles.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/inference_service.dart';

/// Lets the user control the scan accuracy threshold and optionally upload a
/// custom `.tflite` model (with an optional labels file).
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key, required this.dependencies}) : super(key: key);

  final AppDependencies dependencies;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _busy = false;

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade700 : AppConstants.primaryColor,
      ),
    );
  }

  Future<InferenceService?> _pickAndLoadModel(String sourcePath) {
    final settings = widget.dependencies.settings;
    final labelsPath = settings.customLabelsPath;
    return InferenceService.loadFromFile(
      modelFile: File(sourcePath),
      labelsFile: labelsPath != null ? File(labelsPath) : null,
    );
  }

  Future<void> _uploadModel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['tflite'],
    );
    final path = result?.files.single.path;
    if (result == null || path == null) return;

    setState(() => _busy = true);
    final candidate = await _pickAndLoadModel(path);
    if (candidate == null) {
      setState(() => _busy = false);
      _showSnack('Could not load that model. Keeping the current one.',
          isError: true);
      return;
    }

    final saved =
        await widget.dependencies.settings.saveCustomModel(path);
    if (saved == null) {
      candidate.dispose();
      setState(() => _busy = false);
      _showSnack('Could not save the model file.', isError: true);
      return;
    }

    _swapInference(candidate);
    setState(() => _busy = false);
    _showSnack('Model loaded (${candidate.labelCount} classes).');
  }

  Future<void> _uploadLabels() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );
    final path = result?.files.single.path;
    if (result == null || path == null) return;

    setState(() => _busy = true);
    final saved =
        await widget.dependencies.settings.saveCustomLabels(path);
    if (saved == null) {
      setState(() => _busy = false);
      _showSnack('Could not save the labels file.', isError: true);
      return;
    }

    // Reload whichever engine is active so the new labels take effect.
    InferenceService? reloaded;
    final settings = widget.dependencies.settings;
    final modelPath = settings.customModelPath;
    if (modelPath != null) {
      reloaded = await InferenceService.loadFromFile(
        modelFile: File(modelPath),
        labelsFile: File(saved),
      );
    } else {
      reloaded = await InferenceService.load(labelsFilePath: saved);
    }

    if (reloaded == null) {
      setState(() => _busy = false);
      _showSnack('Labels saved but the model could not reload.',
          isError: true);
      return;
    }
    _swapInference(reloaded);
    setState(() => _busy = false);
    _showSnack('Labels updated.');
  }

  Future<void> _resetModel() async {
    setState(() => _busy = true);
    final defaults = await InferenceService.load();
    final settings = widget.dependencies.settings;
    await settings.resetCustomModel();
    if (defaults != null) _swapInference(defaults);
    setState(() => _busy = false);
    _showSnack(defaults != null
        ? 'Reverted to the default model.'
        : 'Custom model removed.');
  }

  void _swapInference(InferenceService newEngine) {
    final old = widget.dependencies.inference;
    widget.dependencies.inference = newEngine;
    old?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.dependencies.settings;
    return Scaffold(
      backgroundColor: Color.lerp(lightGreenLeaves, Colors.white, .5),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.primaryColor,
        elevation: 2,
      ),
      body: AnimatedBuilder(
        animation: settings,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildThresholdCard(settings),
              const SizedBox(height: 16),
              _buildModelCard(settings),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThresholdCard(SettingsRepository settings) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Accuracy threshold',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 4),
            Text(
              'Lower = match more photos as recognised.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withOpacity(.6),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: settings.confidenceThreshold,
                    min: 0.50,
                    max: 1.00,
                    divisions: 50,
                    activeColor: AppConstants.primaryColor,
                    onChanged: _busy
                        ? null
                        : (value) =>
                            settings.setConfidenceThreshold(value),
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: Text(
                    '${(settings.confidenceThreshold * 100).toStringAsFixed(0)}'
                    '%',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelCard(SettingsRepository settings) {
    final customPath = settings.customModelPath;
    final modelName = customPath != null
        ? Uri.parse(customPath).pathSegments.last
        : 'AgriGuard default model';
    final labelCount =
        widget.dependencies.inference?.labelCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Model',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.memory,
                size: 18,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  modelName,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (labelCount != null)
                Text(
                  '$labelCount classes',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
            ],
          ),
          if (settings.customLabelsPath != null) ...[
            const SizedBox(height: 4),
            Text(
              'Labels: '
              '${Uri.parse(settings.customLabelsPath!).pathSegments.last}',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
          const SizedBox(height: 18),
          _uploadButton(
            icon: Icons.upload_file,
            label: 'Upload model (.tflite)',
            onTap: _busy ? null : _uploadModel,
          ),
          const SizedBox(height: 10),
          _uploadButton(
            icon: Icons.description_outlined,
            label: 'Upload labels (.txt, optional)',
            onTap: _busy ? null : _uploadLabels,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _resetModel,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.withOpacity(.6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.restart_alt, size: 20),
              label: const Text('Reset to default model'),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.shade800.withOpacity(.35),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Model requirements',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                _ModelNote(
                  icon: Icons.preview_outlined,
                  text:
                      'The file must be a TensorFlow Lite classification model '
                      '(.tflite), trained for image classification. '
                      'Shape and input format must be similar to the bundled '
                      'model (square input, usually 224\u00d7224 or '
                      '256\u00d7256).',
                ),
                SizedBox(height: 8),
                _ModelNote(
                  icon: Icons.format_list_bulleted,
                  text:
                      'Labels file (.txt): one class label per line, in the '
                      'exact same order as the model output. A leading index '
                      '("0 Leaf Blast") is stripped automatically.',
                ),
                SizedBox(height: 8),
                _ModelNote(
                  icon: Icons.warning_amber_rounded,
                  text:
                      'If a label does not match the app\'s disease names, '
                      'that scan will be shown as unidentified.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          side: BorderSide(color: AppConstants.primaryColor.withOpacity(.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(label),
      ),
    );
  }
}

class _ModelNote extends StatelessWidget {
  const _ModelNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: Colors.black45),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}