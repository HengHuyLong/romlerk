import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:romlerk/data/services/cloud_vision_service.dart';
import 'package:romlerk/data/repositories/ocr_repository.dart';
import 'package:romlerk/data/models/document_type.dart';

// Provide the service
final cloudVisionServiceProvider = Provider(
  (ref) => CloudVisionService("AIzaSyDAkiRjLXYFm50KfGTljytc9twOWv0-DGQ"),
);

// Provide the repository
final ocrRepositoryProvider = Provider(
  (ref) => OcrRepository(
    visionService: ref.read(cloudVisionServiceProvider),
  ),
);

// State for OCR
class OcrState {
  final bool loading;
  final DocumentType? type;
  final dynamic parsed; // structured parsed model if valid
  final String? error;

  const OcrState({
    this.loading = false,
    this.type,
    this.parsed,
    this.error,
  });

  OcrState copyWith({
    bool? loading,
    DocumentType? type,
    dynamic parsed,
    String? error,
  }) {
    return OcrState(
      loading: loading ?? this.loading,
      type: type ?? this.type,
      parsed: parsed ?? this.parsed,
      error: error ?? this.error,
    );
  }
}

// Notifier
class OcrNotifier extends StateNotifier<OcrState> {
  final OcrRepository repository;
  OcrNotifier(this.repository) : super(const OcrState());

  Future<void> scan(File image) async {
    state = const OcrState(loading: true);
    try {
      final result = await repository.scanDocument(image);

      final type = result["type"] as DocumentType;
      final parsed = result["data"];

      if (type == DocumentType.unknown) {
        state = const OcrState(error: "Invalid or unsupported document.");
      } else {
        state = OcrState(type: type, parsed: parsed);
      }
    } catch (e) {
      state = OcrState(error: e.toString());
    }
  }
}

// Provider for UI
final ocrProvider = StateNotifierProvider<OcrNotifier, OcrState>((ref) {
  return OcrNotifier(ref.read(ocrRepositoryProvider));
});
