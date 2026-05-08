// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/api_service.dart';
import 'screens/splash/splash_screen.dart';

// PENTING: file ini dibuat otomatis setelah menjalankan:
// flutterfire configure
// (lihat langkah setup di bawah)
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Inisialisasi Dio (HTTP client)
  ApiService.instance.init();

  runApp(const MajelisRentalApp());
}

class MajelisRentalApp extends StatelessWidget {
  const MajelisRentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Majelis Adventure',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF3E2723),
        scaffoldBackgroundColor: const Color(0xFFF5EFE6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E2723),
          primary: const Color(0xFF3E2723),
          secondary: const Color(0xFFE5A93D),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}