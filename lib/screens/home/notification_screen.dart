import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Color darkBrown = const Color(0xFF3E2723);
  final Color goldenYellow = const Color(0xFFE5A93D);
  final Color creamBg = const Color(0xFFF5EFE6);

  // Data Dummy berdasarkan tabel 'notifikasi' di DB
  final List<Map<String, dynamic>> notifications = [
    {
      "id": 1,
      "judul": "Transaksi Baru — TRX-YRT830CQ",
      "pesan": "Pesanan baru via Cashless (Midtrans) telah berhasil dibuat. Silakan cek detail.",
      "tipe": "transaksi",
      "dibaca": false,
      "created_at": "2026-05-06 10:00:00"
    },
    {
      "id": 2,
      "judul": "Update Pesanan — TRX-AQG5ON37",
      "pesan": "Batas waktu pengembalian sudah terlewati! Segera kembalikan barang untuk menghindari denda.",
      "tipe": "pembayaran",
      "dibaca": true,
      "created_at": "2026-05-05 15:30:00"
    },
    {
      "id": 3,
      "judul": "Tagihan Denda — TRX-WPTTC2Y3",
      "pesan": "Anda memiliki tagihan denda sebesar Rp 10.000. Silakan lakukan pembayaran segera.",
      "tipe": "denda",
      "dibaca": false,
      "created_at": "2026-05-04 09:15:00"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // Background Accent
          Positioned(
            top: -30, left: -30,
            child: Icon(Icons.notifications_none_rounded, size: 300, color: darkBrown.withOpacity(0.03)),
          ),

          // Konten Utama
          Positioned.fill(
            child: SafeArea(
              child: notifications.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 110, 24, 40),
                    physics: const BouncingScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) => _buildNotificationItem(index),
                  ),
            ),
          ),

          // Glass Top Bar
          _buildGlassTopBar(context),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildGlassTopBar(BuildContext context) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              border: Border(bottom: BorderSide(color: darkBrown.withOpacity(0.05), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: darkBrown.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 18),
                  ),
                ),
                Text(
                  "NOTIFIKASI", 
                  style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2.5)
                ),
                const SizedBox(width: 40), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(int index) {
    final item = notifications[index];
    bool isRead = item['dibaca'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white.withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRead ? Colors.transparent : darkBrown.withOpacity(0.08), 
          width: 1.5
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Berdasarkan Tipe
          _buildTypeIcon(item['tipe']),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['judul'], 
                        style: TextStyle(
                          color: darkBrown, 
                          fontSize: 14, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: -0.3
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(color: goldenYellow, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item['pesan'], 
                  style: TextStyle(
                    color: darkBrown.withOpacity(0.5), 
                    fontSize: 12, 
                    fontWeight: FontWeight.w500, 
                    height: 1.4
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _formatDate(item['created_at']), 
                  style: TextStyle(
                    color: darkBrown.withOpacity(0.3), 
                    fontSize: 10, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIcon(String tipe) {
    IconData icon;
    Color color;

    switch (tipe) {
      case 'transaksi':
        icon = Icons.shopping_bag_outlined;
        color = Colors.blue;
        break;
      case 'pembayaran':
        icon = Icons.account_balance_wallet_outlined;
        color = Colors.green;
        break;
      case 'denda':
        icon = Icons.warning_amber_rounded;
        color = goldenYellow;
        break;
      default:
        icon = Icons.notifications_none_rounded;
        color = darkBrown;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('dd MMM, HH:mm').format(date);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: darkBrown.withOpacity(0.05)),
          const SizedBox(height: 16),
          Text(
            "BELUM ADA NOTIFIKASI", 
            style: TextStyle(color: darkBrown.withOpacity(0.2), fontWeight: FontWeight.w900, letterSpacing: 2)
          ),
        ],
      ),
    );
  }
}