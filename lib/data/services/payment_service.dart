import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  /// 🌐 Hosted backend on Render
  static const String _baseUrl = 'https://romlerk-backend.onrender.com';

  /// Create ABA PayWay payment → returns response from backend
  static Future<Map<String, dynamic>?> createPayment({
    required String tranId,
    required double amount,
    required String uid, // ✅ add user UID
  }) async {
    try {
      final body = {
        "uid": uid, // ✅ new field to link payment with user in Firestore
        "merchant_id": "ec462093",
        "tran_id": tranId,
        "first_name": "ABA",
        "last_name": "Bank",
        "email": "aba.bank@gmail.com",
        "phone": "012345678",
        "amount": amount,
        "currency": "USD",
        "purchase_type": "purchase",
        "payment_option": "abapay_khqr",
        // ✅ Must match backend’s ABA_CALLBACK_URL (.env)
        "callback_url": "https://romlerk-backend.onrender.com/payment/callback",
        "return_deeplink": "",
        "lifetime": 6
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final inner = data['data'];
          return {
            ...inner,
            'abapay_deeplink': inner['abapay_deeplink'] ??
                inner['data']?['abapay_deeplink'] ??
                inner['data']?['data']?['abapay_deeplink'],
          };
        } else {
          print('⚠️ Invalid response structure: ${response.body}');
        }
      } else {
        print('❌ Payment request failed: ${response.statusCode}');
        print('🔍 Response body: ${response.body}');
      }
    } catch (e) {
      print('🔥 Error creating payment: $e');
    }

    return null;
  }
}
