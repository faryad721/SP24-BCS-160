import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ReusableCard extends StatelessWidget {
  const ReusableCard({
    super.key,
    required this.child,
    this.colour,
    this.onPress,
    this.gradient,
    this.padding = const EdgeInsets.all(15.0),
  });

  final Widget child;
  final Color? colour;
  final VoidCallback? onPress;
  final LinearGradient? gradient;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.all(8.0),
        padding: padding,
        decoration: BoxDecoration(
          color: gradient == null ? (colour ?? kCardColor) : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class IconContent extends StatelessWidget {
  const IconContent({super.key, required this.icon, required this.label, required this.selected});

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: selected ? kPrimaryGradient : null,
            color: selected ? null : Colors.white10,
          ),
          child: Icon(icon, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: selected ? Colors.white : kTextMuted,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}
