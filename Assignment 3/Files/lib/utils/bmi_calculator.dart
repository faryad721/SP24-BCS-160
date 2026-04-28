import 'dart:math';

enum HeightUnit { cm, feet }

enum WeightUnit { kg, lbs }

enum Gender { male, female }

class BMICalculator {
  final double heightValue; // in selected unit
  final double weightValue; // in selected unit
  final HeightUnit heightUnit;
  final WeightUnit weightUnit;
  final int age;
  final Gender gender;

  late final double _heightMeters;
  late final double _weightKg;
  late final double _bmi;

  BMICalculator({
    required this.heightValue,
    required this.weightValue,
    required this.heightUnit,
    required this.weightUnit,
    required this.age,
    required this.gender,
  }) {
    _heightMeters = heightUnit == HeightUnit.cm
        ? heightValue / 100.0
        : heightValue * 0.3048;
    _weightKg =
        weightUnit == WeightUnit.kg ? weightValue : weightValue * 0.453592;
    _bmi = _weightKg / pow(_heightMeters, 2);
  }

  double get bmi => _bmi;
  double get bmiPrime => _bmi / 25.0;
  double get ponderalIndex => _weightKg / pow(_heightMeters, 3);

  String get bmiText => _bmi.toStringAsFixed(1);

  String get category {
    if (_bmi < 16) return 'Severe Thinness';
    if (_bmi < 17) return 'Moderate Thinness';
    if (_bmi < 18.5) return 'Mild Thinness';
    if (_bmi < 25) return 'Normal';
    if (_bmi < 30) return 'Overweight';
    if (_bmi < 35) return 'Obese Class I';
    if (_bmi < 40) return 'Obese Class II';
    return 'Obese Class III';
  }

  String get interpretation {
    if (_bmi < 18.5) {
      return 'You weigh less than the healthy range for your height. Consider a balanced, nutrient-rich diet and consult a doctor.';
    } else if (_bmi < 25) {
      return 'Excellent! Your body weight is in the healthy range. Keep up your balanced lifestyle and stay active.';
    } else if (_bmi < 30) {
      return 'You weigh more than the healthy range. Consider regular exercise and a balanced diet to maintain wellbeing.';
    } else {
      return 'Your weight is significantly above the healthy range. Please consult a medical professional for guidance.';
    }
  }

  // Healthy weight range for current height (BMI 18.5 - 24.9)
  Map<String, double> get healthyWeightRangeKg => {
        'min': 18.5 * pow(_heightMeters, 2).toDouble(),
        'max': 24.9 * pow(_heightMeters, 2).toDouble(),
      };

  // Robinson formula for ideal weight (kg)
  double get idealWeightKg {
    // Height inches above 5 feet (60 inches)
    final inches = _heightMeters * 39.3701;
    final extra = (inches - 60).clamp(0, 100);
    if (gender == Gender.male) {
      return 52 + 1.9 * extra;
    } else {
      return 49 + 1.7 * extra;
    }
  }

  // BMR using Mifflin-St Jeor
  double get bmr {
    final cm = _heightMeters * 100;
    if (gender == Gender.male) {
      return 10 * _weightKg + 6.25 * cm - 5 * age + 5;
    } else {
      return 10 * _weightKg + 6.25 * cm - 5 * age - 161;
    }
  }

  String get advice {
    if (_bmi < 18.5) {
      return 'Add calorie-dense foods like nuts, seeds, dairy and lean proteins. Strength training helps build healthy mass.';
    } else if (_bmi < 25) {
      return 'Maintain your routine: 30 mins activity, balanced meals, sleep 7–9 hrs and hydrate well.';
    } else if (_bmi < 30) {
      return 'Aim for 150 mins of moderate exercise weekly. Reduce processed sugars and increase fiber & protein.';
    } else {
      return 'Combine professional guidance with sustainable lifestyle changes — gentle daily movement and portion control.';
    }
  }
}
