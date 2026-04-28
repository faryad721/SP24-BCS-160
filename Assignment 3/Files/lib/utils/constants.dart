import 'package:flutter/material.dart';

const Color kScaffoldColor = Color(0xFF0B0F1A);
const Color kCardColor = Color(0xFF1A1F36);
const Color kCardActiveColor = Color(0xFF252B48);
const Color kAccentColor = Color(0xFFEB1555);
const Color kAccentSoft = Color(0xFFFF4E7B);
const Color kSecondaryAccent = Color(0xFF00E0C7);
const Color kTextMuted = Color(0xFF8D8E98);

const LinearGradient kPrimaryGradient = LinearGradient(
  colors: [Color(0xFFEB1555), Color(0xFFFF4E7B)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kBackgroundGradient = LinearGradient(
  colors: [Color(0xFF0B0F1A), Color(0xFF141A2E)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const TextStyle kLabelStyle = TextStyle(
  fontSize: 18,
  color: kTextMuted,
  fontWeight: FontWeight.w500,
  letterSpacing: 1.1,
);

const TextStyle kNumberStyle = TextStyle(
  fontSize: 50,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);

const TextStyle kButtonTextStyle = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.bold,
  color: Colors.white,
  letterSpacing: 1.2,
);

const TextStyle kTitleStyle = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const TextStyle kResultTextStyle = TextStyle(
  color: Color(0xFF24D876),
  fontSize: 22,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.5,
);

const TextStyle kBMITextStyle = TextStyle(
  fontSize: 90,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const TextStyle kBodyTextStyle = TextStyle(
  fontSize: 18,
  color: Colors.white,
  height: 1.4,
);
