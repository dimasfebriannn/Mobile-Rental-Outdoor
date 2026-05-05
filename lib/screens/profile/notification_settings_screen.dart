import 'dart:ui';
import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Mock Settings - Disesuaikan dengan kolom 'tipe' di DB
  bool _notifTransaksi = true;
  bool _notifPembayaran = true;
  bool _notifDenda = true;
  bool _notifInfo = false;

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
            child: Icon(Icons.notifications_none_rounded, size: 300, color: darkBrown.withOpacity(0.03)),
          ),

          // Konten Utama
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 110, 24, 40),
                child: Column(
                  children: [
                    _buildNotificationHero(darkBrown),

                    const SizedBox(height: 50),

                    // GRUP 1: AKTIVITAS RENTAL (Berdasarkan Tipe di DB)
                    _buildSectionLabel("AKTIVITAS RENTAL", darkBrown),
                    _buildDenseGroup(darkBrown, [
                      _toggleTile(
                        icon: Icons.receipt_long_rounded,
                        title: "Status Transaksi",
                        subtitle: "Pembaruan saat booking dikonfirmasi",
                        value: _notifTransaksi,
                        onChanged: (v) => setState(() => _notifTransaksi = v),
                        db: darkBrown,
                      ),
                      _toggleTile(
                        icon: Icons.payments_rounded,
                        title: "Info Pembayaran",
                        subtitle: "Notifikasi tagihan dan bukti bayar",
                        value: _notifPembayaran,
                        onChanged: (v) => setState(() => _notifPembayaran = v),
                        db: darkBrown,
                      ),
                      _toggleTile(
                        icon: Icons.gavel_rounded,
                        title: "Peringatan Denda",
                        subtitle: "Pemberitahuan keterlambatan & kerusakan",
                        value: _notifDenda,
                        onChanged: (v) => setState(() => _notifDenda = v),
                        db: darkBrown,
                      ),
                    ]),

                    const SizedBox(height: 32),

                    // GRUP 2: INFORMASI LAINNYA
                    _buildSectionLabel("LAINNYA", darkBrown),
                    _buildDenseGroup(darkBrown, [
                      _toggleTile(
                        icon: Icons.campaign_rounded,
                        title: "Info & Promo Majelis",
                        subtitle: "Berita terbaru mengenai basecamp",
                        value: _notifInfo,
                        onChanged: (v) => setState(() => _notifInfo = v),
                        db: darkBrown,
                      ),
                    ]),

                    const SizedBox(height: 40),
                    
                    Text(
                      "MAJELIS ADVENTURE PUSH SYSTEM",
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
                  "NOTIFIKASI", 
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

  Widget _buildNotificationHero(Color db) {
    return Column(
      children: [
        Icon(Icons.notifications_active_rounded, color: db, size: 70),
        const SizedBox(height: 16),
        Text("Pusat Notifikasi", style: TextStyle(color: db, fontSize: 22, fontWeight: FontWeight.w900)),
        Text("Atur bagaimana Majelis menghubungi Anda", style: TextStyle(color: db.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600)),
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

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color db,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: db.withOpacity(0.04), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: db, size: 24),
      ),
      title: Text(title, style: TextStyle(color: db, fontSize: 16, fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle, style: TextStyle(color: db.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w600)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
        activeTrackColor: Colors.green.withOpacity(0.1),
        inactiveThumbColor: db.withOpacity(0.2),
        inactiveTrackColor: db.withOpacity(0.05),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    );
  }
}