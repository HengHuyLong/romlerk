import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// 🔹 Manages slots locally + syncs with backend (Node.js + Firestore)
class SlotNotifier extends StateNotifier<Map<String, int>> {
  SlotNotifier() : super({"usedSlots": 0, "maxSlots": 3});

  final _auth = FirebaseAuth.instance;
  static const String _baseUrl =
      'https://romlerk-backend.onrender.com'; // 🌐 your deployed backend

  /// 🧭 Fetch current user slots from backend (Firestore → through Node.js)
  Future<void> fetchSlots() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('⚠️ No user logged in.');
        return;
      }

      final idToken = await user.getIdToken(); // 🔑 Get Firebase Auth token
      final url = Uri.parse('$_baseUrl/users/${user.uid}');

      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken', // ✅ Include auth header
        },
      );

      print('📦 Backend response (${res.statusCode}): ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // Ensure the structure is valid
        if (data['slots'] != null && data['slots'] is Map) {
          final slots = Map<String, dynamic>.from(data['slots']);
          state = {
            "usedSlots": (slots['usedSlots'] ?? 0).toInt(),
            "maxSlots": (slots['maxSlots'] ?? 3).toInt(),
          };
          print('✅ Slots loaded from backend: $state');
        } else {
          print('⚠️ Invalid slot data format, using defaults.');
        }
      } else {
        print('⚠️ Failed to fetch slots: ${res.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching slots: $e');
    }
  }

  /// 🟩 Use 1 slot when adding a document
  void increaseSlot() {
    if (state["usedSlots"]! < state["maxSlots"]!) {
      final newState = {
        "usedSlots": state["usedSlots"]! + 1,
        "maxSlots": state["maxSlots"]!,
      };
      state = newState;
      _updateSlotsInBackend(newState);
    }
  }

  /// 🟥 Free 1 slot when deleting a document
  void decreaseSlot() {
    if (state["usedSlots"]! > 0) {
      final newState = {
        "usedSlots": state["usedSlots"]! - 1,
        "maxSlots": state["maxSlots"]!,
      };
      state = newState;
      _updateSlotsInBackend(newState);
    }
  }

  /// 🆙 Add purchased slots (+5, +10, +20) → syncs with backend
  Future<void> addSlots(int additionalSlots) async {
    final currentMax = state["maxSlots"] ?? 3;
    final newState = {
      "usedSlots": state["usedSlots"]!,
      "maxSlots": currentMax + additionalSlots,
    };
    state = newState;

    await _updateSlotsInBackend(newState);
    print(
        '🎉 Added $additionalSlots slots → new max = ${newState["maxSlots"]}');
  }

  /// 🔄 Push slot update to backend (PATCH → Firestore)
  Future<void> _updateSlotsInBackend(Map<String, int> slots) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final idToken = await user.getIdToken(); // ✅ Get token again
      final url = Uri.parse('$_baseUrl/users/${user.uid}/slots');

      final res = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken', // ✅ Include auth header
        },
        body: jsonEncode({"slots": slots}),
      );

      if (res.statusCode == 200) {
        print('✅ Slots synced to backend successfully.');
      } else {
        print('⚠️ Backend slot update failed: ${res.statusCode}');
      }
    } catch (e) {
      print('❌ Error syncing slots: $e');
    }
  }
}

/// 🪣 Provider
final slotProvider = StateNotifierProvider<SlotNotifier, Map<String, int>>(
  (ref) => SlotNotifier(),
);
