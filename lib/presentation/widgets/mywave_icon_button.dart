import 'package:flutter/material.dart';
import 'bounceable.dart';

class MyWaveIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? iconColor;
  final double size;

  const MyWaveIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.iconColor,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Bounceable(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? theme.primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (color ?? theme.primaryColor).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}
