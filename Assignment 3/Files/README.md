# Nabeel BMI Calculator (Pure Flutter)

A clean, attractive BMI Calculator built with **pure Flutter**. Built for Assignment 03.

## Features

- Stylish dark UI with gradient accents
- **Unique input styles**:
  - Tap-to-select gender cards (Male / Female)
  - Slide input for Height
  - Tap +/- input for Weight & Age
- **All units supported**:
  - Height: cm / ft
  - Weight: kg / lbs
- Stylish 3-second animated loading spinner (dual-rotating arcs + pulse heart)
- Detailed result page with:
  - Animated BMI score
  - Color-coded BMI category
  - Visual BMI scale with marker
  - BMI Prime, Ponderal Index, BMR, Ideal Weight, Healthy Weight Range, Age
  - Personalized interpretation & tips

## Run

```bash
cd nabeel
flutter pub get
flutter run
```

## Project Structure

```
nabeel/
├── pubspec.yaml
├── analysis_options.yaml
└── lib/
    ├── main.dart
    ├── screens/
    │   ├── home_screen.dart
    │   ├── loading_screen.dart
    │   └── result_screen.dart
    ├── widgets/
    │   ├── reusable_card.dart
    │   ├── round_icon_button.dart
    │   └── bottom_button.dart
    └── utils/
        ├── constants.dart
        └── bmi_calculator.dart
```

## BMI Formula

```
BMI = weight (kg) / (height (m))²
```

## Categories

| BMI Range   | Category          |
|-------------|-------------------|
| < 16        | Severe Thinness   |
| 16 – 17     | Moderate Thinness |
| 17 – 18.5   | Mild Thinness     |
| 18.5 – 25   | Normal            |
| 25 – 30     | Overweight        |
| 30 – 35     | Obese Class I     |
| 35 – 40     | Obese Class II    |
| ≥ 40        | Obese Class III   |
