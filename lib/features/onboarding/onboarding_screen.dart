import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_dependencies.dart';
import '../../core/constants/app_constants.dart';
import '../shell/root_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key, required this.dependencies})
      : super(key: key);

  final AppDependencies dependencies;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefsOnboardingKey, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement<RootPage, dynamic>(
      MaterialPageRoute<RootPage>(
        builder: (_) => RootPage(dependencies: widget.dependencies),
      ),
    );
  }

  Future<void> _next() async {
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      await _complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 20),
            child: InkWell(
              onTap: _complete,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            onPageChanged: (page) => setState(() => _currentIndex = page),
            controller: _pageController,
            children: const [
              _OnboardingPage(
                title: AppConstants.titleOne,
                description: AppConstants.descriptionOne,
              ),
              _OnboardingPage(
                title: AppConstants.titleTwo,
                description: AppConstants.descriptionTwo,
              ),
              _OnboardingPage(
                title: AppConstants.titleThree,
                description: AppConstants.descriptionThree,
              ),
            ],
          ),
          Positioned(
            bottom: 80,
            left: 30,
            child: Row(children: _buildIndicator()),
          ),
          Positioned(
            bottom: 60,
            right: 30,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppConstants.primaryColor,
              ),
              child: IconButton(
                onPressed: _next,
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 10.0,
      width: isActive ? 20 : 8,
      margin: const EdgeInsets.only(right: 5.0),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  List<Widget> _buildIndicator() {
    return List.generate(
      3,
      (i) => _indicator(_currentIndex == i),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 350,
            child: Image.asset('assets/images/plant.png'),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppConstants.primaryColor,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}