import 'package:flutter/material.dart';

// Fonts
const String kMainFont = 'Roboto';
const String kButtonFont = 'Roboto';
const String kDisplayFont = 'SquadaOne';

// Color palette (legacy naming kept from the original design system)
const Color kColorGreen = Color(0xFF395144);
const Color kColorLightGreen = Color(0XFF4E6C50);
const Color kColorBrown = Color(0XFFAA8B56);
const Color kColorLightYellow = Color(0xFFF0EBCE);
const Color kColorRed = Color(0xFFD96666);
const Color kColorLightRed = Color(0xFFF2CECE);
const Color kColorLightGray = Color(0xFFDDDDDD);
const Color kColorHunterGreen = Color(0xFF386641);
const Color kColorMayGreen = Color(0xFF6a994e);
const Color kColorAndroidGreen = Color(0xFFa7c957);
const Color kColorEggshell = Color(0xFFf2e8cf);
const Color kColorBitterSweetShimmer = Color(0xFFbc4749);

// Named nature palette (used by the disease content UI)
const Color lightGreenLeaves = Color(0xFFC6F4D6);
const Color matureGreenLeaves = Color(0xFF3E8E41);
const Color riceGrainBeige = Color(0xFFF5F5DC);
const Color soilBrown = Color(0xFF964B00);
const Color waterReflectionBlue = Color(0xFF87CEEB);

const Color kBgColor = kColorGreen;

// Text styles
const TextStyle kTitleTextStyle = TextStyle(
  fontFamily: kDisplayFont,
  fontSize: 50.0,
  color: kColorAndroidGreen,
  decoration: TextDecoration.none,
);

const TextStyle kResultTextStyle = TextStyle(
  fontFamily: kDisplayFont,
  fontSize: 35.0,
  color: kColorLightYellow,
  decoration: TextDecoration.none,
);

const TextStyle kResultRatingTextStyle = TextStyle(
  fontFamily: kMainFont,
  fontSize: 18.0,
  color: Colors.white,
  decoration: TextDecoration.none,
);