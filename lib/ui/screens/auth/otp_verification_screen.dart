import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:romlerk/ui/screens/home/home_screen.dart';
import 'package:romlerk/ui/screens/onboarding/profile_setup_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:romlerk/data/services/auth_service.dart';
import 'package:romlerk/data/repositories/user_repository.dart';
import '../../../core/providers/user_provider.dart';

// Note: This screen now depends on a UserRepository. Ensure you have a provider for it.
// e.g., final userRepositoryProvider = Provider((ref) => UserRepository());

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  static const int _otpLength = 6;
  static const int _cooldownSeconds = 30;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;
  Timer? _resendTimer;
  int _secondsLeft = _cooldownSeconds;

  String? _errorText;
  bool get _canResend => _secondsLeft == 0;
  String get _code => _controllers.map((c) => c.text).join();
  bool get _isComplete => _code.length == _otpLength;
  late String _verificationId;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _nodes = List.generate(_otpLength, (_) => FocusNode());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_nodes.isNotEmpty) _nodes[0].requestFocus();
    });
    _startResendCooldown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() => _secondsLeft = _cooldownSeconds);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  /// FIX: Created a single, reusable function to handle the post-Firebase-auth flow.
  /// This function calls the repository, updates the state, and navigates.
  Future<void> _processBackendLogin(String idToken) async {
    try {
      final result = await UserRepository.loginAndCache(idToken: idToken);

      if (!mounted) return;

      if (result == null) {
        setState(() => _errorText = "Server unreachable. Try again later.");
        return;
      }

      // Update global user state
      ref.read(userProvider.notifier).setUser(result.user);

      // Navigate based on whether the user is new or existing
      if (result.isNew) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = "An unexpected error occurred.");
    }
  }

  Future<void> _validateAndSubmit() async {
    if (!_isComplete) return;
    FocusScope.of(context).unfocus();

    try {
      // ✅ Step 1: Verify OTP with Firebase
      final idToken = await AuthService().signInWithOtp(
        verificationId: _verificationId,
        smsCode: _code,
      );

      if (!mounted) return;
      if (idToken == null) {
        setState(() => _errorText = "Authentication failed. Try again.");
        return;
      }

      // Step 2 & 3: Use the centralized login processor
      await _processBackendLogin(idToken);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = "Invalid code. Please try again.");
    }
  }

  Future<void> _handleResend() async {
    if (!_canResend) return;

    setState(() {
      _errorText = null;
      _secondsLeft = -1; // Indicates resend is in progress
    });

    final auth = FirebaseAuth.instance;
    final formattedPhone = '+855${widget.phoneNumber.substring(1)}';

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),

        /// It no longer bypasses the backend, ensuring user data is consistent.
        verificationCompleted: (PhoneAuthCredential credential) async {
          final userCredential = await auth.signInWithCredential(credential);
          final idToken = await userCredential.user?.getIdToken();

          if (!mounted) return;
          if (idToken != null) {
            await _processBackendLogin(idToken);
          } else {
            setState(() => _errorText = "Auto-verification failed.");
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _errorText = "Resend failed: ${e.message}");
        },
        codeSent: (String newVerificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = newVerificationId;
            _errorText = null;
          });
          _startResendCooldown();
        },
        codeAutoRetrievalTimeout: (String newVerificationId) {
          if (!mounted) return;
          _verificationId = newVerificationId;
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = "Resend error: $e");
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppColors.black,
              ),
              const SizedBox(height: 50),
              Text(
                'Verification',
                style: AppTypography.bodyBold.copyWith(
                  color: AppColors.black,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "We sent a 6-digit code to your phone number (${widget.phoneNumber})",
                style: AppTypography.body.copyWith(
                  color: AppColors.black.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (i) {
                  return SizedBox(
                    width: 42,
                    child: KeyboardListener(
                      focusNode: FocusNode(skipTraversal: true),
                      onKeyEvent: (e) => _onKey(i, e),
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _nodes[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                        style:
                            AppTypography.h3.copyWith(color: AppColors.black),
                        cursorColor: AppColors.green,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.black, width: 1.4),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.green, width: 1.6),
                          ),
                        ),
                        onChanged: (v) => _onChanged(i, v),
                      ),
                    ),
                  );
                }),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    _errorText!,
                    style: AppTypography.body
                        .copyWith(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: _canResend ? _handleResend : null,
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.disabled)
                          ? AppColors.black.withValues(alpha: 0.35)
                          : AppColors.green;
                    }),
                    textStyle: WidgetStatePropertyAll(
                      AppTypography.bodyBold
                          .copyWith(decoration: TextDecoration.underline),
                    ),
                  ),
                  child: Text(
                    _secondsLeft == -1
                        ? "Sending code..."
                        : _canResend
                            ? "Don’t receive the SMS? Resend code"
                            : "Resend code in ${_secondsLeft}s",
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: _isComplete ? _validateAndSubmit : null,
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.disabled)
                          ? AppColors.black.withValues(alpha: 0.35)
                          : AppColors.green;
                    }),
                    textStyle: WidgetStatePropertyAll(
                      AppTypography.bodyBold
                          .copyWith(letterSpacing: 1.0, fontSize: 18),
                    ),
                  ),
                  child: const Text('CONTINUE'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "Welcome to Romlerk",
                  style: AppTypography.body.copyWith(
                    color: AppColors.black.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _onKey(int i, KeyEvent e) {
    if (e is KeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[i].text.isEmpty &&
        i > 0) {
      _nodes[i - 1].requestFocus();
      _controllers[i - 1].clear();
      setState(() {}); // Update UI to reflect change in _isComplete
    }
  }

  void _onChanged(int i, String value) {
    if (_errorText != null) {
      setState(() => _errorText = null);
    }

    if (value.isNotEmpty) {
      if (i < _otpLength - 1) {
        _nodes[i + 1].requestFocus();
      } else {
        // Last digit entered, trigger submission if complete
        if (_isComplete) _validateAndSubmit();
      }
    }
    // Always call setState to update the UI (e.g., button state)
    setState(() {});
  }
}
