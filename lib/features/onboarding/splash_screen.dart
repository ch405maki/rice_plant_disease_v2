import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_dependencies.dart';
import '../../core/constants/app_constants.dart';
import '../shell/root_page.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, required this.dependencies}) : super(key: key);

  final AppDependencies dependencies;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final repeat = prefs.getBool(AppConstants.prefsOnboardingKey);
      final dependencies = widget.dependencies;
      final next = repeat == null
          ? OnboardingScreen(dependencies: dependencies)
          : RootPage(dependencies: dependencies);
      Navigator.of(context).pushReplacement<dynamic, dynamic>(
        MaterialPageRoute<dynamic>(builder: (_) => next),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppConstants.primaryColor,
      child: Center(
        child: Image.asset(
          'assets/images/code-scan-two.png',
          width: 125,
          height: 125,
        ),
      ),
    );
  }
}