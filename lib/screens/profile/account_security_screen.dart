import 'dart:ui';
import 'package:flutter/material.dart';
import 'security/change_password_screen.dart';
import 'security/otp_verification_screen.dart';
import 'security/google_account_screen.dart';

class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkBrown = Color(0xFF3E2723);
    const Color creamBg = Color(0xFFF5EFE6);

    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // Background Accent
          Positioned(
            top: -30,
            left: -30,
            child: Icon(Icons.security, size: 300, color: darkBrown.withOpacity(0.03)),
          ),

          // Konten Utama
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 110, 24, 40),
                child: Column(
                  children: [
                    _buildSecurityHero(darkBrown),

                    const SizedBox(height: 50),

                    // GRUP KEAMANAN (Klik Aktif)
                    _buildSectionLabel("KEAMANAN AKSES", darkBrown),
                    _buildDenseGroup(darkBrown, [
                      _securityTile(
                        context, 
                        Icons.lock_open_rounded, 
                        "Ubah Kata Sandi", 
                        "Kelola password akun Anda",
                        darkBrown, 
                        const ChangePasswordScreen(), // Navigasi ke Layar Ubah Sandi
                      ),
                      _securityTile(
                        context, 
                        Icons.verified_user_rounded, 
                        "Verifikasi OTP", 
                        "Status email & kode OTP",
                        darkBrown, 
                        const OtpVerificationScreen(), // Navigasi ke Layar OTP
                      ),
                      _securityTile(
                        context, 
                        Icons.g_mobiledata_rounded, 
                        "Akun Google", 
                        "Status: Terhubung",
                        darkBrown, 
                        const GoogleAccountScreen(), // Navigasi ke Layar Google
                        isTrailingText: true, 
                        trailingText: "AKTIF",
                      ),
                    ]),

                    const SizedBox(height: 40),
                    
                    Text(
                      "MAJELIS ADVENTURE SECURITY SYSTEM",
                      style: TextStyle(
                        color: darkBrown.withOpacity(0.15),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Glass Top Bar
          _buildGlassTopBar(context, darkBrown),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildGlassTopBar(BuildContext context, Color db) {
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
                    decoration: BoxDecoration(
                      border: Border.all(color: db.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: db, size: 18),
                  ),
                ),
                Text(
                  "KEAMANAN AKUN", 
                  style: TextStyle(color: db, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2.5)
                ),
                const SizedBox(width: 40), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityHero(Color db) {
    return Column(
      children: [
        Icon(Icons.shield_outlined, color: db, size: 75),
        const SizedBox(height: 16),
        Text("Pusat Perlindungan", style: TextStyle(color: db, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        Text("Kelola kredensial dan otorisasi akses", style: TextStyle(color: db.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSectionLabel(String label, Color db) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 6, bottom: 14),
      child: Text(label, style: TextStyle(color: db.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
    );
  }

  Widget _buildDenseGroup(Color db, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: db.withOpacity(0.1), width: 1.5),
      ),
      child: Column(children: items),
    );
  }

  Widget _securityTile(
    BuildContext context, 
    IconData icon, 
    String title, 
    String subtitle, 
    Color db, 
    Widget targetPage, // Parameter baru untuk halaman tujuan
    {bool isTrailingText = false, String trailingText = ""}
  ) {
    return ListTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage)),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: db.withOpacity(0.04), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: db, size: 26),
      ),
      title: Text(title, style: TextStyle(color: db, fontSize: 16, fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle, style: TextStyle(color: db.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w600)),
      trailing: isTrailingText 
        ? Text(trailingText, style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1))
        : Icon(Icons.arrow_forward_ios_rounded, color: db.withOpacity(0.15), size: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}