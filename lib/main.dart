import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:romlerk/core/providers/user_provider.dart'; // ✅ add this import
import 'package:romlerk/ui/screens/splash/simple_splash_screen.dart';
import 'firebase_options.dart';
import './core/theme/app_theme.dart';
import './ui/widgets/app_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Initialize GetStorage
  await GetStorage.init();

  // ✅ Preload cached user before the UI starts
  final container = ProviderContainer();
  await container.read(userProvider.notifier).loadUserFromCache();

  // ✅ Run app with the preloaded provider scope
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const RomlerkApp(),
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
