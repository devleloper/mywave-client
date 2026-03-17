import 'package:flutter/material.dart';

import '../widgets/profile_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            const AvatarCircle(),
            const SizedBox(height: 24),
            UserNameLabel(),
            const SizedBox(height: 8),
            const PremiumBadge(),
            const SizedBox(height: 48),
            const Divider(color: Colors.white12),
            const DarkModeToggle(),
            const Divider(color: Colors.white12),
            const AboutTile(),
            const Divider(color: Colors.white12),
            const SignOutTile(),
          ],
        ),
      ),
    );
  }
}
