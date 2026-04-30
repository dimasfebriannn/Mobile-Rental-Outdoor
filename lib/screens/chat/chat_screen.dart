import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // LOGIKA WHATSAPP
  Future<void> _hubungiAdmin(BuildContext context, String pesan) async {
    final String nomorWA = "6281358609650";
    final Uri urlApp = Uri.parse("whatsapp://send?phone=$nomorWA&text=${Uri.encodeComponent(pesan)}");
    final Uri urlWeb = Uri.parse("https://wa.me/$nomorWA?text=${Uri.encodeComponent(pesan)}");

    try {
      if (await canLaunchUrl(urlApp)) {
        await launchUrl(urlApp);
      } else {
        await launchUrl(urlWeb, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Gagal membuka WhatsApp. Pastikan aplikasi terpasang."),
            backgroundColor: const Color(0xFF3E2723),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color cokelatTua = Color(0xFF3E2723);
    const Color emasMajelis = Color(0xFFE5A93D);
    const Color latarKrem = Color(0xFFF5EFE6);

    return Scaffold(
      backgroundColor: latarKrem,
      body: Column(
        children: [
          // HEADER RAMPING & LUXURY (FIXED)
          _buildSleekHeader(cokelatTua, emasMajelis),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildLayananItem(
                  context,
                  "Cek Stok & Booking",
                  "Tanya ketersediaan alat untuk tanggal pendakian Anda",
                  Icons.calendar_today_rounded,
                  "Halo Admin, saya ingin cek ketersediaan alat untuk tanggal...",
                  cokelatTua, emasMajelis,
                ),
                _buildLayananItem(
                  context,
                  "Pembayaran & Deposit",
                  "Konfirmasi transfer atau klaim pengembalian dana",
                  Icons.account_balance_wallet_outlined,
                  "Halo Admin, saya ingin konfirmasi pembayaran/refund untuk pesanan...",
                  cokelatTua, emasMajelis,
                ),
                _buildLayananItem(
                  context,
                  "Tambah Durasi Sewa",
                  "Perpanjang masa sewa alat yang sedang digunakan",
                  Icons.history_toggle_off_rounded,
                  "Halo Admin, saya ingin memperpanjang durasi sewa alat saya...",
                  cokelatTua, emasMajelis,
                ),
                _buildLayananItem(
                  context,
                  "Lapor Barang Hilang",
                  "Laporan kehilangan atau kerusakan alat rental",
                  Icons.report_problem_outlined,
                  "PENTING: Saya ingin melaporkan adanya kendala/kehilangan pada barang...",
                  cokelatTua, Colors.redAccent,
                ),
                
                const SizedBox(height: 40),
                _buildFooterInfo(cokelatTua),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // HEADER RAMPING (GEOMETRIC LUXURY)
  Widget _buildSleekHeader(Color ct, Color em) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 25),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: ct.withOpacity(0.05), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("CONCIERGE", style: TextStyle(color: em, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 3)),
              const SizedBox(height: 2),
              Text("Layanan Rental", style: TextStyle(color: ct, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ct.withOpacity(0.1)),
            ),
            child: Icon(Icons.forum_outlined, color: ct, size: 22),
          ),
        ],
      ),
    );
  }

  // WIDGET CARD DENGAN ANIMASI INTERAKTIF
  Widget _buildLayananItem(BuildContext context, String judul, String sub, IconData ikon, String pesan, Color ct, Color aksen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ct.withOpacity(0.05)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _hubungiAdmin(context, pesan),
              splashColor: aksen.withOpacity(0.1),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // ICON CONTAINER
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: aksen.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(ikon, color: aksen, size: 26),
                    ),
                    const SizedBox(width: 18),
                    // TEXT CONTENT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(judul, style: TextStyle(color: ct, fontWeight: FontWeight.w900, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(sub, style: TextStyle(color: ct.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w500, height: 1.4)),
                        ],
                      ),
                    ),
                    // SMALL INDICATOR
                    Icon(Icons.arrow_forward_ios_rounded, color: ct.withOpacity(0.1), size: 14),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterInfo(Color ct) {
    return Opacity(
      opacity: 0.3,
      child: Column(
        children: [
          const Icon(Icons.verified_user_outlined, size: 30),
          const SizedBox(height: 12),
          Text(
            "TERHUBUNG DENGAN WHATSAPP RESMI",
            style: TextStyle(color: ct, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          Text(
            "MAJELIS ADVENTURE SUPPORT SYSTEM",
            style: TextStyle(color: ct, fontSize: 8, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}