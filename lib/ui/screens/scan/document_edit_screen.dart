import 'package:flutter/material.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';
import 'package:romlerk/ui/widgets/app_button.dart';
import 'package:romlerk/data/models/base_document.dart';
import 'package:romlerk/data/models/document_type.dart';
import 'package:romlerk/ui/screens/scan/document_preview_screen.dart';

class DocumentEditScreen extends StatefulWidget {
  final DocumentType type;
  final BaseDocument document;

  const DocumentEditScreen({
    super.key,
    required this.type,
    required this.document,
  });

  @override
  State<DocumentEditScreen> createState() => _DocumentEditScreenState();
}

class _DocumentEditScreenState extends State<DocumentEditScreen> {
  late Map<String, TextEditingController> controllers;
  late Map<String, String?> errors;

  @override
  void initState() {
    super.initState();
    controllers = {
      for (var f in widget.document.toFields())
        f.key: TextEditingController(text: f.value ?? "")
    };
    errors = {for (var f in widget.document.toFields()) f.key: null};
  }

  Future<void> _pickDate(BuildContext context, String key) async {
    final initialText = controllers[key]?.text ?? "";
    DateTime? initialDate;
    try {
      if (initialText.isNotEmpty) {
        initialDate = DateTime.parse(initialText.split("/").reversed.join("-"));
      }
    } catch (_) {
      initialDate = null;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.green,
            onPrimary: AppColors.white,
            onSurface: AppColors.black,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      final formatted =
          "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      controllers[key]?.text = formatted;
    }
  }

  void _validateAndContinue() {
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

    setState(() {
      errors = updatedErrors;
    });

    if (!hasError) {
      final updatedFields = {
        for (var entry in controllers.entries) entry.key: entry.value.text
      };
      final updatedDoc = widget.document.copyWithFields(updatedFields);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DocumentPreviewScreen(
            type: widget.type,
            data: updatedDoc,
          ),
        ),
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
              text: "Continue to Preview",
              onPressed: _validateAndContinue,
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // Dynamic field builder based on type
  // =====================================================
  Widget _buildField(DocumentField field) {
    final controller = controllers[field.key]!;

    switch (field.type) {
      case FieldType.dropdown:
        String? currentValue = controller.text.trim();

        // ✅ Normalize OCR / user-entered variations
        if (currentValue.isEmpty) {
          currentValue = null;
        } else {
          final cleaned = currentValue
              .replaceAll(RegExp(r'[^\u1780-\u17FFa-zA-Z]+'), '')
              .trim();

          if (RegExp(r'^(M|MALE|ប្រុស|បុរស|បុស|បុសស)$', caseSensitive: false)
              .hasMatch(cleaned)) {
            currentValue = "ប្រុស";
          } else if (RegExp(r'^(F|FEMALE|ស្រី|សរ)$', caseSensitive: false)
              .hasMatch(cleaned)) {
            currentValue = "ស្រី";
          } else {
            currentValue = null;
          }
        }

        if (!(field.options?.contains(currentValue) ?? false)) {
          currentValue = null;
        }

        return DropdownButtonFormField<String>(
          value: currentValue,
          items: field.options
              ?.toSet()
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
          onChanged: (val) => setState(() {
            controller.text = val ?? "";
          }),
          decoration: _inputDecoration(field.label).copyWith(
            errorText: errors[field.key],
          ),
        );

      case FieldType.number:
        return TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: field.maxLength ?? TextField.noMaxLength,
          buildCounter: (context,
              {required int currentLength,
              required bool isFocused,
              int? maxLength}) {
            if (maxLength == null) return null;
            return Padding(
              padding: const EdgeInsets.only(top: 2, right: 8),
              child: Text(
                "$currentLength/$maxLength",
                style: AppTypography.body.copyWith(
                  fontSize: 10,
                  color: AppColors.darkGray.withValues(alpha: 0.6),
                ),
              ),
            );
          },
          style: AppTypography.bodyKh.copyWith(
            color: AppColors.black,
            fontSize: 14,
          ),
          decoration: _inputDecoration(field.label).copyWith(
            errorText: errors[field.key],
          ),
        );

      case FieldType.date:
        return GestureDetector(
          onTap: () => _pickDate(context, field.key),
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              style: AppTypography.bodyKh.copyWith(
                color: AppColors.black,
                fontSize: 14,
              ),
              decoration: _inputDecoration(field.label).copyWith(
                suffixIcon: const Icon(Icons.calendar_today, size: 18),
                errorText: errors[field.key],
              ),
            ),
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
          decoration: _inputDecoration(field.label).copyWith(
            errorText: errors[field.key],
          ),
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
      errorStyle: AppTypography.body.copyWith(
        color: Colors.red,
        fontSize: 12,
        fontWeight: FontWeight.w500,
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
