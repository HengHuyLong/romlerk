import 'package:romlerk/data/models/user.dart';
import 'package:romlerk/data/models/login_result.dart';
import 'package:romlerk/data/services/api_service.dart';
import 'package:romlerk/data/locale/user_cache.dart';

/// 🔹 Handles user login, caching, and profile retrieval.
/// Used by the OTP and Profile Setup flow.
class UserRepository {
  /// 🔹 Logs in or creates a user via backend and caches the result.
  /// Returns [LoginResult] indicating if it's a new or existing user.
  // 💥 FIX: Removed the unused and incorrect `name` parameter.
  // The initial login flow does not set the name; that's done in profile setup.
  static Future<LoginResult?> loginAndCache({
    required String idToken,
  }) async {
    // 💥 FIX: Call the API service without the name parameter to align with the backend.
    // This correctly uses the retry logic for robustness.
    final json = await ApiService.safeLoginWithRetry(idToken: idToken);

    if (json == null) return null;

    try {
      final data = json['data'] as Map<String, dynamic>;
      final user = UserModel.fromJson(data);
      final isNew = (json['message'] ?? '').toString().toLowerCase().contains('created');

      // ✅ Cache user locally
      await UserCache.save(user);

      return LoginResult(isNew: isNew, user: user);
    } catch (_) {
      return null;
    }
  }

  /// 🔹 Load cached user (for offline access)
  static Future<UserModel?> loadCachedUser() async {
    return await UserCache.load();
  }

  /// 🔹 Update user profile (used in ProfileSetupScreen)
  static Future<UserModel?> updateProfile({
    required String idToken,
    required String name,
  }) async {
    try {
      final response = await ApiService.updateUserProfile(idToken, name);

      if (response == null || response['data'] == null) return null;

      // ✅ Extract data field to keep consistency with backend response
      final updatedUser = UserModel.fromJson(response['data']);
      await UserCache.save(updatedUser);
      return updatedUser;
    } catch (_) {
      return null;
    }
  }

  /// 🔹 Clear user data (logout)
  static Future<void> clearCache() async {
    await UserCache.clear();
  }
}
