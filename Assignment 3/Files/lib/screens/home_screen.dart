import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/bmi_calculator.dart';
import '../widgets/reusable_card.dart';
import '../widgets/round_icon_button.dart';
import '../widgets/bottom_button.dart';
import 'loading_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Gender selectedGender = Gender.male;

  // Height
  HeightUnit heightUnit = HeightUnit.cm;
  double heightCm = 170;
  double heightFeet = 5.7;

  // Weight
  WeightUnit weightUnit = WeightUnit.kg;
  double weightKg = 65;
  double weightLbs = 143;

  int age = 24;

  void _changeHeightUnit(int index) {
    setState(() {
      if (index == 0) {
        heightUnit = HeightUnit.cm;
      } else {
        heightUnit = HeightUnit.feet;
      }
    });
  }

  void _changeWeightUnit(int index) {
    setState(() {
      if (index == 0) {
        weightUnit = WeightUnit.kg;
      } else {
        weightUnit = WeightUnit.lbs;
      }
    });
  }

  void _onCalculate() {
    final calc = BMICalculator(
      heightValue: heightUnit == HeightUnit.cm ? heightCm : heightFeet,
      weightValue: weightUnit == WeightUnit.kg ? weightKg : weightLbs,
      heightUnit: heightUnit,
      weightUnit: weightUnit,
      age: age,
      gender: selectedGender,
    );
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => LoadingScreen(calculator: calc),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: ReusableCard(
                              onPress: () =>
                                  setState(() => selectedGender = Gender.male),
                              colour: selectedGender == Gender.male
                                  ? kCardActiveColor
                                  : kCardColor,
                              child: IconContent(
                                icon: Icons.male_rounded,
                                label: 'MALE',
                                selected: selectedGender == Gender.male,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ReusableCard(
                              onPress: () => setState(
                                  () => selectedGender = Gender.female),
                              colour: selectedGender == Gender.female
                                  ? kCardActiveColor
                                  : kCardColor,
                              child: IconContent(
                                icon: Icons.female_rounded,
                                label: 'FEMALE',
                                selected: selectedGender == Gender.female,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ReusableCard(
                        child: _buildHeightCard(),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: ReusableCard(child: _buildWeightCard()),
                          ),
                          Expanded(
                            child: ReusableCard(child: _buildAgeCard()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              BottomButton(label: 'CALCULATE', onTap: _onCalculate),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: kPrimaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.monitor_heart_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text('BMI CALCULATOR', style: kTitleStyle),
          const Spacer(),
          const Icon(Icons.bolt_rounded, color: kSecondaryAccent),
        ],
      ),
    );
  }

  Widget _buildHeightCard() {
    final isCm = heightUnit == HeightUnit.cm;
    final value = isCm ? heightCm : heightFeet;
    final label = isCm ? 'cm' : 'ft';
    final min = isCm ? 80.0 : 2.6;
    final max = isCm ? 230.0 : 7.5;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('HEIGHT', style: kLabelStyle),
            UnitToggle(
              options: const ['CM', 'FT'],
              selectedIndex: isCm ? 0 : 1,
              onChanged: _changeHeightUnit,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              isCm ? value.toStringAsFixed(0) : value.toStringAsFixed(1),
              style: kNumberStyle,
            ),
            const SizedBox(width: 6),
            Text(label, style: kLabelStyle),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            inactiveTrackColor: Colors.white12,
            activeTrackColor: kAccentSoft,
            thumbColor: Colors.white,
            overlayColor: kAccentColor.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
            trackHeight: 4,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: (v) {
              setState(() {
                if (isCm) {
                  heightCm = v;
                } else {
                  heightFeet = v;
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeightCard() {
  final isKg = weightUnit == WeightUnit.kg;
  final value = isKg ? weightKg : weightLbs;
  final label = isKg ? 'kg' : 'lbs';

  return Column(
    mainAxisSize: MainAxisSize.min, // ✅ IMPORTANT FIX
    children: [
      const Text('WEIGHT', style: kLabelStyle),

      const SizedBox(height: 8),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(value.toStringAsFixed(0), style: kNumberStyle),
          const SizedBox(width: 4),
          Text(label, style: kLabelStyle),
        ],
      ),

      const SizedBox(height: 8),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RoundIconButton(
            icon: Icons.remove,
            onPressed: () {
              setState(() {
                if (isKg) {
                  weightKg = (weightKg - 1).clamp(20, 300);
                } else {
                  weightLbs = (weightLbs - 1).clamp(44, 660);
                }
              });
            },
          ),
          RoundIconButton(
            icon: Icons.add,
            onPressed: () {
              setState(() {
                if (isKg) {
                  weightKg = (weightKg + 1).clamp(20, 300);
                } else {
                  weightLbs = (weightLbs + 1).clamp(44, 660);
                }
              });
            },
          ),
        ],
      ),

      const SizedBox(height: 8),

      UnitToggle(
        options: const ['KG', 'LBS'],
        selectedIndex: isKg ? 0 : 1,
        onChanged: _changeWeightUnit,
      ),
    ],
  );
}
  Widget _buildAgeCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Text('AGE', style: kLabelStyle),
        Text('$age', style: kNumberStyle),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RoundIconButton(
              icon: Icons.remove,
              onPressed: () =>
                  setState(() => age = (age - 1).clamp(1, 120)),
            ),
            RoundIconButton(
              icon: Icons.add,
              onPressed: () =>
                  setState(() => age = (age + 1).clamp(1, 120)),
            ),
          ],
        ),
        const Text('years', style: kLabelStyle),
      ],
    );
  }
}
