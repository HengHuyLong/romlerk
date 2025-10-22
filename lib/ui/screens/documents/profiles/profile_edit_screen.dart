import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';
import 'package:romlerk/ui/widgets/app_button.dart';
import 'package:romlerk/data/models/profile.dart';
import 'package:romlerk/core/providers/profiles_provider.dart';
import 'package:romlerk/core/providers/documents_provider.dart';
import 'package:romlerk/ui/screens/documents/document_detail_screen.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  final Profile profile;

  const ProfileEditScreen({super.key, required this.profile});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late TextEditingController _nameController;
  late String _selectedType;
  late String _selectedAvatar;
  bool _isSaving = false;

  final Map<String, String> avatarMap = {
    'Mom': 'assets/images/mom_avatar.svg',
    'Dad': 'assets/images/dad_avatar.svg',
    'Grandpa': 'assets/images/grandpa_avatar.svg',
    'Grandma': 'assets/images/grandma_avatar.svg',
    'Son': 'assets/images/son_avatar.svg',
    'Daughter': 'assets/images/daughter_avatar.svg',
    'Brother': 'assets/images/brother_avatar.svg',
    'Sister': 'assets/images/sister_avatar.svg',
    'Other': 'assets/images/other_avatar.svg',
  };

  final List<String> profileTypes = [
    'Mom',
    'Dad',
    'Grandpa',
    'Grandma',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _selectedType = widget.profile.type;
    _selectedAvatar =
        avatarMap[widget.profile.type] ?? 'assets/images/other_avatar.svg';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a profile name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final updatedProfile = widget.profile.copyWith(
      name: _nameController.text.trim(),
      type: _selectedType,
    );

    await ref.read(profilesProvider.notifier).updateProfile(updatedProfile);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(documentsProviderForProfile(widget.profile.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: AppTypography.bodyBold.copyWith(
            fontSize: 18,
            color: AppColors.black,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 Avatar preview
            Center(
              child: SvgPicture.asset(
                _selectedAvatar,
                height: 90,
              ),
            ),

            const SizedBox(height: 24),

            // ✏️ Name field
            Text(
              "Name",
              style: AppTypography.bodyBold.copyWith(
                fontSize: 14,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Enter profile name",
                hintStyle:
                    AppTypography.body.copyWith(color: AppColors.darkGray),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.darkGray.withValues(alpha: 0.3),
                  ),
                ),
              ),
              style: AppTypography.body.copyWith(
                fontSize: 14,
                color: AppColors.black,
              ),
            ),

            const SizedBox(height: 24),

            // 🧩 Type selector grid
            Text(
              "Profile Type",
              style: AppTypography.bodyBold.copyWith(
                fontSize: 14,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: profileTypes.map((type) {
                final isSelected = _selectedType == type;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedType = type;
                      _selectedAvatar =
                          avatarMap[type] ?? 'assets/images/other_avatar.svg';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.green.withValues(alpha: 0.15)
                          : AppColors.white,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.green
                            : AppColors.darkGray.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      type,
                      style: AppTypography.body.copyWith(
                        fontSize: 13,
                        color: isSelected ? AppColors.green : AppColors.black,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            // 📄 Documents section
            Text(
              "Documents for ${widget.profile.name}",
              style: AppTypography.bodyBold.copyWith(
                fontSize: 15,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),

            docsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: AppColors.green),
                ),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Failed to load documents: $err",
                  style: AppTypography.body.copyWith(color: Colors.red),
                ),
              ),
              data: (docs) {
                if (docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        "No documents yet",
                        style: AppTypography.body.copyWith(
                          color: AppColors.darkGray,
                        ),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final type = (doc.toJson()['type'] ?? '').toString();
                    final title = switch (type) {
                      'national_id' => 'ID Card',
                      'passport' => 'Passport',
                      'driver_license' => 'Driver License',
                      _ => 'Unknown',
                    };

                    String expiryText = "No expiry";
                    Color expiryColor = AppColors.darkGray;

                    final expiryRaw = doc.toJson()['expiryDate'];
                    if (expiryRaw != null && expiryRaw.toString().isNotEmpty) {
                      try {
                        final expiryDate =
                            DateTime.tryParse(expiryRaw.toString());
                        if (expiryDate != null) {
                          final now = DateTime.now();
                          final isExpired = expiryDate.isBefore(now);
                          expiryColor =
                              isExpired ? Colors.red : AppColors.green;
                          expiryText =
                              DateFormat('dd MMM yyyy').format(expiryDate);
                        }
                      } catch (_) {}
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DocumentDetailScreen(document: doc),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/idCardThumbnail.png',
                                height: 60,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyBold
                                .copyWith(fontSize: 12, color: AppColors.black),
                          ),
                          Text(
                            expiryText,
                            style: AppTypography.body.copyWith(
                              fontSize: 11,
                              color: expiryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),
            AppButton(
              text: _isSaving ? "Saving..." : "Save Changes",
              onPressed: _isSaving ? null : () => _saveProfile(),
              isDisabled: _isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
