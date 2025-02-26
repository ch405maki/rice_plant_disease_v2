import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../constants.dart';
import '../models/plants.dart';
import 'scan_page_gallery.dart';
import 'scan_page.dart';
import 'screens/favorite_page.dart';
import 'screens/home_page.dart';
import 'screens/profile_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  List<Plant> favorites = [];
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ScanPageGallery(),
    PlantListPage(),
    const ProfilePage(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.camera_alt),
      label: 'Scan',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bookmark),
      label: 'Saved',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.2),
        elevation: 2,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text( _bottomNavItems[_currentIndex].label ?? '', style: TextStyle(
              color: Constants.blackColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _bottomNavItems,
        selectedItemColor: Constants.primaryColor,
        unselectedItemColor: Colors.black.withOpacity(0.6),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 2) {
              favorites = Plant.getFavoritedPlants();
            }
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
