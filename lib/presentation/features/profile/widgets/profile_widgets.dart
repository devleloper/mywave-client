import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

class AvatarCircle extends StatelessWidget {
  const AvatarCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.tiffanyBlue, width: 2),
        ),
        child: const Icon(Icons.person_outline, size: 64, color: AppTheme.tiffanyBlue),
      ),
    );
  }
}

class UserNameLabel extends StatelessWidget {
  const UserNameLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'MyWave User',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          AppTheme.tiffanyBlue.withValues(alpha: 0.2),
          Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Premium Account',
        style: TextStyle(
          color: AppTheme.tiffanyBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class DarkModeToggle extends StatelessWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.dark_mode_rounded, color: Colors.white54),
      title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
      trailing: Switch(
        value: true,
        onChanged: (_) {},
        activeThumbColor: AppTheme.tiffanyBlue,
      ),
    );
  }
}

class AboutTile extends StatelessWidget {
  const AboutTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline, color: Colors.white54),
      title: const Text('About & Privacy', style: TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () {},
    );
  }
}

class SignOutTile extends StatelessWidget {
  const SignOutTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.redAccent),
      title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
      onTap: () {},
    );
  }
}
