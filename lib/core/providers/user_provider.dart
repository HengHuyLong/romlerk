import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:romlerk/data/models/user.dart';
import 'package:romlerk/data/repositories/user_repository.dart';

final userProvider =
    StateNotifierProvider<UserNotifier, UserModel?>((ref) => UserNotifier());

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null);

  /// Set user manually after login or fetch
  void setUser(UserModel user) => state = user;

  /// Load user from local cache (for offline use)
  Future<void> loadUserFromCache() async {
    final cached = await UserRepository.loadCachedUser();
    if (cached != null) {
      state = cached;
    }
  }

  /// Clear user on logout
  void clear() => state = null;
}
