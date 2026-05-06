import 'dart:ui';
import 'package:flutter/material.dart';

class GoogleAccountScreen extends StatelessWidget {
  const GoogleAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkBrown = Color(0xFF3E2723);
    const Color creamBg = Color(0xFFF5EFE6);
    
    // Mock data dari DB users[cite: 1]
    const String googleName = "Dimas Dwinugroho"; 
    const String googleEmail = "dimasdwinugroho15@gmail.com"; 

    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 130, 24, 40),
              child: Column(
                children: [
                  _buildGoogleCard(darkBrown, googleName, googleEmail),
                  const SizedBox(height: 32),
                  _buildInfoText(darkBrown),
                ],
              ),
            ),
          ),
          _buildGlassTopBar(context, darkBrown, "GOOGLE SYNC"),
        ],
      ),
    );
  }

  Widget _buildGoogleCard(Color db, String name, String email) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: db.withOpacity(0.08), width: 1.5),
        boxShadow: [BoxShadow(color: db.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          const Icon(Icons.g_mobiledata_rounded, size: 60, color: Colors.blue),
          const SizedBox(height: 16),
          Text(name.toUpperCase(), style: TextStyle(color: db, fontSize: 18, fontWeight: FontWeight.w900)),
          Text(email, style: TextStyle(color: db.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          const Text("TERHUBUNG SEBAGAI METODE LOGIN UTAMA", style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildInfoText(Color db) {
    return Text(
      "Akun Google Anda digunakan untuk mempermudah proses autentikasi tanpa perlu memasukkan kata sandi manual.",
      textAlign: TextAlign.center,
      style: TextStyle(color: db.withOpacity(0.3), fontSize: 12, fontWeight: FontWeight.w600, height: 1.5),
    );
  }

  // Same Glass Top Bar logic...
  Widget _buildGlassTopBar(BuildContext context, Color db, String title) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              border: Border(bottom: BorderSide(color: db.withOpacity(0.05), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(border: Border.all(color: db.withOpacity(0.1)), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: db, size: 18),
                  ),
                ),
                Text(title, style: TextStyle(color: db, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2.5)),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}