import 'package:get_storage/get_storage.dart';

class PreferencesService {
  static final _box = GetStorage();

  static const _darkModeKey = 'dark_mode';
  static const _languageKey = 'language';
  static const _onboardedKey = 'onboarded';

  // 🔹 Dark Mode
  Future<void> setDarkMode(bool value) async {
    await _box.write(_darkModeKey, value);
  }

  bool isDarkMode() {
    return _box.read(_darkModeKey) ?? false;
  }

  // 🔹 Language
  Future<void> setLanguage(String code) async {
    await _box.write(_languageKey, code);
  }

  String getLanguage() {
    return _box.read(_languageKey) ?? 'en';
  }

  // 🔹 Onboarding
  Future<void> setOnboarded(bool value) async {
    await _box.write(_onboardedKey, value);
  }

  bool isOnboarded() {
    return _box.read(_onboardedKey) ?? false;
  }
}
