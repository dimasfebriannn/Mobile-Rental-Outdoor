import 'package:flutter/material.dart';

import 'models/registered_user.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rental Outdoor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF795548)),
        scaffoldBackgroundColor: const Color(0xFFF4F1EF),
        fontFamily: 'Poppins',
      ),
      home: HomePage(
        currentUser: RegisteredUser(
          fullName: 'Demo User',
          email: 'demo@majelis.id',
          password: 'password123',
          phone: '+62 812 3456 7890',
          address: 'Jl. Demo No. 1, Bandung',
        ),
        onLogout: () {},
      ),
    );
  }
}
