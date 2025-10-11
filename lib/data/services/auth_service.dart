import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 Sign in with OTP and return the Firebase ID token
  Future<String?> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in using OTP
      await _auth.signInWithCredential(credential);

      // Fetch the Firebase ID token
      final user = _auth.currentUser;
      final idToken = await user?.getIdToken(true);

      print('🔥 Firebase ID Token: $idToken');
      return idToken;
    } catch (e) {
      print('❌ Error signing in with OTP: $e');
      return null;
    }
  }

  /// 🔹 Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// 🔹 Get current user’s ID token (used in API calls)
  Future<String?> getToken() async {
    try {
      final user = _auth.currentUser;
      return await user?.getIdToken();
    } catch (e) {
      print('⚠️ Error fetching Firebase token: $e');
      return null;
    }
  }

  /// 🔹 Sign out user
  Future<void> signOut() async => _auth.signOut();
}
