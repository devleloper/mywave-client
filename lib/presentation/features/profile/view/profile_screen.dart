import 'package:flutter/material.dart';

import '../widgets/profile_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 48),
            const AvatarCircle(),
            const SizedBox(height: 24),
            const Center(child: UserNameLabel()),
            const SizedBox(height: 12),
            const Center(child: PremiumBadge()),
            const SizedBox(height: 48),
            const DarkModeToggle(),
            const SizedBox(height: 16),
            const AboutTile(),
            const SizedBox(height: 16),
            const SignOutTile(),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
