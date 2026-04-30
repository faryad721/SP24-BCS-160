import 'package:flutter/material.dart';

class GuessCard extends StatelessWidget {
  final Widget child;

  const GuessCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: child,
    );
  }
}