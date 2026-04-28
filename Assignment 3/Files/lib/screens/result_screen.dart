import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/bmi_calculator.dart';
import '../widgets/bottom_button.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.calculator});

  final BMICalculator calculator;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _bmiAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _bmiAnim = Tween<double>(begin: 0, end: widget.calculator.bmi)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _categoryColor() {
    final bmi = widget.calculator.bmi;
    if (bmi < 18.5) return const Color(0xFF4FC3F7);
    if (bmi < 25) return const Color(0xFF24D876);
    if (bmi < 30) return const Color(0xFFFFB74D);
    return const Color(0xFFEF5350);
  }

  @override
  Widget build(BuildContext context) {
    final calc = widget.calculator;
    final color = _categoryColor();
    final range = calc.healthyWeightRangeKg;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBmiHero(color),
                      const SizedBox(height: 16),
                      _buildScale(),
                      const SizedBox(height: 18),
                      _buildStatsGrid(calc, range),
                      const SizedBox(height: 18),
                      _buildInterpretation(calc, color),
                      const SizedBox(height: 18),
                      _buildAdvice(calc),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
              BottomButton(
                label: 'RE-CALCULATE',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 4),
          const Text('YOUR RESULT', style: kTitleStyle),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.share_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiHero(Color color) {
    final calc = widget.calculator;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.18), kCardColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withOpacity(0.4), width: 1.2),
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              calc.category.toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _bmiAnim,
            builder: (_, __) => Text(
              _bmiAnim.value.toStringAsFixed(1),
              style: kBMITextStyle.copyWith(color: color),
            ),
          ),
          const Text('BMI Score', style: TextStyle(color: kTextMuted, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildScale() {
    final bmi = widget.calculator.bmi;
    // Map BMI 10 -> 0.0 ; 40 -> 1.0
    final pos = ((bmi - 10) / 30).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BMI SCALE',
              style: TextStyle(
                  color: kTextMuted,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 14),
          LayoutBuilder(builder: (context, constraints) {
            final w = constraints.maxWidth;
            return SizedBox(
              height: 30,
              child: Stack(
                children: [
                  Container(
                    height: 12,
                    margin: const EdgeInsets.only(top: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(colors: [
                        Color(0xFF4FC3F7),
                        Color(0xFF24D876),
                        Color(0xFFFFB74D),
                        Color(0xFFEF5350),
                      ]),
                    ),
                  ),
                  Positioned(
                    left: (w * pos) - 12,
                    child: Container(
                      width: 24,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_drop_down,
                          color: Colors.black87),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Under', style: TextStyle(color: kTextMuted, fontSize: 12)),
              Text('Normal', style: TextStyle(color: kTextMuted, fontSize: 12)),
              Text('Over', style: TextStyle(color: kTextMuted, fontSize: 12)),
              Text('Obese', style: TextStyle(color: kTextMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BMICalculator calc, Map<String, double> range) {
    final tiles = [
      _StatTile(
        icon: Icons.scale_rounded,
        label: 'BMI Prime',
        value: calc.bmiPrime.toStringAsFixed(2),
      ),
      _StatTile(
        icon: Icons.straighten_rounded,
        label: 'Ponderal Index',
        value: '${calc.ponderalIndex.toStringAsFixed(1)} kg/m³',
      ),
      _StatTile(
        icon: Icons.local_fire_department_rounded,
        label: 'BMR (kcal)',
        value: calc.bmr.toStringAsFixed(0),
      ),
      _StatTile(
        icon: Icons.fitness_center_rounded,
        label: 'Ideal Weight',
        value: '${calc.idealWeightKg.toStringAsFixed(1)} kg',
      ),
      _StatTile(
        icon: Icons.health_and_safety_rounded,
        label: 'Healthy Range',
        value:
            '${range['min']!.toStringAsFixed(0)}–${range['max']!.toStringAsFixed(0)} kg',
      ),
      _StatTile(
        icon: Icons.cake_rounded,
        label: 'Age',
        value: '${calc.age} yrs',
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: tiles,
    );
  }

  Widget _buildInterpretation(BMICalculator calc, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, color: color),
              const SizedBox(width: 8),
              const Text('What it means',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          Text(calc.interpretation,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildAdvice(BMICalculator calc) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: kPrimaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tips_and_updates_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Personalized Tips',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          Text(calc.advice,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: kSecondaryAccent, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: kTextMuted, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
