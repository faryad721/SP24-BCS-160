import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/bmi_calculator.dart';
import 'result_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, required this.calculator});

  final BMICalculator calculator;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _outer;
  late final AnimationController _inner;
  late final AnimationController _pulse;

  final List<String> _messages = [
    'Crunching numbers...',
    'Analyzing your body data...',
    'Computing BMI index...',
    'Almost there...',
  ];
  int _msgIndex = 0;

  @override
  void initState() {
    super.initState();
    _outer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _inner = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: false);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Cycle through messages
    Future.delayed(const Duration(milliseconds: 750), _cycleMessage);

    // Wait 3 seconds then go to result
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) =>
              ResultScreen(calculator: widget.calculator),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(
              opacity: anim,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(anim),
                child: child,
              ),
            );
          },
        ),
      );
    });
  }

  void _cycleMessage() {
    if (!mounted) return;
    setState(() => _msgIndex = (_msgIndex + 1) % _messages.length);
    Future.delayed(const Duration(milliseconds: 750), _cycleMessage);
  }

  @override
  void dispose() {
    _outer.dispose();
    _inner.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating arc
                    AnimatedBuilder(
                      animation: _outer,
                      builder: (_, __) => Transform.rotate(
                        angle: _outer.value * 2 * pi,
                        child: CustomPaint(
                          size: const Size(220, 220),
                          painter: _ArcPainter(
                            color: kAccentColor,
                            strokeWidth: 6,
                            sweep: 1.4,
                          ),
                        ),
                      ),
                    ),
                    // Inner counter-rotating arc
                    AnimatedBuilder(
                      animation: _inner,
                      builder: (_, __) => Transform.rotate(
                        angle: -_inner.value * 2 * pi,
                        child: CustomPaint(
                          size: const Size(170, 170),
                          painter: _ArcPainter(
                            color: kSecondaryAccent,
                            strokeWidth: 5,
                            sweep: 1.0,
                          ),
                        ),
                      ),
                    ),
                    // Innermost pulse
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.85, end: 1.05)
                          .animate(_pulse),
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: const BoxDecoration(
                          gradient: kPrimaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kAccentColor,
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.favorite_rounded,
                            color: Colors.white, size: 50),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: Text(
                  _messages[_msgIndex],
                  key: ValueKey(_msgIndex),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please wait',
                style: TextStyle(color: kTextMuted, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({required this.color, required this.strokeWidth, required this.sweep});

  final Color color;
  final double strokeWidth;
  final double sweep;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [color.withOpacity(0.0), color],
        stops: const [0.0, 1.0],
      ).createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect.deflate(strokeWidth), 0, sweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.sweep != sweep;
}
