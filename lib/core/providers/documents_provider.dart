import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:romlerk/data/models/base_document.dart';
import 'package:romlerk/data/models/national_id_model.dart';
import 'package:romlerk/data/models/birth_certificate_model.dart';
import 'package:romlerk/data/models/driver_license_model.dart';
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

  // 🔹 Fetch documents (optionally by profile)
  Future<void> _fetchDocuments({String? profileId}) async {
    try {
      final idToken = await _getIdToken();
      if (idToken == null) {
        state = AsyncError("User not authenticated", StackTrace.current);
        return;
      }

      final data = await ApiService.fetchDocuments(
        idToken: idToken,
        profileId: profileId,
      );

      if (data == null) {
        state = AsyncError("Failed to fetch documents", StackTrace.current);
        return;
      }

      final docs = data.map<BaseDocument>((json) {
        final type = json['type'];
        switch (type) {
          case 'national_id':
            return NationalId.fromJson(json);
          case 'birth_certificate':
            return BirthCertificate.fromJson(json);
          case 'driver_license':
            return DriverLicense.fromJson(json); // ✅ Fixed line
          default:
            throw Exception("Unsupported document type: $type");
        }
      }).toList();

      state = AsyncData(docs);
      debugPrint(
          '✅ Documents loaded: ${docs.length} (profile: ${profileId ?? "main"})');
    } catch (e, st) {
      state = AsyncError(e, st);
      debugPrint('🔥 Error fetching documents: $e');
    }
  }

  /// 🆕 Public helper: fetch docs and return list (used by other providers)
  Future<List<BaseDocument>> fetchDocumentsForProfile(String profileId) async {
    try {
      final idToken = await _getIdToken();
      if (idToken == null) throw Exception("User not authenticated");

      final data = await ApiService.fetchDocuments(
        idToken: idToken,
        profileId: profileId,
      );

      if (data == null) throw Exception("Failed to fetch documents");

      return data.map<BaseDocument>((json) {
        final type = json['type'];
        switch (type) {
          case 'national_id':
            return NationalId.fromJson(json);
          case 'birth_certificate':
            return BirthCertificate.fromJson(json);
          case 'driver_license':
            return DriverLicense.fromJson(json); // ✅ Fixed line
          default:
            throw Exception("Unsupported document type: $type");
        }
      }).toList();
    } catch (e) {
      debugPrint('🔥 Error fetching docs for profile: $e');
      rethrow;
    }
  }

  // 🔁 Manual refresh (for all or one profile)
  Future<void> refresh({String? profileId}) async {
    state = const AsyncLoading();
    await _fetchDocuments(profileId: profileId);
  }

  // 🆕 Add document locally
  void addDocument(BaseDocument doc) {
    final current = state.value ?? [];
    final updated = [...current, doc];
    state = AsyncData(updated);
  }

  // ✏️ Update existing document locally
  void updateDocument(BaseDocument updatedDoc) {
    final current = state.value ?? [];
    final updatedList = current.map((doc) {
      if (doc.id == updatedDoc.id && doc.id != null) return updatedDoc;
      return doc;
    }).toList();
    state = AsyncData(updatedList);
  }

  // ✅ Instantly update document after editing (used in edit screen)
  void updateLocalDocument(BaseDocument updatedDoc) {
    state.whenData((docs) {
      final updatedList = docs.map((doc) {
        if (doc.id == updatedDoc.id) return updatedDoc;
        return doc;
      }).toList();
      state = AsyncValue.data(updatedList);
      debugPrint("⚡ Document cache updated locally: ${updatedDoc.id}");
    });
  }

  // ♻️ Invalidate all per-profile document caches (so HomeScreen refetches)
  void invalidateAllProfileCaches(WidgetRef ref) {
    try {
      ref.invalidate(documentsProvider);
      ref.invalidate(documentsProviderForProfile);
      debugPrint("♻️ All document caches invalidated successfully");
    } catch (e) {
      debugPrint("⚠️ Cache invalidation failed: $e");
    }
  }
}

/// 🔹 FutureProvider to fetch docs per profile (safe access)
final documentsProviderForProfile =
    FutureProvider.family<List<BaseDocument>, String>((ref, profileId) async {
  final notifier = ref.read(documentsProvider.notifier);
  return await notifier.fetchDocumentsForProfile(profileId);
});
