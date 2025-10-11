import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // ✅ for debugPrint()
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';

/// 🔹 Handles caching user data locally as JSON.
/// ✅ Works offline and avoids using shared_preferences.
/// ✅ Automatically manages file creation and parsing errors safely.
class UserCache {
  static const _filename = 'user_cache.json';

  /// Get cache file reference.
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_filename');
  }

  /// 🔹 Save user model as JSON string.
  static Future<void> save(UserModel user) async {
    try {
      final file = await _getFile();
      final json = jsonEncode(user.toJson());
      await file.writeAsString(json, flush: true);
    } catch (e) {
      debugPrint('⚠️ Failed to save user cache: $e');
    }
  }

  /// 🔹 Load cached user (returns `null` if not found or corrupted).
  static Future<UserModel?> load() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return null;

      final jsonStr = await file.readAsString();
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } catch (e) {
      debugPrint('⚠️ Failed to load user cache: $e');
      return null;
    }
  }

  /// 🔹 Clear cached user data.
  static Future<void> clear() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('⚠️ Failed to clear user cache: $e');
    }
  }
}
