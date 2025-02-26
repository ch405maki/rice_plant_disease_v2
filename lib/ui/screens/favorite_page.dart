import '../../constants.dart';
import 'package:flutter/material.dart';
import '../../models/plant_disease_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'plant_description_page.dart';

class PlantListPage extends StatefulWidget {
  @override
  _PlantListPageState createState() => _PlantListPageState();
}

class _PlantListPageState extends State<PlantListPage> {
  Future<Box<PlantDisease>> _openBox() async {
    await Hive.openBox<PlantDisease>('plantDiseases');
    return Hive.box<PlantDisease>('plantDiseases');
  }

void _deletePlantDisease(int index) async {
  bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      // ignore: lines_longer_than_80_chars
      return AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this plant disease?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );

  if (confirmed != null && confirmed) {
    final plantDiseaseBox = await _openBox();
    final plantDiseases = plantDiseaseBox.values.toList();
    await plantDiseaseBox.delete(plantDiseases[index].key);
    setState(() {});
  }
}


  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return text.substring(0, maxLength) + '...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Plant Diseases'),
      // ),
      body: FutureBuilder<Box<PlantDisease>>(
        future: _openBox(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No plant diseases found.'));
          } else {
            final plantDiseaseBox = snapshot.data!;
            final plantDiseases = plantDiseaseBox.values.toList();
            return ListView.builder(
              itemCount: plantDiseases.length,
              itemBuilder: (context, index) {
                final plantDisease = plantDiseases[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xff296e48).withOpacity(.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(plantDisease.plantName),
                    subtitle: Text(plantDisease.dateCreated.substring(0, 16)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deletePlantDisease(index),
                    ),
                    onTap: () {
                      Navigator.push<PlantDisease>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlantDescriptionPage(
                            plantDisease: plantDisease,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
