import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Bold section label used in Search results and Artist detail views.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.tiffanyBlue,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
