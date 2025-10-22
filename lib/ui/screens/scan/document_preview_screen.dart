import 'dart:io';
import 'package:flutter/material.dart';
import 'package:romlerk/data/models/document_type.dart';
import 'package:romlerk/data/models/document_registry.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';
import 'package:romlerk/ui/screens/scan/document_confirm_screen.dart';
import 'package:romlerk/ui/widgets/app_button.dart';

class DocumentPreviewScreen extends StatelessWidget {
  final DocumentType type;
  final dynamic data; // parsed BaseDocument
  final File? originalImage;

  const DocumentPreviewScreen({
    super.key,
    required this.type,
    this.data,
    this.originalImage,
  });

  @override
  Widget build(BuildContext context) {
    final previewBuilder = DocumentRegistry.registry[type]?.buildPreview;
    print("📸 [PreviewScreen] type = $type (${type.runtimeType})");
    print(
        "📸 [PreviewScreen] registry keys = ${DocumentRegistry.registry.keys}");

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.black,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // 🔹 Step indicator with numbers
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final stepNumber = index + 1;
              final isActive = stepNumber == 2; // current step = 2
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
          const SizedBox(height: 20),

          // 🔹 Title
          Text(
            "Your Document detected",
            style: AppTypography.bodyBold.copyWith(
              fontSize: 16,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            "Review and confirm your document information.",
            style: AppTypography.body.copyWith(
              fontSize: 13,
              color: AppColors.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // 🔹 Document preview inside dark background
          Expanded(
            child: Container(
              color: AppColors.darkGray.withValues(alpha: 0.9),
              width: double.infinity,
              child: Center(
                child: previewBuilder != null && data != null
                    ? previewBuilder(data)
                    : const Text(
                        "No preview available",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 Next step button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: AppButton(
              text: "Next Step",
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 150),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        DocumentConfirmScreen(
                      type: type,
                      document: data,
                      originalImage: originalImage, // ✅ Still passed forward
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
