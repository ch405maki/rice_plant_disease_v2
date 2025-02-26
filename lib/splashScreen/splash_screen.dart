// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import '../constants.dart';
import '../global/global.dart';
import '../ui/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/root_page.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {  
  void startTimer() {
    Timer(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      final bool? repeat = prefs.getBool('repeat');

      // print('Im the Checker $repeat');

      if(repeat == null)
        Navigator.push<dynamic>(context, MaterialPageRoute<dynamic>(builder: (c) => OnboardingScreen()));
      else{
        Navigator.push<dynamic>(context, MaterialPageRoute<dynamic>(builder: (c) => RootPage()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Constants.primaryColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/code-scan-two.png', width: 125, height: 125,),
            ],
          ),
        ),
      ),
    );
  }
}
