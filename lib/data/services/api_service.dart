import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 🔹 Centralized API service for Romlerk backend communication.
class ApiService {
  // 🌐 Use --dart-define=API_BASE_URL=https://api.romlerk.com for production.
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080', // Localhost for Android emulator
  );

  // ✅ Persistent HTTP client
  static final http.Client _client = http.Client();

  // =======================================================================
  // 🔹 TOKEN VERIFICATION (Optional for internal testing)
  // =======================================================================
  static Future<bool> verifyToken(String idToken) async {
    final uri = Uri.parse('$_baseUrl/secure');
    try {
      final response = await _client.get(
        uri,
        headers: {'Authorization': 'Bearer $idToken'},
      ).timeout(const Duration(seconds: 6));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // =======================================================================
  // ✅ LOGIN OR CREATE USER (called immediately after OTP)
  // =======================================================================
  static Future<Map<String, dynamic>?> loginUser({
    required String idToken,
  }) async {
    final uri = Uri.parse('$_baseUrl/users/login');

    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: '{}',
          )
          .timeout(const Duration(seconds: 7));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } on SocketException {
      return null;
    } on TimeoutException {
      return null;
    } on IOException {
      return null;
    } catch (_) {
      return null;
    }
  }

  // =======================================================================
  // 🔹 RETRY HELPER
  // =======================================================================
  static Future<Map<String, dynamic>?> safeLoginWithRetry({
    required String idToken,
    int retries = 1,
  }) async {
    Map<String, dynamic>? result;
    for (int attempt = 0; attempt <= retries; attempt++) {
      result = await loginUser(idToken: idToken);
      if (result != null) break;
      if (attempt < retries) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }
    return result;
  }

  // =======================================================================
  // ✅ UPDATE USER PROFILE
  // =======================================================================
  static Future<Map<String, dynamic>?> updateUserProfile(
    String idToken,
    String name,
  ) async {
    final uri = Uri.parse('$_baseUrl/users/profile');

    try {
      final response = await _client
          .patch(
            uri,
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'name': name}),
          )
          .timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } on SocketException {
      return null;
    } on TimeoutException {
      return null;
    } on IOException {
      return null;
    } catch (_) {
      return null;
    }
  }

  // =======================================================================
  // ✅ UPLOAD IMAGE
  // =======================================================================
  static Future<String?> uploadImage({
    required String idToken,
    required File imageFile,
  }) async {
    final uri = Uri.parse('$_baseUrl/documents/upload');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $idToken'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response =
          await request.send().timeout(const Duration(seconds: 15));
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(jsonDecode(responseBody));
        final imageUrl = data['imageUrl'] ?? data['url'];
        debugPrint('✅ Image uploaded: $imageUrl');
        return imageUrl;
      } else {
        debugPrint('❌ Upload failed: ${response.statusCode}');
        debugPrint('Response: $responseBody');
        return null;
      }
    } on SocketException {
      debugPrint('❌ Network error during upload');
      return null;
    } on TimeoutException {
      debugPrint('⏰ Upload timeout');
      return null;
    } on IOException {
      debugPrint('⚠️ I/O error during upload');
      return null;
    } catch (e) {
      debugPrint('🔥 Unexpected error during upload: $e');
      return null;
    }
  }

  // =======================================================================
  // ✅ SAVE DOCUMENT
  // =======================================================================
  static Future<Map<String, dynamic>?> saveDocument({
    required String idToken,
    required Map<String, dynamic> documentData,
  }) async {
    final uri = Uri.parse('$_baseUrl/documents');

    try {
      debugPrint('📤 Sending document data: ${jsonEncode(documentData)}');

      final response = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(documentData),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final raw = jsonDecode(response.body);

        if (raw is Map) {
          final id = raw['id'] ?? raw['_id'] ?? raw['docId'];
          final normalized = <String, dynamic>{
            'id': id?.toString(),
            ...(raw['data'] is Map
                ? Map<String, dynamic>.from(raw['data'])
                : Map<String, dynamic>.from(raw.cast<String, dynamic>())),
          };
          debugPrint('✅ Document saved successfully: $normalized');
          return normalized;
        }
      } else {
        debugPrint('❌ Failed to save document: ${response.body}');
      }
      return null;
    } on SocketException {
      debugPrint('❌ Network error saving document');
      return null;
    } on TimeoutException {
      debugPrint('⏰ Timeout saving document');
      return null;
    } on IOException {
      debugPrint('⚠️ I/O error saving document');
      return null;
    } catch (e) {
      debugPrint('🔥 Unexpected error saving document: $e');
      return null;
    }
  }

  // =======================================================================
  // ✅ UPDATE DOCUMENT
  // =======================================================================
  static Future<Map<String, dynamic>?> updateDocument({
    required String idToken,
    required String documentId,
    required Map<String, dynamic> documentData,
  }) async {
    final uri = Uri.parse('$_baseUrl/documents/$documentId');

    try {
      debugPrint('📤 Updating document: ${jsonEncode(documentData)}');

      final response = await _client
          .patch(
            uri,
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(documentData),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final raw = jsonDecode(response.body);

        if (raw is Map) {
          final id = raw['id'] ?? raw['_id'] ?? raw['docId'] ?? documentId;
          final normalized = <String, dynamic>{
            'id': id?.toString(),
            ...(raw['data'] is Map
                ? Map<String, dynamic>.from(raw['data'])
                : Map<String, dynamic>.from(raw.cast<String, dynamic>())),
          };
          debugPrint('✅ Document updated successfully: $normalized');
          return normalized;
        }
      } else {
        debugPrint('❌ Failed to update document: ${response.body}');
      }
      return null;
    } on SocketException {
      debugPrint('❌ Network error updating document');
      return null;
    } on TimeoutException {
      debugPrint('⏰ Timeout updating document');
      return null;
    } on IOException {
      debugPrint('⚠️ I/O error updating document');
      return null;
    } catch (e) {
      debugPrint('🔥 Unexpected error updating document: $e');
      return null;
    }
  }

  // =======================================================================
