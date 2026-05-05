import 'dart:ui';
import 'package:flutter/material.dart';

class BasecampLocationScreen extends StatelessWidget {
  const BasecampLocationScreen({super.key});

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
            child: Icon(Icons.map_rounded, size: 300, color: darkBrown.withOpacity(0.03)),
          ),

          // Konten Utama
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 110, 24, 40),
                child: Column(
                  children: [
                    _buildLocationHero(darkBrown),

                    const SizedBox(height: 50),

                    // DETAIL ALAMAT (Berdasarkan Domisili di DB)
                    _buildSectionLabel("TITIK PENGAMBILAN", darkBrown),
                    _buildLocationCard(
                      title: "Basecamp Pusat Majelis",
                      address: "Nogosari, Rambipuji, Jember, Jawa Timur",
                      phone: "+62 852-3346-3360",
                      hours: "08:00 - 22:00 WIB",
                      db: darkBrown,
                    ),

                    const SizedBox(height: 32),

                    // GRUP AKSI
                    _buildSectionLabel("NAVIGASI", darkBrown),
                    _buildDenseGroup(darkBrown, [
                      _actionTile(Icons.near_me_rounded, "Buka di Google Maps", darkBrown),
                      _actionTile(Icons.copy_all_rounded, "Salin Alamat Lengkap", darkBrown),
                      _actionTile(Icons.share_location_rounded, "Bagikan Lokasi", darkBrown),
                    ]),

                    const SizedBox(height: 50),
                    
                    Text(
                      "MAJELIS ADVENTURE COORDINATE SYSTEM",
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
                  "LOKASI BASECAMP", 
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

  Widget _buildLocationHero(Color db) {
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
          child: Icon(Icons.location_on_rounded, color: db, size: 60),
        ),
        const SizedBox(height: 24),
        Text(
          "Titik Penjemputan", 
          style: TextStyle(color: db, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)
        ),
        Text(
          "Lokasi resmi Majelis Adventure untuk serah terima barang", 
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

  Widget _buildLocationCard({
    required String title,
    required String address,
    required String phone,
    required String hours,
    required Color db,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: db.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: db, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(address, style: TextStyle(color: db.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w600, height: 1.5)),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          _infoRow(Icons.phone_rounded, phone, db),
          const SizedBox(height: 12),
          _infoRow(Icons.access_time_filled_rounded, hours, db),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color db) {
    return Row(
      children: [
        Icon(icon, color: db, size: 18),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: db, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
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

  Widget _actionTile(IconData icon, String title, Color db) {
    return ListTile(
      leading: Icon(icon, color: db, size: 22),
      title: Text(title, style: TextStyle(color: db, fontSize: 15, fontWeight: FontWeight.w700)),
      trailing: Icon(Icons.open_in_new_rounded, color: db.withOpacity(0.2), size: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}