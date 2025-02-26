// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../constants.dart';
import '../models/plant_disease_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'screens/widgets/plant_photo_view.dart';
import '../classifier/classifier.dart';
import '../global/global.dart';
import '../models/disease_description.dart';
import '../style/styles.dart';

const _labelsFileName = 'assets/labels.txt';
const _modelFileName = 'model_unquant.tflite';


class ScanPage extends StatefulWidget {
  
  const ScanPage({Key? key, required this.value}) : super(key: key);

  final int value;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

enum _ResultStatus {
  notStarted,
  notFound,
  found,
}

class _ScanPageState extends State<ScanPage> {

  List<Disease> _deseaseList = Disease.plantList;
  int selectedIndex = 0;

  bool _isAnalyzing = false;
  final picker = ImagePicker();
  File? _selectedImageFile;

  late int plantIdSelector = 0;
    // Result
  _ResultStatus _resultStatus = _ResultStatus.notStarted;
  String _plantLabel = ''; // Name of Error Message
  double _accuracy = 0.0;

  late Classifier _classifier;

  bool isBookmarked = false;

  // Access the passed value using widget.value


  @override
  void initState() {
    super.initState();
    int receivedValue = widget.value;
    if (receivedValue == 1) {
    _openScan();
    } else {
    _openGallery();
    }
    _loadClassifier();
  }

  Future<void> _openScan() async {
    _onPickPhoto(ImageSource.camera);
  }

  Future<void> _openGallery() async {
    _onPickPhoto(ImageSource.gallery);
  }

