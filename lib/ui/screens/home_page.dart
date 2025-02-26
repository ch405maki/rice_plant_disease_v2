import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../../constants.dart';
import '../../models/plants.dart';
import 'detail_page.dart';

import 'widgets/plant_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Plant> _plantList = Plant.plantList;

  bool toggleIsFavorited(bool isFavorited) {
    return !isFavorited;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            _banner(size),
            // Section Title
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 20, top: 20),
              child: Text(
                'Healthy Rice plant',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
            ),
            _buildFirstPlantItem(size),

            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 20, top: 20),
              child: Text(
                'Rice Plant Diseases',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
            ),
            // Vertical Plant List
            _buildVerticalPlantList(size),
          ],
        ),
      ),
    );
  }

  Widget _banner(Size size) {
    return SizedBox(
      height: 150.0,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: Image.asset(
                    'assets/images/banner.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstPlantItem(Size size) {
    final plant = _plantList[0]; // Get the first item in the list

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition<DetailPage>(
            child: DetailPage(plantId: plant.plantId),
            type: PageTransitionType.bottomToTop,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Container(
          height: 100, // Adjust the height as needed
          decoration: BoxDecoration(
            color: Colors.white, // Item background color
            borderRadius: BorderRadius.circular(0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Plant Image
              SizedBox(
                width: 80,
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: Image.asset(
                      plant.imageURL,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Plant Details (Title and Description)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          plant.plantName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Description
                      Text(
                        plant.decription,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              // Favorite Icon
              IconButton(
                onPressed: () {
                  setState(() {
                    plant.isFavorated = !plant.isFavorated;
                  });
                },
                icon: Icon(
                  plant.isFavorated
                      ? Icons.bookmark_added
                      : Icons.bookmark_add_outlined,
                  color: Constants.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
    
  Widget _buildVerticalPlantList(Size size) {
    return SizedBox(
      height: size.height * .8,
      child: ListView.builder(
        itemCount: _plantList.length - 1, // Decrease item count by 1
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final plant = _plantList[index + 1]; // Skip index 0
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageTransition<DetailPage>(
                  child: DetailPage(plantId: plant.plantId),
                  type: PageTransitionType.bottomToTop,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Container(
                height: 100, // Adjust the height as needed
                decoration: BoxDecoration(
                  color: Colors.white, // Item background color
                  borderRadius: BorderRadius.circular(0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Plant Image
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(0),
                          child: Image.asset(
                            plant.imageURL,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Plant Details (Title and Description)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                plant.plantName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            // Description
                            Text(
                              plant.decription,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Favorite Icon
                    IconButton(
                      onPressed: () {
                        setState(() {
                          plant.isFavorated = !plant.isFavorated;
                        });
                      },
                      icon: Icon(
                        plant.isFavorated
                            ? Icons.bookmark_added
                            : Icons.bookmark_add_outlined,
                        color: Constants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


}
