// ignore_for_file: lines_longer_than_80_chars

class Plant {
  final int plantId;
  final String category;
  final String plantName;
  final String imageURL;
  final String imageURL2;
  bool isFavorated;
  final String decription;
  bool isSelected;

  Plant(
      {
        required this.plantId,
        required this.category,
        required this.plantName,
        required this.imageURL,
        required this.imageURL2,
        required this.isFavorated,
        required this.decription,
        required this.isSelected});

  //List of Plants data
  static List<Plant> plantList = [
    Plant(
        plantId: 0,
        category: '',
        plantName: 'Normal and Healthy Rice plant',
        imageURL: 'assets/images/normal.jpg',
        imageURL2: 'assets/images/normal.jpg',
        isFavorated: true,
        decription:
          '• Healthy rice leaves are usually a vibrant green, indicating good chlorophyll content.\n' +
          '\n'+
          '• A good rice plant will have multiple tillers, resulting in a bushy appearance, which is beneficial for grain production \n'+
          '\n'+
          '• There should be minimal signs of disease or pest damage, with leaves appearing free of significant blemishes, discoloration, or wilting'+
          '\n'+'\n'+
          'Pathogen  Name: \n'+ 'Oryza Sativa',
        isSelected: false),
    Plant(
        plantId: 1,
        category: '',
        plantName: 'Bacterial Blight',
        imageURL: 'assets/images/bacterialblight.jpg',
        imageURL2: 'assets/images/bacterialblight.jpg',
        isFavorated: false,
        decription:
          '• Bacterial leaf blight is caused by a bacterium called Xanthomonas campestris.\n' +
          '\n'+
          '• Elongated lesions appear near the tips of leaves or edges that are several inches long and water-soaked in appearance.  \n'+
          '\n'+
          '• Leaf tips or edges turn firstly into white, then yellow, and finally gave grey color due to fungi (Saprophytic fungi).\n'+
          '\n'+
          'Pathogen  Name:''\n'+'Xanthomonas campestris pv. oryzae \n',
        isSelected: false),
    Plant(
        plantId: 2,
        category: '',
        plantName: 'Brown Spot',
        imageURL: 'assets/images/brownspot.jpg',
        imageURL2: 'assets/images/brownspot.jpg',
        isFavorated: false,
        decription:
        '• Brown spot has been historically largely ignored as one of the most common and most damaging rice diseases. \n' +
        '\n'+
        '•	Brown spot is a fungal disease that infects the coleoptile, leaves, leaf sheath, panicle branches, glumes, and spikelets. \n' +
        '\n'+
        '•	The disease is common in soils that are poorly drained or deficient in nutrients. \n' +
        '\n'+
        'Pathogen  Name:''\n'+ 'Bipolaris Oryzae',
        isSelected: false),
    Plant(
      plantId: 3,
      category: '',
      plantName: 'Leaf Blast',
      imageURL: 'assets/images/leafblast.jpeg',
      imageURL2: 'assets/images/leafblast.jpeg',
      isFavorated: false,
      decription: 
      '• Blast is caused by the fungus Magnaporthe oryzae. It can affect all above-ground parts of a rice plant: leaf, collar, node, neck, parts of panicle, and sometimes leaf sheath.\n' +
      '\n'+
      '• It is one of the most destructive diseases of rice.\n'+
      '\n'+
      'Pathogen  Name:\n'+ 'Pyricularia oryzae',
      isSelected: false
      ),

      Plant(
      plantId: 4,
      category: '',
      plantName: 'Sheath Blight',
      imageURL: 'assets/images/shielthblight.jpg',
      imageURL2: 'assets/images/shielthblight.jpg',
      isFavorated: false,
      decription: 
      '• Sheath blight is a fungal disease caused by Rhizoctonia solani. It causes brown rot of stems beginning at the soil line, and roots may have brown lesions. \n' +
      '\n'+
      '• The severity the disease depends on cultivation, land preparation, varieties, crop management, etc. \n' +
      '\n'+
      'Pathogen  Name: \n'+ 'Rhizoctonia solani',
      isSelected: false
      ),

      Plant(
      plantId: 5,
      category: '',
      plantName: 'Tungro',
      imageURL: 'assets/images/tungro.jpg',
      imageURL2: 'assets/images/tungro.jpg',
      isFavorated: false,
      decription: 
      '• Rice tungro disease is caused by the combination of two viruses, which are transmitted by leafhoppers. It causes leaf discoloration, stunted growth, reduced tiller numbers, and sterile or partly filled grains. \n' +
      '\n'+
      '• Tungro infects cultivated rice, some wild rice relatives, and other grassy weeds commonly found in rice paddies.\n'+ 
      '\n'+
      'Pathogen  Name: \n'+ 'Rice tungro bacilliform virus (RTBV)',
      isSelected: false
      ),
  ];

  //Get the favorated items
  static List<Plant> getFavoritedPlants(){
    List<Plant> _travelList = Plant.plantList;
    return _travelList.where((element) => element.isFavorated == true).toList();
  }

  //Get the cart items
  static List<Plant> addedToCartPlants(){
    List<Plant> _selectedPlants = Plant.plantList;
    return _selectedPlants.where((element) => element.isSelected == true).toList();
  }
}