  Future<void> _loadClassifier() async {
    debugPrint(
      'Start loading of Classifier with '
      'labels at $_labelsFileName, '
      'model at $_modelFileName',
    );

    final classifier = await Classifier.loadWith(
      labelsFileName: _labelsFileName,
      modelFileName: _modelFileName,
    );
    _classifier = classifier!;
  }


void _saveData() async {
  final plantDiseaseBox = Hive.box<PlantDisease>('plantDiseases');

  final disease = PlantDisease(
    plantName: Disease.plantList[plantIdSelector].plantName.toString(),
    causes: Disease.plantList[plantIdSelector].causes.toString(),
    symptoms: Disease.plantList[plantIdSelector].symptompts.toString(),
    treatment: Disease.plantList[plantIdSelector].treatment.toString(),
    dateCreated: DateTime.now().toString(),
  );

  if (_selectedImageFile != null) {
    final imageBytes = await _selectedImageFile!.readAsBytes();
    disease.imageBytes = Uint8List.fromList(imageBytes);
    print('HIVE IMAGE SAVED!!!');
  }

  plantDiseaseBox.add(disease);
  print('HIVE SAVED!!!');
}

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: (_selectedImageFile == null) ? 160 : 0,
            left: (_selectedImageFile == null) ? 130 : 0,
            child: SizedBox(
              height: 360,
              child: _buildPhotolView(),
            ),
          ),

          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: const Color(0xFFA7C1B4),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Constants.primaryColor,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    height: 40,
                    width: 40,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          isBookmarked = !isBookmarked;
                          _saveData();
                        });
                      },
                      icon: Icon(
                        isBookmarked ? Icons.bookmark_added : Icons.bookmark_add_outlined,
                        color: Constants.primaryColor,
                      ),
                      iconSize: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 1, left: 0, right: 0),
                height: (_selectedImageFile == null)? 0:size.height * .6,
                width: size.width,
                decoration: const BoxDecoration(
                  color:Color(0xFFA7C1B4),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  _buildResultView(),
                  const Spacer(flex: 10),
                ],
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 1, left: 0, right: 0),
                height: size.height * .1,
                width: size.width,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPickPhotoButton(
                        source: ImageSource.camera,
                        iconData: Icons.camera_alt,
                      ),
                      _buildPickPhotoButtonGalery(
                        source: ImageSource.gallery,
                        title: 'Pick from gallery',
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotolView() {
      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          PlantPhotoView(file: _selectedImageFile),
          _buildAnalyzingText(),
        ],
      );
    }

    Widget _buildAnalyzingText() {
      if (!_isAnalyzing) {
        return const SizedBox.shrink();
      }
      return const Text('Analyzing...', style: kAnalyzingTextStyle);
    }

    Widget _buildPickPhotoButton({
    required ImageSource source,
    required IconData iconData,
      }) {
        return TextButton(
          onPressed: () => _onPickPhoto(source),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 1),
                  blurRadius: 5,
                  color: Constants.primaryColor.withOpacity(.3),
                ),
              ],
            ),
            child: Icon(
              iconData,
              size: 30,
              color: Constants.primaryColor,
            ),
          ),
        );
      }

  Widget _buildPickPhotoButtonGalery({
      required ImageSource source,
      String? title,
    }) {
      return TextButton(
        onPressed: () => _onPickPhoto(source),
        child: Container(
          width: 250,
          height: 50,
          decoration: BoxDecoration(
            color: Constants.primaryColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 1),
                blurRadius: 5,
                color: Constants.primaryColor.withOpacity(.3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              title!,
              style: const TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    void _setAnalyzing(bool flag) {
      setState(() {
        _isAnalyzing = flag;
      });
    }

    void _onPickPhoto(ImageSource source) async {
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) {
        return;
      }

      final imageFile = File(pickedFile.path);
      setState(() {
        _selectedImageFile = imageFile;
      });

      _analyzeImage(imageFile);
    }

    void _analyzeImage(File image) {
      _setAnalyzing(true);

      final imageInput = img.decodeImage(image.readAsBytesSync())!;

      final resultCategory = _classifier.predict(imageInput);

      final result = resultCategory.score >= 0.95
          ? _ResultStatus.found
          : _ResultStatus.notFound;
      final plantLabel = resultCategory.label;
      final accuracy = resultCategory.score;

      _setAnalyzing(false);

      setState(() {
        _resultStatus = result;
        _plantLabel = plantLabel;
        _accuracy = accuracy;
      });
    }

  Widget _buildResultView() {
    var title = '';

    if (_resultStatus == _ResultStatus.notFound) {
      title = 'Fail to recognise';
    } else if (_resultStatus == _ResultStatus.found) {
      title = _plantLabel;
      if (title == 'BACTERIAL BLIGHT') {
        plantIdSelector = 1;
      } else if (title == 'BROWN SPOT') {
        plantIdSelector = 2;
      } else if (title == 'LEAF BLAST') {
        plantIdSelector = 3;
      } else if (title == 'NORMAL RICE PLANT') {
        plantIdSelector = 4;
      } else if (title == 'SHEALTH BLIGHT') {
        plantIdSelector = 5;
      } else if (title == 'TUNGRO') {
        plantIdSelector = 6;
      }
    } else {
      title = '';
    }

    //
    var accuracyLabel = '';
    if (_resultStatus == _ResultStatus.found) {
      accuracyLabel = 'Accuracy: ${(_accuracy * 100).toStringAsFixed(2)}%';
    }

    return ListView(
      shrinkWrap: true,
      children: [
        Container(
          height: 400, // Set a specific height for the ListView
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  Disease.plantList[plantIdSelector].plantName.toString(),
                  style: kResultTextStyle,
                ),
                const SizedBox(height: 10),
                Text(accuracyLabel, style: kResultRatingTextStyle),
                // Condition of The Result
                  Column(
                    children: [
                      const Divider(),
                      ListTile(
                      title: const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff296e48),
                        ),
                      ),
                      subtitle: Text(
                        Disease.plantList[plantIdSelector].causes.toString(),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                      const Divider(),
                      ListTile(
                        title: const Text(
                          'Symptoms',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff296e48),
                          ),
                        ),
                        subtitle: Text(
                          Disease.plantList[plantIdSelector].symptompts.toString(),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text(
                          'Control / Interventions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff296e48),
                          ),
                        ),
                        subtitle: Text(
                          Disease.plantList[plantIdSelector].treatment.toString(),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ],
                  ) 
              ],
            ),
          ),
        ),
      ],
    );

  }
}
