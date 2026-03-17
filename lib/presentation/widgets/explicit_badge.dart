import 'package:flutter/material.dart';

/// Small "E" badge to indicate explicit content.
class ExplicitBadge extends StatelessWidget {
  const ExplicitBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'E',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
