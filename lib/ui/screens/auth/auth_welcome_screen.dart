import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'phone_auth_screen.dart.dart';

class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // keep your texture bg
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  AppAssets.logo,
                  width: 250,
                ),

                // Subtitle shifted up closer to logo
                Transform.translate(
                  offset: const Offset(0, -100), // tweak as needed
                  child: Text(
                    "ROMLERK IS NOT JUST A DOCUMENT MANAGEMENT TOOL IT'S A FAMILY STRUCTURE SYSTEM DESIGNED TO SUPPORT THE PEOPLE WHO HOLD EVERYTHING TOGETHER",
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: AppColors.black,
                      height: 1.35,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // CONTINUE WITH PHONE NUMBER button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PhoneAuthScreen()),
                      );
                    },
                    style: ButtonStyle(
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 16),
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      side: WidgetStateProperty.resolveWith<BorderSide?>(
                        (states) => BorderSide(
                          color: states.contains(WidgetState.pressed)
                              ? AppColors.green
                              : AppColors.black,
                          width: 2,
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                        (states) => states.contains(WidgetState.pressed)
                            ? AppColors.green
                            : null,
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                        (states) => states.contains(WidgetState.pressed)
                            ? AppColors.white
                            : AppColors.black,
                      ),
                    ),
                    child: const Text('CONTINUE WITH PHONE NUMBER'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
