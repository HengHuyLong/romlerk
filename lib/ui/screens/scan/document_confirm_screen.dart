import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';
import 'package:romlerk/ui/widgets/app_button.dart';
import 'package:romlerk/data/models/document_type.dart';
import 'package:romlerk/data/models/base_document.dart';
import 'package:romlerk/data/services/api_service.dart';
import 'package:romlerk/core/providers/documents_provider.dart';
import 'package:romlerk/ui/screens/home/home_screen.dart';
import 'select_profile_screen.dart';

class DocumentConfirmScreen extends ConsumerStatefulWidget {
  final DocumentType type;
  final BaseDocument document;
  final File? originalImage;

  const DocumentConfirmScreen({
    super.key,
    required this.type,
    required this.document,
    this.originalImage,
  });

  @override
  ConsumerState<DocumentConfirmScreen> createState() =>
      _DocumentConfirmScreenState();
}

class _DocumentConfirmScreenState extends ConsumerState<DocumentConfirmScreen> {
  Map<String, dynamic>? selectedProfile;

  Future<void> _saveDocument() async {
    if (selectedProfile == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (context) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                width: 140,
                height: 140,
                color: Colors.white.withValues(alpha: 0.8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        color: AppColors.green,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Saving...",
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: AppColors.black,
                        fontSize: 14,
                        height: 1.2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No logged-in user");

      final idToken = await user.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        throw Exception("Missing Firebase ID token");
      }

      String? imageUrl;
      if (widget.originalImage != null) {
        imageUrl = await ApiService.uploadImage(
          idToken: idToken,
          imageFile: widget.originalImage!,
        );
        debugPrint("✅ Uploaded image URL: $imageUrl");
      }

      if (!mounted) return;

      final Map<String, dynamic> documentData = {
        ...Map<String, dynamic>.from(widget.document.toJson()),
        'profileId': selectedProfile!["id"],
        'profileName': selectedProfile!["name"],
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

      final response = await ApiService.saveDocument(
        idToken: idToken,
        documentData: documentData,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // close loading dialog

      if (response != null) {
        ref.read(documentsProvider.notifier).addDocument(widget.document);

        if (!mounted) return;
        Future.delayed(const Duration(milliseconds: 400), () async {
          if (!mounted) return;
          await Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        });
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Error"),
            content: const Text("Failed to save document. Please try again."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // close loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text("🔥 Error: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final stepNumber = index + 1;
                final isActive = stepNumber == 3;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Text(
                        "$stepNumber",
                        style: AppTypography.bodyBold.copyWith(
                          fontSize: 14,
                          color: isActive
                              ? AppColors.green
                              : AppColors.darkGray.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 30,
                        height: 2,
                        color: isActive
                            ? AppColors.green
                            : AppColors.darkGray.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Text(
              "Add to a profile",
              style: AppTypography.bodyBold.copyWith(
                fontSize: 16,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              "Select a profile this document belongs to",
              style: AppTypography.body.copyWith(
                fontSize: 13,
                color: AppColors.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SelectProfileScreen(),
                  ),
                );
                if (!mounted) return;
                if (result != null) {
                  setState(() => selectedProfile = result);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.darkGray.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedProfile?["name"] ?? "Select profile",
                      style: AppTypography.body.copyWith(
                        color: selectedProfile == null
                            ? AppColors.darkGray.withValues(alpha: 0.6)
                            : AppColors.black,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            const Spacer(),
            AppButton(
              text: "Done",
              isDisabled: selectedProfile == null,
              onPressed: _saveDocument,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
