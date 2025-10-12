import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:romlerk/data/models/profile.dart';
import 'package:romlerk/data/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 🔹 Provider for managing all user sub-profiles
final profilesProvider =
    StateNotifierProvider<ProfilesNotifier, AsyncValue<List<Profile>>>(
  (ref) => ProfilesNotifier(ref),
);

class ProfilesNotifier extends StateNotifier<AsyncValue<List<Profile>>> {
  final Ref ref;

  ProfilesNotifier(this.ref) : super(const AsyncLoading()) {
    fetchProfiles(); // ✅ Auto-fetch on initialization
  }

  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  /// 🔹 Fetch all profiles from backend
  Future<void> fetchProfiles() async {
    try {
      final idToken = await _getIdToken();
      if (idToken == null) {
        state = AsyncError("User not authenticated", StackTrace.current);
        return;
      }

      final result = await ApiService.getProfiles(idToken: idToken);
      if (result == null) {
        state = AsyncError("Failed to fetch profiles", StackTrace.current);
        return;
      }

      final profiles = result.map((p) => Profile.fromJson(p)).toList();
      profiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = AsyncData(profiles);
      // ignore: avoid_print
      print("✅ Profiles loaded: ${profiles.length}");
    } catch (e, st) {
      state = AsyncError(e, st);
      // ignore: avoid_print
      print("🔥 Error fetching profiles: $e");
    }
  }

  /// 🔹 Create a new profile (and update list)
  Future<void> createProfile({
    required String name,
    required String type,
  }) async {
    try {
      final idToken = await _getIdToken();
      if (idToken == null) return;

      final result = await ApiService.createProfile(
        idToken: idToken,
        name: name,
        type: type,
      );

      if (result != null) {
        final newProfile = Profile.fromJson(result['data'] ?? result);
        final current = state.value ?? [];
        state = AsyncData([...current, newProfile]);
        // ignore: avoid_print
        print("✅ Profile created: ${newProfile.name}");
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      // ignore: avoid_print
      print("🔥 Error creating profile: $e");
    }
  }
}

/// 🔹 Currently selected profile (for document creation or filtering)
final selectedProfileProvider = StateProvider<Profile?>((ref) => null);
