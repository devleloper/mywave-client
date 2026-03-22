import 'package:flutter/material.dart';
import 'bounceable.dart';

class MyWaveButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final Widget? icon;

  const MyWaveButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Bounceable(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? theme.primaryColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: (color ?? theme.primaryColor).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
