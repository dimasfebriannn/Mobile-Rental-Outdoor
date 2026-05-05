import 'dart:ui';
import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkBrown = Color(0xFF3E2723);
    const Color goldenYellow = Color(0xFFE5A93D);
    const Color creamBg = Color(0xFFF5EFE6);

    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // Background Accent
          Positioned(
            top: -30,
            right: -30,
            child: Icon(Icons.help_center_rounded, size: 300, color: darkBrown.withOpacity(0.03)),
          ),

          // Konten Utama
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 110, 24, 40),
                child: Column(
                  children: [
                    _buildHelpHero(darkBrown),

                    const SizedBox(height: 50),

                    // DAFTAR FAQ (Berdasarkan Aturan DB)
                    _buildSectionLabel("PERTANYAAN POPULER", darkBrown),
                    _buildFaqGroup(darkBrown, [
                      _faqTile(
                        "Bagaimana sistem jaminan identitas?",
                        "Penyewa wajib mengunggah foto KTP, SIM, atau Kartu Pelajar. Data ini akan diproses di tabel jaminan identitas sebagai syarat verifikasi[cite: 1].",
                        darkBrown,
                      ),
                      _faqTile(
                        "Berapa biaya denda keterlambatan?",
                        "Denda keterlambatan dihitung otomatis sebesar 50% dari total biaya sewa per hari sesuai data di tabel denda[cite: 1].",
                        darkBrown,
                      ),
                      _faqTile(
                        "Mengapa pesanan COD saya dibatalkan?",
                        "Sistem membatalkan pesanan tunai (COD) secara otomatis jika pembayaran tidak dilakukan dalam waktu 24 jam[cite: 1].",
                        darkBrown,
                      ),
                      _faqTile(
                        "Apa yang terjadi jika barang rusak?",
                        "Admin akan mencatat jenis kerusakan di tabel denda dan menentukan jumlah biaya ganti rugi yang harus dibayar[cite: 1].",
                        darkBrown,
                      ),
                      _faqTile(
                        "Bagaimana cara pembayaran denda?",
                        "Denda dapat dibayar secara tunai di basecamp atau melalui sistem pembayaran digital (Midtrans)[cite: 1].",
                        darkBrown,
                      ),
                    ]),

                    const SizedBox(height: 40),
                    
                    Text(
                      "MAJELIS ADVENTURE HELP DESK",
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
                  "PUSAT BANTUAN", 
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

  Widget _buildHelpHero(Color db) {
    return Column(
      children: [
        Icon(Icons.live_help_rounded, color: db, size: 70),
        const SizedBox(height: 16),
        Text("Ada yang bisa dibantu?", style: TextStyle(color: db, fontSize: 22, fontWeight: FontWeight.w900)),
        Text("Temukan jawaban instan untuk kendala Anda", style: TextStyle(color: db.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600)),
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

  Widget _buildFaqGroup(Color db, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: db.withOpacity(0.1), width: 1.5),
      ),
      child: Column(children: items),
    );
  }

  Widget _faqTile(String question, String answer, Color db) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          question,
          style: TextStyle(color: db, fontSize: 15, fontWeight: FontWeight.w800),
        ),
        iconColor: db,
        collapsedIconColor: db.withOpacity(0.2),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              answer,
              style: TextStyle(color: db.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w600, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}