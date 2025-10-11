import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:romlerk/data/services/auth_service.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';
import 'package:romlerk/data/models/base_document.dart';
import 'package:romlerk/data/models/document_type.dart';
import 'package:romlerk/data/services/api_service.dart';
import 'package:romlerk/core/providers/documents_provider.dart';
import 'package:romlerk/ui/widgets/app_button.dart';

class DocumentEditDocScreen extends ConsumerStatefulWidget {
  final DocumentType type;
  final BaseDocument document;

  const DocumentEditDocScreen({
    super.key,
    required this.type,
    required this.document,
  });

  @override
  ConsumerState<DocumentEditDocScreen> createState() =>
      _DocumentEditInfoScreenState();
}

class _DocumentEditInfoScreenState
    extends ConsumerState<DocumentEditDocScreen> {
  late final Map<String, TextEditingController> controllers;
  Map<String, String?> errors = {};

  @override
  void initState() {
    super.initState();
    controllers = {
      for (var f in widget.document.toFields())
        f.key: TextEditingController(text: f.value ?? "")
    };
    errors = {for (var f in widget.document.toFields()) f.key: null};
  }

  @override
  void dispose() {
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveChanges() async {
    bool hasError = false;
    final updatedErrors = <String, String?>{};

    for (var entry in controllers.entries) {
      if (entry.value.text.trim().isEmpty) {
        updatedErrors[entry.key] = "This field is required";
        hasError = true;
      } else {
        updatedErrors[entry.key] = null;
      }
    }

    setState(() => errors = updatedErrors);
    if (hasError) return;

    final updatedFields = {
      for (var entry in controllers.entries) entry.key: entry.value.text.trim()
    };

    final updatedDoc = widget.document.copyWithFields(updatedFields);
    final documentId = widget.document.id;

    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (!mounted) return;
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      if (token == null || token.isEmpty) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Missing Firebase ID token.")),
        );
        return;
      }

      if (documentId == null || documentId.isEmpty) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Invalid document ID.")),
        );
        return;
      }

      // 🔹 Show loading
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.2),
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.green),
        ),
      );

      // 🔹 Update existing document
      debugPrint("🧩 Updating document ID: $documentId");
      await ApiService.updateDocument(
        idToken: token,
        documentId: documentId,
        documentData: updatedDoc.toJson(),
      );

      if (!mounted) return;
      navigator.pop(); // close loading

      // 🔹 Refresh provider cache
      ref.read(documentsProvider.notifier).refresh();

      // ✅ Return updated document to detail screen
      if (mounted) navigator.pop(updatedDoc);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving document: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = widget.document.toFields();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Information",
          style: AppTypography.bodyBold.copyWith(
            color: AppColors.black,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: fields.length,
                itemBuilder: (context, index) {
                  final field = fields[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildField(field),
                  );
                },
              ),
            ),
            AppButton(
              text: "Save Changes",
              onPressed: _saveChanges,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(DocumentField field) {
    final controller = controllers[field.key]!;

    switch (field.type) {
      case FieldType.dropdown:
        return DropdownButtonFormField<String>(
          initialValue: controller.text.isNotEmpty ? controller.text : null,
          items: field.options
              ?.map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
          onChanged: (val) => controller.text = val ?? "",
          decoration: _inputDecoration(field.label)
              .copyWith(errorText: errors[field.key]),
        );

      case FieldType.number:
        return TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: field.maxLength ?? TextField.noMaxLength,
          style: AppTypography.bodyKh.copyWith(
            color: AppColors.black,
            fontSize: 14,
          ),
          decoration: _inputDecoration(field.label)
              .copyWith(errorText: errors[field.key]),
        );

      case FieldType.date:
        return TextField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (picked != null && mounted) {
              controller.text =
                  "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
            }
          },
          style: AppTypography.bodyKh.copyWith(
            color: AppColors.black,
            fontSize: 14,
          ),
          decoration: _inputDecoration(field.label).copyWith(
            suffixIcon: const Icon(Icons.calendar_today, size: 18),
            errorText: errors[field.key],
          ),
        );

      default:
        return TextField(
          controller: controller,
          maxLines: field.maxLines,
          style: AppTypography.bodyKh.copyWith(
            color: AppColors.black,
            fontSize: 14,
          ),
          decoration: _inputDecoration(field.label)
              .copyWith(errorText: errors[field.key]),
        );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.bodyKh.copyWith(
        color: AppColors.darkGray,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.darkGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
    );
  }
}
