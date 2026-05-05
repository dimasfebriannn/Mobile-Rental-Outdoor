import 'dart:ui';
import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
            left: -30,
            child: Icon(Icons.gavel_rounded, size: 300, color: darkBrown.withOpacity(0.03)),
          ),

          // Konten Utama
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 110, 24, 40),
                child: Column(
                  children: [
                    _buildTermsHero(darkBrown),

                    const SizedBox(height: 50),

                    // PASAL 1: IDENTITAS (Tabel: jaminan_identitas)
                    _buildSectionLabel("PASAL I: JAMINAN IDENTITAS", darkBrown),
                    _buildTermsContent(
                      "Penyewa wajib mengunggah identitas asli yang masih berlaku (KTP, SIM, atau Kartu Pelajar) ke sistem jaminan identitas sebelum melakukan pengambilan barang.",
                      darkBrown,
                    ),

                    const SizedBox(height: 32),

                    // PASAL 2: PEMBAYARAN (Tabel: transaksi & pembayaran)
                    _buildSectionLabel("PASAL II: SKEMA PEMBAYARAN", darkBrown),
                    _buildTermsContent(
                      "Pembayaran dapat dilakukan melalui metode Cashless (Midtrans) atau Tunai (COD). Untuk metode Tunai, pesanan akan dibatalkan otomatis jika pembayaran tidak diselesaikan dalam waktu 24 jam.",
                      darkBrown,
                    ),

                    const SizedBox(height: 32),

                    // PASAL 3: KETERLAMBATAN & KERUSAKAN (Tabel: denda)
                    _buildSectionLabel("PASAL III: DENDA & TANGGUNG JAWAB", darkBrown),
                    _buildTermsContent(
                      "Keterlambatan pengembalian dikenakan denda otomatis sebesar 50% dari total nilai sewa per hari. Segala bentuk kerusakan atau kehilangan barang menjadi tanggung jawab penuh penyewa sesuai biaya perbaikan yang ditetapkan.",
                      darkBrown,
                    ),

                    const SizedBox(height: 32),

                    // PASAL 4: PENGAMBILAN BARANG
                    _buildSectionLabel("PASAL IV: PROSEDUR PENGAMBILAN", darkBrown),
                    _buildTermsContent(
                      "Barang hanya dapat diambil di Basecamp Majelis Adventure sesuai dengan tanggal ambil yang tertera pada invoice digital. Penyewa wajib mengecek kondisi fisik barang saat serah terima.",
                      darkBrown,
                    ),

                    const SizedBox(height: 50),
                    
                    Text(
                      "DITETAPKAN OLEH MAJELIS ADVENTURE",
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
                  "SYARAT & KETENTUAN", 
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

  Widget _buildTermsHero(Color db) {
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
          child: Icon(Icons.verified_user_rounded, color: db, size: 60),
        ),
        const SizedBox(height: 24),
        Text(
          "Aturan Ekspedisi", 
          style: TextStyle(color: db, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)
        ),
        Text(
          "Syarat resmi penggunaan layanan Majelis Adventure", 
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
        style: TextStyle(color: db.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2.0)
      ),
    );
  }

  Widget _buildTermsContent(String text, Color db) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: db.withOpacity(0.1), width: 1.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: db,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.6,
        ),
      ),
    );
  }
}