// ✅ FETCH DOCUMENTS
// =======================================================================
  static Future<List<Map<String, dynamic>>?> fetchDocuments({
    required String idToken,
    String? profileId, // 🔹 optional filter for profile-specific docs
  }) async {
    // ✅ Updated URL: supports ?profileId=XYZ filter cleanly
    final uri = Uri.parse(
      profileId != null && profileId.isNotEmpty
          ? '$_baseUrl/documents?profileId=$profileId'
          : '$_baseUrl/documents',
    );

    try {
      debugPrint('📤 Fetching documents from: $uri');

      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final rawList = jsonDecode(response.body);

        if (rawList is! List) {
          debugPrint('⚠️ Unexpected response type for documents');
          return null;
        }

        debugPrint('✅ Documents fetched: ${rawList.length}');

        // ✅ Normalize to consistent structure
        final normalized = rawList.map<Map<String, dynamic>>((doc) {
          if (doc is Map<String, dynamic>) {
            final id = doc['id'] ?? doc['_id'] ?? doc['docId'];
            final data = (doc['data'] is Map<String, dynamic>)
                ? Map<String, dynamic>.from(doc['data'])
                : Map<String, dynamic>.from(doc);
            return {'id': id?.toString(), ...data};
          }
          return <String, dynamic>{};
        }).toList();

        return normalized;
      } else {
        debugPrint('❌ Failed to fetch documents: ${response.body}');
        return null;
      }
    } on SocketException {
      debugPrint('❌ Network error while fetching documents');
      return null;
    } on TimeoutException {
      debugPrint('⏰ Timeout while fetching documents');
      return null;
    } on IOException {
      debugPrint('⚠️ I/O error while fetching documents');
      return null;
    } catch (e) {
      debugPrint('🔥 Unexpected error while fetching documents: $e');
      return null;
    }
  }

  // =======================================================================
  // ✅ FETCH PROFILES
  // =======================================================================
  static Future<List<Map<String, dynamic>>?> getProfiles({
    required String idToken,
  }) async {
    final uri = Uri.parse('$_baseUrl/profiles');

    try {
      debugPrint('📤 Fetching profiles from: $uri');

      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      debugPrint('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final rawList = jsonDecode(response.body);
        if (rawList is! List) {
          debugPrint('⚠️ Unexpected response type for profiles');
          return null;
        }

        debugPrint('✅ Profiles fetched: ${rawList.length}');
        return rawList.map<Map<String, dynamic>>((p) {
          if (p is Map<String, dynamic>) return Map<String, dynamic>.from(p);
          return <String, dynamic>{};
        }).toList();
      } else {
        debugPrint('❌ Failed to fetch profiles: ${response.body}');
        return null;
      }
    } on SocketException {
      debugPrint('❌ Network error while fetching profiles');
      return null;
    } on TimeoutException {
      debugPrint('⏰ Timeout while fetching profiles');
      return null;
    } on IOException {
      debugPrint('⚠️ I/O error while fetching profiles');
      return null;
    } catch (e) {
      debugPrint('🔥 Unexpected error while fetching profiles: $e');
      return null;
    }
  }

  // =======================================================================
  // ✅ CREATE PROFILE
  // =======================================================================
  static Future<Map<String, dynamic>?> createProfile({
    required String idToken,
    required String name,
    required String type,
  }) async {
    final uri = Uri.parse('$_baseUrl/profiles');

    try {
      debugPrint('📤 Creating profile: $name ($type)');

      final response = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'name': name, 'type': type}),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final raw = jsonDecode(response.body);
        if (raw is Map) {
          debugPrint('✅ Profile created: $raw');
          return Map<String, dynamic>.from(raw);
        }
      } else {
        debugPrint('❌ Failed to create profile: ${response.body}');
      }
      return null;
    } on SocketException {
      debugPrint('❌ Network error while creating profile');
      return null;
    } on TimeoutException {
      debugPrint('⏰ Timeout while creating profile');
      return null;
    } on IOException {
      debugPrint('⚠️ I/O error while creating profile');
      return null;
    } catch (e) {
      debugPrint('🔥 Unexpected error while creating profile: $e');
      return null;
    }
  }
}
