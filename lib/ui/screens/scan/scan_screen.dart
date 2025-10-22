import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';
import 'package:romlerk/core/providers/ocr_providers.dart';
import 'package:romlerk/core/providers/documents_provider.dart';
import 'package:romlerk/core/providers/profiles_provider.dart';
import 'package:romlerk/core/providers/slot_provider.dart';
import 'package:romlerk/data/models/document_type.dart';
import 'package:romlerk/ui/screens/payment/payment_screen.dart';
import 'package:romlerk/ui/screens/scan/document_edit_screen.dart';

class ScanScreen extends ConsumerWidget {
  const ScanScreen({super.key});

  Future<void> _pickImage(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    // ✅ Calculate totalDocs (same as DocumentsScreen)
    final slotData = ref.read(slotProvider);
    final mainDocs = ref.read(documentsProvider).value ?? [];
    final profiles = ref.read(profilesProvider).value ?? [];
    int totalDocs = mainDocs.length;
    for (final p in profiles) {
      final subDocs = ref.read(documentsProviderForProfile(p.id)).value ?? [];
      totalDocs += subDocs.length;
    }

    final maxSlots = slotData['maxSlots'] ?? 3;

    // ✅ Block scanning if limit reached
    if (totalDocs >= maxSlots) {
      _showSlotLimitDialog(context, maxSlots);
      return;
    }

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid or unsupported document type."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ Safe navigation
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

  /// 🧩 Slot limit dialog (same as DocumentsScreen)
  void _showSlotLimitDialog(BuildContext context, int maxSlots) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: AppColors.green,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "You’ve run out of slots",
                textAlign: TextAlign.center,
                style: AppTypography.bodyBold.copyWith(
                  fontSize: 17,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "You can only store up to $maxSlots documents.\nBuy more slots or subscribe to the Family Plan to add more.",
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  fontSize: 13,
                  color: AppColors.darkGray,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.darkGray),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        "Close",
                        style: AppTypography.body.copyWith(
                          fontSize: 13,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(
                        "View Plans",
                        style: AppTypography.body.copyWith(
                          fontSize: 13,
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Calculate totalDocs for live slot display
    final slotData = ref.watch(slotProvider);
    final mainDocs = ref.watch(documentsProvider).value ?? [];
    final profiles = ref.watch(profilesProvider).value ?? [];
    int totalDocs = mainDocs.length;
    for (final p in profiles) {
      final subDocs = ref.watch(documentsProviderForProfile(p.id)).value ?? [];
      totalDocs += subDocs.length;
    }
    final maxSlots = slotData['maxSlots'] ?? 3;
    final bool isFull = totalDocs >= maxSlots;

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

          // 🟩 Scan buttons first
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

          // 🗂️ Slot Counter (only if max reached)
          if (isFull) ...[
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.darkGray.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open_rounded, color: AppColors.green),
                  const SizedBox(width: 10),
                  Text(
                    "$totalDocs / $maxSlots",
                    style: AppTypography.bodyBold.copyWith(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentScreen(),
                  ),
                );
              },
              child: Text(
                "Purchase more slots to add more documents.",
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  fontSize: 13,
                  color: AppColors.green,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
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
