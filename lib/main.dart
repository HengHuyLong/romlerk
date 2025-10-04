import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // ✅ Add this
import './core/theme/app_theme.dart';
import './ui/screens/splash/splash_screen.dart';
import './ui/widgets/app_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Required for async init
  await Firebase.initializeApp(); // ✅ Initialize Firebase

  runApp(
    const ProviderScope(
      child: RomlerkApp(),
    ),
  );
}

class RomlerkApp extends StatelessWidget {
  const RomlerkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Romlerk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      builder: (context, child) =>
          AppBackground(child: child ?? const SizedBox()),
      home: const SplashScreen(),
    );
  }
}
