import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../data/datasources/local/auth_storage.dart';
import '../../../core/bloc/theme_cubit.dart';
import '../../../widgets/bounceable.dart';

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Bounceable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? colorScheme.onSurface.withValues(alpha: 0.6)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color ?? colorScheme.onSurface,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class AvatarCircle extends StatelessWidget {
  const AvatarCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.tiffanyBlue.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: AppTheme.tiffanyBlue, width: 3),
        ),
        child: const Icon(Icons.person_rounded, size: 64, color: AppTheme.tiffanyBlue),
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
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
    );
  }
}

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.tiffanyBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Text(
        'Premium Account',
        style: TextStyle(
          color: AppTheme.tiffanyBlue,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class DarkModeToggle extends StatelessWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final theme = Theme.of(context);

    return ProfileTile(
      icon: Icons.dark_mode_rounded,
      title: 'Dark Mode',
      trailing: Transform.scale(
        scale: 0.8,
        child: Switch(
          value: theme.brightness == Brightness.dark,
          onChanged: (_) => themeCubit.toggleTheme(),
          activeThumbColor: AppTheme.tiffanyBlue,
          activeTrackColor: AppTheme.tiffanyBlue.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class AboutTile extends StatelessWidget {
  const AboutTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileTile(
      icon: Icons.info_outline_rounded,
      title: 'About & Privacy',
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.white24),
    );
  }
}

class SignOutTile extends StatelessWidget {
  const SignOutTile({super.key});

  Future<void> _signOut(BuildContext context) async {
    final authStorage = getIt<AuthStorage>();
    await authStorage.clearToken();
    if (context.mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileTile(
      icon: Icons.logout_rounded,
      title: 'Sign Out',
      color: Colors.redAccent,
      onTap: () => _signOut(context),
    );
  }
}
