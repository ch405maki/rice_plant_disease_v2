import 'package:flutter/material.dart';

/// Static credits screen for the capstone project.
class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                        cacheWidth: 150,
                        cacheHeight: 150,
                      ),
                      const SizedBox(width: 17),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(color: Colors.green),
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
                      const SizedBox(width: 16),
                      Image.asset(
                        'assets/images/logo2.png',
                        width: 50,
                        height: 50,
                        cacheWidth: 150,
                        cacheHeight: 150,
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Rice Plant Disease Detector App: With Drone Integration',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 35),
                  const Text(
                    'A Capstone Project Study Presented to the Faculty of the '
                    'College of Engineering and Information Technology '
                    'Kalinga State University',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 35),
                  const Text(
                    'In Partial Fulfillment of the Requirements for the '
                    'Degree Bachelor of Science in Computer Engineering',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  const Text(
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