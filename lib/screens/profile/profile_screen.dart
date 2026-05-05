import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:majelis_adventure/screens/profile/account_security_screen.dart';
import 'package:majelis_adventure/screens/profile/edit_profile_screen.dart';
import 'package:majelis_adventure/screens/profile/help_center_screen.dart';
import 'package:majelis_adventure/screens/profile/how_to_rent_screen.dart';
import 'package:majelis_adventure/screens/profile/language_settings_screen.dart';
import 'package:majelis_adventure/screens/profile/notification_settings_screen.dart';
import 'package:majelis_adventure/screens/profile/service_complaint_screen.dart';
import 'package:majelis_adventure/screens/profile/terms_conditions_screen.dart';
import 'package:majelis_adventure/screens/profile/basecamp_location_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TEMA WARNA MAJELIS ADVENTURE
    const Color darkBrown = Color(0xFF3E2723);
    const Color goldenYellow = Color(0xFFE5A93D);
    const Color creamBg = Color(0xFFF5EFE6);

    // MOCK DATA (Sesuai kolom tabel users di DB)
    const String mockName = "Dimas Dwinugroho"; 
    const String mockEmail = "dimasdwinugroho15@gmail.com"; 

    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // 1. BACKGROUND ACCENT (Halus)
          Positioned(
            top: -40,
            right: -40,
            child: Icon(Icons.landscape, size: 280, color: goldenYellow.withOpacity(0.03)),
          ),

          // 2. SCROLLABLE CONTENT
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
              child: Column(
                children: [
                  const SizedBox(height: 135), // Spasi di bawah Glass Header

                  // IDENTITY SECTION (Ramping & Tanpa Status Aktif)
                  _buildIdentitySection(mockName, mockEmail, darkBrown, goldenYellow),

                  const SizedBox(height: 35),

                  // GRUP 1: PENGATURAN UTAMA
                  _buildSectionLabel("AKUN & KEAMANAN", darkBrown),
                  _buildMenuGroup(darkBrown, [
                    _menuTile(context, Icons.person_outline_rounded, "Ubah Informasi Profil", const EditProfileScreen(), darkBrown),
                    _menuTile(context, Icons.security_rounded, "Keamanan & Autentikasi", const AccountSecurityScreen(), darkBrown),
                    _menuTile(context, Icons.translate_rounded, "Bahasa / Language", const LanguageSettingsScreen(), darkBrown),
                    _menuTile(context, Icons.notifications_none_rounded, "Notifikasi", const NotificationSettingsScreen(), darkBrown),
                  ]),

                  const SizedBox(height: 25),

                  // GRUP 2: MAJELIS ADVENTURE
                  _buildSectionLabel("EKSPLORASI MAJELIS", darkBrown),
                  _buildMenuGroup(darkBrown, [
                    _menuTile(context, Icons.assignment_outlined, "Cara Penyewaan", const HowToRentScreen(), darkBrown),
                    _menuTile(context, Icons.gavel_outlined, "Syarat & Ketentuan", const TermsConditionsScreen(), darkBrown),
                    _menuTile(context, Icons.map_outlined, "Lokasi Basecamp", const BasecampLocationScreen(), darkBrown),
                  ]),

                  const SizedBox(height: 25),

                  // GRUP 3: DUKUNGAN
                  _buildSectionLabel("LAYANAN DUKUNGAN", darkBrown),
                  _buildMenuGroup(darkBrown, [
                    _menuTile(context, Icons.chat_bubble_outline_rounded, "Komplain Layanan", const ServiceComplaintScreen(), darkBrown),
                    _menuTile(context, Icons.help_outline_rounded, "Pusat Bantuan & FAQ", const HelpCenterScreen(), darkBrown),
                  ]),

                  const SizedBox(height: 45),

                  // 3. LOGOUT BUTTON (Simple & Clean)
                  _buildSimpleLogout(darkBrown),

                  const SizedBox(height: 20),
                  Text(
                    "MAJELIS ADVENTURE • BUILD V.3.41.7",
                    style: TextStyle(
                      color: darkBrown.withOpacity(0.2),
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. GLASS TOP BAR (Tetap Konsisten)
          _buildGlassTopBar(darkBrown, goldenYellow),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildGlassTopBar(Color db, Color gy) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              border: Border(bottom: BorderSide(color: db.withOpacity(0.05), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("PENGATURAN", style: TextStyle(color: gy, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 3)),
                    const SizedBox(height: 2),
                    Text("Profil Saya", style: TextStyle(color: db, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: db.withOpacity(0.04), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.manage_accounts_outlined, color: db, size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdentitySection(String name, String email, Color db, Color gy) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: db.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: db.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          // Double Ring Avatar (Konsisten)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: gy.withOpacity(0.2), width: 1.5)),
            child: const CircleAvatar(
              radius: 35,
              backgroundColor: Color(0xFFF5EFE6),
              backgroundImage: AssetImage('lib/assets/img/majelis.png'),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: db, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                Text(email, style: TextStyle(color: db.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color db) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        label,
        style: TextStyle(color: db.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2),
      ),
    );
  }

  Widget _buildMenuGroup(Color db, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: db.withOpacity(0.06), width: 1.2),
      ),
      child: Column(children: items),
    );
  }

  Widget _menuTile(BuildContext context, IconData icon, String title, Widget page, Color db) {
    return ListTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      leading: Icon(icon, color: db, size: 20),
      title: Text(title, style: TextStyle(color: db, fontSize: 14, fontWeight: FontWeight.w700)),
      trailing: Icon(Icons.chevron_right_rounded, color: db.withOpacity(0.1), size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }

  Widget _buildSimpleLogout(Color db) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: BorderSide(color: const Color(0xFFBE2B4A).withOpacity(0.2), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          "KELUAR AKUN",
          style: TextStyle(
            color: Color(0xFFBE2B4A),
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}