import 'dart:ui';
import 'package:flutter/material.dart';

class HowToRentScreen extends StatelessWidget {
  const HowToRentScreen({super.key});

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
            child: Icon(Icons.auto_stories_rounded, size: 300, color: darkBrown.withOpacity(0.03)),
          ),

          // Konten Utama
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 110, 24, 40),
                child: Column(
                  children: [
                    _buildHowToHero(darkBrown),

                    const SizedBox(height: 50),

                    // ALUR PENYEWAAN (Berdasarkan Logika DB)
                    _buildSectionLabel("LANGKAH-LANGKAH EKSPEDISI", darkBrown),
                    _buildDenseGroup(darkBrown, [
                      _stepTile(
                        number: "01",
                        title: "Pilih Perlengkapan",
                        desc: "Cari barang berdasarkan kategori (Camping, Hiking, dll) yang tersedia di katalog.",
                        db: darkBrown,
                      ),
                      _stepTile(
                        number: "02",
                        title: "Tentukan Durasi",
                        desc: "Pilih tanggal ambil dan kembali. Sistem akan menghitung harga per hari secara otomatis.",
                        db: darkBrown,
                      ),
                      _stepTile(
                        number: "03",
                        title: "Jaminan Identitas",
                        desc: "Unggah foto KTP, SIM, atau Kartu Pelajar sebagai syarat jaminan rental.",
                        db: darkBrown,
                      ),
                      _stepTile(
                        number: "04",
                        title: "Selesaikan Pembayaran",
                        desc: "Gunakan metode Cashless (Midtrans) atau Tunai (COD) di Basecamp.",
                        db: darkBrown,
                      ),
                      _stepTile(
                        number: "05",
                        title: "Pengambilan & Kembali",
                        desc: "Ambil barang sesuai jadwal. Pastikan barang kembali tepat waktu untuk menghindari denda.",
                        db: darkBrown,
                      ),
                    ]),

                    const SizedBox(height: 40),
                    
                    Text(
                      "MAJELIS ADVENTURE RENTAL GUIDE",
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
                  "CARA PENYEWAAN", 
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

  Widget _buildHowToHero(Color db) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: db.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Icon(Icons.menu_book_rounded, color: db, size: 60),
        ),
        const SizedBox(height: 24),
        Text(
          "Prosedur Rental", 
          style: TextStyle(color: db, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)
        ),
        Text(
          "Panduan lengkap perjalanan perlengkapan Anda", 
          textAlign: TextAlign.center,
          style: TextStyle(color: db.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600)
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label, Color db) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 6, bottom: 14),
      child: Text(
        label, 
        style: TextStyle(color: db.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2.0)
      ),
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

  Widget _stepTile({
    required String number,
    required String title,
    required String desc,
    required Color db,
  }) {
    return ListTile(
      leading: Container(
        width: 45,
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: db,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          number, 
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)
        ),
      ),
      title: Text(
        title, 
        style: TextStyle(color: db, fontSize: 16, fontWeight: FontWeight.w800)
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          desc, 
          style: TextStyle(color: db.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600, height: 1.4)
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }
}