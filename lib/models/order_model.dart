// lib/models/order_model.dart
//
// FIX Bug B: Foto barang tidak tampil.
// asset() di PHP bisa mengembalikan http://127.0.0.1:PORT/storage/...
// yang tidak bisa diakses dari device/emulator.
// Gunakan ImageUrlHelper.fix() untuk mengganti host ke base URL aktif.

import '../utils/image_url_helper.dart';

enum OrderStatus { diproses, aktif, selesai, dibatalkan }

class OrderModel {
  final int id;
  final String orderId;
  final String productName;
  final String price;
  final String date;
  final OrderStatus status;

  /// Status mentah dari API (mis. 'berjalan', 'terlambat', 'selesai', …)
  final String rawStatus;

  final String imagePath;
  final DateTime? tanggalAmbil;
  final DateTime? tanggalKembali;
  final double? totalSewa;
  final String? nomorTransaksi;
  final String? metodePembayaran;

  /// Total nominal denda (sum semua denda pada transaksi ini).
  final double? dendaNominal;

  /// 'lunas' jika semua denda sudah dibayar, selain itu null/string lain.
  final String? dendaStatus;

  /// Raw list detail item dari API.
  final List<dynamic>? items;

  const OrderModel({
    required this.id,
    required this.orderId,
    required this.productName,
    required this.price,
    required this.date,
    required this.status,
    required this.rawStatus,
    required this.imagePath,
    this.tanggalAmbil,
    this.tanggalKembali,
    this.totalSewa,
    this.nomorTransaksi,
    this.metodePembayaran,
    this.dendaNominal,
    this.dendaStatus,
    this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // ── 1. Status ──────────────────────────────────────────────────────────
    final String rawStatus = json['status']?.toString() ?? '';

    OrderStatus parsedStatus;
    switch (rawStatus) {
      case 'menunggu_pembayaran':
      case 'dibayar':
        parsedStatus = OrderStatus.diproses;
        break;
      case 'berjalan':
      case 'terlambat':
      case 'dikembalikan':
        parsedStatus = OrderStatus.aktif;
        break;
      case 'dibatalkan':
        parsedStatus = OrderStatus.dibatalkan;
        break;
      default: // 'selesai' dan lainnya
        parsedStatus = OrderStatus.selesai;
    }

    // ── 2. Nama produk & gambar dari details[] ────────────────────────────
    String prodName = 'Multiple Items';
    String imgPath  = 'lib/assets/img/majelis.png';

    final details = json['details'] as List?;
    if (details != null && details.isNotEmpty) {
      final firstDetail = details[0];
      final barang      = firstDetail is Map ? firstDetail['barang'] : null;

      if (barang is Map) {
        prodName = barang['nama']?.toString() ?? 'Unknown Item';

        // FIX Bug B: foto_utama_url dari PHP mungkin masih 127.0.0.1
        // Gunakan ImageUrlHelper.fix() untuk memperbaiki host-nya.
        final rawFotoUrl  = barang['foto_utama_url']?.toString();
        final rawFotoPath = barang['foto_utama']?.toString();

        final fixedUrl  = ImageUrlHelper.fix(rawFotoUrl);
        final fixedPath = ImageUrlHelper.fix(rawFotoPath);

        if (fixedUrl.isNotEmpty) {
          imgPath = fixedUrl;
        } else if (fixedPath.isNotEmpty) {
          imgPath = fixedPath;
        }
      }

      if (details.length > 1) {
        prodName += ' (+${details.length - 1} item lainnya)';
      }
    }

    // ── 3. Harga & tanggal ────────────────────────────────────────────────
    final total      = json['total_sewa']?.toString() ?? '0';
    final tglAmbil   = json['tanggal_ambil']?.toString()   ?? '';
    final tglKembali = json['tanggal_kembali']?.toString() ?? '';

    // ── 4. Denda ──────────────────────────────────────────────────────────
    //
    // `denda` dari Laravel hasMany dikirim sebagai LIST.
    // Iterasi list, jumlahkan semua nominal denda.
    //
    double? dendaNominal;
    String? dendaStatusVal;

    final rawDenda = json['denda'];

    if (rawDenda is List && rawDenda.isNotEmpty) {
      double totalDenda = 0;
      bool   adaLunas   = false;

      for (final d in rawDenda) {
        if (d is! Map) continue;
        totalDenda += double.tryParse(d['jumlah']?.toString() ?? '0') ?? 0;
        if (d['dibayar_pada'] != null) adaLunas = true;
      }

      if (totalDenda > 0) {
        dendaNominal   = totalDenda;
        dendaStatusVal = adaLunas ? 'lunas' : 'menunggu';
      }
    } else if (rawDenda is Map) {
      // Fallback jika suatu saat API mengembalikan object tunggal
      dendaNominal   = double.tryParse(rawDenda['jumlah']?.toString() ?? '0');
      dendaStatusVal = rawDenda['status_pembayaran']?.toString();
    }

    return OrderModel(
      id:               json['id'] as int? ?? 0,
      orderId:          json['nomor_transaksi']?.toString() ?? 'UNKNOWN',
      productName:      prodName,
      price:            total,
      date:             tglAmbil.isNotEmpty && tglKembali.isNotEmpty
                            ? '$tglAmbil – $tglKembali'
                            : tglAmbil,
      status:           parsedStatus,
      rawStatus:        rawStatus,
      imagePath:        imgPath,
      nomorTransaksi:   json['nomor_transaksi']?.toString(),
      totalSewa:        double.tryParse(total),
      tanggalAmbil:     tglAmbil.isNotEmpty   ? DateTime.tryParse(tglAmbil)   : null,
      tanggalKembali:   tglKembali.isNotEmpty ? DateTime.tryParse(tglKembali) : null,
      metodePembayaran: json['metode_pembayaran']?.toString(),
      dendaNominal:     dendaNominal,
      dendaStatus:      dendaStatusVal,
      items:            details,
    );
  }
}