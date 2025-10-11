import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:romlerk/core/providers/user_provider.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';
import 'package:romlerk/data/models/document_registry.dart';
import 'package:romlerk/data/models/document_type.dart';
import 'package:romlerk/data/models/base_document.dart';
import 'package:romlerk/ui/screens/documents/document_edit_doc_screen.dart';
import 'package:romlerk/ui/widgets/app_button.dart';
import 'package:romlerk/ui/screens/documents/document_image_viewer_screen.dart';

class DocumentDetailScreen extends ConsumerStatefulWidget {
  final BaseDocument document;

  const DocumentDetailScreen({
    super.key,
    required this.document,
  });

  @override
  ConsumerState<DocumentDetailScreen> createState() =>
      _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  late BaseDocument document;

  @override
  void initState() {
    super.initState();
    document = widget.document;
  }

  DocumentType _getDocumentType() {
    final typeString = (document.toJson()['type'] ?? '').toString();
    switch (typeString) {
      case 'national_id':
        return DocumentType.nationalId;
      case 'passport':
        return DocumentType.passport;
      case 'driver_license':
        return DocumentType.drivingLicense;
      default:
        return DocumentType.nationalId;
    }
  }

  String _getDocTypeName(DocumentType type) {
    switch (type) {
      case DocumentType.nationalId:
        return 'ID Card';
      case DocumentType.passport:
        return 'Passport';
      case DocumentType.drivingLicense:
        return 'Driver License';
      default:
        return 'Document';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final type = _getDocumentType();
    final docTypeName = _getDocTypeName(type);
    final userName = (user?.name?.isNotEmpty ?? false) ? user!.name! : "User";
    final title = "$userName’s $docTypeName";

    final previewBuilder = DocumentRegistry.registry[type]?.buildPreview;

    debugPrint("🧩 DocumentDetailScreen opened with ID: ${document.id}");

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: AppTypography.bodyBold.copyWith(
            fontSize: 16,
            color: AppColors.black,
          ),
        ),
        foregroundColor: AppColors.black,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // 🔹 Document Preview
          Expanded(
            child: Container(
              color: AppColors.darkGray.withValues(alpha: 0.9),
              width: double.infinity,
              child: Center(
                child: previewBuilder != null
                    ? previewBuilder(document)
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

          // 🔹 Bottom Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // ✏️ Edit
                SizedBox(
                  height: 50,
                  width: 100,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      debugPrint(
                          "🧩 Navigating to edit screen for ID: ${document.id}");

                      // 👇 Wait for updated document result
                      final updatedDoc =
                          await Navigator.of(context).push<BaseDocument>(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 150),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  DocumentEditDocScreen(
                            type: type,
                            document: document,
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

                      // ✅ Refresh with new data if returned
                      if (updatedDoc != null && mounted) {
                        setState(() {
                          document = updatedDoc;
                        });
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.darkGray.withValues(alpha: 0.6),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    icon:
                        const Icon(Icons.edit_outlined, color: AppColors.black),
                    label: Text(
                      "Edit",
                      style: AppTypography.body.copyWith(
                        color: AppColors.black,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // 🖼️ View Original Photo
                Expanded(
                  child: AppButton(
                    text: "View Original Photo",
                    onPressed: () {
                      final imageUrl = document.toJson()['imageUrl'];
                      if (imageUrl != null && imageUrl.toString().isNotEmpty) {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 250),
                            pageBuilder: (_, animation, __) => FadeTransition(
                              opacity: animation,
                              child: DocumentImageViewerScreen(
                                  imageUrl: imageUrl.toString()),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("No original photo available.")),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
