import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart'; // ✅ added
import 'package:romlerk/data/models/user.dart';
import 'package:romlerk/data/repositories/user_repository.dart';

final userProvider =
    StateNotifierProvider<UserNotifier, UserModel?>((ref) => UserNotifier());

class UserNotifier extends StateNotifier<UserModel?> {
  final _box = GetStorage(); // ✅ added storage box

  UserNotifier() : super(null) {
    _loadFromCache(); // ✅ auto-load user on startup
  }

  /// Set user manually after login or fetch
  void setUser(UserModel user) {
    state = user;
    _box.write('user', user.toJson()); // ✅ save to cache
  }

  /// Load user from local cache (for offline use)
  Future<void> loadUserFromCache() async {
    final cached = _box.read('user'); // ✅ replaced with GetStorage
    if (cached != null) {
      state = UserModel.fromJson(Map<String, dynamic>.from(cached));
    }
  }

  /// Auto load cached user on startup
  void _loadFromCache() {
    final cached = _box.read('user');
    if (cached != null) {
      state = UserModel.fromJson(Map<String, dynamic>.from(cached));
    }
  }

  /// Clear user on logout
  void clear() {
    state = null;
    _box.remove('user'); // ✅ clear from cache
  }
}
