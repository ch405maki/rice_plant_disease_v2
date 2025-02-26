// ignore_for_file: lines_longer_than_80_chars

class Disease {
  final int plantId;
  final String plantName;
  final String causes;
  final String symptompts;
  final String treatment;
  bool isFavorated;
  bool isSelected;

  Disease(
      {
        required this.plantId,
        required this.plantName,
        required this.causes,
        required this.symptompts,
        required this.treatment,
        required this.isFavorated,
        required this.isSelected});

  //List of Plants data
  static List<Disease> plantList = [
    Disease(
      plantId: 0,
      plantName: 'Fail to recognise',
      causes: 'Fail to recognise',
      symptompts: 'Fail to recognise',
      treatment: 'Fail to recognise',
      isFavorated: true,
      isSelected: false
    ),
    Disease(
      plantId: 1,
      plantName: 'Bacterial Blight',
      // description
      causes: '• Bacterial leaf blight is caused by a bacterium called Xanthomonas campestris.\n' +
              '• Elongated lesions appear near the tips of leaves or edges that are several inches long and water-soaked in appearance.  \n'+
              '• Leaf tips or edges turn firstly into white, then yellow, and finally gave grey color due to fungi (Saprophytic fungi).\n'+
              '\n'+
              'Pathogen  Name: Xanthomonas campestris pv. oryzae \n',

      // Damage of Bacterial Leaf Blast
      symptompts:'Damage of Bacterial Leaf Blast:\n'+
                  '• Yield loss due to bacterial blight can be as much as 70% when susceptible varieties are grown, in environments favorable to the disease.\n',

      // Control/Interventions
      treatment: '•	Use balanced amounts of plant nutrients, especially nitrogen.\n' +
                '• Ensure good drainage of fields (in conventionally flooded crops) and nurseries.\n' +
                '• Keep fields clean. Remove weed hosts and plow under rice stubble, straw, rice ratoons, and volunteer seedlings, which can serve as hosts of bacteria.\n' +
                '• Allow fallow fields to dry to suppress disease agents in the soil and plant residues.\n',
      isFavorated: true,
      isSelected: false,
    ),
    Disease(
      plantId: 2,
      plantName: 'Brown Spot',
      // description
      causes: '• Brown spot has been historically largely ignored as one of the most common and most damaging rice diseases. \n' +
              '•	Brown spot is a fungal disease that infects the coleoptile, leaves, leaf sheath, panicle branches, glumes, and spikelets. \n' +
              '•	The disease is common in soils that are poorly drained or deficient in nutrients. \n' +
              '\n'+
              'Pathogen  Name: •	Bipolaris oryzae',

      // Damage of Bacterial Leaf Blast
      symptompts:'•	The symptoms are brown spots on the leaf and grain.  \n' +
                '• Seedling blight may occur in seedlings grown from infected seeds \n'+
                '\n'+
                'Damage of Brown Spot \n' +
                '• It lowers grain quality and weight. The brown spot may kill up to 50 % of seedlings.',
                
      // Control/Interventions
      treatment: '•	The most effective way of controlling brown spots is to grow plants in good soil and provide adequate fertilizer. \n' +
                '• Planting a resistant variety is the most practical way of controlling. \n'+
                '• Treating the seeds with fungicide or hot water helps control the disease.\n'+
                '• Copper fungicides spray in the right amount and at right time will reduce the damage.\n',
      isFavorated: true,
      isSelected: false,
    ),
    Disease(
      plantId: 3,
      plantName: 'Leaf Blast',
      // description
      causes: '• Blast is caused by the fungus Magnaporthe oryzae. It can affect all above-ground parts of a rice plant: leaf, collar, node, neck, parts of panicle, and sometimes leaf sheath.\n' +
              '• It is one of the most destructive diseases of rice.\n'+
              '\n'+
              'Pathogen  Name: Pyricularia oryzae',

      // Damage of Bacterial Leaf Blast
      symptompts:'•	The fungus produces spots or lesions on leaves, nodes, panicles, and grains.    The spots are elongated and pointed at each end.\n' +
                '\n'+
                'Damage of Leaf Blast: \n'
                '• In severe infections, yields may be reduced by 50 %. Upland rice is more severely damaged than lowland rice. \n',
                
      // Control/Interventions
      treatment: '•	Planting resistant varieties is the most economical way of controlling this disease \n' +
                '• Avoid excess nitrogen fertilizer. \n'+
                '• Several fungicides effectively control blast, but they are not used in the tropics for economic reasons.\n'+
                '• Based on the study, Tricyclazole 22% + Hexaconazole 3% fungicide proved effective in controlling rice blast when applied at weekly intervals starting from the booting stage. \n'+
                '• Silicon application to rice crops showed a positive effect in combating rice blast disease.\n',
      isFavorated: true,
      isSelected: false,
    ),

    Disease(
      plantId: 4,
        plantName: 'Normal and Healthy Rice plant ',
        // description
        causes: '• Healthy rice leaves are usually a vibrant green, indicating good chlorophyll content.\n' +
                '• A good rice plant will have multiple tillers, resulting in a bushy appearance, which is beneficial for grain production \n'+
                '• There should be minimal signs of disease or pest damage, with leaves appearing free of significant blemishes, discoloration, or wilting'+
                '\n'+
                'Pathogen  Name: Oryza Sativa',

        // Damage
        symptompts:'• A normal and Healthy Rice plant doesnt have any symptoms of diseases \n' +
                  '• \n',
                  
        // Control/Interventions
        treatment: 'Not Applicable \n' +
                  '•\n',
      isFavorated: true,
      isSelected: false,
    ),

    Disease(
      plantId: 5,
      plantName: 'Sheath Blight',
      // description
      causes: '• Sheath blight is a fungal disease caused by Rhizoctonia solani. It causes brown rot of stems beginning at the soil line, and roots may have brown lesions. \n' +
              '• The severity the disease depends on cultivation, land preparation, varieties, crop management, etc. \n' +
              '\n'+
              'Pathogen  Name: Rhizoctonia solani',

      // Damage of Bacterial Leaf Blast
      symptompts: '•	Sheath blight causes spots on the leaf sheath. \n' +
                  '•	High temperature and humidity increase the severity. \n' +
                  '\n'+
                  'Damage of Sheath Blight: \n'
                  '•	Many of the leaves are killed during severe infections and yields may be reduced by 20‐25 % \n',
                
                
      // Control/Interventions
      treatment: '•	No variety has a high level of resistance to the disease. \n' +
                '• Do not apply too much nitrogen fertilizer.\n'+
                '• Foliar application of appropriate fungicides (e.g. azoxystrobin, propiconazole, trifloxystrobin and propiconazole, iprodine) is carried out to control sheath blight. \n'+
                '• Seed treatment with trifloxystrobin or azoxystrobin or carboxin + thiram is also used to control sheath blight.\n',
      isFavorated: true,
      isSelected: false,
    ),
    Disease(
      plantId: 6,
      plantName: 'Tungro',
      // description
      causes: '• Rice tungro disease is caused by the combination of two viruses, which are transmitted by leafhoppers. It causes leaf discoloration, stunted growth, reduced tiller numbers, and sterile or partly filled grains. \n' +
              '• Tungro infects cultivated rice, some wild rice relatives, and other grassy weeds commonly found in rice paddies.\n'+ 
              '\n'+
              'Pathogen  Name: Rice tungro bacilliform virus (RTBV)',

      // Damage of Bacterial Leaf Blast
      symptompts:'•	Plants are stunted and change color from green to yellow then orange.  \n' +
                '• Numbers of tillers are reduced, and brown-colored lesions appear on the leaf.  \n'
                '• Leaves are striped, mottled, or show inter-venial necrosis. \n'+
                '\n'+
                'Damage of Tungro: \n'
                '• Tungro is one of South and Southeast Asias most damaging and destructive rice diseases. Tungro-susceptible varieties infected at an early growth stage could have as high as 100% yield loss in severe cases. \n',
                
      // Control/Interventions
      treatment: '•	Preventive measures are more effective for the control of tungro than direct disease control measures. \n' +
                '• Using insecticides to control leafhoppers is often not effective, because green leafhoppers continuously move to surrounding fields and spread tungro rapidly in very short feeding times.\n',
      isFavorated: true,
      isSelected: false,
    ),
  ];

  //Get the favorated items
  static List<Disease> getFavoritedPlants(){
    List<Disease> _travelList = Disease.plantList;
    return _travelList.where((element) => element.isFavorated == true).toList();
  }
}


