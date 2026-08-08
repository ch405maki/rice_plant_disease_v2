import 'package:flutter/material.dart';

import '../../app_dependencies.dart';
import '../../core/constants/app_constants.dart';
import '../about/about_page.dart';
import '../home/home_page.dart';
import '../saved/saved_page.dart';
import '../scan/scan_chooser_page.dart';

/// Bottom-navigation shell hosting the four main tabs.
class RootPage extends StatefulWidget {
  const RootPage({Key? key, required this.dependencies}) : super(key: key);

  final AppDependencies dependencies;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(diseases: widget.dependencies.diseases),
      ScanChooserPage(dependencies: widget.dependencies),
      SavedPage(scans: widget.dependencies.scans),
      const AboutPage(),
    ];
  }

  static const List<BottomNavigationBarItem> _bottomNavItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan'),
    BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
    BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'About'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          _bottomNavItems[_currentIndex].label ?? '',
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _bottomNavItems,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.black.withOpacity(0.6),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}