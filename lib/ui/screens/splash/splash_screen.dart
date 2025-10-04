import 'dart:async';
import 'package:flutter/material.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_typography.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0; // for fade-in animation

  @override
  void initState() {
    super.initState();

    // Trigger fade-in after short delay
    Timer(const Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Auto navigate after 3s (adjust as needed)
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionDuration: const Duration(milliseconds: 2000),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // let texture show
      body: Stack(
        children: [
          // Logo top-left
          Positioned(
            top: -50,
            left: -20,
            child: SafeArea(
              child: Image.asset(
                AppAssets.logo,
                width: 200,
              ),
            ),
          ),

          // Welcome with fade-in + Hero
          Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(seconds: 1),
              child: Hero(
                tag: 'welcomeText',
                child: Text(
                  'Welcome',
                  style: AppTypography.h1.copyWith(
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
