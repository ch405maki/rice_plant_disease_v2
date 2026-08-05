import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app_dependencies.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/disease.dart';
import '../../data/models/saved_scan.dart';
import '../../data/models/scan_result.dart';
import '../../widgets/circle_icon_button.dart';
import '../../widgets/primary_button.dart';
import 'widgets/analyzing_overlay.dart';
import 'widgets/result_view.dart';
import 'widgets/unrecognized_panel.dart';

enum _ScanStatus { idle, analyzing, success, error }

const _minAnalyzingDuration = Duration(milliseconds: 3000);

class ScanPage extends StatefulWidget {
  const ScanPage({
    Key? key,
    required this.source,
    required this.dependencies,
  }) : super(key: key);

  final ImageSource source;
  final AppDependencies dependencies;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  _ScanStatus _status = _ScanStatus.idle;
  File? _imageFile;
  Disease? _disease;
  String _accuracyLabel = '';
  bool _saved = false;
  bool _recognized = false;

  @override
  void initState() {
    super.initState();
    _pickAndAnalyze();
  }

  Future<void> _pickAndAnalyze([ImageSource? source]) async {
    final inference = widget.dependencies.inference;
    if (inference == null) {
      setState(() => _status = _ScanStatus.error);
      return;
    }

    final picked =
        await widget.dependencies.imageService.pick(source ?? widget.source);
    if (picked == null) {
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    final startedAt = DateTime.now();
    setState(() {
      _status = _ScanStatus.analyzing;
      _imageFile = File(picked.path);
      _disease = null;
      _accuracyLabel = '';
      _saved = false;
      _recognized = false;
    });

    Future<void> ensureMinDisplay() async {
      final shownForMs =
          DateTime.now().difference(startedAt).inMilliseconds;
      final remainingMs = _minAnalyzingDuration.inMilliseconds - shownForMs;
      if (remainingMs > 0) {
        await Future.delayed(Duration(milliseconds: remainingMs));
      }
    }

    try {
      final file = _imageFile!;
      final decoded = await widget.dependencies.imageService.decode(file);
      await ensureMinDisplay();
      if (!mounted) return;
      if (decoded == null) {
        setState(() => _status = _ScanStatus.error);
        return;
      }
      final result = inference.predict(decoded);
      final disease = _resolveDisease(result);
      setState(() {
        _status = _ScanStatus.success;
        _imageFile = file;
        _disease = disease;
        _recognized = disease.modelLabel != null;
        _accuracyLabel = formatAccuracy(result.confidence);
      });
    } catch (_) {
      await ensureMinDisplay();
      if (!mounted) return;
      setState(() => _status = _ScanStatus.error);
    }
  }

  ImageSource get _otherSource =>
      widget.source == ImageSource.camera
          ? ImageSource.gallery
          : ImageSource.camera;

  Disease _resolveDisease(ScanResult result) {
    final aboveThreshold =
        result.confidence >= AppConstants.confidenceThreshold;
    if (!aboveThreshold) {
      return widget.dependencies.diseases.fallback;
    }
    return widget.dependencies.diseases.byLabel(result.label) ??
        widget.dependencies.diseases.fallback;
  }

  Future<void> _saveScan() async {
    final disease = _disease;
    final file = _imageFile;
    if (_saved || disease == null || file == null) return;

    final scan = SavedScan(
      plantName: _recognized ? disease.name : 'Unidentified',
      causes: _recognized ? disease.causes : '',
      symptoms: _recognized ? disease.symptoms : '',
      treatment: _recognized ? disease.treatment : '',
      imageBytes: Uint8List.fromList(await file.readAsBytes()),
      dateCreated: DateTime.now().toIso8601String(),
    );
    await widget.dependencies.scans.add(scan);
    if (!mounted) return;
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showImage = _imageFile != null;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_status == _ScanStatus.success)
            ColoredBox(
              color: Color.lerp(lightGreenLeaves, Colors.white, .5)!,
            )
          else ...[
            const ColoredBox(color: Colors.black),
            if (showImage)
              Image.file(_imageFile!, fit: BoxFit.cover, gaplessPlayback: true),
          ],
          if (_status == _ScanStatus.analyzing) const AnalyzingOverlay(),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleIconButton(
                  icon: Icons.close,
                  onTap: () => Navigator.of(context).pop(),
                  backgroundColor: Colors.black45,
                  iconColor: Colors.white,
                ),
                _buildSaveButton(),
              ],
            ),
          ),
          if (_status == _ScanStatus.error)
            Positioned.fill(child: _buildErrorOverlay()),
          if (_status == _ScanStatus.success)
            Positioned(
              top: 96,
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildResultPanel(),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final canSave = _status == _ScanStatus.success && !_saved;
    return CircleIconButton(
      icon: _saved ? Icons.bookmark_added : Icons.bookmark_add_outlined,
      onTap: canSave ? _saveScan : () {},
      backgroundColor: Colors.black45,
      iconColor: Colors.white,
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to analyse this image.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Try again',
            width: 180,
            onPressed: _pickAndAnalyze,
          ),
        ],
      ),
    );
  }

  Widget _buildResultPanel() {
    if (!_recognized) {
      return UnrecognizedPanel(
        confidenceLabel: _accuracyLabel,
        onRetry: _pickAndAnalyze,
        onChangePhoto: () => _pickAndAnalyze(_otherSource),
        imageFile: _imageFile,
      );
    }
    return ResultView(
      disease: _disease ?? widget.dependencies.diseases.fallback,
      accuracyLabel: _accuracyLabel,
      imageFile: _imageFile,
    );
  }
}