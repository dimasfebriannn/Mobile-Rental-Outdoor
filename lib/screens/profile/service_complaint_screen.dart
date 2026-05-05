import 'dart:ui';
import 'package:flutter/material.dart';

class ServiceComplaintScreen extends StatelessWidget {
  const ServiceComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkBrown = Color(0xFF3E2723);
    const Color goldenYellow = Color(0xFFE5A93D);
    const Color creamBg = Color(0xFFF5EFE6);

    // Data Kontak Pusat Bantuan (Berdasarkan DB)
    const String supportPhone = "+62 852-3346-3360"; //
    const String supportEmail = "dimasdwinugroho15@gmail.com"; //[cite: 1]

    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // Background Accent
          Positioned(
            top: -30,
            left: -30,
            child: Icon(Icons.headset_mic_rounded, size: 300, color: darkBrown.withOpacity(0.03)),
          ),

          // Konten Utama
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 110, 24, 40),
                child: Column(
                  children: [
                    _buildComplaintHero(darkBrown),

                    const SizedBox(height: 50),

                    // PILIHAN METODE KOMPLAIN
                    _buildSectionLabel("PILIH METODE KOMPLAIN", darkBrown),
                    _buildDenseGroup(darkBrown, [
                      _complaintTile(
                        icon: Icons.chat_bubble_rounded,
                        title: "WhatsApp Chat",
                        subtitle: "Respon cepat melalui admin WhatsApp",
                        value: supportPhone,
                        db: darkBrown,
                        onTap: () {
                          // Logika buka WhatsApp
                        },
                      ),
                      _complaintTile(
                        icon: Icons.mail_rounded,
                        title: "Kirim Email",
                        subtitle: "Sampaikan keluhan secara tertulis",
                        value: supportEmail,
                        db: darkBrown,
                        onTap: () {
                          // Logika buka Email Client
                        },
                      ),
                    ]),

                    const SizedBox(height: 32),

                    // CATATAN TAMBAHAN
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: darkBrown.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: darkBrown.withOpacity(0.4), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Layanan komplain aktif pada jam operasional Basecamp (08:00 - 22:00 WIB).",
                              style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                    
                    Text(
                      "MAJELIS ADVENTURE SUPPORT SYSTEM",
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
                  "KOMPLAIN LAYANAN", 
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

  Widget _buildComplaintHero(Color db) {
    return Column(
      children: [
        Icon(Icons.support_agent_rounded, color: db, size: 70),
        const SizedBox(height: 16),
        Text("Pusat Bantuan", style: TextStyle(color: db, fontSize: 22, fontWeight: FontWeight.w900)),
        Text("Sampaikan keluhan atau kendala penyewaan Anda", style: TextStyle(color: db.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600)),
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

  Widget _complaintTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color db,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: db.withOpacity(0.04), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: db, size: 24),
      ),
      title: Text(title, style: TextStyle(color: db, fontSize: 16, fontWeight: FontWeight.w800)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle, style: TextStyle(color: db.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: db, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ],
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, color: db.withOpacity(0.1), size: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }
}