import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../../data/datasources/local/auth_storage.dart';
import '../../../../core/theme/app_theme.dart';

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
    
    // Optionally validate token via API
    
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ).animate().slideY(begin: 0.2).fadeIn(delay: 400.ms),
              
              const SizedBox(height: 16),
              
              Text(
                'Please enter your Streaming Access Token to continue.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ).animate().slideY(begin: 0.2).fadeIn(delay: 500.ms),
              
              const SizedBox(height: 48),
              
              TextField(
                controller: _tokenController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Streaming Access Token (ARL)',
                  hintStyle: TextStyle(color: Colors.white38),
                  prefixIcon: Icon(Icons.key, color: AppTheme.tiffanyBlue),
                ),
              ).animate().fadeIn(delay: 600.ms),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTokenAndProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.tiffanyBlue,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: _isLoading 
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}
