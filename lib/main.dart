import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:romlerk/ui/screens/splash/simple_splash_screen.dart';
import 'firebase_options.dart'; // ✅ generated Firebase options
import './core/theme/app_theme.dart';
import './ui/widgets/app_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase with the correct platform options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Initialize GetStorage (local lightweight key-value storage)
  await GetStorage.init();

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
      home: const SimpleSplashScreen(),
    );
  }
}
