import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:romlerk/data/models/base_document.dart';
import 'package:romlerk/data/models/national_id_model.dart';
import 'package:romlerk/data/services/api_service.dart';

/// 🔹 Provider — exposes document state throughout the app
final documentsProvider =
    StateNotifierProvider<DocumentsNotifier, AsyncValue<List<BaseDocument>>>(
  (ref) => DocumentsNotifier(ref),
);

/// 🔹 Notifier — manages fetching, caching, and updating
class DocumentsNotifier extends StateNotifier<AsyncValue<List<BaseDocument>>> {
  final Ref ref;

  DocumentsNotifier(this.ref) : super(const AsyncLoading()) {
    _fetchDocuments();
  }

  // 🔑 Get current Firebase ID token
  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  // 🔹 Fetch all documents from backend
  Future<void> _fetchDocuments() async {
    try {
      final idToken = await _getIdToken();
      if (idToken == null) {
        state = AsyncError("User not authenticated", StackTrace.current);
        return;
      }

      final data = await ApiService.fetchDocuments(idToken: idToken);
      if (data == null) {
        state = AsyncError("Failed to fetch documents", StackTrace.current);
        return;
      }

      // ✅ Convert JSON into the right model using fromJson()
      final docs = data.map<BaseDocument>((json) {
        final type = json['type'];
        switch (type) {
          case 'national_id':
            return NationalId.fromJson(json);
          default:
            throw Exception("Unsupported document type: $type");
        }
      }).toList();

      state = AsyncData(docs);
      debugPrint('✅ Documents loaded: ${docs.length}');
    } catch (e, st) {
      state = AsyncError(e, st);
      debugPrint('🔥 Error fetching documents: $e');
    }
  }

  // 🔁 Refresh manually
  Future<void> refresh() async {
    state = const AsyncLoading();
    await _fetchDocuments();
  }

  // 🆕 Add a document to local state
  void addDocument(BaseDocument doc) {
    final current = state.value ?? [];
    final updated = [...current, doc];
    state = AsyncData(updated);
    debugPrint("📄 Added document locally (${doc.runtimeType})");
  }

  // ✏️ Update document in local state
  void updateDocument(BaseDocument updatedDoc) {
    final current = state.value ?? [];

    // ✅ Use real document ID to match
    final updatedList = current.map((doc) {
      if (doc.id == updatedDoc.id && doc.id != null) {
        return updatedDoc;
      }
      return doc;
    }).toList();

    state = AsyncData(updatedList);
    debugPrint("✏️ Updated document locally (${updatedDoc.runtimeType})");
  }
}
