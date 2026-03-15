import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:picverse/features/auth/presentation/bloc/auth_event.dart';
import 'package:picverse/features/auth/presentation/widgets/auth_gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Trigger auth check after short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthGradientBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo / brand area
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryPurple,
                          AppColors.primaryLight,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.glowPurpleStrong,
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Picverse',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Share your world, one photo at a time',
                    style: TextStyle(fontSize: 14, color: AppColors.grey400),
                  ),

                  const SizedBox(height: 48),

                  // Feature badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _featureBadge(Icons.photo_library_rounded, 'Share'),
                      const SizedBox(width: 24),
                      _featureBadge(Icons.favorite_rounded, 'Connect'),
                      const SizedBox(width: 24),
                      _featureBadge(Icons.explore_rounded, 'Discover'),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Progress indicator
                  SizedBox(
                    width: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        backgroundColor: AppColors.cardDark,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'Loading your experience...',
                    style: TextStyle(fontSize: 12, color: AppColors.grey500),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureBadge(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardDarkBorder),
          ),
          child: Icon(icon, color: AppColors.primaryLight, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.grey400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
