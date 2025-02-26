import 'package:flutter/material.dart';
import '../../constants.dart';
import 'widgets/profile_widget.dart';

// ignore_for_file: lines_longer_than_80_chars, sort_child_properties_last, camel_case_types, use_build_context_synchronously

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo1.png',
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(width: 17),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.green,
                            ),
                            children: [
                              TextSpan(
                                text: ' Kalinga State University\n',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'Bulanao, Tabuk City, Kalinga',
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Image.asset(
                        'assets/images/logo2.png',
                        width: 50,
                        height: 50,
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Text(
                    'Rice Plant Disease Detector App: With Drone Integration',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 35),
                  Text(
                    'A Capstone Project Study Presented to the Faculty of the College of Engineering and Information Technology Kalinga State University',
                    textAlign: TextAlign.center,  
                  ),
                  SizedBox(height: 35),
                  Text(
                    'In Partial Fulfillment of the Requirements for the Degree Bachelor of Science in Computer Engineering',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 50),
                  Text(
                    'by\n'
                    'Clemente, Justine Joseph P.\n'
                    'Codiam, Cheska P.\n'
                    'Sullin, Alexis Jones L.\n'
                    'Taluyan, Cheery Deyeah M.\n\n\n',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}