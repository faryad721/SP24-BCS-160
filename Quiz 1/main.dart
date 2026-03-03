// main.dart
// ============================================================
//  main.dart — Simple Dice App
//  Student : Nabeel
//  Quiz 1  : Quiz 1 using Flutter & setState()
//
//  How it works:
//   • A dice image is shown on screen (assets/images/1.png – 6.png)
//   • Tapping the dice OR pressing "Roll Dice" calls _rollDice()
//   • _rollDice() picks a random number 1-6, then calls setState()
//   • setState() triggers rebuild → Image.asset() loads the new image
//   • An AnimationController adds a spin + bounce visual effect
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Entry Point ────────────────────────────────────────────
void main() {
  // Ensure Flutter engine is ready before we call platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Lock screen to portrait so layout stays consistent
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Style the status bar icons to be white (suits our dark theme)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const DiceApp());
}

// ─── Root Application Widget ─────────────────────────────────
class DiceApp extends StatelessWidget {
  const DiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz 1',
      debugShowCheckedModeBanner: false, // Hide the debug banner

      // Apply the Poppins font and dark color scheme globally
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          surface: AppColors.navy,
          background: AppColors.navy,
        ),
      ),

      home: const DiceScreen(), // Start at the main dice screen
    );
  }
}

// ─── App Color Palette ───────────────────────────────────────
// All colors are defined here in one place for easy customization.
class AppColors {
  // Background shades (dark navy)
  static const Color navy = Color(0xFF0B1120);
  static const Color navyMid = Color(0xFF141D33);
  static const Color navyCard = Color(0xFF1A2540);
  static const Color navyBorder = Color(0xFF243058);

  // Accent colors (gold / amber)
  static const Color gold = Color(0xFFF5C842);
  static const Color goldLight = Color(0xFFFFE082);
  static const Color goldDim = Color(0xFFC9A227);

  // Text colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color white60 = Color(0x99FFFFFF); // 60% opacity white
  static const Color white20 = Color(0x33FFFFFF); // 20% opacity white
}

// ─── Main Screen ─────────────────────────────────────────────
// Uses StatefulWidget because we need setState() to update the UI
// every time the dice is rolled.
class DiceScreen extends StatefulWidget {
  const DiceScreen({super.key});

  @override
  State<DiceScreen> createState() => _DiceScreenState();
}

