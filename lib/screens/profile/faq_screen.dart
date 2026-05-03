import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color darkBrown = const Color(0xFF3E2723);
    final Color creamBg = const Color(0xFFF5EFE6);

    final faqs = <Map<String, String>>[
      {
        'question': 'Bagaimana cara membatalkan pesanan?',
        'answer':
            'Buka riwayat sewa, pilih pesanan lalu tekan Batalkan. Pastikan pembatalan dilakukan sebelum jadwal mulai.',
      },
      {
        'question': 'Metode pembayaran apa saja yang tersedia?',
        'answer':
            'Kamu bisa menggunakan kartu debit, GoPay, OVO, atau transfer bank untuk pembayaran sewa.',
      },
      {
        'question': 'Bagaimana cara mengubah data pribadi?',
        'answer':
            'Masuk ke Informasi Pribadi, klik EDIT, lalu perbarui data seperti nama atau nomor KTP.',
      },
      {
        'question': 'Bagaimana jika alat rusak saat sewa?',
        'answer':
            'Hubungi tim support melalui Pusat Bantuan atau chat untuk proses klaim dan penjadwalan perbaikan.',
      },
    ];

    return Scaffold(
      backgroundColor: creamBg,
      appBar: AppBar(
        backgroundColor: creamBg,
        elevation: 0,
        foregroundColor: darkBrown,
        title: const Text('Bantuan & FAQ'),
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        itemCount: faqs.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _faqHeader(darkBrown);
          }

          final item = faqs[index - 1];
          return ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 0,
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            iconColor: darkBrown,
            collapsedIconColor: darkBrown,
            title: Text(
              item['question']!,
              style: TextStyle(
                color: darkBrown,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Text(
                  item['answer']!,
                  style: TextStyle(
                    color: darkBrown.withOpacity(0.78),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _faqHeader(Color darkBrown) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(62, 39, 35, 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pertanyaan Umum',
            style: TextStyle(
              color: darkBrown,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Cari jawaban cepat terkait pemesanan, pembayaran, dan layanan sewa kami.',
            style: TextStyle(
              color: darkBrown.withOpacity(0.72),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
