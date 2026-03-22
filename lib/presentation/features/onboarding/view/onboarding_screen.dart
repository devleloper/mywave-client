import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../../data/datasources/local/auth_storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/widgets/mywave_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _tokenController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveTokenAndProceed() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) return;

    setState(() => _isLoading = true);
    
    // Save to Secure Storage
    final storage = getIt<AuthStorage>();
    await storage.saveToken(token);
    
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.waves_rounded,
                size: 80,
                color: AppTheme.tiffanyBlue,
              ).animate().scale(delay: 200.ms).fadeIn(),
              
              const SizedBox(height: 32),
              
              Text(
                'Welcome to MyWave',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ).animate().slideY(begin: 0.2).fadeIn(delay: 400.ms),
              
              const SizedBox(height: 16),
              
              Text(
                'Please enter your Streaming Access Token to continue.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ).animate().slideY(begin: 0.2).fadeIn(delay: 500.ms),
              
              const SizedBox(height: 48),
              
              TextField(
                controller: _tokenController,
                decoration: InputDecoration(
                  hintText: 'Streaming Access Token (ARL)',
                  hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3)),
                  prefixIcon: const Icon(Icons.key, color: AppTheme.tiffanyBlue),
                ),
              ).animate().fadeIn(delay: 600.ms),
              
              const SizedBox(height: 24),
              
              MyWaveButton(
                text: _isLoading ? '' : 'Continue',
                onTap: _isLoading ? () {} : _saveTokenAndProceed,
                icon: _isLoading 
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(
                          strokeWidth: 2, 
                          color: Colors.white,
                        )
                      )
                    : null,
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}
