import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'otp_verification_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final RegExp _khPhone = RegExp(r'^0\d{8,9}$');

  String? _errorText;
  bool _isLoading = false; // ✅ added loading state

  Future<void> _validatePhone() async {
    final value = _phoneController.text.trim();

    if (value.isEmpty) {
      setState(() => _errorText = "Phone number is required");
      return;
    }
    if (!_khPhone.hasMatch(value)) {
      setState(() => _errorText = "Must be a valid phone number");
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true; // ✅ start loading
    });

    final formattedPhone = '+855${value.substring(1)}';
    final auth = FirebaseAuth.instance;

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Phone verified automatically")),
          );
          setState(() => _isLoading = false); // ✅ stop loading
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _isLoading = false); // ✅ stop loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification failed: ${e.message}")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() => _isLoading = false); // ✅ stop loading
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                phoneNumber: value,
                verificationId: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!mounted) return;
          setState(() => _isLoading = false); // ✅ stop loading
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false); // ✅ stop loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Logo
              Center(
                child: Image.asset(
                  AppAssets.logo,
                  width: 250,
                ),
              ),

              // Phone number field + inline error
              Transform.translate(
                offset: const Offset(0, -60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      style:
                          AppTypography.body.copyWith(color: AppColors.black),
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: AppColors.green,
                          size: 28,
                        ),
                        hintText: "enter your phone number",
                        hintStyle: AppTypography.body.copyWith(
                          color: AppColors.black.withValues(alpha: 0.3),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.black, width: 1),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.green, width: 2),
                        ),
                      ),
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _errorText!,
                        style: AppTypography.body.copyWith(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Spacer(),

              // ✅ Next button with loading state
              _isLoading
                  ? const CircularProgressIndicator(
                      color: AppColors.green,
                      strokeWidth: 3,
                    )
                  : TextButton(
                      onPressed: _validatePhone,
                      style: ButtonStyle(
                        foregroundColor:
                            const WidgetStatePropertyAll(AppColors.green),
                        textStyle: WidgetStatePropertyAll(
                          AppTypography.bodyBold.copyWith(
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      child: const Text('Next'),
                    ),

              const SizedBox(height: 20),

              // Footer
              Text(
                "Welcome to Romlerk",
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.black.withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
