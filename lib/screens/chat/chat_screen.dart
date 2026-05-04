import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Color cokelatTua = const Color(0xFF3E2723);
  final Color emasMajelis = const Color(0xFFE5A93D);
  final Color latarKrem = const Color(0xFFF5EFE6);

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
            backgroundColor: cokelatTua,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latarKrem,
      body: Column(
        children: [
          // 1. LUXURY HEADER (Tinggi & Padding Sama Presisi dengan Home)
          _buildLuxuryHeader(),

          // 2. DAFTAR LAYANAN CONCIERGE
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(26, 25, 24, 10),
                    child: Text(
                      "PILIH KATEGORI LAYANAN",
                      style: TextStyle(
                        color: cokelatTua.withOpacity(0.3),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildEliteContactTile(
                        context,
                        "Cek Stok & Booking",
                        "Tanya ketersediaan alat untuk tanggal pendakian Anda",
                        Icons.inventory_2_outlined,
                        "Halo Admin Majelis Adventure, saya ingin mengecek ketersediaan alat untuk tanggal...",
                        emasMajelis,
                      ),
                      _buildEliteContactTile(
                        context,
                        "Pembayaran & Deposit",
                        "Konfirmasi transfer atau klaim pengembalian dana",
                        Icons.payments_outlined,
                        "Halo Admin, saya ingin konfirmasi pembayaran atau pengembalian deposit untuk pesanan...",
                        emasMajelis,
                      ),
                      _buildEliteContactTile(
                        context,
                        "Perpanjang Sewa",
                        "Tambah durasi sewa alat yang sedang Anda gunakan",
                        Icons.more_time_rounded,
                        "Halo Admin, saya ingin memperpanjang durasi sewa perlengkapan saya...",
                        emasMajelis,
                      ),
                      _buildEliteContactTile(
                        context,
                        "Lapor Kendala & Hilang",
                        "Laporan kerusakan atau kehilangan alat rental",
                        Icons.report_gmailerrorred_rounded,
                        "PENTING: Saya ingin melaporkan adanya kendala atau kehilangan pada barang rental...",
                        const Color(0xFFE24A4A), // Soft Red
                      ),
                      
                      const SizedBox(height: 40),
                      _buildFooterInfo(),
                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // HEADER: Identik dengan HomeScreen (Padding 60px atas, 20px bawah)
  Widget _buildLuxuryHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0x0D3E2723), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PUSAT BANTUAN",
                style: TextStyle(
                  color: emasMajelis,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Hubungi Admin",
                style: TextStyle(
                  color: cokelatTua,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: latarKrem.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.support_agent_rounded, color: cokelatTua, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildEliteContactTile(BuildContext context, String judul, String sub, IconData ikon, String pesan, Color aksen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cokelatTua.withOpacity(0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: cokelatTua.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 75,
                color: aksen.withOpacity(0.05),
                child: Center(
                  child: Icon(ikon, color: aksen, size: 26),
                ),
              ),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _hubungiAdmin(context, pesan),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            judul,
                            style: TextStyle(
                              color: cokelatTua,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sub,
                            style: TextStyle(
                              color: cokelatTua.withOpacity(0.4),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "HUBUNGI SEKARANG",
                                style: TextStyle(
                                  color: aksen,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right_rounded, size: 12, color: aksen),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Column(
      children: [
        Icon(Icons.verified_user_outlined, size: 24, color: cokelatTua.withOpacity(0.1)),
        const SizedBox(height: 12),
        Text(
          "ENKRIPSI END-TO-END",
          style: TextStyle(
            color: cokelatTua.withOpacity(0.2),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          "Layanan resmi Majelis Adventure Support",
          style: TextStyle(
            color: cokelatTua.withOpacity(0.2),
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}