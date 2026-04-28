import 'dart:ui';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color darkBrown = const Color(0xFF3E2723);
    final Color goldenYellow = const Color(0xFFE5A93D);
    final Color creamBg = const Color(0xFFF5EFE6);
    final Color deepBlack = const Color(0xFF1B1210);

    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // 1. LATAR BELAKANG AKSEN
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: goldenYellow.withOpacity(0.05),
                border: Border.all(color: goldenYellow.withOpacity(0.1), width: 2),
              ),
            ),
          ),

          // 2. KONTEN UTAMA
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 80),
                
                // HEADER PROFIL
                _buildProfileHeader(darkBrown, goldenYellow),

                const SizedBox(height: 30),

                // STATS CARD (Point, Sewa, Voucher)
                _buildStatsGrid(darkBrown, goldenYellow),

                const SizedBox(height: 30),

                // MENU LIST
                _buildMenuSection(darkBrown, goldenYellow),

                const SizedBox(height: 120), // Spasi Bottom Nav
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Header Profil Luxury
  Widget _buildProfileHeader(Color db, Color gy) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: gy, width: 2),
              ),
              child: const CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('lib/assets/img/majelis.png'),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: db,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Icon(Icons.verified_rounded, color: gy, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "Dimas Febrian",
          style: TextStyle(color: db, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: gy.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "PLATINUM MEMBER",
            style: TextStyle(color: gy, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ),
      ],
    );
  }

  // WIDGET: Stats Grid (Points & Activity)
  Widget _buildStatsGrid(Color db, Color gy) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _statItem("1.2k", "Poin Saya", Icons.stars_rounded, db, gy),
          const SizedBox(width: 12),
          _statItem("24", "Total Sewa", Icons.shopping_bag_rounded, db, gy),
          const SizedBox(width: 12),
          _statItem("5", "Voucher", Icons.confirmation_number_rounded, db, gy),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label, IconData icon, Color db, Color gy) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: db.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: [
            Icon(icon, color: gy, size: 20),
            const SizedBox(height: 8),
            Text(val, style: TextStyle(color: db, fontWeight: FontWeight.w900, fontSize: 16)),
            Text(label, style: TextStyle(color: db.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // WIDGET: Menu List Modern
  Widget _buildMenuSection(Color db, Color gy) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: db.withOpacity(0.03), blurRadius: 20)],
      ),
      child: Column(
        children: [
          _menuItem(Icons.person_outline_rounded, "Informasi Pribadi", db),
          _menuItem(Icons.account_balance_wallet_outlined, "Metode Pembayaran", db),
          _menuItem(Icons.security_outlined, "Keamanan Akun", db),
          _menuItem(Icons.notifications_active_outlined, "Notifikasi", db),
          _menuItem(Icons.help_outline_rounded, "Pusat Bantuan", db),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(height: 1, thickness: 0.5),
          ),
          _menuItem(Icons.logout_rounded, "Keluar Akun", Colors.redAccent),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, Color color) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, color: color.withOpacity(0.3), size: 14),
      onTap: () {},
    );
  }
}