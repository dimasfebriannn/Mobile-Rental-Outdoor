import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart'; 

void main() {
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
        primaryColor: const Color(0xFF3E2723), // Dark Brown
        scaffoldBackgroundColor: const Color(0xFFF5EFE6), // Cream
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E2723),
          primary: const Color(0xFF3E2723),
          secondary: const Color(0xFFE5A93D), // Gold Accent
        ),
        fontFamily: 'Roboto', 
        useMaterial3: true,
      ),
      home: const SplashScreen(), 
    );
  }
}