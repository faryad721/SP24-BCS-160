import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BottomButton extends StatelessWidget {
  const BottomButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(vertical: 18),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: kPrimaryGradient,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: kAccentColor.withOpacity(0.45),
              blurRadius: 18,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: kButtonTextStyle),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}
