// main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(const NeonCounterApp());
}

class NeonCounterApp extends StatelessWidget {
  const NeonCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Deep Midnight
      ),
      home: const CounterScreen(),
    );
  }
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF0F172A), Colors.blueGrey.shade900],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glow Effect Header
            const Text(
              'TOTAL SCORE',
              style: TextStyle(
                color: Colors.cyanAccent,
                letterSpacing: 4,
                fontWeight: FontWeight.w300,
              ),
            ),

            // Large Neon Counter
            Text(
              '$_count',
              style: TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 20,
                    color: Colors.cyanAccent.withOpacity(0.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // Vertical Action Buttons
            _neonButton(
              label: 'BOOST',
              icon: Icons.keyboard_arrow_up,
              color: Colors.cyanAccent,
              onTap: () => setState(() => _count++),
            ),

            const SizedBox(height: 20),

            _neonButton(
              label: 'DRAIN',
              icon: Icons.keyboard_arrow_down,
              color: Colors.pinkAccent,
              onTap: () => setState(() => _count--),
            ),

            const SizedBox(height: 40),

            // Subtle Reset
            TextButton.icon(
              onPressed: () => setState(() => _count = 0),
              icon: const Icon(Icons.refresh, color: Colors.white54),
              label: const Text(
                'SYSTEM RESET',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Neon Button Builder
  Widget _neonButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Icon(icon, color: color),
          ],
        ),
      ),
    );
  }
}
