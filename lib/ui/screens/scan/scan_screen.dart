import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';
import 'package:romlerk/core/providers/ocr_providers.dart';
import 'package:romlerk/data/models/document_type.dart';
import 'package:romlerk/ui/screens/scan/document_edit_screen.dart';

class ScanScreen extends ConsumerWidget {
  const ScanScreen({super.key});

  Future<void> _pickImage(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: source);
    if (picked == null) return;

    final originalFile = File(picked.path);

    // ✅ Show loading overlay safely before async
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.2),
        builder: (ctx) {
          return Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  width: 160,
                  height: 160,
                  color: Colors.white.withValues(alpha: 0.85),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          color: AppColors.green,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "Scanning...",
                        style: AppTypography.body.copyWith(
                          color: AppColors.black,
                          fontSize: 14,
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
    }

    // 🔹 Perform OCR
    final result =
        await ref.read(ocrRepositoryProvider).scanDocument(originalFile);

    // ✅ Close dialog safely
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

    final docType = result["type"];
    final data = result["data"];

    // ✅ Check if context is still mounted before navigation or snackbar
    if (!context.mounted) return;

    if (docType == DocumentType.unknown || data == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid or unsupported document type."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ Safe navigation
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentEditScreen(
          type: docType,
          document: data,
          originalImage: originalFile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            "Scan Photo to add your document",
            style: AppTypography.bodyBold
                .copyWith(fontSize: 20, color: AppColors.darkGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            "Please scan your valid government document.\n"
            "Make sure the photo is clear, without blur or lost corners",
            style: AppTypography.body
                .copyWith(color: AppColors.darkGray.withValues(alpha: 0.5)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _ScanOptionButton(
            icon: Icons.camera_alt_outlined,
            text: "Take a photo of your document",
            onTap: () => _pickImage(context, ref, ImageSource.camera),
          ),
          const SizedBox(height: 16),
          _ScanOptionButton(
            icon: Icons.upload_file_outlined,
            text: "Upload a photo of your document",
            onTap: () => _pickImage(context, ref, ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}

class _ScanOptionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ScanOptionButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 50),
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.green, size: 32),
            const SizedBox(height: 12),
            Text(
              text,
              style: AppTypography.body.copyWith(color: AppColors.darkGray),
            ),
          ],
        ),
      ),
    );
  }
}
