import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';
import 'package:romlerk/core/providers/profiles_provider.dart';
import 'package:romlerk/ui/widgets/app_button.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedType;
  bool _isLoading = false;

  // ✅ Each avatar now points to its own SVG file
  final List<Map<String, dynamic>> _avatars = [
    {'label': 'Mom', 'asset': 'assets/images/mom_avatar.svg'},
    {'label': 'Dad', 'asset': 'assets/images/dad_avatar.svg'},
    {'label': 'Grandpa', 'asset': 'assets/images/grandpa_avatar.svg'},
    {'label': 'Grandma', 'asset': 'assets/images/grandma_avatar.svg'},
    {'label': 'Son', 'asset': 'assets/images/son_avatar.svg'},
    {'label': 'Daughter', 'asset': 'assets/images/daughter_avatar.svg'},
    {'label': 'Brother', 'asset': 'assets/images/brother_avatar.svg'},
    {'label': 'Sister', 'asset': 'assets/images/sister_avatar.svg'},
    {'label': 'Other', 'asset': 'assets/images/other_avatar.svg'},
  ];

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedType == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(profilesProvider.notifier).createProfile(
            name: name,
            type: _selectedType!,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create profile: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isButtonEnabled = _nameController.text.trim().isNotEmpty &&
        _selectedType != null &&
        !_isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Create Profile", style: AppTypography.bodyBold),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                style: AppTypography.body.copyWith(
                  color: AppColors.black,
                ),
                decoration: InputDecoration(
                  hintText: "Enter profile name",
                  hintStyle: AppTypography.body.copyWith(
                    color: AppColors.darkGray,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.darkGray.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.green,
                      width: 1.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Choose an avatar",
                style: AppTypography.bodyBold.copyWith(
                  fontSize: 15,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // ✅ Two per row
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.9, // ✅ Larger boxes
                  ),
                  itemCount: _avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = _avatars[index];
                    final isSelected = _selectedType == avatar['label'];

                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedType = avatar['label'];
                      }),
                      child: Column(
                        children: [
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.green.withValues(alpha: 0.15)
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.green
                                      : AppColors.darkGray
                                          .withValues(alpha: 0.2),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              // ✅ Dynamic SVG per avatar
                              child: SvgPicture.asset(
                                avatar['asset'],
                                fit: BoxFit.contain,
                                placeholderBuilder: (context) => const Center(
                                  child: Icon(Icons.person,
                                      color: AppColors.darkGray, size: 36),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            avatar['label'],
                            style: AppTypography.body.copyWith(
                              fontSize: 14,
                              color: isSelected
                                  ? AppColors.green
                                  : AppColors.darkGray,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                text: _isLoading ? "Saving..." : "Save",
                isDisabled: !isButtonEnabled,
                onPressed: _isLoading ? () {} : _saveProfile,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
