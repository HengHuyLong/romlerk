import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../auth/auth_welcome_screen.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Onboarding image
                Center(
                  child: Hero(
                    tag: 'onboardingImage', // same tag
                    child: Image.asset(
                      AppAssets.splashBg,
                      width: MediaQuery.of(context).size.width * 0.4,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Transform.translate(
                  offset:
                      Offset(0, -screenHeight * 0.05), // ~5% of screen height
                  child: Image.asset(
                    AppAssets.logo,
                    width: screenHeight * 0.2, // responsive logo size
                  ),
                ),
              ],
            ),

            // Sign up bottom-right
            Positioned(
              bottom: 16,
              right: 16,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AuthWelcomeScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: const TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
                child: const Text('Sign up'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
