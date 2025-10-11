import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ add Riverpod
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../home/home_screen.dart';
import '../../widgets/app_button.dart';
import 'package:romlerk/data/services/api_service.dart';
import '../../../core/providers/user_provider.dart'; // ✅ for global user state
import 'package:romlerk/data/models/user.dart'; // ✅ user model

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameCtrl = TextEditingController();
  String? _errorText;
  bool _isSaving = false;
  bool _isValid = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  /// 🔹 Validate user name securely (called live on input)
  bool _validateName(String name, {bool updateState = true}) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      if (updateState) setState(() => _errorText = 'Please enter your name.');
      return false;
    }

    final pattern = RegExp(r'^[a-zA-Z\u1780-\u17FF\s]{2,30}$');
    if (!pattern.hasMatch(trimmed)) {
      if (updateState) {
        setState(() => _errorText =
            'Name can only contain letters and spaces (2–30 chars).');
      }
      return false;
    }

    if (updateState) setState(() => _errorText = null);
    return true;
  }

  Future<void> _finish() async {
    final name = _nameCtrl.text.trim();
    if (!_validateName(name)) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken(true);

      if (idToken == null) {
        setState(() {
          _errorText = "Authentication error. Please re-login.";
          _isSaving = false;
        });
        return;
      }

      // ✅ Call PATCH /users/profile
      final response = await ApiService.updateUserProfile(idToken, name);

      if (response == null || response['data'] == null) {
        setState(() {
          _errorText = "Failed to save name. Please try again.";
        });
        return;
      }

      // ✅ Convert response to UserModel and update global provider
      final updatedUser = UserModel.fromJson(response['data']);
      ref.read(userProvider.notifier).setUser(updatedUser);

      if (!mounted) return;

      // ✅ Go Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (r) => false,
      );
    } catch (e) {
      setState(() {
        _errorText = "Failed to save name. Please try again.";
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: AppColors.black,
            ),
            const SizedBox(height: 40),
            Text(
              'Set up your profile',
              style: AppTypography.bodyBold.copyWith(
                color: AppColors.black,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tell us your name to personalize your experience.',
              style: AppTypography.body.copyWith(
                color: AppColors.black.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.done,
              enabled: !_isSaving,
              style: AppTypography.body.copyWith(color: AppColors.black),
              cursorColor: AppColors.green,
              maxLength: 30,
              inputFormatters: [
                LengthLimitingTextInputFormatter(30),
              ],
              decoration: InputDecoration(
                counterText: "",
                labelText: 'Your name',
                labelStyle: AppTypography.body.copyWith(
                  color: AppColors.black.withValues(alpha: 0.6),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.green, width: 1.6),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.black, width: 1.2),
                ),
                errorText: _errorText,
              ),
              onChanged: (value) {
                final valid = _validateName(value, updateState: false);
                setState(() {
                  _isValid = valid;
                  _errorText = valid ? null : _errorText;
                });
              },
              onSubmitted: (_) => _finish(),
            ),
            const Spacer(),
            AppButton(
              text: _isSaving ? 'Saving...' : 'Continue',
              isDisabled: _isSaving || !_isValid,
              onPressed: _isSaving ? () {} : _finish,
            ),
          ],
        ),
      ),
    );
  }
}
