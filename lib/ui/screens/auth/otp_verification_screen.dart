import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:romlerk/ui/screens/home/home_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
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
  late String _verificationId; // ✅ local copy to update after resend

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

  Future<void> _validateAndSubmit() async {
    final code = _code;
    if (code.length == _otpLength) {
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: code,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } on FirebaseAuthException {
        if (!mounted) return;
        setState(() {
          _errorText = "Invalid code. Please try again.";
        });
      }
    }
  }

  Future<void> _handleResend() async {
    if (!_canResend) return;

    setState(() {
      _errorText = null;
      _secondsLeft = -1;
    });

    final auth = FirebaseAuth.instance;
    final formattedPhone = '+855${widget.phoneNumber.substring(1)}';

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() {
            _errorText = "Resend failed: ${e.message}";
          });
        },
        codeSent: (String newVerificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = newVerificationId; // ✅ update verificationId
            _errorText = null;
          });
          _startResendCooldown(); // restart timer
        },
        codeAutoRetrievalTimeout: (String newVerificationId) {
          _verificationId = newVerificationId;
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = "Resend error: $e";
      });
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
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.black,
                  ),
                ],
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

              // OTP boxes
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
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.black, width: 1.4),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.green, width: 1.6),
                          ),
                        ),
                        onChanged: (v) {
                          _onChanged(i, v);
                          _errorText = null; // clear error on input
                        },
                      ),
                    ),
                  );
                }),
              ),

              // Inline error message
              if (_errorText != null) ...[
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    _errorText!,
                    style: AppTypography.body.copyWith(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ✅ Resend button
              Center(
                child: TextButton(
                  onPressed: _canResend ? _handleResend : null,
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return AppColors.black.withValues(alpha: 0.35);
                      }
                      return AppColors.green;
                    }),
                    textStyle: WidgetStatePropertyAll(
                      AppTypography.bodyBold.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  child: Text(
                    _secondsLeft == -1
                        ? "Code resent"
                        : _canResend
                            ? "Don’t receive the sms ? Resend code"
                            : "Resend code ${_secondsLeft}s",
                  ),
                ),
              ),

              const Spacer(),

              Center(
                child: TextButton(
                  onPressed: _isComplete ? _validateAndSubmit : null,
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return AppColors.black.withValues(alpha: 0.35);
                      }
                      return AppColors.green;
                    }),
                    textStyle: WidgetStatePropertyAll(
                      AppTypography.bodyBold.copyWith(
                        letterSpacing: 1.0,
                        fontSize: 18,
                      ),
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
      setState(() {});
    }
  }

  void _onChanged(int i, String value) {
    if (value.isNotEmpty && i < _otpLength - 1) {
      _nodes[i + 1].requestFocus();
    }
    setState(() {});
  }
}
