import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:romlerk/core/constants/app_assets.dart';
import '../home/home_screen.dart';
import 'splash_screen.dart';
import '../../../firebase_options.dart';

class SimpleSplashScreen extends StatefulWidget {
  const SimpleSplashScreen({super.key});

  @override
  State<SimpleSplashScreen> createState() => _SimpleSplashScreenState();
}

class _SimpleSplashScreenState extends State<SimpleSplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndCheckAuth();
  }

  Future<void> _initializeAndCheckAuth() async {
    try {
      // ✅ Ensure Firebase is ready
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 🕐 Wait briefly for smoother UX (1.5s)
      await Future.delayed(const Duration(milliseconds: 1500));

      final user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (user != null) {
        // ✅ Logged in → go to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // ❌ Not logged in → go to SplashScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase init error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // ✅ keep texture background
      body: Stack(
        children: [
          // Centered logo
          Center(
            child: Image.asset(
              AppAssets.logo,
              width: 200,
            ),
          ),
        ],
      ),
    );
  }
}
