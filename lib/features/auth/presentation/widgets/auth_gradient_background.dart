import 'package:flutter/material.dart';

import 'package:picverse/core/constants/app_colors.dart';

class AuthGradientBackground extends StatelessWidget {
  final Widget child;

  const AuthGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.authGradientStart,
            AppColors.authGradientMiddle,
            AppColors.authGradientEnd,
          ],
        ),
      ),
      child: child,
    );
  }
}