class _DiceScreenState extends State<DiceScreen>
    with SingleTickerProviderStateMixin {
  // ── State Variables ──────────────────────────────────────
  int _diceValue = 1; // Currently displayed dice face (1 – 6)
  bool _isRolling = false; // True while the roll animation plays
  int _rollCount = 0; // How many times the user has rolled
  final List<int> _history = []; // History of past rolls (newest first)
  final Random _random = Random(); // Used to generate random dice values

  // ── Animation Controller ─────────────────────────────────
  late AnimationController _controller;
  late Animation<double> _scaleAnim; // Dice shrinks then pops larger
  late Animation<double> _rotateAnim; // Dice spins
  late Animation<double> _liftAnim; // Dice lifts then drops (bounce)

  // ── initState: runs once when the widget is first created ──
  @override
  void initState() {
    super.initState();

    // Controller drives all three animations over 700 milliseconds
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Scale animation: 1.0 → shrink to 0.82 → bounce up to 1.15 → settle 1.0
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.82)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.82, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    // Rotation animation: two full spins (0 → 4π radians) during first 65% of duration
    _rotateAnim = Tween<double>(begin: 0.0, end: 4 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    // Lift animation: moves dice 30px up then bounces it back down
    _liftAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -30.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -30.0, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 60,
      ),
    ]).animate(_controller);

    // Listen for when animation finishes → allow the next roll
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isRolling = false);
      }
    });
  }

  // ── dispose: clean up controller when widget is removed ────
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── _rollDice: the core quiz requirement ─────────────────
  // Generates a random number 1–6, updates state, and plays animation.
  // setState() is what makes Flutter re-render the dice image.
  void _rollDice() {
    if (_isRolling) return; // Don't allow rolling during animation

    // ▼ setState() is called here — Flutter rebuilds the widget tree
    setState(() {
      _isRolling = true;

      // Pick a random number from 1 to 6
      _diceValue = _random.nextInt(6) + 1;

      // Increment the total roll counter
      _rollCount++;

      // Add result to history (keep newest first, max 8 entries)
      _history.insert(0, _diceValue);
      if (_history.length > 8) _history.removeLast();
    });

    // Play the spin + bounce animation from the start
    _controller.forward(from: 0.0);

    // Trigger device vibration for tactile feedback
    HapticFeedback.mediumImpact();
  }

  // ── build: called every time setState() is called ─────────
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final diceSize = screenWidth * 0.58; // Dice is 58% of screen width

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Container(
        // Dark gradient background — navyMid at top, very dark at bottom
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.navyMid,
              AppColors.navy,
              Color(0xFF060B17),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header bar ─────────────────────────────
              _buildHeader(),

              // ── Dice + value display (centered, takes remaining space)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedDice(diceSize), // Tappable animated dice
                    const SizedBox(height: 28),
                    _buildValueDisplay(), // "THREE  3"
                    const SizedBox(height: 12),
                    _buildHintText(), // "Tap the dice to roll"
                  ],
                ),
              ),

              // ── Roll button ────────────────────────────
              _buildRollButton(),
              const SizedBox(height: 20),

              // ── Roll history badges ────────────────────
              _buildHistory(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // SECTION: Individual Widget Builders
  // Each method builds one part of the UI for clarity.
  // ────────────────────────────────────────────────────────────

  // Header: title "QUIZ 1" + roll count badge
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'QUIZ 1',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
              color: AppColors.white60,
            ),
          ),
        ],
      ),
    );
  }

  // Animated dice: combines rotate + lift + scale on each roll
  Widget _buildAnimatedDice(double diceSize) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _liftAnim.value), // Lift / bounce
          child: Transform.rotate(
            angle: _rotateAnim.value, // Spin
            child: Transform.scale(
              scale: _scaleAnim.value, // Scale bounce
              child: child,
            ),
          ),
        );
      },
      // GestureDetector lets the user tap the dice image to roll
      child: GestureDetector(
        onTap: _rollDice,
        child: _buildDiceCard(diceSize),
      ),
    );
  }

  // The dice card: shows the correct image for _diceValue via setState()
  Widget _buildDiceCard(double diceSize) {
    return Container(
      width: diceSize,
      height: diceSize,
      decoration: BoxDecoration(
        color: AppColors.navyCard,
        borderRadius: BorderRadius.circular(diceSize * 0.18),
        border: Border.all(color: AppColors.navyBorder, width: 1.5),
        boxShadow: [
          // Gold outer glow
          BoxShadow(
            color: AppColors.gold.withOpacity(0.38),
            blurRadius: 45,
            spreadRadius: 3,
          ),
          // Soft dark shadow beneath
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(diceSize * 0.18),
        child: Stack(
          children: [
            // ── Dice Image ──────────────────────────────
            // This is rebuilt by setState() each roll.
            // Flutter picks the right file: assets/images/3.png, etc.
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(diceSize * 0.10),
                child: Image.asset(
                  'assets/images/$_diceValue.png',
                  fit: BoxFit.contain,
                  // If image is missing, draw dots with the custom painter
                  errorBuilder: (context, error, stackTrace) {
                    return CustomPaint(
                      painter: FallbackDicePainter(value: _diceValue),
                    );
                  },
                ),
              ),
            ),

            // Subtle gradient shimmer overlay for depth
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.gold.withOpacity(0.07),
                        Colors.transparent,
                        AppColors.gold.withOpacity(0.04),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Displays the current roll value as word + large number
  // e.g.  "FOUR  4"
  Widget _buildValueDisplay() {
    // Word labels aligned to dice values 1–6
    const labels = ['', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // Word label
        Text(
          labels[_diceValue],
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            letterSpacing: 3,
            color: AppColors.white60,
          ),
        ),
        const SizedBox(width: 12),
        // Large number
        Text(
          '$_diceValue',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 54,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  // Hint text below the value — changes during rolling
  Widget _buildHintText() {
    return Text(
      _isRolling ? 'Rolling...' : 'Tap the dice  ·  or press Roll',
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        color: AppColors.white20,
        letterSpacing: 0.4,
      ),
    );
  }

  // Gold gradient "Roll Dice" button
  Widget _buildRollButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: _isRolling
                ? const LinearGradient(
                    colors: [AppColors.goldDim, Color(0xFF7A5C0E)],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.goldLight,
                      AppColors.gold,
                      AppColors.goldDim,
                    ],
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isRolling
                ? []
                : [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.42),
                      blurRadius: 22,
                      offset: const Offset(0, 7),
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: _isRolling ? null : _rollDice,
            child: Text(
              _isRolling ? 'Rolling...' : 'Roll Dice',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Roll history: shows last 8 rolls as small badges
  Widget _buildHistory() {
    // Empty state before any rolls
    if (_history.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.history_rounded, size: 16, color: AppColors.white20),
          SizedBox(width: 8),
          Text(
            'Roll history will appear here',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.white20,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'HISTORY',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                letterSpacing: 3,
                color: AppColors.white60,
              ),
            ),
            if (_rollCount > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navyCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.navyBorder),
                ),
                child: Text(
                  '$_rollCount',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // Wrap of badge widgets (wraps to new line if needed)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(_history.length, (index) {
              final val = _history[index];
              final isLatest = index == 0; // Highlight the most recent roll

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  // Latest roll → gold gradient; older → navy card
                  gradient: isLatest
                      ? const LinearGradient(
                          colors: [AppColors.goldLight, AppColors.gold],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isLatest ? null : AppColors.navyCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLatest ? AppColors.gold : AppColors.navyBorder,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$val',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isLatest ? AppColors.navy : AppColors.white60,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ─── Fallback Dice Painter ────────────────────────────────────
// Draws pip dots on a canvas when image assets are unavailable.
// This ensures the app always shows the correct dice face.
class FallbackDicePainter extends CustomPainter {
  final int value;
  const FallbackDicePainter({required this.value});

  // Pip positions for each dice value (row, col on a 3×3 grid)
  static const Map<int, List<List<int>>> _pips = {
    1: [
      [1, 1]
    ],
    2: [
      [0, 0],
      [2, 2]
    ],
    3: [
      [0, 0],
      [1, 1],
      [2, 2]
    ],
    4: [
      [0, 0],
      [0, 2],
      [2, 0],
      [2, 2]
    ],
    5: [
      [0, 0],
      [0, 2],
      [1, 1],
      [2, 0],
      [2, 2]
    ],
    6: [
      [0, 0],
      [0, 2],
      [1, 0],
      [1, 2],
      [2, 0],
      [2, 2]
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    // Gold paint with a soft glow
    final paint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final cellW = size.width / 3;
    final cellH = size.height / 3;
    final pipR = size.width * 0.1; // Pip radius

    for (final pos in _pips[value] ?? []) {
      final cx = cellW * pos[1] + cellW / 2; // column → x
      final cy = cellH * pos[0] + cellH / 2; // row    → y
      canvas.drawCircle(Offset(cx, cy), pipR, paint);
    }
  }

  @override
  bool shouldRepaint(FallbackDicePainter old) => old.value != value;
}
