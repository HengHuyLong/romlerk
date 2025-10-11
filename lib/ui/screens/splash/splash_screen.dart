import 'dart:async';
import 'package:flutter/material.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _welcomeOpacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Step 1️⃣ Animate welcome text
    Timer(const Duration(milliseconds: 300), () {
      setState(() => _welcomeOpacity = 1.0);
    });

    // Step 2️⃣ Navigate to Onboarding after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: AnimatedOpacity(
          opacity: _welcomeOpacity,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          child: Hero(
            tag: 'welcomeText',
            child: Text(
              'Welcome',
              style: AppTypography.h1.copyWith(
                color: AppColors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
