// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../constants.dart';
import '../models/plants.dart';
import 'scan_page.dart';

class ScanPageGallery extends StatefulWidget {
  const ScanPageGallery({Key? key}) : super(key: key);

  @override
  State<ScanPageGallery> createState() => _ScanPageGalleryState();
}

class _ScanPageGalleryState extends State<ScanPageGallery> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height, // Set a fixed height for the container
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end, // Align the column at the bottom
          children: [
            Expanded(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      child: Image.asset('assets/images/code-scan.png'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Please choose an option',
                      style: TextStyle(
                        color: Constants.primaryColor,
                        fontWeight: FontWeight.w300,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20), // Adjust the horizontal spacing
              child: TextButton(
                onPressed: () {
                  Navigator.push<dynamic>(
                    context,
                    PageTransition<dynamic>(
                      child: ScanPage(value: 1),
                      type: PageTransitionType.bottomToTop,
                    ),
                  );
                },
                child: Container(
                  width: 250,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Constants.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 1),
                        blurRadius: 5,
                        color: Constants.primaryColor.withOpacity(.3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Camera',
                      style: const TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20), // Adjust the horizontal spacing
              child: TextButton(
                onPressed: () {
                  Navigator.push<dynamic>(
                    context,
                    PageTransition<dynamic>(
                      child: ScanPage(value: 2),
                      type: PageTransitionType.bottomToTop,
                    ),
                  );
                },
                child: Container(
                  width: 250,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Constants.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 1),
                        blurRadius: 5,
                        color: Constants.primaryColor.withOpacity(.3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Pick from Gallery',
                      style: const TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ),
                  SizedBox(height: 90),
          ],
        ),
      )
    );
  }
}
